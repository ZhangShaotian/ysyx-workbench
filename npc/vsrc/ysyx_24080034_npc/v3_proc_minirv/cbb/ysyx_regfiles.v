// Two asynchronous read ports share one register array; writes are synchronous.
module ysyx_RegisterFile_2r1w #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clk, rstn,
    input [DATA_WIDTH-1:0] wdata,
    input [ADDR_WIDTH-1:0] waddr, raddr1, raddr2,
    output [DATA_WIDTH-1:0] rdata1, rdata2,
    input wen,
    output wire [DATA_WIDTH-1:0] debug_regs [0:2**ADDR_WIDTH-1]
);
    reg [DATA_WIDTH-1:0] rf [0:2**ADDR_WIDTH-1];
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (integer i = 0; i < 2**ADDR_WIDTH; i = i + 1) rf[i] <= 0;
        end else if (wen && waddr != 0) rf[waddr] <= wdata;
    end
    assign rdata1 = raddr1 == 0 ? 0 : rf[raddr1];
    assign rdata2 = raddr2 == 0 ? 0 : rf[raddr2];
    for (genvar i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin : debug_ports
        assign debug_regs[i] = i == 0 ? 0 : rf[i];
    end
endmodule
