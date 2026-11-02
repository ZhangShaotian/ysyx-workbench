# v3：支持访存的 minirv 处理器

顶层模块为 `ysyx_v3_TopProc_minirv`。当前实现 minirv 的八条指令：
`add、addi、lui、lw、lbu、sw、sb、jalr`，另有仿真退出用的 `ebreak`。
ADD 是讲义 `mem/sum` 程序的必需指令，与四条访存指令一同补齐。

v3 使用两读一写寄存器堆，保留 32 个 32 位 GPR 以兼容现有测试；这比讲义的
16 GPR 配置多。指令 ROM 与数据 RAM 各为 512 KiB，初始加载同一镜像。
load 组合读取 RAM，store 在上升沿写 RAM；`sb` 只更新选中的字节通道。
`lw/sw` 仅支持四字节对齐访问，`lbu/sb` 支持四个字节偏移，小端布局。

## 运行与地址选择

在 `npc/` 目录运行：

```bash
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_lw.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_lbu.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_sw.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_sb.hex sim

make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/mem.hex sim WAVE=0
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/sum.hex sim WAVE=0
```

`BASE=auto` 对普通 hex 选择 `0x80000000`，对 Logisim 镜像选择 `0`，同时作为 PC、ROM、RAM
的起始地址。`CYCLES=auto` 分别选择 1000、6000 周期。可显式覆盖，例如 `BASE=0 CYCLES=7000`。
切换这些运行时参数不需要重新编译 RTL。Logisim 镜像由运行脚本自动转换，原文件保持不变。

也支持 AM `ARCH=minirv-npc` 生成的程序，入口为 `0x80000000`。从仓库根目录执行：

```bash
export AM_HOME="$PWD/abstract-machine"
export NPC_HOME="$PWD/npc"
make -C am-kernels/tests/cpu-tests ARCH=minirv-npc ALL=dummy run
```

运行入口自动转换 `.bin`、从 ELF 提取 `halt` 地址并检查 a0。
`dummy.c` 已实测通过：19 周期，`halt_pc=0x80000020`，`a0=0`。
返回 1 和无限循环的 AM 测试分别正确报告 FAIL 和 TIMEOUT。
详情见 [AM 程序运行说明](../../../README.md#运行-am-程序)。

## 支持的 hex 与检查点

| 文件（相对于 `npc/hex/`） | 配置 / 预期结果 |
| --- | --- |
| `program_lw.hex` | 默认高地址；`x2=0x12345678、x3=0x89abcdef、x4=0xfedcba98`，验证负偏移、相邻字及 x0 |
| `program_lbu.hex` | 默认高地址；`x2..x5=0、0x7f、0xff、0x80`，`x7=0x80`，验证四通道和零扩展 |
| `program_sw.hex` | 默认高地址；`BASE+0x100` 起四个 RAM 字为 `0x12345678、0xffffffff、0、0xdeadbeef`，检查 store 不改 GPR |
| `program_sb.hex` | 默认高地址；两个 RAM 字最终为 `0x90abcdef、0xdead00ef`，检查其他字节和 GPR 保持不变 |
| `logisim/mem.hex` | 自动低地址，在 `0x1218` 注入 EBREAK；检查 `a0=0` |
| `logisim/sum.hex` | 自动低地址，在 `0x224` 注入 EBREAK；检查 `a0=0` |
| `program_addi_jalr_lui.hex` | 默认镜像；`x1=0x8000000c、x2=0x80000018、x5=10` 后执行 `ebreak` |
| `program_ebreak.hex` | `x0..x31=0..31` 后执行 `ebreak` |
| `program_raw.hex` | 只含两条 ADDI，没有结束指令；用 `CYCLES=2`，预期 `x1=1、x2=3` |
| `program_ysyx_addi_jalr.hex` | 显式加 `BASE=0`，预期 `a0=30、ra=0x0c、PC=0x0c` |

四个访存自测包含完整期望值注释，均以 `ebreak` 结束。讲义 `mem/sum` 的原始 halt 是死循环；现在自动在 ROM 的 halt 入口注入 EBREAK，
到达指定地址且 a0=0 时输出 PASS，非零 a0、其他地址的 EBREAK 或超时均返回失败。
原始 hex 和数据 RAM 不改动。用 `HALT=none` 可恢复旧的循环结束方式。
`logisim/vga.hex` 仍不能运行：当前没有 VGA MMIO 地址译码、帧缓冲或显示设备。

从仓库根目录运行 `python3 npc/tests/test_minirv.py` 可检查四个访存自测和讲义的两个程序。
完整参数、镜像格式、波形路径和环境说明见 [NPC README](../../../README.md)。

## 实测记录

2026-11-02，六个程序均已通过实际 v3 RTL 仿真和寄存器结果检查：

| 程序 | 执行周期数 | 停止后的 PC | 检查结果 |
| --- | --- | --- | --- |
| `program_lw.hex` | 9 | `0x80000024` | 期望寄存器值匹配，EBREAK 退出 |
| `program_lbu.hex` | 12 | `0x80000030` | 四字节通道和零扩展结果匹配，EBREAK 退出 |
| `program_sw.hex` | 15 | `0x8000003c` | 写入后 LW 读回值及 GPR 哨兵值匹配，EBREAK 退出 |
| `program_sb.hex` | 26 | `0x80000068` | 每次字节写入的 LW 读回值及 GPR 哨兵值匹配，EBREAK 退出 |
| `logisim/mem.hex` | 5763 | `0x0000121c` | halt `0x1218` 执行 EBREAK，`a0=0`，PASS |
| `logisim/sum.hex` | 5883 | `0x00000228` | halt `0x224` 执行 EBREAK，`a0=0`，PASS |

表中 PC 是 EBREAK 所在上升沿完成后观测到的 PC，已经加 4，不是 EBREAK 自身地址。
测试日志和波形分别保存在 `npc/build/ysyx_v3_TopProc_minirv/test-<名称>.log`、
`test-<名称>.fst`，完整寄存器结果保存在同目录的 `test_results.json`。

另外，旧讲义样例以 `BASE=0 CYCLES=20` 运行后实测 `PC=0x0c、a0=30`；
原有 `test_hex_selection.py` 回归及 Verilator `-Wall` 静态检查也已通过。

`HALT=auto` 只对 SHA-256 匹配的已知 mem/sum 原始镜像自动生效，避免同名文件被误修改。
自定义镜像可传 `HALT=0x80000008` 等字节地址；必须指向实际结束入口，且 a0 遵循退出状态约定。
