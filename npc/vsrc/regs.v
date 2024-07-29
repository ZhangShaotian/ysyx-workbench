//===========================================
//Verilog Components: Registers
//===========================================



//----------------------------------------------------------
//Simple Register
//----------------------------------------------------------
module simpleReg#(
	parameter nbit = 1
)
(
	input clk,
	input rst,
	input [nbit-1:0] din,
	output reg [nbit-1:0] dout
);
	always@(posedge clk)begin
		if(rst)
			dout <= 0;
		else
			dout <= din;
	end
endmodule


//------------------------------------------------------------
//Positive-edge triggered flip-flop with enable, reset and set
//------------------------------------------------------------
module EnResetSetPosEdgeReg
#(
	parameter nbit = 1,
	parameter reset_value = 0,
	parameter set_value = {nbit{1'b1}}
)
(
	input en,
	input rst,
	input set_signal,
	input clk,
	input [nbit-1:0] d,
	output reg [nbit-1:0] q
);
	always@(posedge clk or negedge rst) begin
		if(!rst)
			q <= reset_value;
		else if(set_signal)
			q <= set_value;
		else if(en)
			q <= d;
	end
endmodule
