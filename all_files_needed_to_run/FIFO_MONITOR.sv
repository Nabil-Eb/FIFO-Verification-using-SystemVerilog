  import fifo_pkg_trans::*;
  import fifo_pkg_COV::*;
  import fifo_pkg_score::*;
  import shared_pkg::*;

module fifo_monitor(fifo_if.MONITOR f_if);

  FIFO_transaction mon_txn;
  FIFO_coverage  mon_cvg;
  FIFO_scoreboard mon_sb;

   initial begin

    mon_txn = new();
    mon_cvg = new();
    mon_sb  = new();

    forever begin
     @(sample_event);
      mon_txn.data_in    = f_if.data_in;
      mon_txn.wr_en      = f_if.wr_en;
      mon_txn.rd_en      = f_if.rd_en;
      mon_txn.rst_n      = f_if.rst_n;

      @(negedge f_if.clk);
      
      mon_txn.data_out   = f_if.data_out;
      mon_txn.wr_ack     = f_if.wr_ack;
      mon_txn.overflow   = f_if.overflow;
      mon_txn.underflow  = f_if.underflow;
      mon_txn.full       = f_if.full;
      mon_txn.empty      = f_if.empty;
      mon_txn.almostfull = f_if.almostfull;
      mon_txn.almostempty= f_if.almostempty;


      fork
        begin
          mon_cvg.sample_data(mon_txn);
        end
        begin
          mon_sb.check_data(mon_txn);
        end
      join

 
      if (test_finished) begin
        $display("[%0t] MONITOR: Test finished. correct=%0d errors=%0d", $time, correct_count, error_count);
        $finish;
      end
    end
  end

endmodule