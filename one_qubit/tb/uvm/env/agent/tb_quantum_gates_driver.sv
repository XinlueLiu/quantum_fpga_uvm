// driver
class tb_quantum_gates_driver extends uvm_driver #(tb_quantum_gates_item); //#(REQ,RSP). If same, just put one
    `uvm_component_utils(tb_quantum_gates_driver)

    virtual quantum_gate_if q_vif;
    
    function new(name = "tb_quantum_gates_driver", parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction : build_phase

    virtual task run_phase(uvm_phase);
        tb_quantum_gates_item q_obj;
        // driver sequencer handshake
        // allow driver to get a series of transaction objects from sequencer
        // it we need response from driver to sequence with a different resposne type, we can use get(REQ) put(RSP) duo 
        q_vif.rst_n <= 0; // reset
        repeat(5) @(q_vif.driver_cb);
        q_vif.rst_n <= 1;
        @(q_vif.driver_cb);
        forever begin
            `uvm_info(get_type_name(), $sformatf("Waiting data from sequencer"), UVM_MEDIUM)
            seq_item_port.get_next_item(q_obj);
            drive_item(q_obj);
            seq_item_port.item_done();
        end
    endtask : run_phase

    virtual task drive_item(tb_quantum_gates_item q_obj);
        @(q_vif.driver_cb);
        q_vif.driver_cb.load_en <= q_obj.load_en;
        q_vif.driver_cb.gate_evolve <= q_obj.gate_evolve;
        q_vif.driver_cb.gate_select <= q_obj.gate_select;
        q_vif.driver_cb.alpha_real <= q_obj.alpha_real;
        q_vif.driver_cb.alpha_imag <= q_obj.alpha_imag;
        q_vif.driver_cb.beta_real <= q_obj.beta_real;
        q_vif.driver_cb.beta_imag <= q_obj.beta_imag;
        do @(q_vif.driver_cb);
        while ((!q_vif.driver_cb.gate_done) && (!q_vif.driver_cb.load_en));
        q_vif.driver_cb.load_en <= 0;
        q_vif.driver_cb.gate_evolve <= 0;
    endtask : drive_item
endclass : tb_quantum_gates_driver