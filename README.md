# Synchronous FIFO Buffer

A parameterized, synthesizable synchronous FIFO (First-In-First-Out) buffer written in Verilog. Supports simultaneous read and write operations, safe overflow/underflow handling, and combinational full/empty flag generation.

## Features
- Parameterized `DATA_WIDTH` and `DEPTH` (depth must be a power of 2)
- Counter-based full/empty detection (no ambiguous pointer-wrap edge cases)
- Combinational `full`/`empty` flags — update instantly with `count`, no extra latency
- Correctly handles simultaneous read + write on the same clock cycle
- Synchronous, active-high reset

## Interface

| Signal    | Direction | Width          | Description                     |
|-----------|-----------|----------------|----------------------------------|
| `clk`     | input     | 1              | Clock                            |
| `rst`     | input     | 1              | Synchronous active-high reset    |
| `wr_en`   | input     | 1              | Write enable                     |
| `wr_data` | input     | `DATA_WIDTH`   | Write data                       |
| `rd_en`   | input     | 1              | Read enable                      |
| `rd_data` | output    | `DATA_WIDTH`   | Read data (registered)           |
| `full`    | output    | 1              | FIFO full flag                   |
| `empty`   | output    | 1              | FIFO empty flag                  |

## Design Notes
Full/empty status is tracked with a `count` register (rather than comparing write/read pointers directly), which avoids the classic ambiguity where `wr_ptr == rd_ptr` can mean either full or empty. `count` is one bit wider than needed to represent 0 through `DEPTH` inclusive.

Writes are ignored while `full`; reads are ignored while `empty`. A simultaneous valid read and write on the same cycle correctly leaves `count` unchanged.

## Verification
A testbench (`fifo_tb.v`) exercises:
- Reset behavior
- Basic single write/read
- Filling to full and verifying the flag
- Write-while-full (dropped safely)
- Full drain and FIFO ordering check
- Read-while-empty (dropped safely)
- Simultaneous read + write

<img width="2518" height="383" alt="image" src="https://github.com/user-attachments/assets/729611db-7ca8-429c-9f58-2d881c7f306b" />


Run with Icarus Verilog:
```bash
iverilog -o sim fifo.v fifo_tb.v
vvp sim
```

## Possible Extensions
- Add a `count` output port
- Convert to an asynchronous FIFO (separate read/write clocks, Gray-coded pointers, CDC synchronizers)
- Add SystemVerilog assertions for overflow/underflow protection
