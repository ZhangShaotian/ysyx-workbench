# "一生一芯"工程项目

这是"一生一芯"的工程项目. 通过运行
```bash
bash init.sh subproject-name
```
进行初始化, 具体请参考[实验讲义][lecture note].

[lecture note]: https://ysyx.oscc.cc/docs/

## NPC 处理器仿真

通过 `MODULENAME` 选择处理器，通过 `HEX` 选择运行时加载的程序：

```bash
make -C npc MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/program_addi_jalr_lui.hex sim
```

v3 已实现八条 minirv 指令，可直接选择讲义的 `mem/sum` 原始镜像：

```bash
make -C npc MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/mem.hex sim WAVE=0
make -C npc MODULENAME=ysyx_v3_TopProc_minirv HEX=hex/logisim/sum.hex sim WAVE=0
```

运行脚本自动转换 Logisim 格式，并选择零基地址和 6000 周期上限；原文件保持不变。
可用 `BASE`、`CYCLES` 覆盖自动值。`HEX` 的相对路径以 `npc/` 为基准，
`WAVE=0` 关闭自动打开 GTKWave。
各处理器支持的指令、hex 兼容性、默认程序及预期结果见 [NPC 使用说明](npc/README.md)。

## AM minirv 运行时

从仓库根目录设置环境后，可直接编译并运行 `dummy.c`：

```bash
export AM_HOME="$PWD/abstract-machine"
export NPC_HOME="$PWD/npc"
make -C am-kernels/tests/cpu-tests ARCH=minirv-npc ALL=dummy run
```

默认使用 v3、入口 `0x80000000`，自动加载镜像并在 `halt` 检查退出状态。
省略 `run` 只编译程序；详细流程、输出文件和限制见
[AM 程序运行说明](npc/README.md#运行-am-程序)。

## 清理构建产物

在仓库根目录执行 `make clean`，统一清理 NPC、Abstract Machine（含 am/klib）、
cpu-tests 和已下载的 riscv-tests 的 `build/`，以及测试临时 Makefile、`.result`、
NPC Python 缓存和 minirv 的 `lut.bin`、锁文件、临时生成器。
NPC 的测试日志、批量测试报告、临时运行脚本和波形均随 `npc/build/` 删除。
这会清除上述项目所有架构的构建缓存；源码和输入镜像保留，查找表会在下次编译时重新生成。
根目录清理不包含 NEMU、NVBoard、fceux-am 和 riscv-arch-test。

也可以按项目清理，无需设置 `ARCH` 或 `NVBOARD_HOME`：

```bash
make -C npc clean
make -C am-kernels/tests/cpu-tests clean
make -C am-kernels/tests/riscv-tests clean
make -C abstract-machine/tools/minirv clean
```

`make -n clean` 可预览清理命令；重复执行 `make clean` 不会重新创建构建目录或 `.result`。
独立测试仓库中的修改以 `patches/` 下的补丁随主仓库保存，另一台电脑的恢复方法见下文。

## RISC-V 测试仓库

两个 AM 适配版测试集放在 `am-kernels/tests/`，与 `cpu-tests` 并列：

```text
am-kernels/tests/
├── cpu-tests/
├── riscv-tests/       # NJU-ProjectN/riscv-tests-am
└── riscv-arch-test/   # NJU-ProjectN/riscv-arch-test-am
```

它们各自保留独立 Git 仓库，已在 `am-kernels/.gitignore` 中排除，避免作为嵌套仓库
误提交给 am-kernels。新的工作目录可在本仓库根目录用以下命令获取：

```bash
git clone --recursive https://github.com/NJU-ProjectN/riscv-tests-am.git am-kernels/tests/riscv-tests
git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/NJU-ProjectN/riscv-arch-test-am.git am-kernels/tests/riscv-arch-test
```

`riscv-arch-test` 使用浅克隆以减少下载量，测试文件完整；若需要完整提交历史，可执行
`git -C am-kernels/tests/riscv-arch-test fetch --unshallow`。

### 恢复独立仓库的本地修改

这两个独立仓库的远端仍指向 NJU，主仓库的 push 不会上传它们的工作区修改。
以下补丁保存了本地测试目录忽略规则及 `make clean` 修复：

| 本地目录 | 补丁 | 已验证的基础提交 |
| --- | --- | --- |
| `am-kernels` | [am-kernels.patch](patches/am-kernels.patch) | `bb725d6f8223dd7de831c3b692e8c4531e9d01af` |
| `am-kernels/tests/riscv-tests` | [riscv-tests-am.patch](patches/riscv-tests-am.patch) | `676cbc7a4e520fca1c3d4dd1b586b2550769e02e` |

在另一台电脑克隆相应仓库后，从工作台根目录逐条执行；每个补丁先检查，成功后再应用：

```bash
git -C am-kernels apply --check ../patches/am-kernels.patch
git -C am-kernels apply ../patches/am-kernels.patch
git -C am-kernels/tests/riscv-tests apply --check ../../../patches/riscv-tests-am.patch
git -C am-kernels/tests/riscv-tests apply ../../../patches/riscv-tests-am.patch
```

当前工作目录已包含这些修改，不需要再次应用。其他版本若检查失败，应先核对差异；
补丁不会自动应用，主仓库 pull 也不会更新独立仓库。以后使用自己的 Fork 后，
可在对应仓库提交、推送这些修改。此补丁仅保存已有修改，不会将目录转换成子模块。

两个测试项目共用上文设置的 `AM_HOME` 和 `NPC_HOME`。例如，从本仓库根目录运行：

```bash
make -C am-kernels/tests/riscv-tests ARCH=minirv-npc ALL=addi run
make -C am-kernels/tests/riscv-tests ARCH=minirv-npc TEST_ISA=i run

make -C am-kernels/tests/riscv-arch-test ARCH=minirv-npc ALL=addi-01 run
make -C am-kernels/tests/riscv-arch-test ARCH=minirv-npc TEST_ISA=I run
```

注意两个项目的 `TEST_ISA` 大小写不同：前者为 `i`，后者为 `I`；测试名也不同，
如 `addi` 与 `addi-01`。两者默认还包含 M 扩展测试，以上集合命令显式选择整数基础测试。

完整使用说明分别见 [riscv-tests README](am-kernels/tests/riscv-tests/README.md)
和 [riscv-arch-test README](am-kernels/tests/riscv-arch-test/README.md)。
下载完成不代表全部测试已通过；目前已验证的 AM 程序及退出状态检查见 NPC 使用说明。
