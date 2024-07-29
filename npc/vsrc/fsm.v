//=======================================================
//Verilog Component: FSM
//=======================================================



//--------------------------------------------------------
//Sequence Detector Moore FSM
//- This module implements a Moore finite state machine (FSM) with one input 'din' and one output 'dout'.
//- The FSM checks for four consecutive '0's or four consecutive '1's in the input sequence.
//- When either condition is met, the output 'z' is set to 1. Otherwise, 'z' is set to 0.
//- The FSM supports overlapping sequences.
//--------------------------------------------------------
module sequenceDetectorMooreFSM(
	input clk,
	input rst,
	input din,
	output dout
);
	parameter [3:0] S0=0, S1=1, S2=2, S3=3, S4=4,
	       	S5=5, S6=6, S7=7, S8=8;
	
	wire [3:0] state_curr;
	wire [3:0] state_next;
	
	//Change current state to next state
	simpleReg
	#(
		.nbit(4)
	)
	myReg(
		.clk(clk),
		.rst(rst),
		.din(state_next),
		.dout(state_curr)
	);	

	//Generate FSM Output based on current state
	MuxKeyWithDefault#(9, 4, 1) myMux0(
		.out(dout),
		.key(state_curr),
		.default_out(0),
		.lut({
			S0, 1'b0,
			S1, 1'b0,
			S2, 1'b0,
			S3, 1'b0,
			S4, 1'b1,
			S5, 1'b0,
			S6, 1'b0,
			S7, 1'b0,
			S8, 1'b1
		})
	);

	//Generate next state based on the current state and input
	MuxKeyWithDefault#(9, 4, 4) myMux1(
		.out(state_next),
		.key(state_curr),
		.default_out(S0),
		.lut({
			S0, din ? S5:S1,
			S1, din ? S5:S2,
			S2, din ? S5:S3,
			S3, din ? S5:S4,
			S4, din ? S5:S4,
			S5, din ? S6:S1,
			S6, din ? S7:S1,
			S7, din ? S8:S1,
			S8, din ? S8:S1
		})
	);	
endmodule



//------------------------------------------------------------
//Sequence Detector Mealy FSM
//- This module implements a Mealy finite state machine (FSM) with one input 'din' and one output 'dout'.
//- The FSM checks for four consecutive '0's or four consecutive '1's in the input sequence.
//- When either condition is met, the output 'z' is set to 1. Otherwise, 'z' is set to 0.
//- The FSM supports overlapping sequences.
//------------------------------------------------------------
module sequenceDetectorMealyFSM(
	input clk,
	input rst,
	input din,
	output dout
);
	parameter [2:0] IDLE = 0,
			S0   = 1,
			S00  = 2,
			S000 = 3,
			S1   = 4,
			S11  = 5,
			S111 = 6;

	wire [2:0] state_curr;
	wire [2:0] state_next;

	//Change current state to next state
	simpleReg
	#(
		.nbit(3)
	)
	myReg(
		.clk(clk),
		.rst(rst),
		.din(state_next),
		.dout(state_curr)
	);	
	
//	//Generate output based on the current state and input
//	always@(*) begin
//		case(state_curr)
//			IDLE: dout = 0;
//			S0:   dout = 0;
//			S00:  dout = 0;
//			S000: dout = din ? 0:1;
//			S1:   dout = 0;
//			S11:  dout = 0;
//			S111: dout = din ? 1:0;
//			default: dout = 0;
//		endcase
//	end
//
//	//Generate next state based on the current state and input
//	always@(*) begin
//		case(state_curr)
//			IDLE: state_next = din ? S1:S0;
//			S0:   state_next = din ? S1:S00;
//			S00:  state_next = din ? S1:S000;
//			S000: state_next = din ? S1:S000;
//			S1:   state_next = din ? S11:S0;
//			S11:  state_next = din ? S111:S0;
//			S111: state_next = din ? S111:S0;
//			default: state_next = IDLE;
//		endcase
//	end

	//Generate FSM Output based on current state
	MuxKeyWithDefault#(7, 3, 1) myMux0(
		.out(dout),
		.key(state_curr),
		.default_out(0),
		.lut({
			IDLE, din ? 1'b0:1'b0,
			S0,   din ? 1'b0:1'b0,
			S00,  din ? 1'b0:1'b0,
			S000, din ? 1'b0:1'b1,
			S1,   din ? 1'b0:1'b0,
			S11,  din ? 1'b0:1'b0,
			S111, din ? 1'b1:1'b0
		})
	);

	//Generate next state based on the current state and input
	MuxKeyWithDefault#(7, 3, 3) myMux1(
		.out(state_next),
		.key(state_curr),
		.default_out(IDLE),
		.lut({
			IDLE, din ? S1:S0,
			S0,   din ? S1:S00,
			S00,  din ? S1:S000,
			S000, din ? S1:S000,
			S1,   din ? S11:S0,
			S11,  din ? S111:S0,
			S111, din ? S111:S0
		})
	);	

endmodule



