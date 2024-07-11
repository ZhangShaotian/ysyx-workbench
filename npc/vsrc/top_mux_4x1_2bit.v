//==========================
// Module: top_mux_4x1_2bit
//
// Description:
// This top module implements a 4-to-1 multiplexer for 2-bit signals.
// It selects between four 2-bit inputs packed into an 8-bit bus (sw)
// based on a 2-bit selection signal (sel), and outputs the selected 
// 2-bit value to two LEDs (led0 and led1). The module is clocked and 
// can be reset.
//
// Inputs:
// - clk: Clock signal
// - rst: Reset signal
// - sw0 - sw9: Individual input switches
//
// Outputs:
// - led0: First LED output
// - led1: Second LED output
//
// Functionality:
// - Packs the individual input signals into an 8-bit bus (sw).
// - Packs the selection signals into a 2-bit bus (sel).
// - Selects between the packed inputs based on sel and outputs the 
//   result to led0 and led1.
//==========================

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







