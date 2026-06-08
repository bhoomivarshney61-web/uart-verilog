module uart_rx(
  input clk,
  input rst,
  input rx,
  output reg [7:0] data_out,
  output reg data_ready
);

  parameter CLKS_PER_BIT = 5208;
  parameter HALF_BIT     = 2604;

  parameter IDLE      = 2'b00;
  parameter START_BIT = 2'b01;
  parameter DATA_BITS = 2'b10;
  parameter STOP_BIT  = 2'b11;

  reg [1:0]  state     = IDLE;
  reg [12:0] clk_count = 0;
  reg [2:0]  bit_index = 0;
  reg [7:0]  data_reg  = 0;

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      state      <= IDLE;
      clk_count  <= 0;
      bit_index  <= 0;
      data_out   <= 0;
      data_ready <= 0;
    end
    else begin
      case(state)

        IDLE: begin
          data_ready <= 0;
          clk_count  <= 0;
          bit_index  <= 0;
          if(rx == 0) begin        // detected LOW — start bit arriving
            state <= START_BIT;
          end
        end

        START_BIT: begin
          if(clk_count == HALF_BIT - 1) begin   // wait to middle of start bit
            if(rx == 0) begin      // confirm still LOW — valid start bit
              clk_count <= 0;
              state     <= DATA_BITS;
            end
            else begin
              state <= IDLE;       // false alarm — go back
            end
          end
          else clk_count <= clk_count + 1;
        end

        DATA_BITS: begin
          if(clk_count == CLKS_PER_BIT - 1) begin   // wait full bit period
            clk_count          <= 0;
            data_reg[bit_index] <= rx;               // sample the bit
            if(bit_index == 7) begin
              bit_index <= 0;
              state     <= STOP_BIT;
            end
            else bit_index <= bit_index + 1;
          end
          else clk_count <= clk_count + 1;
        end

        STOP_BIT: begin
          if(clk_count == CLKS_PER_BIT - 1) begin
            clk_count  <= 0;
            data_out   <= data_reg;   // output the received byte
            data_ready <= 1;          // signal data is ready
            state      <= IDLE;
          end
          else clk_count <= clk_count + 1;
        end

      endcase
    end
  end

endmodule
