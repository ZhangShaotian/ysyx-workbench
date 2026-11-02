// Little-endian data RAM: asynchronous read, synchronous byte-enabled write.
module ysyx_data_mem #(
    parameter DATA_W = 32, DEPTH = 131072,
    parameter HEX_FILE = "hex/program_addi_jalr_lui.hex"
)(
    input logic clk, rstn, valid, wr_en, byte_access,
    input logic [31:0] base_addr, addr,
    input logic [DATA_W-1:0] wdata,
    output logic [DATA_W-1:0] rdata
);
    logic [DATA_W-1:0] mem [0:DEPTH-1];
    wire [31:0] word_idx = (addr - base_addr) >> 2;
    wire in_range = addr >= base_addr && word_idx < DEPTH;
    wire [1:0] lane = addr[1:0];
    wire [3:0] wstrb = byte_access ? (4'b0001 << lane) : 4'b1111;
    wire [31:0] store_data = byte_access ? ({24'b0, wdata[7:0]} << {lane, 3'b000}) : wdata;
    wire [31:0] word_data = valid && in_range ? mem[word_idx[$clog2(DEPTH)-1:0]] : 32'b0;
    assign rdata = byte_access ? {24'b0, word_data[8*lane +: 8]} : word_data;

    initial begin : load_image
        string image_path;
        integer image_fd;
        if (!$value$plusargs("hex=%s", image_path)) image_path = HEX_FILE;
        image_fd = $fopen(image_path, "r");
        if (image_fd == 0) $fatal(1, "Cannot open HEX file: %s", image_path);
        $fclose(image_fd);
        for (integer i = 0; i < DEPTH; i = i + 1) mem[i] = 0;
        $display("[RAM] Loading %s", image_path);
        $readmemh(image_path, mem);
    end
    always @(posedge clk) begin
        if (rstn && valid) begin
            if (!in_range) $fatal(1, "Data address out of range: %08x", addr);
            else if (!byte_access && lane != 0) $fatal(1, "Unaligned word access: %08x", addr);
            else if (wr_en) begin
                for (integer b = 0; b < 4; b = b + 1)
                    if (wstrb[b]) mem[word_idx[$clog2(DEPTH)-1:0]][8*b +: 8] <= store_data[8*b +: 8];
            end
        end
    end
endmodule
