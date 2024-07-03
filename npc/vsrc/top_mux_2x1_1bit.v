module top_mux_2x1_1bit(
	input clk,
	input rst,
	input sw0,
	input sw1,
	input sw2,
	output led0

);

mux_2x1_1bit(
	.a(sw0),
	.b(sw1),
	.sel(sw2),
	.y(led0)
);
endmodule

