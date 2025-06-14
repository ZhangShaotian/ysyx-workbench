module ysyx_24080034_TopProcAddi(
    input clk,
    input rst
);

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

initial begin
    $readmemh("hex/program.hex", imem);
end

reg  [31:0] imem [0:255];

wire [31:0] imemreq_data;

// Suppress Verilator warning for unused upper bits of imemreq_addr
// Only the lower 8 bits are currently used for addressing 256-entry `imem`
// verilator lint_on UNUSED
wire [31:0] imemreq_addr;
// verilator lint_on UNUSED

assign imemreq_addr = (pc_out - 32'h80000000) >> 2;

assign imemreq_data = imem[imemreq_addr];

wire [31:0] alu0, alu1, alu_out;
wire wen;

assign wen = (imemreq_data[6:0] == 7'b0010011) &&  // OPCODE
							(imemreq_data[14:12] == 3'b000);       // func3

ysyx_24080034_RegisterFile_1r1w#(5, 32) RegFile(
    .clk(clk),
    .raddr(imemreq_data[19:15]),
    .rdata(alu0),
    .waddr(imemreq_data[11:7]),
    .wdata(alu_out),
    .wen(wen)
);

ysyx_24080034_ImmGen imm(
		.imm_in(imemreq_data),
		.imm_type(imemreq_data[14:12]),
		.imm_out(alu1)
);

ysyx_24080034_alu alu(
		.in0(alu0),
		.in1(alu1),
		.fn(4'b0000),
		.out(alu_out)
);

endmodule
