module baud_rate_gen(
  input clk,          // 50MHz clock
  input rst,          // reset
  output reg tick     // one pulse every bit period
);

  parameter CLKS_PER_BIT = 5208; // 50MHz / 9600 baud
  
  integer counter = 0;
  
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      counter <= 0;
      tick <= 0;
    end
    else if(counter == CLKS_PER_BIT - 1) begin
      counter <= 0;
      tick <= 1;  // pulse for one clock cycle
    end
    else begin
      counter <= counter + 1;
      tick <= 0;
    end
  end

endmodule
