// Separate instruction ROM, using the same initialized image as the data RAM.
module ysyx_inst_mem #(
    parameter ADDR_W = 32, DATA_W = 32, DEPTH = 131072,
    parameter HEX_FILE = "hex/program_addi_jalr_lui.hex"
)(
    input logic clk, rstn,
    input logic [ADDR_W-1:0] base_addr, pc,
    output logic [DATA_W-1:0] inst
);
    logic [DATA_W-1:0] mem [0:DEPTH-1];
    wire [ADDR_W-1:0] word_idx = (pc - base_addr) >> 2;
    wire in_range = pc >= base_addr && word_idx < DEPTH;
    initial begin : load_image
        string image_path;
        integer image_fd;
        logic [31:0] halt_addr, image_base, halt_index;
        if (!$value$plusargs("hex=%s", image_path)) image_path = HEX_FILE;
        image_fd = $fopen(image_path, "r");
        if (image_fd == 0) $fatal(1, "Cannot open HEX file: %s", image_path);
        $fclose(image_fd);
        // Unfilled locations behave as NOPs; range checks prevent address aliasing.
        for (integer i = 0; i < DEPTH; i = i + 1) mem[i] = 32'h00000013;
        $display("[ROM] Loading %s", image_path);
        $readmemh(image_path, mem);
        // Patch instruction ROM only, after image loading and before execution.
        if ($value$plusargs("halt=%h", halt_addr)) begin
            if (!$value$plusargs("base=%h", image_base)) image_base = 32'h80000000;
            halt_index = (halt_addr - image_base) >> 2;
            if (halt_addr < image_base || halt_index >= DEPTH || halt_addr[1:0] != 0)
                $fatal(1, "Invalid halt address: %08x", halt_addr);
            mem[halt_index[$clog2(DEPTH)-1:0]] = 32'h00100073;
            $display("[HALT] Patched instruction ROM at %08x with EBREAK", halt_addr);
        end
    end
    assign inst = in_range ? mem[word_idx[$clog2(DEPTH)-1:0]] : 32'h00000013;
    always @(posedge clk) begin
        if (rstn && (!in_range || pc[1:0] != 0))
            $fatal(1, "Invalid instruction address: %08x", pc);
    end
endmodule
