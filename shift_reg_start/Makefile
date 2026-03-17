ROOT_DIR = /Users/luelue/Documents/FPGA_PYNQ_Z2
RTL_DIR = $(ROOT_DIR)/pynq_z2_projects/shift_reg_start/rtl
TB_DIR = $(ROOT_DIR)/pynq_z2_projects/shift_reg_start/tb

RTL = $(RTL_DIR)/shift_reg.v
TB = $(TB_DIR)/systemverilog/tb.sv

OUT = sim.out
VCD = shift_reg_wave.vcd

TOP = tb_shift_register

.PHONY: sim wave clean

sim:
	iverilog -g2012 -o $(OUT) $(TB) $(RTL)
	vvp $(OUT)

wave: sim
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
	