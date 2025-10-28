package fifo_pkg_COV;
import fifo_pkg_trans::*;

class FIFO_coverage;
FIFO_transaction F_cvg_txn;

    covergroup cg;

      cp_wr_en : coverpoint F_cvg_txn.wr_en;
      cp_rd_en : coverpoint F_cvg_txn.rd_en;

      cp_wr_ack: coverpoint F_cvg_txn.wr_ack;
      cp_overflow: coverpoint F_cvg_txn.overflow;
      cp_underflow: coverpoint F_cvg_txn.underflow;
      cp_full: coverpoint F_cvg_txn.full;
      cp_empty: coverpoint F_cvg_txn.empty;
      cp_almostfull: coverpoint F_cvg_txn.almostfull;
      cp_almostempty: coverpoint F_cvg_txn.almostempty;

      cross_wre_rd_wrack: cross cp_wr_en, cp_rd_en, cp_wr_ack {
          // wr_ack can only be 1 when wr_en is 1
          illegal_bins wr_ack_without_wr_en = binsof(cp_wr_en) intersect {0} && 
                                               binsof(cp_wr_ack) intersect {1};
      }
      
      cross_wre_rd_oflow: cross cp_wr_en, cp_rd_en, cp_overflow {
          // overflow can only be 1 when wr_en is 1
          illegal_bins overflow_without_wr_en = binsof(cp_wr_en) intersect {0} && 
                                                 binsof(cp_overflow) intersect {1};
      }
      
      cross_wre_rd_uflow: cross cp_wr_en, cp_rd_en, cp_underflow {
          // underflow can only be 1 when rd_en is 1
          illegal_bins underflow_without_rd_en = binsof(cp_rd_en) intersect {0} && 
                                                  binsof(cp_underflow) intersect {1};
      }
      
      cross_wre_rd_full: cross cp_wr_en, cp_rd_en, cp_full {
          illegal_bins full_with_only_read = binsof(cp_rd_en) intersect {1} &&
                                             binsof(cp_full) intersect {1};
      }
      
      cross_wre_rd_empty: cross cp_wr_en, cp_rd_en, cp_empty;

      cross_wre_rd_afull: cross cp_wr_en, cp_rd_en, cp_almostfull;
      
      cross_wre_rd_aempty: cross cp_wr_en, cp_rd_en, cp_almostempty;
      
    endgroup : cg


    function new();
      cg = new();
    endfunction

   function void sample_data(FIFO_transaction F_txn);
      this.F_cvg_txn = F_txn;

      cg.sample();
    endfunction

endclass


endpackage