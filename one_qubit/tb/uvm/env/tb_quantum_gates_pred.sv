// predictor
class tb_quantum_gates_pred extends uvm_subscriber #(tb_quantum_gates_item);
    `uvm_component_utils(tb_quantum_gates_pred)
    import tb_quantum_gates_dpi_pkg::*;

    uvm_analysis_port #(tb_quantum_gates_item) pred_golden_data_ap;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        pred_golden_data_ap = new("pred_golden_data_ap", this);
    endfunction : build_phase

    // write function for analysis_export that receives rtl data from monitor
    virtual function void write(tb_quantum_gates_item q_pkt);
        tb_quantum_gates_item expected_out_q_pkt;
        expected_out_q_pkt = tb_quantum_gates_item::type_id::create("expected_out_q_pkt");

        sv_apply_quantum_gates(q_pkt.gate_select, q_pkt.alpha_real, q_pkt.alpha_imag, q_pkt.beta_real, q_pkt.beta_imag, 
                                expected_out_q_pkt.out_alpha_real, expected_out_q_pkt.out_alpha_imag, expected_out_q_pkt.out_beta_real, expected_out_q_pkt.out_beta_imag);
        pred_golden_data_ap.write(expected_out_q_pkt);
    endfunction : write
endclass : tb_quantum_gates_pred