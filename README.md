# UART Implementation in Verilog

## Overview
UART communication protocol implemented in Verilog.
Simulated using Icarus Verilog on EDA Playground.

## Modules
- baud_rate_gen.v — generates tick at 9600 baud rate
- uart_tx.v — UART transmitter with FSM logic
- tb_uart_tx.v — testbench verifying transmission of data

## Tools Used
- EDA Playground (Icarus Verilog 12.0)
- GTKWave for waveform analysis

## Status
Week 1 complete — Baud rate generator and TX module working
