//==========================================================
// Module: FIFO
//==========================================================



//---------------------------------------------------------
// Synchronous FIFO
//----------------------------------------------------------
module sync_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 16
)
(
  input clk,
  input rst_n,
  input [DATA_WIDTH-1:0] din,
  output [DATA_WIDTH-1:0] dout,
  input wr_en,
  input rd_en,
  output empty,
  output full
);
  // Memory Array
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Write pointer and read pointer
  reg [$clog2(DEPTH)-1:0] wr_ptr = 0;
  reg [$clog2(DEPTH)-1:0] rd_ptr = 0;

  // Counter
  reg [$clog2(DEPTH+1)-1:0] counter = 0;
  
  // Write Operation
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      wr_ptr <= 0;
    end else if(!full && wr_en)begin
      wr_ptr <= wr_ptr + 1;
      mem[wr_ptr] <= din;
    end else begin
      wr_ptr <= wr_ptr;
    end
  end
  
  // Read Operation
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      rd_ptr <= 0;
    end else if(rd_en && !empty) begin
      rd_ptr <= rd_ptr + 1;
    end else begin
      rd_ptr <= rd_ptr;
    end
  end

  // Data Out
  assign dout = mem[rd_ptr];

  // Counter Management
  always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
      counter <= 0;
    end else begin
      case({wr_en && !full, rd_en && !empty})
        2'b10: counter <= counter + 1;
        2'b01: counter <= counter - 1;
        default: counter <= counter;
      endcase
    end
  end

  // Full sign and Empty sign
  assign full = (counter==DEPTH);
  assign empty = (counter==0);

endmodule

