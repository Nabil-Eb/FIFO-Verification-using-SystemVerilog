module fifo_top;

bit clk;

initial begin
  clk = 0;
  forever #1 clk = ~clk;
end

fifo_if f_if (clk);
fifo_tb     f_tb (f_if.TEST);
fifo        f_dut(f_if.DUT);
fifo_monitor f_mon(f_if.MONITOR);

endmodule