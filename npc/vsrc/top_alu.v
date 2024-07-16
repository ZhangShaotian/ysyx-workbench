//==========================================================
//Module: top_alu.v
//=========================================================

module top_alu(
	input clk,
	input rst,
	input [3:0] sw_A,//input A, sw3~sw0
	input [3:0] sw_B,//input B, sw7~sw4
	input [2:0] sw_sel,//select sw, sw10~sw8
	output [3:0] led_result,//result output, led3~led0
	output led6_overflow, led5_zero, led4_carry // led6:overflow, led5:zero, led4:carry
);
	alu #(
		.nbit(4)
	)
	myAlu(
		.A(sw_A),
		.B(sw_B),
		.sel(sw_sel),
		.result(led_result),
		.overflow(led6_overflow),
		.zero(led5_zero),
		.carry(led4_carry)
	);

endmodule
