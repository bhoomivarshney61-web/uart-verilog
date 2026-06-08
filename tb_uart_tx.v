module tb_uart_tx;
  reg clk = 0;
  reg rst = 1;
  reg start = 0;
  reg [7:0] data_in = 0;
  wire tx;
  wire busy;

  uart_tx uut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .tx(tx),
    .busy(busy)
  );

  always #10 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_tx);

    #100 rst = 0;

    #100;
    data_in = 8'h41;  // ASCII 'A' = 01000001
    start = 1;
    #20;
    start = 0;

    @(negedge busy);
    $display("Transmission complete! Sent letter A");

    #1000;
    $finish;
  end

endmodule
