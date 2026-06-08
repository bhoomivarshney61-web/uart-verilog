module uart_tx(
  input clk,
  input rst,
  input start,
  input [7:0] data_in,
  output reg tx,
  output reg busy
);

  parameter CLKS_PER_BIT = 5208;

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
      state     <= IDLE;
      tx        <= 1;
      busy      <= 0;
      clk_count <= 0;
      bit_index <= 0;
    end
    else begin
      case(state)

        IDLE: begin
          tx        <= 1;
          busy      <= 0;
          clk_count <= 0;
          bit_index <= 0;
          if(start) begin
            data_reg <= data_in;
            state    <= START_BIT;
            busy     <= 1;
          end
        end

        START_BIT: begin
          tx <= 0;
          if(clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            state     <= DATA_BITS;
          end
          else clk_count <= clk_count + 1;
        end

        DATA_BITS: begin
          tx <= data_reg[bit_index];
          if(clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            if(bit_index == 7) begin
              bit_index <= 0;
              state     <= STOP_BIT;
            end
            else bit_index <= bit_index + 1;
          end
          else clk_count <= clk_count + 1;
        end

        STOP_BIT: begin
          tx <= 1;
          if(clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            state     <= IDLE;
            busy      <= 0;
          end
          else clk_count <= clk_count + 1;
        end

      endcase
    end
  end

endmodule
