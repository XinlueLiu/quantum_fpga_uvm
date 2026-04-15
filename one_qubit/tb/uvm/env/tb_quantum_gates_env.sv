// environment
class tb_quantum_gates_env extends uvm_env;
    `uvm_component_utils(tb_quantum_gates_env)

    tb_quantum_gates_agt q_agt;
    tb_quantum_gates_cov q_cov;
    tb_quantum_gates_scb q_scb;
    tb_quantum_gates_pred q_pred;
    tb_quantum_gates_env_cfg q_env_cfg;

    function new(string name = "tb_quantum_gates_env", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // getting for me, so path is env. second field is empty string. not getting for a child
        if (!uvm_config_db #(tb_quantum_gates_env_cfg)::get(this, "", "q_env_cfg", q_env_cfg))
            `uvm_fatal(get_type_name(), "Failed to get uvm_cfg in env")

        q_agt = tb_quantum_gates_agt::type_id::create("q_agt", this);
        q_agt.q_vif = q_env_cfg.q_vif;

        q_cov = tb_quantum_gates_cov::type_id::create("q_cov", this);
        q_scb = tb_quantum_gates_scb::type_id::create("q_scb", this);
        q_pred = tb_quantum_gates_pred::type_id::create("q_pred", this);

        
    endfunction : build_phase

    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        // monitor produces data, and scoreboard and predictor consumes
        // analysis port broadcasts, and imp port receives the data and calls write function
        q_agt.q_mon.mon_analysis_port.connect(q_scb.rtl_data_imported);
        q_agt.q_mon.mon_analysis_port.connect(q_pred.rtl_data_imported);
        q_pred.analysis_export.connect(q_scb.golden_data_imported);
    endfunction : connect_phase
endclass : tb_quantum_gates_env