package fifo_pkg_trans;
import shared_pkg::*;

class FIFO_transaction;
		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;
		localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    rand logic [15:0] data_in;
    rand logic wr_en;
    rand logic rd_en;
    rand logic rst_n;

    logic wr_ack;
    logic overflow;
    logic underflow;
    logic full;
    logic empty;
    logic almostfull;
    logic almostempty;
    logic [FIFO_WIDTH-1:0] data_out;

    int RD_EN_ON_DIST;
    int WR_EN_ON_DIST;
    function new(int rd_on = 30, int wr_on = 70);
      this.RD_EN_ON_DIST = rd_on;
      this.WR_EN_ON_DIST = wr_on;
    endfunction

    constraint rst_less_often {
      rst_n dist {1 :/ 95, 0 :/ 5}; 
    }

    constraint wr_dist {
      wr_en dist {1 :/ WR_EN_ON_DIST, 0 :/ (100-WR_EN_ON_DIST)};
    }
    constraint rd_dist {
      rd_en dist {1 :/ RD_EN_ON_DIST, 0 :/ (100-RD_EN_ON_DIST)};
    }

endclass

endpackage