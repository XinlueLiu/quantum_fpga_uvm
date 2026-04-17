// monitor
class tb_quantum_gates_mon extends uvm_monitor;
    `uvm_component_utils(tb_quantum_gates_mon)

    virtual quantum_gate_if q_vif;
    uvm_analysis_port #(tb_quantum_gates_item) mon_analysis_port;
    
    function new(string name = "tb_quantum_gates_mon", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        // object should not take parent. second argument is for component only
        forever begin
            tb_quantum_gates_item q_obj = tb_quantum_gates_item::type_id::create("q_obj");
            @(q_vif.mon_cb);
            q_obj.load_en = q_vif.mon_cb.load_en;
            q_obj.gate_evolve = q_vif.mon_cb.gate_evolve;
            q_obj.gate_done = q_vif.mon_cb.gate_done;
            q_obj.gate_select = q_vif.mon_cb.gate_select;
            if (q_obj.load_en) begin
                q_obj.alpha_real = q_vif.mon_cb.alpha_real;
                q_obj.alpha_imag = q_vif.mon_cb.alpha_imag;
                q_obj.beta_real = q_vif.mon_cb.beta_real;
                q_obj.beta_imag = q_vif.mon_cb.beta_imag;
            end
            if (q_obj.gate_done) begin
                q_obj.out_alpha_real = q_vif.mon_cb.out_alpha_real;
                q_obj.out_alpha_imag = q_vif.mon_cb.out_alpha_imag;
                q_obj.out_beta_real = q_vif.mon_cb.out_beta_real;
                q_obj.out_beta_imag = q_vif.mon_cb.out_beta_imag;
                mon_analysis_port.write(q_obj);
            end
        end
    endtask : run_phase
endclass : tb_quantum_gates_mon