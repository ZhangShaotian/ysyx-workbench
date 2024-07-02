//==========================
//Verilog Components: Muxes
//==========================

//--------------------------
//2 to 1 mux
//--------------------------
module mux2(
	input a,
	input b,
	input s,
	output y
);

assign y = (~s&a)|(s&b);

endmodule
