module tb_uart_rx;
  reg clk = 0;
  reg rst = 1;
  reg rx  = 1;
  wire [7:0] data_out;
  wire data_ready;

  uart_rx uut(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .data_out(data_out),
    .data_ready(data_ready)
  );

  always #10 clk = ~clk;

  integer i;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_rx);

    #100 rst = 0;
    #200;

    // Send START bit
    rx = 0;
    repeat(5208) @(posedge clk);

    // Send 8 data bits of 8'h41 = 01000001
    // LSB first: 1,0,0,0,0,0,1,0
    rx = 1; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);
    rx = 1; repeat(5208) @(posedge clk);
    rx = 0; repeat(5208) @(posedge clk);

    // Send STOP bit
    rx = 1;
    repeat(5208) @(posedge clk);

    // Wait for data_ready
    repeat(10) @(posedge clk);

    $display("Received data: %h", data_out);

    if(data_out == 8'h41)
      $display("SUCCESS! Received A correctly");
    else
      $display("ERROR! Data mismatch");

    #1000;
    $finish;
  end

endmodule
