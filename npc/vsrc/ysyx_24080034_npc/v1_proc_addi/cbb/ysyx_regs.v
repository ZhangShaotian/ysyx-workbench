module ysyx_EnResetReg
#(
    WIDTH = 1,
    RESET_VAL = 0
)(
    input clk,                  //Clock input
    input rstn,                 //Sync reset input
    input [WIDTH-1:0] d,        //Data input
    output reg [WIDTH-1:0] q,   //Data output
    input en                    //Enable input
);
    always @(posedge clk) begin
        if (~rstn) q <= RESET_VAL;
        else if (en) q <= d;
    end
endmodule
