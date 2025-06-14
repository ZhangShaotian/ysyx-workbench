module ysyx_24080034_RegisterFile_1r1w #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
    input clk,                          // Clock signal
    input  [DATA_WIDTH-1:0] wdata,      // Write data input
    input  [ADDR_WIDTH-1:0] waddr,      // Write address input
    input  [ADDR_WIDTH-1:0] raddr,      // Read address input
    output [DATA_WIDTH-1:0] rdata,      // Read data output
    input wen                           // Write enable signal
);
    
    // Register file storage
    reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
    
    // Synchronous write operation
    always @(posedge clk) begin
        if (wen && waddr != 0) rf[waddr] <= wdata; // Prevent writes to register 0
    end

    //Combinational Read
    assign rdata = (raddr == 0) ? 0 : rf[raddr]; // Ensure register 0 always outputs 0

endmodule
