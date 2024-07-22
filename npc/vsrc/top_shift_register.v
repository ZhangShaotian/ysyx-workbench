module top_shift_register(
	input clk,
	input button_clk,//BTNC
	input rst,//SW0
	output [7:0] seg0,
	output [7:0] seg1,
	output [7:0] seg2,
	output [7:0] seg3,
	output [7:0] seg4,
	output [7:0] seg5,
	output [7:0] seg6,
	output [7:0] seg7
);
	wire [7:0] binary;

	shift_register myShiftRegister(
		.clk(button_clk),
		.rst(rst),
		.out(binary)
	);

	segments_x7_display_hex instance0(
		.binary(binary[3:0]),
		.seg(seg0)
	);

	segments_x7_display_hex instance1(
		.binary(binary[7:4]),
		.seg(seg1)
	);

	assign seg2 = 8'b11111111;
	assign seg3 = 8'b11111111;
	assign seg4 = 8'b11111111;
	assign seg5 = 8'b11111111;
	assign seg6 = 8'b11111111;
	assign seg7 = 8'b11111111;

endmodule
