module ysyx_24080034_ImmGen(
	input  wire [31:0] imm_in,   // 32-bit instruction
    input  wire [ 2:0] imm_type, // Immediate type selector
	output wire [31:0] imm_out   // 32-bit sign-extended immediate output
);
	
	assign imm_out = (imm_type == 3'd0) ? {{20{imm_in[31]}}, imm_in[31:20]} // Type_I immediate
                     : 32'b0; // Default case: return 0

	// Disable unused signal warning for this wire
	// verilator lint_off UNUSED
    wire [19:0] _unused = imm_in[19:0];
	// verilator lint_on UNUSED

endmodule
