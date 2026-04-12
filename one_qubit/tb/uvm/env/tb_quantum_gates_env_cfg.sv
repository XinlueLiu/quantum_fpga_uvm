// env cfg
class tb_quantum_gates_env_cfg extends uvm_object;
    `uvm_object_utils(tb_quantum_gates_env_cfg)

    uvm_active_passive_enum is_active;
    bit has_coverage;
    bit has_scb;
    virtual quantum_gate_if q_vif;

    function new(string name = "tb_quantum_gates_env_cfg");
        super.new(name);
    endfunction : new
endclass : tb_quantum_gates_env_cfg