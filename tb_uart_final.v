module tb_uart_final;
  reg clk = 0;
  reg rst = 1;
  reg start = 0;
  reg [7:0] data_in = 0;
  wire [7:0] data_out;
  wire data_ready;
  wire busy;

  integer pass_count = 0;
  integer fail_count = 0;

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

  // Task to send one byte and verify
  task send_and_verify;
    input [7:0] data;
    input [7:0] expected;
    begin
      // Send data
      data_in = data;
      start   = 1;
      repeat(2) @(posedge clk);
      start = 0;

      // Wait enough time for full transmission
      // 10 bits x 5208 clocks x 2 (TX+RX) = safe margin
      repeat(120000) @(posedge clk);

      // Check result
      if(data_out == expected) begin
        $display("PASS - Sent: %h  Received: %h", data, data_out);
        pass_count = pass_count + 1;
      end
      else begin
        $display("FAIL - Sent: %h  Received: %h", data, data_out);
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_final);

    #100 rst = 0;
    repeat(10) @(posedge clk);

    $display("=============================");
    $display("   UART FINAL TEST STARTING  ");
    $display("=============================");

    // Send U A R T
    send_and_verify(8'h55, 8'h55);  // U
    send_and_verify(8'h41, 8'h41);  // A
    send_and_verify(8'h52, 8'h52);  // R
    send_and_verify(8'h54, 8'h54);  // T

    $display("=============================");
    $display("PASSED: %0d / 4", pass_count);
    $display("FAILED: %0d / 4", fail_count);

    if(pass_count == 4)
      $display("PROJECT COMPLETE - ALL TESTS PASSED!");
    else
      $display("Some tests failed - check output above");

    $display("=============================");

    #1000;
    $finish;
  end

endmodule
