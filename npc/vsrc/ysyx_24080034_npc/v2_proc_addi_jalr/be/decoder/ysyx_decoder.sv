// =============================================================
// Module:   ysyx_decoder
// Role:     Decode ADDI / JALR / LUI, emit register addresses,
//           immediate and control signals.
// Notes:    - ADDI and JALR are I-type (funct3 = 000).
//           - LUI is U-type and has no rs1 field; the decoder routes
//             x0 to rs1 so the ALU computes 0 + imm_u = imm_u.
// =============================================================
module ysyx_decoder #(
    parameter DATA_W = 32,
    parameter REG_AW = 5
)(
    input  logic [DATA_W-1:0] inst,

    // Register addresses
    output logic [REG_AW-1:0] rs1_addr,
    output logic [REG_AW-1:0] rd_addr,

    // Sign-extended (or U-type) immediate
    output logic [DATA_W-1:0] imm,

    // Control signals
    output logic              is_alu,   // enables ALU path (ADDI, LUI)
    output logic              is_bru,   // enables BRU path (JALR)
    output logic              wr_en,    // register-file write enable
    output logic              pc_sel    // 0 = PC+4, 1 = BRU target
);

    // --- Opcode encodings (RV32I, base ISA) ---
    localparam [6:0] OPC_ADDI = 7'b0010011;   // OP-IMM
    localparam [6:0] OPC_JALR = 7'b1100111;   // JALR
    localparam [6:0] OPC_LUI  = 7'b0110111;   // LUI

    logic [6:0] opcode;
    logic [2:0] funct3;

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];

    // --- Per-instruction detect ---
    logic is_addi;
    logic is_jalr;
    logic is_lui;

    assign is_addi = (opcode == OPC_ADDI) & (funct3 == 3'b000);
    assign is_jalr = (opcode == OPC_JALR) & (funct3 == 3'b000);
    assign is_lui  = (opcode == OPC_LUI);

    // --- Execution unit selection ---
    assign is_alu = is_addi | is_lui;
    assign is_bru = is_jalr;

    // --- Register fields ---
    // rd is in the same slot for all three instructions.
    assign rd_addr  = inst[11:7];
    // LUI has no rs1; force x0 so the ALU sees 0 on in0.
    assign rs1_addr = is_lui ? {REG_AW{1'b0}} : inst[19:15];

    // --- Immediate mux: U-type for LUI, I-type otherwise ---
    logic [DATA_W-1:0] imm_i;
    logic [DATA_W-1:0] imm_u;

    // I-type: sign-extend inst[31:20]
    assign imm_i = {{(DATA_W-12){inst[31]}}, inst[31:20]};
    // U-type: inst[31:12] in upper bits, lower 12 bits zero
    assign imm_u = {inst[31:12], 12'b0};

    assign imm = is_lui ? imm_u : imm_i;

    // --- Register-file write enable: ADDI, JALR, LUI all write rd ---
    assign wr_en  = is_alu | is_bru;

    // --- PC source: only JALR changes PC non-sequentially ---
    assign pc_sel = is_bru;

endmodule
