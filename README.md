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
