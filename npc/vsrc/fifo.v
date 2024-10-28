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



//--------------------------------------------------------------
// Asynchronous FIFO
//--------------------------------------------------------------
module async_fifo#
(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4 // FIFO Depth 2^ADDR_WIDTH
)
(
  input wr_en,
  input rd_en,
  input [DATA_WIDTH-1:0] wr_data,
  input wr_clk,
  input rd_clk,
  input rst_n,
  output full,
  output empty,
  output [DATA_WIDTH-1:0] rd_data
);
  reg [DATA_WIDTH-1:0] fifo_mem [0:(1<<ADDR_WIDTH)-1];
  reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
  reg [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray, wr_ptr_gray_rd_clk, rd_ptr_gray_wr_clk;

  // Write Logic
  always@(posedge wr_clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0;
      wr_ptr_gray <= 0;
    end else if(wr_en && !full) begin
      fifo_mem[wr_ptr] <= wr_data;
      wr_ptr <= wr_ptr + 1;
      wr_ptr_gray <= (wr_ptr+1)^((wr_ptr+1) >> 1);
    end
  end

  // Read Logic
  always@(posedge rd_clk or negedge rst) begin
    if(!rst_n)begin
      rd_ptr <= 0;
      rd_ptr_gray <= 0;
    end else if(rd_en && !empty) begin
      rd_ptr <= rd_ptr + 1;
      rd_ptr_gray <= (rd_ptr+1)^((rd_ptr+1) >> 1);
    end
  end

  // Synchronize wr_ptr to rd_clk, for 'full' signal
  always@(posedge rd_clk or negedge rst_n) begin
    if(!rst_n)begin
      wr_ptr_gray_rd_clk <= 0;
    end else begin
      wr_ptr_gray_rd_clk <= wr_ptr_gray; // Simple synchronization
    end
  end

  // Synchronize rd_ptr to wr_clk, for 'empty' signal
  always@(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
      rd_ptr_gray_wr_clk <= 0;
    end else begin
      rd_ptr_gray_wr_clk <= rd_ptr_gray;
    end
  end

  // Empty/Full detection
  assign empty = (wr_ptr_gray_rd_clk == rd_ptr_gray);
  assign full = (wr_ptr_gray[ADDR_WIDTH-1:0] == rd_ptr_gray_wr_clk[ADDR_WIDTH-1:0]) 
                  && (wr_ptr_gray[ADDR_WIDTH] != rd_ptr_gray_wr_clk[ADDR_WIDTH]);
  
  // Read output
  assign rd_data = fifo_mem[rd_ptr];

endmodule


















