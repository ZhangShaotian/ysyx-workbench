module ysyx_pc_file #(parameter PC_WIDTH = 32)(
    input logic clk, rstn, pc_select,
    input logic [PC_WIDTH-1:0] reset_pc, jump_addr,
    output logic [PC_WIDTH-1:0] pc_out, pc_plus4
);
    assign pc_plus4 = pc_out + PC_WIDTH'(4);
    always @(posedge clk or negedge rstn) begin
        if (!rstn) pc_out <= reset_pc;
        else pc_out <= pc_select ? jump_addr : pc_plus4;
    end
endmodule
