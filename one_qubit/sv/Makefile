ROOT_DIR   = /Users/luelue/Documents/FPGA_PYNQ_Z2
RTL_DIR    = $(ROOT_DIR)/quantum_fpga/one_qubit/sv/rtl
TB_DIR     = $(ROOT_DIR)/quantum_fpga/one_qubit/sv/tb
MODEL_DIR  = $(ROOT_DIR)/quantum_fpga/one_qubit/sv/model

RTL = $(RTL_DIR)/single_qubit.sv $(RTL_DIR)/lfsr.sv $(RTL_DIR)/quantum_gates.sv
TB  = $(TB_DIR)/tb_single_qubit.sv

OUT     = sim.out
VCD     = single_qubit.vcd
REF_BIN = test_ref_model
CPP_CSV = results_cpp.csv
QISKIT_CSV = results_qiskit.csv

TOP = single_qubit

.PHONY: sim wave ref verify clean

sim:
	iverilog -g2012 -o $(OUT) $(TB) $(RTL)
	vvp $(OUT)

wave: sim
	gtkwave $(VCD) &

ref:
	g++ $(TB_DIR)/test_ref_model.cpp $(MODEL_DIR)/ref_model_quantum_gates.cpp -I$(MODEL_DIR) -o $(REF_BIN)
	./$(REF_BIN)

verify:
	g++ $(TB_DIR)/test_ref_model.cpp $(MODEL_DIR)/ref_model_quantum_gates.cpp -I$(MODEL_DIR) -o $(REF_BIN)
	./$(REF_BIN) > $(CPP_CSV)
	python3 $(TB_DIR)/qiskit_ref_model.py > $(QISKIT_CSV)
	python3 $(TB_DIR)/compare.py $(CPP_CSV) $(QISKIT_CSV)

clean:
	rm -f $(OUT) $(VCD) $(REF_BIN) $(CPP_CSV) $(QISKIT_CSV) $(LOG)
