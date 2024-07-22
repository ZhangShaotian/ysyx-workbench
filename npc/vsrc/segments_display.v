//========================================
//Verilog Components: Segments Display
//=======================================



//-----------------------------------------
//Module: SevenSegmentDisplay
//Description: This module interfaces with a seven-segment common anode LED 
//              display on the DE10-Standard development board. Each segment 
//              of the display is connected to a specific pin on the Cyclone V 
//              SoC FPGA. Driving a logic low (0) on a segment pin will turn on 
//              that segment.
//
//Connections:
//   seg[7:0] - Pins connected to the segments of the seven-segment display
//   seg[0] - Segment 0
//   seg[1] - Segment 1
//   seg[2] - Segment 2
//   seg[3] - Segment 3
//   seg[4] - Segment 4
//   seg[5] - Segment 5
//   seg[6] - Segment 6
//   DP - Decimal Point (if used)
//
// Notes:
//   - This module assumes a common anode configuration where a logic low (0)
//     will turn on the segment and a logic high (1) will turn off the segment.
//   - The mapping of segments to FPGA pins should match the schematic shown
//     in the DE10-Standard documentation.
// 
// Schematic representation of the seven-segment display:
//
//         7
//       ------
//      |      |
//    2 |      | 6
//      |  1   |
//       ------
//      |      |
//    3 |      | 5
//      |      |
//       ------'. 0
//         4
//------------------------------------------

module segments_x7_display(
	input [3:0] binary,
	output reg [7:0] seg
);
	always@(*) begin
		seg = 8'b11111111;  // Initialization
		case(binary)
		4'b0000: seg = 8'b00000010;//0
		4'b0001: seg = 8'b10011110;//1
		4'b0010: seg = 8'b00100100;//2
		4'b0011: seg = 8'b00001100;//3
		4'b0100: seg = 8'b10011000;//4
		4'b0101: seg = 8'b01001000;//5
		4'b0110: seg = 8'b01000000;//6
		4'b0111: seg = 8'b00011110;//7
		4'b1000: seg = 8'b00000000;//8
		4'b1001: seg = 8'b00001000;//9
		default: seg = 8'b11111111;//Default: disenable all pins
		endcase
	end
endmodule


//-----------------------------------------------------
// Able to display hex numbers
//----------------------------------------------------
module segments_x7_display_hex(
	input [3:0] binary,
	output reg [7:0] seg
);
	always@(*) begin
		seg = 8'b11111111;  // Initialization
		case(binary)
		4'b0000: seg = 8'b00000010;//0
		4'b0001: seg = 8'b10011110;//1
		4'b0010: seg = 8'b00100100;//2
		4'b0011: seg = 8'b00001100;//3
		4'b0100: seg = 8'b10011000;//4
		4'b0101: seg = 8'b01001000;//5
		4'b0110: seg = 8'b01000000;//6
		4'b0111: seg = 8'b00011110;//7
		4'b1000: seg = 8'b00000000;//8
		4'b1001: seg = 8'b00001000;//9
		4'b1010: seg = 8'b00010000;//A
		4'b1011: seg = 8'b11000000;//b
		4'b1100: seg = 8'b01100010;//C
		4'b1101: seg = 8'b10000100;//d
		4'b1110: seg = 8'b01100000;//E
		4'b1111: seg = 8'b01110000;//F
		default: seg = 8'b11111111;//Default: disenable all pins
		endcase
	end
endmodule

