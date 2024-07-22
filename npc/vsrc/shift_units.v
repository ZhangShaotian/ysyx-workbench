//============================================
//Verilog Components: shift unit.
//Shift Registers and Barrel Shifter
//============================================


//-------------------------------------------
// Linear-feedback shift register
//-------------------------------------------
module shift_register
#(
	parameter nbit = 8
)
(
	input clk,
	input rst,
	output [nbit-1:0] out
);
	reg [nbit-1:0] data;
	wire feedback;
	
	assign feedback = data[4]^data[3]^data[2]^data[0];

	always@(posedge clk or posedge rst)begin
		if(rst)
			data <= {{(nbit-1){1'b0}}, 1'b1};
		else
			data <= {feedback, data[nbit-1:1]};
	end	

	assign out = data;

endmodule

