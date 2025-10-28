vlib work

vlog -f src_files.list +cover +covercells +coveropt

vsim -voptargs=+acc work.fifo_top -cover

add wave *
add wave -position insertpoint  \
sim:/fifo_top/f_if/data_in \
sim:/fifo_top/f_if/rst_n \
sim:/fifo_top/f_if/wr_en \
sim:/fifo_top/f_if/rd_en \
sim:/fifo_top/f_if/data_out \
sim:/fifo_top/f_if/wr_ack \
sim:/fifo_top/f_if/overflow \
sim:/fifo_top/f_if/underflow \
sim:/fifo_top/f_if/full \
sim:/fifo_top/f_if/empty \
sim:/fifo_top/f_if/almostfull \
sim:/fifo_top/f_if/almostempty

coverage save fifo_top.ucdb -onexit

run -all

## vcover report fifo_top.ucdb -details -annotate -all -output coverage_pro_rpt.txt