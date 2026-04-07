ROOT_DIR = /Users/luelue/Documents/FPGA_PYNQ_Z2
RTL_DIR  = $(ROOT_DIR)/pynq_z2_projects/one_qubit/sv/rtl
TB_DIR   = $(ROOT_DIR)/pynq_z2_projects/one_qubit/sv/tb

RTL = $(RTL_DIR)/single_qubit.sv $(RTL_DIR)/lfsr.sv $(RTL_DIR)/quantum_gates.sv
TB  = $(TB_DIR)/tb_single_qubit.sv

OUT = sim.out
VCD = single_qubit.vcd

TOP = single_qubit

.PHONY: sim wave clean

sim:
	iverilog -g2012 -o $(OUT) $(TB) $(RTL)
	vvp $(OUT)

wave: sim
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
