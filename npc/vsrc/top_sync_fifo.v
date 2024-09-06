module top_sync_fifo(
  input clk,
  input button_clk, // BTNC
  input rst,// SW14
  input [7:0] din,// SW0-SW7
  output [7:0] dout,// LD0-LD7
  input wr_en, //SW12
  input rd_en, //SW13
  output empty, //LD14
  output full //LD15
);
  sync_fifo myFifo(
    .clk(button_clk),
    .rst_n(rst),
    .din(din),
    .dout(dout),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .empty(empty),
    .full(full)
  );
endmodule
