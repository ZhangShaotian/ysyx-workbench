// =============================================================
// Module:   ysyx_inst_mem
// Role:     Instruction Memory (ROM-style, preloaded from hex)
// Notes:    Word-addressed internally. The incoming PC is a byte
//           address in the [BASE_ADDR, BASE_ADDR + DEPTH*4) range.
// =============================================================
module ysyx_inst_mem #(
    parameter ADDR_W    = 32,
    parameter DATA_W    = 32,
    parameter DEPTH     = 256,
    parameter [ADDR_W-1:0] BASE_ADDR = 32'h80000000,
    parameter HEX_FILE  = "hex/program_ebreak.hex"
)(
    input  logic [ADDR_W-1:0] pc,
    output logic [DATA_W-1:0] inst
);

    // ROM storage
    logic [DATA_W-1:0] mem [0:DEPTH-1];

    // Preload from hex file at time 0
    initial $readmemh(HEX_FILE, mem);

    // Byte address -> word index. Only the lower $clog2(DEPTH) bits are
    // actually used to index the array; upper bits are silenced for lint.
    // verilator lint_off UNUSED
    logic [ADDR_W-1:0] word_idx;
    // verilator lint_on UNUSED
    assign word_idx = (pc - BASE_ADDR) >> 2;

    assign inst = mem[word_idx];

endmodule
