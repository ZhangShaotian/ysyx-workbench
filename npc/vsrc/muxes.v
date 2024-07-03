//==========================
//Verilog Components: Muxes
//==========================

//--------------------------
//2 to 1 1-bit mux
//--------------------------
module mux_2x1_1bit(
	input a,
	input b,
	input sel,
	output y
);

assign y = (~sel&a)|(sel&b);

endmodule
