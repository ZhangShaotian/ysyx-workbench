# v1：ADDI 处理器

- 顶层模块：`ysyx_v1_TopProcAddi`。
- 实现 `addi`，支持用 `ebreak` 结束仿真。
- 默认 hex：`hex/program_ebreak.hex`；预期 `x0..x31=0..31` 后退出。
- `hex/program_raw.hex` 中的两条 ADDI 也可执行，前两条执行后 `x1=1、x2=3`；
  该文件没有结束指令，只适合观察前两条指令。
- 不支持 `program_addi_jalr_lui.hex` 和 `program_ysyx_addi_jalr.hex` 所需的 LUI/JALR。

在 `npc/` 下运行，无需修改源码中的文件名：

```bash
make MODULENAME=ysyx_v1_TopProcAddi HEX=hex/program_ebreak.hex sim
```

ROM 起始地址为 `0x80000000`，容量为 256 个 32 位字。
完整参数说明、自定义 hex 格式和波形位置见 [NPC README](../../../README.md)。
