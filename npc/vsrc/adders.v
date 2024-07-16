//=============================================
//Verilog Components: Adders
//============================================


//--------------------------------------------
//1 bit Full Adder
//--------------------------------------------
module full_adder(
	input a,
	input b,
	input c_in,
	output c_out,
	output sum
);
	assign sum = a ^ b ^ c_in;//sum equals to 1 only when there are an odd numbers of 1s in a, b, c_in
	assign c_out = (a & b) | ((a | b) & c_in);

endmodule



//-------------------------------------------
//n bit Ripple Carry Adder
//------------------------------------------
module ripple_carry_adder
#(
	parameter nbit = 4
)
(
	input [nbit-1:0] a,
	input [nbit-1:0] b,
	input c_in,
	output [nbit-1:0] sum,
	output c_out
);
	wire [nbit:0] carry;//Why not "[nbit-1:0]"? Because it needs one more bit for carry[i+1]
	assign carry[0] = c_in;

	genvar i;
	generate
		for (i = 0; i < nbit; i++)begin : full_adder_block
			full_adder fullAdder(
				.a(a[i]),
				.b(b[i]),
				.c_in(carry[i]),
				.c_out(carry[i+1]),
				.sum(sum[i])
			);
			end
	endgenerate
endmodule



//-----------------------------------------
//n bit Carry Look-Ahead Adder
//----------------------------------------
module carry_look_ahead_adder
#(
	parameter nbit = 4
)
(
	input [nbit-1:0] a,
	input [nbit-1:0] b,
	input c_in,
	output reg c_out,
	output reg [nbit-1:0] sum
);
	wire [nbit:0] carry;
	wire [nbit-1:0] p;//Propagate
	wire [nbit-1:0] g;//Generate
	
	assign p = a | b;
	assign g = a & b;
	
	integer i;
	
	always@(*) begin
	carry[0] = c_in;
	for(i = 1; i <= nbit; i++)begin
		carry[i] = g[i-1] | (p[i-1]&carry[i-1]);
	end
	
	c_out = carry[nbit];	
	for(i = 0; i < nbit; i++)begin
		sum[i] = a[i]^b[i]^carry[i];
	end

	end
endmodule















