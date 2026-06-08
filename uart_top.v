// Module 1 - Baud Rate Generator
module baud_rate_gen(
  input clk,
  input rst,
  output reg tick
);
  parameter CLKS_PER_BIT = 5208;
  integer counter = 0;
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      counter <= 0;
      tick    <= 0;
    end
    else if(counter == CLKS_PER_BIT - 1) begin
      counter <= 0;
      tick    <= 1;
    end
    else begin
      counter <= counter + 1;
      tick    <= 0;
    end
  end
endmodule

// Module 2 - UART TX
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

// Module 3 - UART RX
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
          if(rx == 0) begin
            state <= START_BIT;
          end
        end
        START_BIT: begin
          if(clk_count == HALF_BIT - 1) begin
            if(rx == 0) begin
              clk_count <= 0;
              state     <= DATA_BITS;
            end
            else begin
              state <= IDLE;
            end
          end
          else clk_count <= clk_count + 1;
        end
        DATA_BITS: begin
          if(clk_count == CLKS_PER_BIT - 1) begin
            clk_count           <= 0;
            data_reg[bit_index] <= rx;
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
            data_out   <= data_reg;
            data_ready <= 1;
            state      <= IDLE;
          end
          else clk_count <= clk_count + 1;
        end
      endcase
    end
  end
endmodule

// Module 4 - UART Top
module uart_top(
  input clk,
  input rst,
  input start,
  input [7:0] data_in,
  output [7:0] data_out,
  output data_ready,
  output busy
);
  wire tx_line;
  uart_tx tx_inst(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .tx(tx_line),
    .busy(busy)
  );
  uart_rx rx_inst(
    .clk(clk),
    .rst(rst),
    .rx(tx_line),
    .data_out(data_out),
    .data_ready(data_ready)
  );
endmodule
