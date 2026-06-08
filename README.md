# UART Implementation in Verilog

## Overview
UART (Universal Asynchronous Receiver Transmitter) communication 
protocol implemented in Verilog. Simulated using Icarus Verilog 
on EDA Playground.

## Modules
- baud_rate_gen.v — generates tick at 9600 baud rate for 50MHz clock
- uart_tx.v — UART transmitter with FSM logic (IDLE, START, DATA, STOP)
- tb_uart_tx.v — testbench verifying transmission of ASCII data

## Tools Used
- EDA Playground (Icarus Verilog 12.0)
- GTKWave for waveform analysis

## Key Concepts
- Baud rate: 9600
- Clock frequency: 50 MHz
- Clocks per bit: 5208
- Data format: 8 data bits, 1 start bit, 1 stop bit

## Status
Week 1 complete — Baud rate generator and TX module working
Week 2 — UART RX module (in progress)

## Author
Bhoomi Varshney
ECE Student — Chandigarh University
