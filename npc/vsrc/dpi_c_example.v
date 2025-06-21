// ===============================================================
// Module: dpi_c_example
// Description: 
//   This is a simple Verilog module for testing the DPI-C mechanism,
//   as part of the C2 stage task "尝试DPI-C机制".
//   It imports a C function `add(int a, int b)` using DPI-C and
//   calls it inside an initial block to verify integration.
// ===============================================================

module dpi_c_example();

  import "DPI-C" function int add(input int a, input int b);

  initial begin
    int result;
    result = add(1, 2);
    $display("%0d + %0d = %0d", 1, 2, result);
    $finish;
  end

endmodule
