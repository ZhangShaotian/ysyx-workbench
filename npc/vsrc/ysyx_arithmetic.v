module ysyx_24080034_Incrementer
#(
    parameter p_nbits = 1,
    parameter p_inc_value = 1
)(
    input  [p_nbits-1:0] in,
    output [p_nbits-1:0] out
);
    assign out = in + p_inc_value;

endmodule
