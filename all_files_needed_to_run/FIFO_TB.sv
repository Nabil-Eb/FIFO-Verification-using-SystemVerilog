module fifo_tb(fifo_if.TEST f_if);

  import fifo_pkg_trans::*;
  import shared_pkg::*;
  import fifo_pkg_COV::*;
  import fifo_pkg_score::*;

  FIFO_transaction drv_txn;

  int unsigned NUM_CYCLES = 10000;

  initial begin

    drv_txn = new();

	f_if.rst_n=0; f_if.rd_en=0; f_if.wr_en=0; f_if.data_in=0;
	@(negedge f_if.clk); 	
	-> sample_event; 
	f_if.rst_n=1;

	repeat(NUM_CYCLES) begin
		assert(drv_txn.randomize());
		f_if.rst_n=drv_txn.rst_n;
		f_if.rd_en=drv_txn.rd_en;
		f_if.wr_en=drv_txn.wr_en;
		f_if.data_in=drv_txn.data_in;
		@(negedge f_if.clk);
		-> sample_event; 
	end

	test_finished =1;
	
  end
  
endmodule