module timer_display(
	input clk,
	input start,
	input rst,
	output reg [7:0] seg0,
	output reg [7:0] seg1
);
	reg [25:0] count_clk;
	reg clk_1s;

	always@(posedge clk)begin
		if(start)begin
			if(count_clk == 24999999)begin
				count_clk <= 0;
				clk_1s <= ~clk_1s;
			end
			else
				count_clk <= count_clk + 1;
		end
	end
	
	reg [6:0] count;

	always@(posedge clk_1s or rst) begin
		if (rst)
			count <= 0;
		else if (count == 99)
			count <= 0;
		else
			count <= count + 1;
	end

	always@(*) begin
		case(count/10)
			0: seg1 = 8'b00000010;//0
			1: seg1 = 8'b10011110;//1
			2: seg1 = 8'b00100100;//2
			3: seg1 = 8'b00001100;//3
			4: seg1 = 8'b10011000;//4
			5: seg1 = 8'b01001000;//5
			6: seg1 = 8'b01000000;//6
			7: seg1 = 8'b00011110;//7
			8: seg1 = 8'b00000000;//8
			9: seg1 = 8'b00011000;//9
			default: seg1 = 8'b11111111;//Default: disenable all pins
		endcase

		case(count % 10)
			0: seg0 = 8'b00000010;//0
			1: seg0 = 8'b10011110;//1
			2: seg0 = 8'b00100100;//2
			3: seg0 = 8'b00001100;//3
			4: seg0 = 8'b10011000;//4
			5: seg0 = 8'b01001000;//5
			6: seg0 = 8'b01000000;//6
			7: seg0 = 8'b00011110;//7
			8: seg0 = 8'b00000000;//8
			9: seg0 = 8'b00011000;//9
			default: seg0 = 8'b11111111;//Default: disenable all pins
		endcase

	end
endmodule
