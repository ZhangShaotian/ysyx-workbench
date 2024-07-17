//=======================================================
//Verilog Components: Counter
//=======================================================



//------------------------------------------------------
// nbit up counter with enable, reset and set
//------------------------------------------------------
module up_counter
#(
	parameter nbit = 3
)
(
	input clk,
	input en,
	input rst,
	input set_signal,
	output [nbit-1:0] Q
);
	wire [nbit-1:0] clks;
	assign clks[0] = clk;
	genvar i;
	generate
		for(i = 1; i<=nbit-1; i++) begin
			assign clks[i] = ~Q[i-1];
		end
		
		for(i = 0; i <= nbit-1; i++) begin: D_Flip_Flop_Block
			EnResetSetPosEdgeReg myReg(
				.en(en),
				.rst(rst),
				.set_signal(set_signal),
				.clk(clks[i]),
				.d(~Q[i]),
				.q(Q[i])
			);
		end
	endgenerate
endmodule

//module up_counter
//#(
//	parameter nbit = 3
//)
//(
//	input clk,
//	input en,
//	input rst,
//	input set_signal,
//	output reg [nbit-1:0] Q
//);
//	wire D0;
//	wire D1;
//	wire D2;
//	assign D0 = ~Q[0];
//	assign D1 = ~Q[1];
//	assign D2 = ~Q[2];
//
//    	initial begin
//		Q = 0; // 初始化 Q
//    	end
//
//	EnResetSetPosEdgeReg myReg0(
//		.en(en),
//		.rst(rst),
//		.set_signal(set_signal),
//		.clk(clk),
//		.d(D0),
//		.q(Q[0])
//	);
//
//	EnResetSetPosEdgeReg myReg1(
//		.en(en),
//		.rst(rst),
//		.set_signal(set_signal),
//		.clk(~Q[0]),
//		.d(D1),
//		.q(Q[1])
//	);
//
//	EnResetSetPosEdgeReg myReg2(
//		.en(en),
//		.rst(rst),
//		.set_signal(set_signal),
//		.clk(~Q[1]),
//		.d(D2),
//		.q(Q[2])
//	);
//
//endmodule


//--------------------------------------------------------
//nbit down counter with reset, set and enable
//-------------------------------------------------------
module down_counter
#(
	parameter nbit = 3
)
(
	input clk,
	input en,
	input rst,
	input set_signal,
	output [nbit-1:0] Q
);
	wire [nbit-1:0] clks;
	assign clks[0] = clk;
	genvar i;
	generate
		for(i = 1; i<=nbit-1; i++) begin
			assign clks[i] = Q[i-1];
		end
		
		for(i = 0; i <= nbit-1; i++) begin: D_Flip_Flop_Block
			EnResetSetPosEdgeReg myReg(
				.en(en),
				.rst(rst),
				.set_signal(set_signal),
				.clk(clks[i]),
				.d(~Q[i]),
				.q(Q[i])
			);
		end
	endgenerate
endmodule













