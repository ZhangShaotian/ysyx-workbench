module ysyx_alu #(
    parameter DATA_W = 32
)(
    input  [DATA_W-1:0] in0,
    input  [DATA_W-1:0] in1,
    input  [      3:0]  fn,
    output [DATA_W-1:0] out
);

    // Only ADD (fn=0) is needed for ADDI (and for BRU's jump target via a
    // separate adder inside the BRU module). All other ops return 0.
    assign out = (fn == 4'd0) ? in0 + in1 : {DATA_W{1'b0}};

endmodule
