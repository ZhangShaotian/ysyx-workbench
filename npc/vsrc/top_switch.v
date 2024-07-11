//==========================
// Module: top_switch
//
// Description:
// This top module interfaces with a simple XOR switch module. It takes 
// two input switches (sw0 and sw1) and produces an output to an LED 
// (led0) based on the XOR operation. The module is clocked and can be reset.
//
// Inputs:
// - clk: Clock signal
// - rst: Reset signal
// - sw0: First input switch
// - sw1: Second input switch
//
// Outputs:
// - led0: LED output
//
// Functionality:
// - Connects the input switches to the switch module, which performs 
//   an XOR operation, and outputs the result to the LED.

module top_switch(
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
