module ysyx_pc_file #(
    parameter PC_WIDTH = 32
)(
    input  logic                 clk,
    input  logic                 rstn,      // Active low reset
    
    // Control signal: 0 for PC+4, 1 for Jump/Branch
    input  logic                 pc_select, 
    
    // Target address calculated by ALU or Jump-unit (for jal, jalr, or branch)
    input  logic [PC_WIDTH-1:0]  jump_addr, 
    output logic [PC_WIDTH-1:0]  pc_out
);

    // Internal wires for the next PC value and the incremented PC
    logic [PC_WIDTH-1:0] pc_next;
    logic [PC_WIDTH-1:0] pc_plus_4;

    // --- 1. Sequential Logic: Incrementer ---
    // Computes the next sequential instruction address (PC + 4)
    ysyx_Incrementer#(PC_WIDTH, 4) pc_inc (
        .in(pc_out),
        .out(pc_plus_4)
    );

    // --- 2. Combinational Logic: PC Source Multiplexer ---
    // Selects between the sequential address and the jump target address
    // If pc_select is 1, the CPU performs a jump (jal/jalr/branch)
    assign pc_next = pc_select ? jump_addr : pc_plus_4;

    // --- 3. Sequential Logic: Program Counter Register ---
    // Updates the PC value on every clock cycle
    // 'en' is set to 1 to keep the PC updating; 
    // In a pipeline, 'en' would be connected to a 'stall' signal.
    ysyx_EnResetReg#(PC_WIDTH, 32'h80000000) pc_reg (
        .clk(clk),
        .rstn(rstn),   // Converts active-low rstn to active-high for the register
        .en(1'b1),     
        .d(pc_next),
        .q(pc_out)
    );

endmodule
