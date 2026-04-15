// =============================================================
// Module:   ysyx_bru
// Role:     Branch / Jump Resolution Unit.
//           For JALR:
//             pc_target = (rs1 + imm) & ~1   (bit 0 forced to 0)
//             rd_wdata  = PC + 4             (link register)
//             pc_sel    = 1                  (always taken)
// =============================================================
module ysyx_bru #(
    parameter DATA_W = 32
)(
    input  logic [DATA_W-1:0] rs1,
    input  logic [DATA_W-1:0] imm,
    input  logic [DATA_W-1:0] pc_plus4,

    output logic              pc_sel,     // 1 = take jump (JALR: always)
    output logic [DATA_W-1:0] pc_target,  // (rs1 + imm) & ~1
    output logic [DATA_W-1:0] rd_wdata    // PC + 4
);

    // LSB of the sum is discarded (forced to 0 per the JALR spec).
    /* verilator lint_off UNUSED */
    logic [DATA_W-1:0] sum;
    /* verilator lint_on UNUSED */
    assign sum = rs1 + imm;

    // Force LSB to 0 per RISC-V JALR spec
    assign pc_target = {sum[DATA_W-1:1], 1'b0};

    // JALR always jumps; when conditional branches are added later,
    // this will become the comparator result.
    assign pc_sel    = 1'b1;

    // Link register value (return address)
    assign rd_wdata  = pc_plus4;

endmodule
