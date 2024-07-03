module top_module1(
	input clk,
	input rst,
	input sw0,
	input sw1,
	output led0
);

switch mySwitch(
	.a(sw0),
	.b(sw1),
	.f(led0)
);
endmodule
