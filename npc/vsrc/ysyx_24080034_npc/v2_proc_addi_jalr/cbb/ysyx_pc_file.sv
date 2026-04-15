module ysyx_pc_file #(
    parameter PC_WIDTH  = 32,
    parameter RESET_PC  = 32'h80000000
)(
    input  logic                 clk,
    input  logic                 rstn,       // Active low reset

    // Control signal: 0 = PC+4, 1 = jump target (from BRU)
    input  logic                 pc_select,

    // Target address from BRU (for jalr / branch)
    input  logic [PC_WIDTH-1:0]  jump_addr,

    output logic [PC_WIDTH-1:0]  pc_out,
    output logic [PC_WIDTH-1:0]  pc_plus4    // Exposed to BRU for link register
);

    logic [PC_WIDTH-1:0] pc_next;

    // --- 1. PC + 4 incrementer ---
    ysyx_Incrementer #(PC_WIDTH, 4) pc_inc (
        .in (pc_out),
        .out(pc_plus4)
    );

    // --- 2. PC source mux: PC+4 (default) or jump target ---
    assign pc_next = pc_select ? jump_addr : pc_plus4;

    // --- 3. PC register ---
    ysyx_EnResetReg #(PC_WIDTH, RESET_PC) pc_reg (
        .clk (clk),
        .rstn(rstn),
        .en  (1'b1),
        .d   (pc_next),
        .q   (pc_out)
    );

endmodule
