# ==========================================
# UVM Verification Makefile
# Run this from: one_qubit/tb/uvm/
# ==========================================

# Relative paths from tb/uvm/ back to the project directories
BASE_DIR   = ../..
DESIGN_DIR = $(BASE_DIR)/design
MODEL_DIR  = $(BASE_DIR)/model

# UVM Environment Variable
UVM_HOME ?= $(HOME)/1800.2-2017-1.0/src

# DUT Sources (Only what the UVM controller needs)
RTL = $(DESIGN_DIR)/quantum_gate_controller.sv \
      $(DESIGN_DIR)/quantum_gates.sv

# UVM Testbench Sources
UVM_TB = top/tb_quantum_gates_dpi_pkg.sv \
         top/tb_quantum_gates_if.sv \
         top/tb_quantum_gates_pkg.sv \
         top/tb_quantum_gates.sv

DPI_CPP = $(MODEL_DIR)/ref_model_quantum_gates.cpp

.PHONY: sim clean

sim:
	# 1. Compile with Verilator
	verilator -Wno-fatal -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC --binary --timing -j $$(sysctl -n hw.logicalcpu) \
	--top-module tb_quantum_gates \
	+incdir+$(UVM_HOME) +define+UVM_NO_DPI \
	+incdir+. \
	$(UVM_HOME)/uvm_pkg.sv \
	$(RTL) \
	$(UVM_TB) \
	$(DPI_CPP)
	
	# 2. Run the simulation
	./obj_dir/Vtb_quantum_gates +UVM_TESTNAME=tb_quantum_gates_base_tests

clean:
	rm -rf obj_dir/
	rm -f *.log *.vcd