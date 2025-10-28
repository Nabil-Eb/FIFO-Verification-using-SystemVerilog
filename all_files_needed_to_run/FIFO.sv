module fifo (fifo_if.DUT f_if);

    // -------------------------------------------------
    // Local parameters (taken from interface)
    // -------------------------------------------------
    localparam FIFO_WIDTH    = f_if.FIFO_WIDTH;
    localparam FIFO_DEPTH    = f_if.FIFO_DEPTH;
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    // -------------------------------------------------
    // Internal registers
    // -------------------------------------------------
    reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
    reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
    reg [max_fifo_addr:0]   count;

    // -------------------------------------------------
    // WRITE logic
    // -------------------------------------------------
    always @(posedge f_if.clk or negedge f_if.rst_n) begin
        if (!f_if.rst_n) begin
            wr_ptr         <= 0;
            // Bug detected: Reset signals FIFO_IF.overflow & FIFO_IF.wr_ack
            f_if.wr_ack    <= 0;
            f_if.overflow  <= 0;
        end
        else if (f_if.wr_en && !f_if.full) begin
            mem[wr_ptr]    <= f_if.data_in;
            wr_ptr         <= wr_ptr + 1;
            f_if.wr_ack    <= 1;
            f_if.overflow  <= 0;
        end
        else begin
            f_if.wr_ack    <= 0;
            if (f_if.wr_en && f_if.full)
                f_if.overflow <= 1;   // reject write when full
            else
                f_if.overflow <= 0;
        end
    end

    // -------------------------------------------------
    // READ logic
    // -------------------------------------------------
    always @(posedge f_if.clk or negedge f_if.rst_n) begin
        if (!f_if.rst_n) begin
            rd_ptr          <= 0;
            // Bug detected: Reset signals FIFO_IF.underflow 
            f_if.data_out   <= 0;
            f_if.underflow  <= 0;
        end
        else if (f_if.rd_en && !f_if.empty) begin
            f_if.data_out   <= mem[rd_ptr];
            rd_ptr          <= rd_ptr + 1;
            f_if.underflow  <= 0;
        end
        else begin
            if (f_if.rd_en && f_if.empty)
                f_if.underflow <= 1;   // reject read when empty
            else
                f_if.underflow <= 0;
        end
    end

    // -------------------------------------------------
    // COUNT logic
    // -------------------------------------------------
    always @(posedge f_if.clk or negedge f_if.rst_n) begin
        if (!f_if.rst_n) begin
            count <= 0;
        end
        else begin
            case ({f_if.wr_en, f_if.rd_en})
                2'b10: if (!f_if.full)  count <= count + 1; // write only
                2'b01: if (!f_if.empty) count <= count - 1; // read only
                2'b11: begin
    // simultaneous read and write
// Bug detected: Unhandled case,  If a read and write enables were high and the FIFO was FIFO_IF.empty, only writing will take place.
// Bug detected: Unhandled cases,  If a read and write enables were high and the FIFO was FIFO_IF.full, only reading will take place.
                    if (f_if.empty)      count <= count + 1; // write takes effect
                    else if (f_if.full)  count <= count - 1; // read takes effect
                    // else: count unchanged (balanced read/write)
                end
                default: count <= count; // no operation
            endcase
        end
    end

    // -------------------------------------------------
    // Status signals
    // -------------------------------------------------
    assign f_if.full        = (count == FIFO_DEPTH);
    assign f_if.empty       = (count == 0);
    assign f_if.almostfull  = (count == FIFO_DEPTH-1); // Bug detected: f_if.FIFO_DEPTH-2 --> f_if.FIFO_DEPTH-1

    assign f_if.almostempty = (count == 1);

  always_comb begin
	if(!f_if.rst_n) begin
	reset_rd :assert final(rd_ptr==1'b0);
	reset_wr :assert final(wr_ptr==1'b0);
	reset_co :assert final(count==0);
	end
end 

property ack;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en && !f_if.full) |=> f_if.wr_ack ;
endproperty

property ovr;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en && f_if.full) |=> f_if.overflow;
endproperty

property udr;
	@(posedge f_if.clk) disable iff (!f_if.rst_n)  (f_if.rd_en && f_if.empty) |=> f_if.underflow;
endproperty

property emp;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) count==0 |-> f_if.empty;
endproperty

property ful;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) count==FIFO_DEPTH |-> f_if.full;
endproperty

property Aful;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (count==FIFO_DEPTH-1) |-> f_if.almostfull;
endproperty

property Aemp;
	@(posedge f_if.clk) disable iff (!f_if.rst_n) (count==1) |-> f_if.almostempty;
endproperty

property wrap1;
	 @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en && !f_if.full && wr_ptr == FIFO_DEPTH-1) |=> (wr_ptr == 0);
endproperty

property wrap2;
	 @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.rd_en && !f_if.empty && rd_ptr == FIFO_DEPTH-1) |=> (rd_ptr == 0);
endproperty

property wrap3;
	 @(posedge f_if.clk) disable iff (!f_if.rst_n) (count<=FIFO_DEPTH && count>=0);
endproperty
property FIFO_internal_bounds;
  @(posedge f_if.clk) disable iff (!f_if.rst_n) (wr_ptr < FIFO_DEPTH) && (rd_ptr < FIFO_DEPTH) && (count <= FIFO_DEPTH);
endproperty

assert property (ack);
assert property (ovr);
assert property (udr);
assert property (emp);
assert property (ful);
assert property (Aful);
assert property (Aemp);
assert property (wrap1);
assert property (wrap2);
assert property (wrap3);
assert property (FIFO_internal_bounds);
cover property (ack);
cover property (ovr);
cover property (udr);
cover property (emp);
cover property (ful);
cover property (Aful);
cover property (Aemp);
cover property (wrap1);
cover property (wrap2);
cover property (wrap3);
cover property (FIFO_internal_bounds);

endmodule