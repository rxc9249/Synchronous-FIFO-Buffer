`timescale 1ns/1ps

module fifo_tb;
  parameter DATA_WIDTH = 8;
  parameter DEPTH = 4;

  reg clk, rst, wr_en, rd_en;
  reg [DATA_WIDTH-1:0] wr_data;
  wire [DATA_WIDTH-1:0] rd_data;
  wire full, empty;

  FIFO #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
    .clk(clk), .rst(rst),
    .wr_en(wr_en), .wr_data(wr_data),
    .rd_en(rd_en), .rd_data(rd_data),
    .full(full), .empty(empty)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, fifo_tb);

    rst = 1; wr_en = 0; rd_en = 0; wr_data = 0;
    @(posedge clk); @(posedge clk);
    rst = 0;

    // fill the FIFO (depth=4)
    @(negedge clk); wr_en = 1; wr_data = 8'h11;
    @(negedge clk); wr_data = 8'h22;
    @(negedge clk); wr_data = 8'h33;
    @(negedge clk); wr_data = 8'h44;
    @(negedge clk); wr_en = 0;

    // read 2 values
    @(negedge clk); rd_en = 1;
    @(negedge clk);
    @(negedge clk); rd_en = 0;

    // simultaneous read + write
    @(negedge clk); wr_en = 1; rd_en = 1; wr_data = 8'h55;
    @(negedge clk); wr_en = 0; rd_en = 0;

    // drain the rest
    @(negedge clk); rd_en = 1;
    repeat (4) @(negedge clk);
    rd_en = 0;

    @(posedge clk);
    $finish;
  end
endmodule