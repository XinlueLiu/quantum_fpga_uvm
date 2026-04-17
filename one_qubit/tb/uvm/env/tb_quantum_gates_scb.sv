//scoreboard
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)
class tb_quantum_gates_scb extends uvm_scoreboard;
    `uvm_component_utils(tb_quantum_gates_scb)

    uvm_analysis_imp_actual #(tb_quantum_gates_item, tb_quantum_gates_scb) actual_data_imp_port;
    uvm_analysis_imp_expected #(tb_quantum_gates_item, tb_quantum_gates_scb) expected_data_imp_port;

    int match_count;
    int mismatch_count;

    // two queues for data input
    tb_quantum_gates_item actual_data_q[$];
    tb_quantum_gates_item expected_data_q[$];

    function new(string name = "tb_quantum_gates_scb", uvm_component parent);
        super.new(name, parent);
        match_count = 0;
        mismatch_count = 0;
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        actual_data_imp_port = new("actual_data_imp_port", this);
        expected_data_imp_port = new("expected_data_imp_port", this);
    endfunction : build_phase

    virtual function void write_actual(tb_quantum_gates_item q_t);
        actual_data_q.push_back(q_t);
    endfunction : write_actual

    virtual function void write_expected(tb_quantum_gates_item q_t);
        expected_data_q.push_back(q_t);
    endfunction : write_expected

    task run_phase(uvm_phase phase);
        tb_quantum_gates_item actual_data_item;
        tb_quantum_gates_item expected_data_item;
        super.run_phase(phase);
        forever begin
            wait((actual_data_q.size() > 0) && (expected_data_q.size() > 0));
            actual_data_item = actual_data_q.pop_front();
            expected_data_item = expected_data_q.pop_front();
            if (actual_data_item.compare(expected_data_item)) begin
                match_count++;
            end else begin
                mismatch_count++;
                `uvm_info(get_type_name(), $sformatf("MISMATCH_COUNT=%d", mismatch_count), UVM_NONE)
            end
        end
    endtask : run_phase

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if ((mismatch_count == 0) && (actual_data_q.size() == 0) && (expected_data_q.size() == 0))begin
            `uvm_info(get_type_name(), $sformatf("TEST SUCCESS"), UVM_NONE)
        end else begin
            if (mismatch_count != 0) begin
                `uvm_info(get_type_name(), $sformatf("MISMATCH_COUNT=%d", mismatch_count), UVM_NONE)
            end else if (actual_data_q.size() != 0) begin
                `uvm_info(get_type_name(), $sformatf("actual_data_q.size()=%d", actual_data_q.size()), UVM_NONE)
            end else if (expected_data_q.size() != 0) begin
                `uvm_info(get_type_name(), $sformatf("expected_data_q.size()=%d", expected_data_q.size()), UVM_NONE)
            end
            `uvm_fatal(get_type_name(), "TEST FAILED")
        end
    endfunction : check_phase


endclass : tb_quantum_gates_scb