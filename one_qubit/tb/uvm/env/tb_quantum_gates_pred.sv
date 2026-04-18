// predictor
class tb_quantum_gates_pred extends uvm_subscriber #(tb_quantum_gates_item);
    `uvm_component_utils(tb_quantum_gates_pred)

    uvm_analysis_port #(tb_quantum_gates_item) pred_golden_data_ap;
    real in_q_a_r, in_q_a_i, in_q_b_r, in_q_b_i; // input signals
    real out_q_a_r, out_q_a_i, out_q_b_r, out_q_b_i; // input signals

    function bit signed [15:0] normalize_real_Q1_15_format(real signed_val);
        bit signed [15:0]tmp_val;
        if (signed_val > 32767.0) begin
            tmp_val = $rtoi(32767.0);
        end else if (signed_val < -32768.0) begin
            tmp_val = $rtoi(-32768.0);
        end else begin
            tmp_val = $rtoi(signed_val);
        end
        return tmp_val;
    endfunction : normalize_real_Q1_15_format

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
        // Q1.15 format is the hardware. we tried to use int bits to represent real number
        // so to convert from bits to real, we need to divide by 32768
        in_q_a_r = $itor(q_pkt.alpha_real) / 32768.0;
        in_q_a_i = $itor(q_pkt.alpha_imag) / 32768.0;
        in_q_b_r = $itor(q_pkt.beta_real) / 32768.0;
        in_q_b_i = $itor(q_pkt.beta_imag) / 32768.0;
        sv_apply_quantum_gates(q_pkt.gate_select, in_q_a_r, in_q_a_i, in_q_b_r, in_q_b_i, 
                                out_q_a_r, out_q_a_i, out_q_b_r, out_q_b_i);

        expected_out_q_pkt.out_alpha_real = normalize_real_Q1_15_format(out_q_a_r * 32768.0);
        expected_out_q_pkt.out_alpha_imag = normalize_real_Q1_15_format(out_q_a_i * 32768.0);
        expected_out_q_pkt.out_beta_real = normalize_real_Q1_15_format(out_q_b_r * 32768.0);
        expected_out_q_pkt.out_beta_imag = normalize_real_Q1_15_format(out_q_b_i * 32768.0);

        expected_out_q_pkt.alpha_real = q_pkt.alpha_real;
        expected_out_q_pkt.alpha_imag = q_pkt.alpha_imag;
        expected_out_q_pkt.beta_real = q_pkt.beta_real;
        expected_out_q_pkt.beta_imag = q_pkt.beta_imag;
        expected_out_q_pkt.gate_select = q_pkt.gate_select;
        expected_out_q_pkt.gate_evolve = q_pkt.gate_evolve;
        expected_out_q_pkt.gate_done = q_pkt.gate_done;
        expected_out_q_pkt.load_en = q_pkt.load_en;
        pred_golden_data_ap.write(expected_out_q_pkt);
    endfunction : write
endclass : tb_quantum_gates_pred