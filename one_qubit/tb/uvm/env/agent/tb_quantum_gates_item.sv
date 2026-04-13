// tlm item
class tb_quantum_gates_item extends uvm_sequence_item;
    `uvm_object_utils_begin(tb_quantum_gates_item)
        `uvm_field_int(load_en, UVM_ALL_ON)
        `uvm_field_int(gate_evolve, UVM_ALL_ON)
        `uvm_field_int(gate_select, UVM_ALL_ON)
        `uvm_field_int(gate_done, UVM_ALL_ON)
        `uvm_field_int(alpha_real, UVM_ALL_ON)
        `uvm_field_int(alpha_imag, UVM_ALL_ON)
        `uvm_field_int(beta_real, UVM_ALL_ON)
        `uvm_field_int(beta_imag, UVM_ALL_ON)
        `uvm_field_int(out_alpha_real, UVM_ALL_ON)
        `uvm_field_int(out_alpha_imag, UVM_ALL_ON)
        `uvm_field_int(out_beta_real, UVM_ALL_ON)
        `uvm_field_int(out_beta_imag, UVM_ALL_ON)
    `uvm_object_utils_end

    rand bit load_en;
    rand bit gate_evolve;
    rand bit gate_done;
    rand bit [1:0] gate_select;
    rand bit signed [15:0] alpha_real;
    rand bit signed [15:0] alpha_imag;
    rand bit signed [15:0] beta_real;
    rand bit signed [15:0] beta_imag;
    rand bit signed [15:0] out_alpha_real;
    rand bit signed [15:0] out_alpha_imag;
    rand bit signed [15:0] out_beta_real;
    rand bit signed [15:0] out_beta_imag;


    function new(string name = "tb_quantum_gates_item");
        super.new(name);
    endfunction : new
endclass : tb_quantum_gates_item 