module dpi_c_example();

  import "DPI-C" function int add(input int a, input int b);

  initial begin
    int result;
    result = add(1, 2);
    $display("%0d + %0d = %0d", 1, 2, result);
    $finish;
  end

endmodule
