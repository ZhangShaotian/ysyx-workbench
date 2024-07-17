module top_timer_display(
	input clk,
	input sw0_start,//sw0
	input rst,//sw1
	output [7:0] seg0, //Display 0
        output [7:0] seg1, //Display 1
        output [7:0] seg2, //Display 2
        output [7:0] seg3, //Display 3
        output [7:0] seg4, //Display 4
        output [7:0] seg5, //Display 5
        output [7:0] seg6, //Display 6
        output [7:0] seg7 //Display 7
);
	//Enable timer on display0 and display1
	timer_display myTimer(
		.clk(clk),
		.start(sw0_start),
		.rst(rst),
		.seg0(seg0),
		.seg1(seg1)
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
