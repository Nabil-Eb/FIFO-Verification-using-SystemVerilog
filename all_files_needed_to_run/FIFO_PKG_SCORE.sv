package fifo_pkg_score;
import fifo_pkg_trans::*;
import shared_pkg::*;

FIFO_transaction FIFO_transaction_object = new();

class FIFO_scoreboard;
    
    bit [FIFO_transaction_object.FIFO_WIDTH-1:0] fifo_q[$];

    logic [FIFO_transaction_object.FIFO_WIDTH-1:0] data_out_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref;
    logic wr_ack_ref, overflow_ref, underflow_ref;
    int count_ref;

function void reference_model(FIFO_transaction tr);
  
  if (!tr.rst_n) begin
    fifo_q.delete();
    data_out_ref    = '0;
    full_ref        = 0;
    empty_ref       = 1;
    almostfull_ref  = 0;
    almostempty_ref = 0;
    count_ref       = 0;
    return;
  end  else begin
  if (tr.wr_en && (!full_ref)) begin
    fifo_q.push_back(tr.data_in);
  end
  if ( tr.rd_en && (!empty_ref)) begin
    data_out_ref = fifo_q.pop_front();
  end

        count_ref       = fifo_q.size();
        full_ref        = (count_ref == tr.FIFO_DEPTH);
        empty_ref       = (count_ref == 0);
 end
endfunction


    function void check_data(input FIFO_transaction ob1);
        reference_model(ob1);

			if ((ob1.data_out !== data_out_ref)&&(ob1.wr_en)&&(ob1.rst_n)) begin
				$display("Error!!, At time %t, data_out %d doesn't equal data_out_ref %d !!", $time, ob1.data_out, data_out_ref);
				error_count++;
			end
			else begin
				$display("Success, At time %t, data_out= %d equals data_out_ref= %d", $time, ob1.data_out, data_out_ref);
				correct_count++;
			end
		endfunction

        function new();
    data_out_ref    = '0;
    full_ref        = 0;
    empty_ref       = 1;
    almostfull_ref  = 0;
    almostempty_ref = 0;
    count_ref       = 0;
        endfunction

  endclass
endpackage