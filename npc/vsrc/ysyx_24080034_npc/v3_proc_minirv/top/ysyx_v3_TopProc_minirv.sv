// Single-cycle minirv: ADD, ADDI, LUI, JALR, LW, LBU, SW, SB.
// +base configures both reset PC and memory origin; +hex initializes ROM and RAM.
module ysyx_v3_TopProc_minirv #(
    parameter ADDR_W = 32, DATA_W = 32, REG_NUM = 32,
    parameter REG_AW = $clog2(REG_NUM), MEM_DEPTH = 131072
)(
    input logic clk,
    // Reset is asynchronous for state and also gates synchronous side effects.
    /* verilator lint_off SYNCASYNCNET */
    input logic rstn,
    /* verilator lint_on SYNCASYNCNET */
    output logic [ADDR_W-1:0] debug_pc,
    output wire [DATA_W-1:0] debug_regs [0:REG_NUM-1]
);
    import "DPI-C" function void sim_exit();
    logic [31:0] base_addr;
    initial begin
        if (!$value$plusargs("base=%h", base_addr)) base_addr = 32'h80000000;
        if (base_addr[1:0] != 0) $fatal(1, "Memory base must be word aligned");
    end
    logic [ADDR_W-1:0] pc_out, pc_plus4, bru_target;
    logic [DATA_W-1:0] inst, imm, rs1_data, rs2_data, alu_out, load_data, prf_wdata;
    logic [REG_AW-1:0] rs1_addr, rs2_addr, rd_addr;
    logic is_add, is_bru, is_load, is_store, is_byte, wr_en, valid;
    assign debug_pc = pc_out;

    ysyx_pc_file #(.PC_WIDTH(ADDR_W)) u_pc_file (
        .clk(clk), .rstn(rstn), .reset_pc(base_addr), .pc_select(is_bru),
        .jump_addr(bru_target), .pc_out(pc_out), .pc_plus4(pc_plus4)
    );
    ysyx_inst_mem #(.ADDR_W(ADDR_W), .DATA_W(DATA_W), .DEPTH(MEM_DEPTH)) u_inst_mem (
        .clk(clk), .rstn(rstn), .base_addr(base_addr), .pc(pc_out), .inst(inst)
    );
    ysyx_decoder #(.DATA_W(DATA_W), .REG_AW(REG_AW)) u_decoder (
        .inst(inst), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .imm(imm), .is_add(is_add), .is_bru(is_bru), .is_load(is_load),
        .is_store(is_store), .is_byte(is_byte), .wr_en(wr_en), .valid(valid)
    );
    ysyx_RegisterFile_2r1w #(.ADDR_WIDTH(REG_AW), .DATA_WIDTH(DATA_W)) u_prf (
        .clk(clk), .rstn(rstn), .raddr1(rs1_addr), .rdata1(rs1_data),
        .raddr2(rs2_addr), .rdata2(rs2_data), .waddr(rd_addr),
        .wdata(prf_wdata), .wen(wr_en), .debug_regs(debug_regs)
    );
    ysyx_alu #(.DATA_W(DATA_W)) u_alu (
        .in0(rs1_data), .in1(is_add ? rs2_data : imm), .fn(4'b0000), .out(alu_out)
    );
    // The BRU computes the same sum as the ALU for JALR; clear only bit zero.
    assign bru_target = {alu_out[ADDR_W-1:1], 1'b0};
    ysyx_data_mem #(.DATA_W(DATA_W), .DEPTH(MEM_DEPTH)) u_data_mem (
        .clk(clk), .rstn(rstn), .base_addr(base_addr), .addr(alu_out),
        .valid(is_load | is_store), .wr_en(is_store), .byte_access(is_byte),
        .wdata(rs2_data), .rdata(load_data)
    );
    assign prf_wdata = is_load ? load_data : is_bru ? pc_plus4 : alu_out;
    always @(posedge clk) begin
        if (rstn) begin
            if (!valid) $fatal(1, "Unsupported instruction %08x at PC=%08x", inst, pc_out);
            if (inst == 32'h00100073) begin
                $display("[DPI-C] ebreak detected, exiting simulation...");
                sim_exit();
            end
        end
    end
endmodule
