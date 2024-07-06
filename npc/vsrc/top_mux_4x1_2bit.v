module top_mux_4x1_2bit(
	input clk,
	input rst,
	input sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9,
	output led0, led1
);

wire [7:0] sw;
wire [1:0] sel;
wire [1:0] led;

assign sw = {sw9, sw8, sw7, sw6, sw5, sw4, sw3, sw2};// Pack input signals into an 8-bit bus
assign sel = {sw1, sw0};// Pack selection signals into a 2-bit bus

// Instantiate the 4x1 2-bit multiplexer
mux_4x1_2bit u_mux_0(
	.a(sw),
	.sel(sel),
	.y(led)
);

// Assign the output bus signals to the individual LED outputs
assign led0 = led[0];
assign led1 = led[1];

endmodule


module mux_4x1_2bit(
	input [7:0] a,
        input [1:0] sel,
        output [1:0] y
);
	MuxKeyWithDefault #(4, 2, 2) i0 (y, sel, 2'b0, {
	2'b00, {a[1], a[0]},
	2'b01, {a[3], a[2]},
	2'b10, {a[5], a[4]},
	2'b11, {a[7], a[6]}
	});

endmodule







