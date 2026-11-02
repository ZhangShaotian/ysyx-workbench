# NPC 处理器仿真

## 选择处理器和程序

在 `npc/` 目录执行：

```bash
make MODULENAME=<顶层模块名> HEX=<hex文件路径> sim
```

`MODULENAME` 选择 RTL 和仿真入口，`HEX` 选择运行时加载的镜像。
切换处理器或 hex 无需修改脚本、无需 `make clean`；同一处理器切换 hex 可以复用编译结果。
更改 RTL 后仍会正常重新构建。参数名区分大小写。

```bash
cd npc  # 从仓库根目录进入

# v1：ADDI 寄存器初始化
make MODULENAME=ysyx_v1_TopProcAddi HEX=hex/program_ebreak.hex sim

# v2：当前已支持 LUI / ADDI / JALR
make MODULENAME=ysyx_v2_TopProc_Addi_Jalr HEX=hex/program_addi_jalr_lui.hex sim

# v3：四条访存指令的独立测试
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_lw.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_lbu.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_sw.hex sim
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_sb.hex sim

# v3：直接选择讲义的 Logisim 原始文件，自动转换并采用 PC=0
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/mem.hex sim WAVE=0
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/sum.hex sim WAVE=0
```

在仓库根目录使用 `make -C npc ...`，相对 hex 路径仍以 `npc/` 为基准。
也支持绝对路径；含空格的参数应整体加引号，例如 `"HEX=/tmp/my program.hex"`。
文件不存在、不是普通文件或不可读时会报错。

| 参数 | 默认值 | 用途 |
| --- | --- | --- |
| `MODULENAME` | 必填 | 选择下表中的处理器 |
| `HEX` | 各处理器的默认文件 | 选择程序及初始数据 |
| `BASE` | `auto` | v3 的复位 PC、ROM 和 RAM 起始地址；可指定 `0` 或 `0x80000000` 等四字节对齐地址 |
| `CYCLES` | `auto` | 正十进制整数，限制执行周期数；遇到 `ebreak` 可提前停止 |
| `HALT` | `auto` | v3 自动识别仓库内原始 mem/sum 的 halt；也可指定字节地址或 `none` 禁用补丁 |
| `WAVE` | `1` | `0` 不打开 GTKWave，但仍生成波形 |

`BASE=auto` 对普通 `$readmemh` 文件选择 `0x80000000`，对 Logisim 文件选择 `0`。
`CYCLES=auto` 对普通文件选择 1000 周期，对 Logisim 文件选择 6000 周期。
v1/v2 仍固定使用 `0x80000000`，不支持 Logisim 镜像和其他 BASE。

## 处理器与默认 hex

| MODULENAME | 当前实现的指令 | 未传 HEX 时的默认文件 | 版本说明 |
| --- | --- | --- | --- |
| `ysyx_v1_TopProcAddi` | `addi`，仿真退出用 `ebreak` | `hex/program_ebreak.hex` | [v1 README](vsrc/ysyx_24080034_npc/v1_proc_addi/README.md) |
| `ysyx_v2_TopProc_Addi_Jalr` | `addi、jalr、lui`，仿真退出用 `ebreak` | `hex/program_addi_jalr_lui.hex` | [v2 README](vsrc/ysyx_24080034_npc/v2_proc_addi_jalr/README.md) |
| `ysyx_v3_TopProc_minirv` | `add、addi、lui、lw、lbu、sw、sb、jalr`，仿真退出用 `ebreak` | `hex/program_addi_jalr_lui.hex` | [v3 README](vsrc/ysyx_24080034_npc/v3_proc_minirv/README.md) |

v2 的 LUI 已通过实际仿真及寄存器波形检查；其目录名和顶层模块名仍保留 ADDI/JALR，
不代表只有两条指令。复现命令和已有代码依据见
[v2 的 LUI 支持验证](vsrc/ysyx_24080034_npc/v2_proc_addi_jalr/README.md#lui-支持的实测依据)。

三个版本均使用 32 位数据和 32 个 GPR。v1/v2 的指令 ROM 为 256 个 32 位字（1 KiB），
没有数据 RAM；v3 的 ROM、RAM 各为 131072 个 32 位字（512 KiB）。
v3 为兼容现有测试保留 32 个 GPR，并非讲义限定 16 个 GPR 的严格 RV32E 配置。

## 仓库内 hex 兼容性和预期结果

| hex 文件（位于 `npc/hex/`） | v1 | v2 | v3 | 预期结果 / 限制 |
| --- | --- | --- | --- | --- |
| `program_ebreak.hex` | 支持 | 支持 | 支持 | `x0=0`，`x1..x31=1..31`，随后执行 `ebreak` |
| `program_addi_jalr_lui.hex` | 不支持 | 支持 | 支持 | `x1=0x8000000c、x2=0x80000018、x5=10`，跳过 `x5=255` 的指令并执行 `ebreak` |
| `program_raw.hex` | 支持其中两条指令 | 支持其中两条指令 | 支持其中两条指令 | 前两条执行后 `x1=1、x2=3`；文件没有结束指令，使用 `CYCLES=2` 观察这两条指令 |
| `program_ysyx_addi_jalr.hex` | 不支持 JALR | 地址布局不匹配 | 支持，需 `BASE=0` | 旧讲义样例：`a0=30、ra=0x0c`，PC 在 `0x0c` 自循环 |
| `program_lw.hex` | 不支持 | 不支持 | 支持 | 负偏移、相邻字、丢弃写入 x0；`x2=0x12345678、x3=0x89abcdef、x4=0xfedcba98` |
| `program_lbu.hex` | 不支持 | 不支持 | 支持 | 四个字节通道、小端顺序、零扩展；`x2..x5=0、0x7f、0xff、0x80`，`x7=0x80` |
| `program_sw.hex` | 不支持 | 不支持 | 支持 | 从 `BASE+0x100` 起的 RAM 字为 `0x12345678、0xffffffff、0、0xdeadbeef`；store 不写 GPR |
| `program_sb.hex` | 不支持 | 不支持 | 支持 | 逐字节更新后两个 RAM 字为 `0x90abcdef、0xdead00ef`；未选中的字节和 GPR 保持原值 |
| `logisim/mem.hex` | 不支持 | 不支持 | 支持 | 自动在 `0x1218` 注入 EBREAK；5763 周期后检查 `a0=0` 并报告 PASS |
| `logisim/sum.hex` | 不支持 | 不支持 | 支持 | 自动在 `0x224` 注入 EBREAK；5883 周期后检查 `a0=0` 并报告 PASS |
| `logisim/vga.hex` | 不支持 | 不支持 | 尚不支持 | 缺少 VGA MMIO 地址译码和帧缓冲/显示设备；镜像格式可转换不等于程序可运行 |

四个访存自测使用 `BASE=0x80000000`，数据从 `BASE+0x100` 开始，完整寄存器和 RAM
期望值写在各 hex 的末尾注释中。`lw/sw` 按四字节对齐访问；`lbu/sb` 按字节访问。
`lbu` 的读数据零扩展，地址立即数仍符号扩展；store 使用 S 型有符号立即数。

运行旧讲义的两指令样例时，显式指定低地址布局：

```bash
make MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_ysyx_addi_jalr.hex BASE=0 sim WAVE=0
```

v1/v2 的地址布局不变；不能因为旧样例曾通过数组索引截断得到 `a0=30` 就认为映射正确。
v2 默认使用地址匹配的 `program_addi_jalr_lui.hex`。

## 镜像格式、地址与停止条件

普通文件使用 Verilog `$readmemh` 格式，每个十六进制数是一个 32 位字，支持 `//` 注释。
`@00000040` 表示数组字索引 `0x40`，对应字节地址 `BASE+0x100`，不是字节偏移 `0x40`。
例如下面的程序可用于 v1/v2/v3：

```text
00100093    // addi x1, x0, 1
00208113    // addi x2, x1, 2
00100073    // ebreak
```

讲义原始文件保存在 `hex/logisim/`，格式为 `v3.0 hex words addressed`。
Makefile 调用 [scripts/run_image.py](scripts/run_image.py) 自动转换为
`build/<MODULENAME>/image.readmemh.hex`，保留原文件内容。转换时行首字地址转换为
`@` 字索引，不乘以 4。v3 的 ROM 和 RAM 加载同一镜像，后续 store 只更新 RAM。
目前只识别这个 Logisim 格式，不支持任意其他 Logisim 头部或二进制文件。

`mem` 和 `sum` 的程序、数据和栈使用零基地址，且需要 ADD 和全部四条访存指令。
镜像约 300 KiB，运行时最高访问地址分别为 `0x51fff` 和 `0x50fff`，因此原来的 1 KiB
存储器不能满足需求。现在 v3 的 512 KiB ROM/RAM 覆盖这些地址。

两个讲义原始程序通过 halt 死循环结束。现在 `HALT=auto` 根据原始文件的 SHA-256
识别已核验的 mem/sum 镜像：ROM 加载完成后，仅将 halt 入口处的指令替换为 `ebreak`。
原始 hex 和数据 RAM 保持原样。命中指定入口且 `a0=0` 输出 `[RESULT] PASS`、退出码为 0；
`a0!=0` 或在其他地址遇到 EBREAK 输出 FAIL、返回非 0；未到 halt 就耗尽周期则输出 TIMEOUT、返回非 0。
6000 周期现在是超时上限，不必等满。

自定义程序可用 `HALT=0x地址` 指定入口，约定 a0 是退出状态。未知镜像不会根据文件名猜测地址；
没有启用 HALT 检查的普通测试仍只在 EBREAK 或周期上限停止，其退出码不代表功能通过。
`HALT=none` 可保留原 halt 循环，按旧方法运行 6000 周期并检查 a0 和 halt PC。
短程序应以 `ebreak` 或明确结束循环停止，避免执行镜像以外的内容。

## 构建、波形和环境

- 各处理器的构建产物保存在 `build/<MODULENAME>/obj_dir/`，切换无需清理缓存。
- 波形保存在 `build/<MODULENAME>/waveform.fst`；同一处理器的后一次运行会覆盖它。
  如需保留不同 hex 的波形，请在下一次运行前复制保存。
- 默认打开 GTKWave 并等待窗口关闭。`WAVE=0` 跳过打开窗口，仍生成波形。
- 运行需要 Python 3、GNU Make、C++ 编译器和 Verilator；查看波形还需 GTKWave。
  Ubuntu 可用 `sudo apt install python3 build-essential verilator gtkwave` 安装。
- `sim` 和 `clean` 不依赖 NVBoard。`make TOPNAME=... run` 属于单独的 NVBoard 流程，
  仍需配置 `NVBOARD_HOME`。
- 未设置 `NEMU_HOME` 时，Makefile 默认使用仓库内的 `nemu/`，用于课程自动 Git 记录。

运行脚本将镜像、地址和周期参数传给仿真器，C++ 将参数注册到 Verilator，RTL 在运行时
获取 `+hex=`、v3 的 `+base=` 及可选 `+halt=`。这些值不参与 RTL 编译参数，因此切换程序和地址布局
可复用同一个处理器可执行文件。

## 验证与新增处理器

从仓库根目录执行：

```bash
# 原有处理器 / HEX 参数选择回归
python3 npc/tests/test_hex_selection.py

# v3 的四个访存自测及讲义 mem/sum
python3 npc/tests/test_minirv.py
```

2026-11-02，四个访存自测和讲义 `mem/sum` 已通过 v3 RTL 实测；周期数、停止 PC 和
结果文件位置见 [v3 实测记录](vsrc/ysyx_24080034_npc/v3_proc_minirv/README.md#实测记录)。

回归应核对寄存器、内存结果及程序停止位置，而非仅检查进程是否正常退出。
测试需要 Verilator、C++ 编译器和 GTKWave 包中的 `fst2vcd`，不会打开 GUI。

新增处理器时，在 Makefile 注册 `SIM_SRCDIR_<MODULENAME>` 和
`SIM_DEFAULT_HEX_<MODULENAME>`，接入 C++ 仿真入口并支持运行时镜像加载，
随后补充版本 README 和兼容性表。完成一次接入后，运行时只需选择参数。
