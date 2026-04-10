BASE_DIR     = /Users/luelue/Documents/FPGA_PYNQ_Z2/quantum_fpga/one_qubit
DESIGN_DIR   = $(BASE_DIR)/design
MODEL_DIR    = $(BASE_DIR)/model
MODEL_TB_DIR = $(BASE_DIR)/tb/model_tb
SV_TB_DIR    = $(BASE_DIR)/tb/sv_tb

RTL = $(DESIGN_DIR)/single_qubit.sv $(DESIGN_DIR)/lfsr.sv $(DESIGN_DIR)/quantum_gates.sv
TB  = $(SV_TB_DIR)/tb_single_qubit.sv

OUT     = sim.out
VCD     = single_qubit.vcd
REF_BIN = test_ref_model
CPP_CSV = results_cpp.csv
QISKIT_CSV = results_qiskit.csv

TOP = single_qubit

.PHONY: sim wave verify_golden clean

sim:
	iverilog -g2012 -o $(OUT) $(TB) $(RTL)
	vvp $(OUT)

wave: sim
	gtkwave $(VCD) &
	
verify_golden:
	g++ $(MODEL_TB_DIR)/test_ref_model.cpp $(MODEL_DIR)/ref_model_quantum_gates.cpp -I$(MODEL_DIR) -o $(REF_BIN)
	./$(REF_BIN) > $(CPP_CSV)
	python3 $(MODEL_TB_DIR)/qiskit_ref_model.py > $(QISKIT_CSV)
	python3 $(MODEL_TB_DIR)/compare.py $(CPP_CSV) $(QISKIT_CSV)

clean:
	rm -f $(OUT) $(VCD) $(REF_BIN) $(CPP_CSV) $(QISKIT_CSV) $(LOG)
