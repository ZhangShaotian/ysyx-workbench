# v2：ADDI / JALR / LUI 处理器

- 顶层模块：`ysyx_v2_TopProc_Addi_Jalr`。虽然名字只含 ADDI/JALR，当前译码器也已支持 LUI。
- 支持 `addi、jalr、lui`，以及仿真退出用的 `ebreak`。
- 默认 hex：`hex/program_addi_jalr_lui.hex`；预期 `x1=0x8000000c、x2=0x80000018、x5=10` 后退出。
- 也支持 `hex/program_ebreak.hex`，预期 `x0..x31=0..31` 后退出。
- `hex/program_raw.hex` 的两条 ADDI 可执行，前两条执行后 `x1=1、x2=3`，但该文件没有结束指令。
- `program_ysyx_addi_jalr.hex` 按 PC=0 编写，与当前 ROM 起始地址 `0x80000000` 不匹配，
  不作为可靠的通过测试，也不再作为默认镜像。

在 `npc/` 下运行：

```bash
make MODULENAME=ysyx_v2_TopProc_Addi_Jalr HEX=hex/program_addi_jalr_lui.hex sim
make MODULENAME=ysyx_v2_TopProc_Addi_Jalr HEX=hex/program_ebreak.hex sim WAVE=0
```

ROM 容量为 256 个 32 位字，尚无数据 RAM 和访存指令。
完整参数说明、自定义 hex 格式和波形位置见 [NPC README](../../../README.md)。

## LUI 支持的实测依据

当前 v2 已支持 LUI，不能仅根据目录名 `v2_proc_addi_jalr` 或顶层模块名判断指令范围。
顶层文件的旧描述也只列出了 ADDI/JALR；实际支持范围应以译码和运行结果为准。
已有提交 `33400ea` 中的 v2 译码器就包含 LUI 支持，此次核对未新增或修改指令实现。

2026-11-02 在当前 v2 上执行：

```bash
make -C npc MODULENAME=ysyx_v2_TopProc_Addi_Jalr HEX=hex/program_addi_jalr_lui.hex sim WAVE=0
```

此命令从仓库根目录运行。对生成波形的检查结果为：

| 检查点 | 实际结果 |
| --- | --- |
| 执行 `lui x2,0x80000` 后 | `x2=0x80000000` |
| 执行 `addi x2,x2,24` 后 | `x2=0x80000018` |
| 执行 JALR 后 | 跳到 `0x80000018`，`x1=0x8000000c` |
| 跳过的指令 | `x5` 没有被写成 255 |
| 程序结束 | `x5=10`，执行 `0x8000001c` 处的 `ebreak` 后退出 |

实现位于 [译码器](be/decoder/ysyx_decoder.sv)：识别 opcode `0110111`，
生成 `{inst[31:12],12'b0}`，将读寄存器选为 x0，再利用 ALU 的 `0 + imm_u` 写回 rd。
因此当前 v2 的指令范围应记录为 **ADDI / JALR / LUI**。
