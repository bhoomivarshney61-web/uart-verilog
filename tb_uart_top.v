module tb_uart_top;
  reg clk = 0;
  reg rst = 1;
  reg start = 0;
  reg [7:0] data_in = 0;
  wire [7:0] data_out;
  wire data_ready;
  wire busy;

  uart_top uut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .data_out(data_out),
    .data_ready(data_ready),
    .busy(busy)
  );

  always #10 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_top);

    #100 rst = 0;
    #200;

    // Send letter A
    data_in = 8'h41;
    start   = 1;
    #20;
    start   = 0;

    // Wait for RX to receive
    @(posedge data_ready);

    $display("Sent:     %h", 8'h41);
    $display("Received: %h", data_out);

    if(data_out == 8'h41)
      $display("LOOPBACK TEST PASSED! TX and RX matched");
    else
      $display("LOOPBACK TEST FAILED! Data mismatch");

    #1000;
    $finish;
  end

endmodule
