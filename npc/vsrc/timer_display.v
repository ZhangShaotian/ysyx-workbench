module timer_display(
	input clk,
	input start,
	input rst,//Active low reset
	output reg [7:0] seg0,
	output reg [7:0] seg1,
	output reg light
);
	reg [25:0] count_clk;
	reg clk_1s;
	
	// Frequency divider to generate 1Hz clock
	always@(posedge clk or negedge rst)begin
		if (!rst) begin
			count_clk <= 0;
			clk_1s <= 0;
		end
		else if(start)begin
			if(count_clk == 24999999)begin
				count_clk <= 0;
				clk_1s <= ~clk_1s;
			end
			else
				count_clk <= count_clk + 1;
		end
	end
	
	reg [6:0] count;
	
	// Counter to count from 0 to 99
	always@(posedge clk_1s or negedge rst) begin
		if (!rst)
			count <= 0;
		else if (count == 99)
			count <= 0;
		else
			count <= count + 1;
	end

	// Display logic for the 7-segment displays
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

	// Light control logic
	always@(posedge clk_1s or negedge rst) begin
		if(!rst)
			light <= 0;
		else if(count >= 90)
			light <= ~light;
		else
			light <= 0;
	end
endmodule



















