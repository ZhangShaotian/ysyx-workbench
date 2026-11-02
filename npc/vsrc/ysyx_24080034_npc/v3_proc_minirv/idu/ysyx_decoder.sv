// Decoder for the eight minirv instructions. Stores never write a GPR.
module ysyx_decoder #(
    parameter DATA_W = 32,
    parameter REG_AW = 5
)(
    input logic [DATA_W-1:0] inst,
    output logic [REG_AW-1:0] rs1_addr, rs2_addr, rd_addr,
    output logic [DATA_W-1:0] imm,
    output logic is_add, is_bru, is_load, is_store, is_byte,
    output logic wr_en, valid
);
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire is_addi = opcode == 7'h13 && funct3 == 3'b000;
    wire is_lui  = opcode == 7'h37;
    wire is_lw   = opcode == 7'h03 && funct3 == 3'b010;
    wire is_lbu  = opcode == 7'h03 && funct3 == 3'b100;
    wire is_sw   = opcode == 7'h23 && funct3 == 3'b010;
    wire is_sb   = opcode == 7'h23 && funct3 == 3'b000;
    assign is_add = opcode == 7'h33 && funct3 == 0 && inst[31:25] == 0;
    assign is_bru = opcode == 7'h67 && funct3 == 0;
    assign is_load = is_lw | is_lbu;
    assign is_store = is_sw | is_sb;
    assign is_byte = is_lbu | is_sb;
    assign wr_en = is_add | is_addi | is_lui | is_bru | is_load;
    assign valid = wr_en | is_store | (inst == 32'h00100073);

    assign rs1_addr = is_lui ? '0 : inst[19:15];
    assign rs2_addr = inst[24:20];
    assign rd_addr = inst[11:7];
    wire [DATA_W-1:0] imm_i = {{(DATA_W-12){inst[31]}}, inst[31:20]};
    wire [DATA_W-1:0] imm_s = {{(DATA_W-12){inst[31]}}, inst[31:25], inst[11:7]};
    assign imm = is_lui ? {inst[31:12], 12'b0} : is_store ? imm_s : imm_i;
endmodule
