// base tests
class tb_quantum_gates_base_tests extends uvm_test;
    `uvm_component_utils(tb_quantum_gates_base_tests) // register with uvm_factory for dynamic create and override

    tb_quantum_gates_env q_env;
    tb_quantum_gates_env_cfg q_env_cfg;
    /*1. sequence doesn't talk to driver(for delivering transactions generated) directly. it delivers those transactions to sequencer, which latter controlls how it gets delivered to driver.
      2. System-Level (Multiple Agents): If we have multiple agents (e.g., AXI, SPI, I2C) and need to coordinate traffic across all of them in one test, we use a Virtual Sequence and a Virtual Sequencer.
         The Virtual Sequencer is built in the Environment and acts as a "map". It holds pointers to all the physical sequencers. This saves the Test from having to manually wire many different agents into the sequence. 
         The Virtual Sequence runs on the Virtual Sequencer, reads the map, and tells standard sequences to start running on their respective physical sequencers.*/
    tb_quantum_gates_seq q_seq;
    virtual quantum_gate_if q_vif;

    function new(string name = "tb_quantum_gates_base_tests", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual quantum_gate_if)::get(this, "", "q_vif", q_vif))
            `uvm_fatal(get_type_name(), "Failed to get virtual qif")

        q_env_cfg = tb_quantum_gates_env_cfg::type_id::create("q_env_cfg");
        q_env_cfg.is_active = UVM_ACTIVE;
        q_env_cfg.has_coverage = 1;
        q_env_cfg.has_scb = 1;
        q_env_cfg.q_vif = q_vif;

        // no virtual because already a class
        // set path this.q_env, so setting it to tests.q_env
        uvm_config_db #(tb_quantum_gates_env_cfg)::set(this, "q_env", "q_env_cfg", q_env_cfg);

        q_env = tb_quantum_gates_env::type_id::create("q_env", this);
    endfunction : build_phase

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);

        q_seq = tb_quantum_gates_seq::type_id::create("q_seq");
        // starts 
        phase.raise_objection(this);
        // start the sequencer for this test
        q_seq.start(q_env.q_agt.q_sequencer);
        // finishes
        phase.drop_objection(this);
    endtask : run_phase

    virtual function void report_phase (uvm_phase phase);
        super.report_phase(phase);
        if (q_env.q_scb.num_mismatch == 0) begin
            `uvm_info(get_type_name(), "TEST PASS", UVM_NONE)
        end else begin
            `uvm_error(get_type_name(), "TEST_FAIL")
        end

    endfunction : report_phase

endclass : tb_quantum_gates_base_tests