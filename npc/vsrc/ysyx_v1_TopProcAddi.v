module ysyx_24080034_TopProcAddi(
    input clk,
    input rst
);

// -----------------------------------------------------------------------------
// [EBREAK Handling via DPI-C]
// Detects the EBREAK instruction in fetch stage and invokes a C-side DPI-C 
// function `sim_exit()` to terminate simulation gracefully.
// This allows test programs to self-terminate without external intervention.
// -----------------------------------------------------------------------------
import "DPI-C" function void sim_exit();

wire is_ebreak = imemreq_data == 32'h00100073;

always @(posedge clk) begin
    if (is_ebreak) begin
        $display("[DPI-C] ebreak detected, exiting simulation...");
        sim_exit();  
    end
end

// -----------------------------------------------------------------------------
// [PC Register & PC + 4 Logic]
// Program counter starts at 0x80000000 and increments by 4 every cycle.
// -----------------------------------------------------------------------------
wire [31:0] pc_in;
wire [31:0] pc_out;

ysyx_24080034_EnResetReg#(32, 32'h80000000) pc(
    .clk(clk),
    .rst(rst),
    .d(pc_in),
    .q(pc_out),
    .en(1)
);

ysyx_24080034_Incrementer#(32, 4) pc_plus_4(
    .in(pc_out),
    .out(pc_in)
);

// -----------------------------------------------------------------------------
// [Instruction Memory Initialization]
// Loads instructions from a HEX file into imem at time 0.
// Modify the filename to switch test programs.
// -----------------------------------------------------------------------------
initial begin
    // Load instruction memory from a hex file into imem
    // NOTE: Replace "hex/xxxxx.hex" with the appropriate file for your current test
    // Examples:
    // - hex/program.hex        // Basic test: addi x1, x0, 1; addi x2, x1, 2
    // - hex/program_ebreak.hex // Init x0–x31 to 0–31 with ADDI, ends with ebreak for auto-stop
    $readmemh("hex/program_ebreak.hex", imem);
end

// -----------------------------------------------------------------------------
// [Instruction Fetch Logic]
// Maps PC to instruction memory index (256-entry ROM), fetches 32-bit instruction.
// -----------------------------------------------------------------------------
reg  [31:0] imem [0:255];
wire [31:0] imemreq_data;

// Suppress Verilator warning for unused upper bits of imemreq_addr
// Only the lower 8 bits are currently used for addressing 256-entry `imem`
// verilator lint_off UNUSED
wire [31:0] imemreq_addr;
// verilator lint_on UNUSED

assign imemreq_addr = (pc_out - 32'h80000000) >> 2;

assign imemreq_data = imem[imemreq_addr];

// -----------------------------------------------------------------------------
// [Instruction Decode: ADDI Detection]
// Decodes whether current instruction is an ADDI. Enables write-back if true.
// -----------------------------------------------------------------------------
wire [31:0] alu0, alu1, alu_out;
wire wen;

assign wen = (imemreq_data[6:0] == 7'b0010011) &&  // OPCODE
							(imemreq_data[14:12] == 3'b000);       // func3

// -----------------------------------------------------------------------------
// [Register File]
// 1R1W register file: read rs1, write rd (if ADDI)
// -----------------------------------------------------------------------------
ysyx_24080034_RegisterFile_1r1w#(5, 32) RegFile(
    .clk(clk),
    .raddr(imemreq_data[19:15]),
    .rdata(alu0),
    .waddr(imemreq_data[11:7]),
    .wdata(alu_out),
    .wen(wen)
);

// -----------------------------------------------------------------------------
// [Immediate Generator]
// Extracts immediate value for ADDI instruction
// -----------------------------------------------------------------------------
ysyx_24080034_ImmGen imm(
		.imm_in(imemreq_data),
		.imm_type(imemreq_data[14:12]),
		.imm_out(alu1)
);

// -----------------------------------------------------------------------------
// [ALU]
// Performs rd = rs1 + imm for ADDI
// -----------------------------------------------------------------------------
ysyx_24080034_alu alu(
		.in0(alu0),
		.in1(alu1),
		.fn(4'b0000),
		.out(alu_out)
);

endmodule
