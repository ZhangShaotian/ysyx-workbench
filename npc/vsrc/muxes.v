//==========================
//Verilog Components: Muxes
//==========================

//--------------------------
//2 to 1 1-bit mux
//--------------------------
module mux_2x1_1bit(
	input a,
	input b,
	input sel,
	output y
);

assign y = (~sel&a)|(sel&b);

endmodule



//--------------------------
//4 to 1 1-bit mux
//-------------------------
module mux_4x1_1bit(
	input [3:0] a,
	input [1:0] sel,
	output reg  y
);
	always@(*) begin
		case(sel)
		2'b00: y = a[0];
		2'b01: y = a[1];
		2'b10: y = a[2];
		2'b11: y = a[3];
		default: y = 1'b0;
		endcase
	end
endmodule



//--------------------------
//Multiplexer Template
//--------------------------
//Usage, example:
//--------------------------
//2 to 1 1bit mux
//-------------------------
//module mux21e(a,b,s,y);
//  input   a,b,s;
//  output  y;
//  MuxKey #(2, 1, 1) i0 (y, s, {
//    1'b0, a,
//    1'b1, b
//  });
//endmodule
//
//-------------------------
//4 to 1 1bit mux
//------------------------
//module mux41b(a,s,y);
//  input  [3:0] a;
//  input  [1:0] s;
//  output y;
//  MuxKeyWithDefault #(4, 2, 1) i0 (y, s, 1'b0, {
//    2'b00, a[0],
//    2'b01, a[1],
//    2'b10, a[2],
//    2'b11, a[3]
//  });
//endmodule

module MuxKeyInternal 
#(
  parameter NR_KEY = 2, 
  parameter KEY_LEN = 1, 
  parameter DATA_LEN = 1, 
  parameter HAS_DEFAULT = 0
) 
(
  output reg [DATA_LEN-1:0] out,
  input [KEY_LEN-1:0] key,
  input [DATA_LEN-1:0] default_out,
  input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);

  localparam PAIR_LEN = KEY_LEN + DATA_LEN;
  wire [PAIR_LEN-1:0] pair_list [NR_KEY-1:0];
  wire [KEY_LEN-1:0] key_list [NR_KEY-1:0];
  wire [DATA_LEN-1:0] data_list [NR_KEY-1:0];

  generate
    genvar n;
    for (n = 0; n < NR_KEY; n = n + 1) begin
      assign pair_list[n] = lut[PAIR_LEN*(n+1)-1 : PAIR_LEN*n];
      assign data_list[n] = pair_list[n][DATA_LEN-1:0];
      assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
    end
  endgenerate

  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;
  integer i;
  always @(*) begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
      hit = hit | (key == key_list[i]);
    end
    if (!HAS_DEFAULT) out = lut_out;
    else out = (hit ? lut_out : default_out);
  end

endmodule

module MuxKey 
#(
  parameter NR_KEY = 2, 
  parameter KEY_LEN = 1, 
  parameter DATA_LEN = 1
) 
(
  output [DATA_LEN-1:0] out,
  input [KEY_LEN-1:0] key,
  input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);
  MuxKeyInternal #(NR_KEY, KEY_LEN, DATA_LEN, 0) i0 (out, key, {DATA_LEN{1'b0}}, lut);
endmodule

module MuxKeyWithDefault 
#(
  parameter NR_KEY = 2, 
  parameter KEY_LEN = 1, 
  parameter DATA_LEN = 1
) 
(
  output [DATA_LEN-1:0] out,
  input [KEY_LEN-1:0] key,
  input [DATA_LEN-1:0] default_out,
  input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);
  MuxKeyInternal #(NR_KEY, KEY_LEN, DATA_LEN, 1) i0 (out, key, default_out, lut);
endmodule



// -----------------------------------
// 4 to 1 2-bit mux
// ----------------------------------

module mux_4x1_2bit(
	input [7:0] a,
        input [1:0] sel,
        output [1:0] y
);
	MuxKeyWithDefault #(4, 2, 2) i0 (y, sel, 2'b0, {
	2'b00, {a[1], a[0]},
	2'b01, {a[3], a[2]},
	2'b10, {a[5], a[4]},
	2'b11, {a[7], a[6]}
	});

endmodule



