module ysyx_24080034_alu(
    input  [31:0] in0,
    input  [31:0] in1,
    input  [ 3:0] fn,
    output [31:0] out 
);

    assign out = (fn == 4'd0) ? in0 + in1 : // ADD
                 32'b0;

endmodule
