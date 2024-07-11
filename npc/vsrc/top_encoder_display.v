/*
 * Module: top_encoder_display
 * 
 * Description:
 * This top module takes an 8-bit binary input and performs a priority encoding to generate a 3-bit binary output.
 * It also includes an indicator output that signals if any of the 8 input bits are set. The encoding operation 
 * can be enabled or disabled via an enable switch. The 3-bit encoded result and the indicator are displayed on 
 * four LEDs. Additionally, the binary encoded result is converted and displayed in decimal format on a set of 
 * seven-segment displays.
 * 
 * Inputs:
 * - clk: Clock signal
 * - rst: Reset signal
 * - sw_toggle: 8-bit input toggle switches (sw7 ~ sw0)
 * - sw_en: Enable switch (sw8)
 * 
 * Outputs:
 * - led_outputs: 3-bit LED outputs (led2 ~ led0)
 * - led_indicator: LED output indicator (led4)
 * - seg0 to seg7: Seven-segment display outputs (Display 0 to Display 7)
 * 
 * Functionality:
 * - Encodes the 8-bit input to a 3-bit binary value using a priority encoder.
 * - Sets the indicator LED based on whether any input bits are set.
 * - Displays the 3-bit binary output on LEDs.
 * - Converts and displays the binary result in decimal format on seven-segment displays.
 */

module top_encoder_display(
	input clk,
	input rst,
	input [7:0] sw_toggle,//toggle switch, sw7 ~ sw0
	input sw_en,//enable, sw8
	output [2:0] led_outputs,//LED Outputs, led2 ~ led0
	output led_indicator, //LED output indication, led4
	output [7:0] seg0, //Display 0
	output [7:0] seg1, //Display 1
	output [7:0] seg2, //Display 2
	output [7:0] seg3, //Display 3
	output [7:0] seg4, //Display 4
	output [7:0] seg5, //Display 5
	output [7:0] seg6, //Display 6
	output [7:0] seg7 //Display 7
);

	//8 to 3 priority encoder
	encoder_priority#(8, 3) encoder_8to3_priority(
		.a(sw_toggle),
		.en(sw_en),
		.y(led_outputs)
	);

	//LED indicator
	assign led_indicator = | sw_toggle;

	//Display 0
	wire [3:0] binary = {1'b0, led_outputs};

	segments_x7_display instance0(
		.binary(binary),
		.seg(seg0)
	);
	
	//Display 1
	segments_x7_display instance1(
		.binary(4'b1111),
		.seg(seg1)
	);

	//Display2
	segments_x7_display instance2(
		.binary(4'b1111),
		.seg(seg2)
	);

	//Display 3
	segments_x7_display instance3(
		.binary(4'b1111),
		.seg(seg3)
	);

	//Display 4
	segments_x7_display instance4(
		.binary(4'b1111),
		.seg(seg4)
	);

	//Display 5
	segments_x7_display instance5(
		.binary(4'b1111),
		.seg(seg5)
	);

	//Display 6
	segments_x7_display instance6(
		.binary(4'b1111),
		.seg(seg6)
	);

	//Display 7
	segments_x7_display instance7(
		.binary(4'b1111),
		.seg(seg7)
	);

endmodule
