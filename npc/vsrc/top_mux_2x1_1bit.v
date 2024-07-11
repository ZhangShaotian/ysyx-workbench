//==========================
// Module: top_mux_2x1_1bit
//
// Description:
// This top module implements a 2-to-1 multiplexer for a single bit.
// It selects between two input switches (sw0 and sw1) based on a 
// selection switch (sw2), and outputs the selected value to an LED 
// (led0). The module is clocked and can be reset.
//
// Inputs:
// - clk: Clock signal
// - rst: Reset signal
// - sw0: First input switch
// - sw1: Second input switch
// - sw2: Selection switch
//
// Outputs:
// - led0: LED output
//
// Functionality:
// - Selects between sw0 and sw1 based on sw2 and outputs the result 
//   to led0.
//==========================

module top_mux_2x1_1bit(
	input clk,
	input rst,
	input sw0,
	input sw1,
	input sw2,
	output led0

);

mux_2x1_1bit mux_instance(
	.a(sw0),
	.b(sw1),
	.sel(sw2),
	.y(led0)
);
endmodule

