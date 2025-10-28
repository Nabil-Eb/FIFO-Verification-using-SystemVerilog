interface fifo_if (clk);

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
input bit clk;
logic  [FIFO_WIDTH-1:0] data_in;
logic rst_n, wr_en, rd_en;

logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow, underflow;
logic full, empty, almostfull, almostempty;

  modport TEST (input clk, full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out,
              output data_in, wr_en, rd_en, rst_n);

  modport DUT (input clk, data_in, wr_en, rd_en, rst_n, output full, empty, almostfull,
               almostempty, wr_ack, overflow, underflow, data_out);

  modport MONITOR (input clk, data_in, wr_en, rd_en, full, empty,
               rst_n, almostfull, almostempty, wr_ack, overflow, underflow, data_out);

endinterface
