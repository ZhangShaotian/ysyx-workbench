//==============================
//Verilog Components: Decoders
//==============================

//------------------------------
// 2 to 4 oenhot decoder
//------------------------------
module decoder_2to4_onehot(
	input [1:0] a,
	input en,
	output reg [3:0] y
);
	always@(*)
	begin
		if(en)
		begin
			case(a)
				2'b00: y = 4'b0001;
				2'b01: y = 4'b0010;
				2'b10: y = 4'b0100;
				2'b11: y = 4'b1000;
			endcase
		end
		else
		begin
			y = 4'b0000;
		end
	end
endmodule



//-------------------------------------------
// 3 to 8 decoder, implemented using for loop
// ------------------------------------------

module decoder_3to8_onehot(
	input [2:0] a,
	input en,
	output reg [7:0] y,
	integer i
);

	always@(*) begin
	if(en) begin
		for(i=0; i <= 7; i=i+1)
			if(i == a)
				y[i] = 1;
			else
				y[i] = 0;
	end
	else begin
		y = 8'd0;
	end	
	end

endmodule
