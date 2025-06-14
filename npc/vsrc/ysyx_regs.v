module ysyx_24080034_EnResetReg
#(
    WIDTH = 1,
    RESET_VAL = 0
)(
    input clk,                  //Clock input
    input rst,                  //Sync reset input
    input [WIDTH-1:0] d,        //Data input
    output reg [WIDTH-1:0] q,   //Data output
    input en                    //Enable input
);
    always @(posedge clk) begin
        if (rst) q <= RESET_VAL;
        else if (en) q <= d;
    end
endmodule
