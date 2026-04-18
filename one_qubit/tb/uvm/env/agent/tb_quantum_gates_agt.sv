class tb_quantum_gates_agt extends uvm_agent;
    `uvm_component_utils(tb_quantum_gates_agt)

    tb_quantum_gates_driver q_drv;
    tb_quantum_gates_mon q_mon;
    tb_quantum_gates_sequencer q_sqr;
    virtual quantum_gate_if q_vif;

    function new(string name = "tb_quantum_gates_agt", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (get_is_active()) begin
            q_sqr = tb_quantum_gates_sequencer::type_id::create("q_sqr", this);
            q_drv = tb_quantum_gates_driver::type_id::create("q_drv", this);
            q_drv.q_vif = q_vif;
        end
        q_mon = tb_quantum_gates_mon::type_id::create("q_mon", this);
        q_mon.q_vif = q_vif;

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active())
            q_drv.seq_item_port.connect(q_sqr.seq_item_export); // default name seq_item_port and seq_item_export for the handshake
    endfunction : connect_phase

endclass : tb_quantum_gates_agt