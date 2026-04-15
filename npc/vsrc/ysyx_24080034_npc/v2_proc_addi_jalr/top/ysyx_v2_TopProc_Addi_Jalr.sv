// =============================================================
// Project:  YSYX (One Student One Chip)
// Module:   ysyx_v2_TopProc_Addi_Jalr
// Version:  V2.0
// Author:   Shaotian
//
// Description:
//   Single-cycle RV32I processor supporting ADDI and JALR, with
//   EBREAK hook for DPI-C simulation exit.
//
// Datapath (matches architecture diagram):
//
//   +--------+   +---------+   +---------+   +-----+   +-----+
//   | PCFile |-->| InstMem |-->| Decoder |-->| PRF |-->| ALU |--+
//   +--------+   +---------+   +---------+   +-----+   +-----+  |
//        ^                          |           |               |
//        |                          |           |    +-----+    |
//        |                          +------Type_Enable| BRU |<--+rs1
//        |                                            +-----+
//        |                                               | pc_sel
//        |                                               | pc_target
//        +-----------------------------------------------+ rd_wdata
//                                                          (PC+4)
// =============================================================
module ysyx_v2_TopProc_Addi_Jalr #(
    parameter ADDR_W    = 32,
    parameter DATA_W    = 32,
    parameter REG_NUM   = 32,
    parameter REG_AW    = $clog2(REG_NUM),
    parameter MEM_DEPTH = 256
)(
    input logic clk,
    input logic rstn
);

    // -------------------------------------------------------------------------
    // [EBREAK] DPI-C hook that terminates the simulator when the EBREAK
    // instruction is fetched.
    // -------------------------------------------------------------------------
    import "DPI-C" function void sim_exit();

    // =========================================================================
    // Internal wires
    // =========================================================================

    // --- Fetch ---
    logic [ADDR_W-1:0] pc_out;
    logic [ADDR_W-1:0] pc_plus4;
    logic [DATA_W-1:0] inst;

    // --- Decode ---
    logic [REG_AW-1:0] rs1_addr;
    logic [REG_AW-1:0] rd_addr;
    logic [DATA_W-1:0] imm;
    logic              is_alu;
    logic              is_bru;
    logic              wr_en;
    logic              pc_sel;

    // --- Execute ---
    logic [DATA_W-1:0] rs1_data;
    logic [DATA_W-1:0] alu_out;
    logic [ADDR_W-1:0] bru_target;
    logic [DATA_W-1:0] bru_rd_wdata;
    // BRU also drives its own pc_sel (always 1 for JALR). The decoder's
    // pc_sel already encodes is_bru, so this one is held for future branches.
    // verilator lint_off UNUSED
    logic              bru_pc_sel;
    // verilator lint_on UNUSED

    // --- Writeback ---
    logic [DATA_W-1:0] prf_wdata;

    // =========================================================================
    // EBREAK detection (fetch-stage)
    // =========================================================================
    always @(posedge clk) begin
        if (inst == 32'h00100073) begin
            $display("[DPI-C] ebreak detected, exiting simulation...");
            sim_exit();
        end
    end

    // =========================================================================
    // PC File: PC register + PC+4 + jump mux
    // =========================================================================
    ysyx_pc_file #(
        .PC_WIDTH(ADDR_W),
        .RESET_PC(32'h80000000)
    ) u_pc_file (
        .clk      (clk),
        .rstn     (rstn),
        .pc_select(pc_sel),
        .jump_addr(bru_target),
        .pc_out   (pc_out),
        .pc_plus4 (pc_plus4)
    );

    // =========================================================================
    // Instruction Memory (ROM)
    // =========================================================================
    ysyx_inst_mem #(
        .ADDR_W   (ADDR_W),
        .DATA_W   (DATA_W),
        .DEPTH    (MEM_DEPTH),
        .BASE_ADDR(32'h80000000),
        .HEX_FILE ("hex/program_ysyx_addi_jalr.hex")
    ) u_inst_mem (
        .pc  (pc_out),
        .inst(inst)
    );

    // =========================================================================
    // Decoder: ADDI / JALR decode + control signals
    // =========================================================================
    ysyx_decoder #(
        .DATA_W(DATA_W),
        .REG_AW(REG_AW)
    ) u_decoder (
        .inst    (inst),
        .rs1_addr(rs1_addr),
        .rd_addr (rd_addr),
        .imm     (imm),
        .is_alu  (is_alu),
        .is_bru  (is_bru),
        .wr_en   (wr_en),
        .pc_sel  (pc_sel)
    );

    // =========================================================================
    // Physical Register File (1R1W, x0 hardwired to 0)
    //   ADDI and JALR both need exactly one read port (rs1), so 1R1W suffices.
    // =========================================================================
    ysyx_RegisterFile_1r1w #(
        .ADDR_WIDTH(REG_AW),
        .DATA_WIDTH(DATA_W)
    ) u_prf (
        .clk  (clk),
        .raddr(rs1_addr),
        .rdata(rs1_data),
        .waddr(rd_addr),
        .wdata(prf_wdata),
        .wen  (wr_en)
    );

    // =========================================================================
    // ALU: ADDI  ->  rd = rs1 + imm
    // =========================================================================
    ysyx_alu #(
        .DATA_W(DATA_W)
    ) u_alu (
        .in0(rs1_data),
        .in1(imm),
        .fn (4'b0000),        // ADD
        .out(alu_out)
    );

    // =========================================================================
    // BRU: JALR  ->  pc_target = (rs1+imm)&~1, rd = PC+4
    // =========================================================================
    ysyx_bru #(
        .DATA_W(DATA_W)
    ) u_bru (
        .rs1      (rs1_data),
        .imm      (imm),
        .pc_plus4 (pc_plus4),
        .pc_sel   (bru_pc_sel),
        .pc_target(bru_target),
        .rd_wdata (bru_rd_wdata)
    );

    // =========================================================================
    // Writeback mux: select which EU's result goes back to PRF.
    //   is_bru=1  -> BRU link value (PC+4)
    //   otherwise -> ALU result     (rs1+imm)
    // =========================================================================
    assign prf_wdata = is_bru ? bru_rd_wdata : alu_out;

    // is_alu is implicitly consumed by the writeback mux (as !is_bru when
    // wr_en is asserted); silence verilator's unused-signal warning.
    // verilator lint_off UNUSED
    wire _unused_is_alu = is_alu;
    // verilator lint_on UNUSED

endmodule
