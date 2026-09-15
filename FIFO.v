//Synchronized FIFO
module FIFO #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 16
)(
  input clk, rst, wr_en, rd_en, 
  output full, empty,
  output reg [DATA_WIDTH-1:0] rd_data,
  input [DATA_WIDTH-1:0] wr_data 
);
  reg [$clog2(DEPTH):0] count;
  reg [DATA_WIDTH-1:0] store [0:DEPTH-1];
  reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
  
  assign full  = (count == DEPTH);
  assign empty = (count == 0);
  
  always @(posedge clk) begin
    if(rst) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
    end else begin
      if(wr_en && !full) begin 
          store[wr_ptr] <= wr_data;
          wr_ptr <= wr_ptr + 1;
      end

      if(rd_en && !empty) begin  
          rd_data <= store[rd_ptr];	
          rd_ptr <= rd_ptr + 1;
      end

      if (wr_en && !full && rd_en && !empty) begin
          count <= count;
      end else if (wr_en && !full) begin
          count <= count + 1;
      end else if (rd_en && !empty) begin
          count <= count - 1;
      end
    end
  end
endmodule