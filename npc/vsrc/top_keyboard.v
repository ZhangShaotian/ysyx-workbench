module top_keyboard(
	input clk,
	input rst, //Negative reset
	input ps2_data,
	input ps2_clk,
	output [7:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7
);
	reg nextdata_n;
	wire [7:0] scan_code;
	reg ready;
	reg overflow;

	ps2_keyboard myKeyboard(
		.clk(clk),
		.clrn(rst),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
		.nextdata_n(nextdata_n),
		.data(scan_code),
		.ready(ready),
		.overflow(overflow)	
	);

	wire [7:0] ascii_code;
	wire [7:0] scan_code;
	
	scan_to_ascii instance0(
		.scan_code(scan_code),
		.ascii_code(ascii_code)
	);

	parameter IDLE = 2'b00, KEY_PRESSED = 2'b01, KEY_RELEASED = 2'b10;
	reg [1:0] state_curr, state_next;
	reg [7:0] key_count; // Count total key presses (0-99)
	reg [4:0] seg7_code, seg6_code, seg5_code, seg4_code, seg3_code, seg2_code, seg1_code, seg0_code;

	// State register
	always @(posedge clk) begin
        	if (!rst) begin
            		state_curr <= IDLE;
			key_count <= 0;
        	end 
		else begin
            		state_curr <= state_next;
			if (ready && scan_code == 8'hf0) begin
           			 key_count <= key_count + 1; 
        		end
		end
    	end

	// next state logic
	always @(*) begin
		if (ready) begin
			case (state_curr)
			    IDLE: begin
				if (ready) begin
				    state_next = KEY_PRESSED;
				    nextdata_n = 0;
				end else begin
				    state_next = IDLE;
				end
			    end
			    KEY_PRESSED: begin
				if (scan_code == 8'hf0) begin
				    state_next = KEY_RELEASED;
				end else begin
				    state_next = KEY_PRESSED;
				    nextdata_n = 0;
				end
			    end
			    KEY_RELEASED: begin
				if (ready) begin
				    state_next = KEY_PRESSED;
				    nextdata_n = 0;
				end else begin
				    state_next = KEY_RELEASED;
				end
			    end
			    default: state_next = IDLE;
			endcase
			nextdata_n = 0;
		end
		else
			nextdata_n = 1;
	end

	reg [7:0] seg6_code_temp;
	reg [7:0] seg7_code_temp;

	// Output logic
	always@(*) begin
		if (ready) begin
			case(state_curr) 
				IDLE: begin
					seg0_code = 5'b11111;
					seg1_code = 5'b11111;
					seg2_code = 5'b11111;
					seg3_code = 5'b11111;
					seg4_code = 5'b11111;
					seg5_code = 5'b11111;
					seg6_code_temp = 8'b11111111;
					seg7_code_temp = 8'b11111111;
				end
				KEY_PRESSED: begin
					seg0_code = {1'b0, scan_code[3:0]};
					seg1_code = {1'b0, scan_code[7:4]};
					seg2_code = {1'b0, ascii_code[3:0]};
					seg3_code = {1'b0, ascii_code[7:4]};
					seg4_code = 5'b11111;
					seg5_code = 5'b11111;
					seg6_code_temp = key_count % 10;
					seg7_code_temp = (key_count / 10) % 10;

				end
				KEY_RELEASED: begin
					seg0_code = 5'b11111;
                                        seg1_code = 5'b11111;
                                        seg2_code = 5'b11111;
                                        seg3_code = 5'b11111;
                                        seg4_code = 5'b11111;
                                        seg5_code = 5'b11111;
					seg6_code_temp = key_count % 10;
					seg7_code_temp = (key_count / 10) % 10;
				end
				default: begin
					seg0_code = 5'b11111;
                                        seg1_code = 5'b11111;
                                        seg2_code = 5'b11111;
                                        seg3_code = 5'b11111;
                                        seg4_code = 5'b11111;
                                        seg5_code = 5'b11111;
                                        seg6_code_temp = 8'b11111111;
                                        seg7_code_temp = 8'b11111111;
				end
			endcase
		end
	end
	
	assign seg6_code = seg6_code_temp[4:0];
	assign seg7_code = seg7_code_temp[4:0];

	// Instantiate segments display module
	light mySeg0(.binary(seg0_code), .seg(seg0));
	light mySeg1(.binary(seg1_code), .seg(seg1));
	light mySeg2(.binary(seg2_code), .seg(seg2));
	light mySeg3(.binary(seg3_code), .seg(seg3));
	light mySeg4(.binary(seg4_code), .seg(seg4));
	light mySeg5(.binary(seg5_code), .seg(seg5));
	light mySeg6(.binary(seg6_code), .seg(seg6));
	light mySeg7(.binary(seg7_code), .seg(seg7));



endmodule
