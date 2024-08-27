module top_running_light(
  input clk,
  input rst,
  output [15:0] led
);
  running_light mylight(
    .clk(clk),
    .rst(rst),
    .led(led)
  );
endmodule
