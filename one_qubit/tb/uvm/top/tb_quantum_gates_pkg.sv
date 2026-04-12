// package

package tb_quantum_gates_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

// tlm item
`include "env/agent/tb_quantum_gates_item.sv"
// sequences
`include "env/sequences/tb_quantum_gates_seq.sv"

// agent components
`include "env/agent/tb_quantum_gates_sequencer.sv"
`include "env/agent/tb_quantum_gates_mon.sv"
`include "env/agent/tb_quantum_gates_driver.sv"

// agent wrapper
`include "env/agent/tb_quantum_gates_agt.sv"

// environment components
`include "cov/tb_quantum_gates_cov.sv"
`include "env/tb_quantum_gates_pred.sv"
`include "env/tb_quantum_gates_scb.sv"

// environment wrapper
`include "env/tb_quantum_gates_env.sv"

// tests
`include "tests/tb_quantum_gates_base_tests.sv"

endpackage : tb_quantum_gates_pkg
