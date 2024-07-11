//===================================
//Verilog Components: Encoders
//==================================



//-----------------------------------
//4 to 2 onehot encoder
//----------------------------------
module encoder_4to2_onehot(
	input en,
	input [3:0] a,
	output reg [1:0] y
);
	always@(*) begin
		if(en) begin
			case(a)
				4'b0001: y = 2'b00;
				4'b0010: y = 2'b01;
				4'b0100: y = 2'b10;
				4'b1000: y = 2'b11;
				default: y = 2'b00;
			endcase
		end
		else
			y = 2'b00;
	end
endmodule



//------------------------------------
//4 to 2 priority encoder
//------------------------------------
module encoder_4to2_priority(
	input en,
	input [3:0] a,
	output reg [1:0] y
);
	integer i;
	always@(*) begin
		if(en) begin
			y = 2'b00;
			for(i = 0; i <= 3; i = i + 1)
				if(a[i] == 1) y = i[1:0];
		end
		else
			y = 2'b00;
	end

endmodule

//-----------------------------------------------
// M-to-N Priority Encoder
// Parameters: M (default = 8), N (default = 3)
// Description: Encodes M input lines to N output lines,
//              prioritizing higher-order inputs.
//------------------------------------------------
module encoder_priority 
#(
	parameter M = 8, //Input bit width
	parameter N = 3 //Output bit width
)
(
	input en,
	input [M-1:0] a,
	output reg [N-1:0] y
);
	integer i;
	always@(*) begin
		if(en)begin
			y = 0;
			for(i = 0; i <= M - 1; i++) begin
				if(a[i] == 1) 
					y = i[N-1:0];
			end
		end
		else
			y = 0;
	end
endmodule
