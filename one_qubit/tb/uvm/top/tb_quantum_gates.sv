// top level
module tb_quantum_gates;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import tb_quantum_gates_pkg::*;

    bit clk, rst_n;
    always #10 clk <= ~clk;

    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    quantum_gate_if qif (clk, rst_n);
    quantum_gate_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(qif.load_en),
        .gate_evolve(qif.gate_evolve),
        .gate_select(qif.gate_select),
        .alpha_real(qif.alpha_real),
        .alpha_imag(qif.alpha_imag),
        .beta_real(qif.beta_real),
        .beta_imag(qif.beta_imag),
        .gate_done(qif.gate_done),
        .out_alpha_real(qif.out_alpha_real),
        .out_alpha_imag(qif.out_alpha_imag),
        .out_beta_real(qif.out_beta_real),
        .out_beta_imag(qif.out_beta_imag)
    );

    initial begin
        // set the handle of interface
        // virtual quantum_gate_if is type of item being stored, virtual because its a handler
        // null is context. since this is top level instead of a class, this is null(static top level)
        // * is the path thats allowed to see the data. * for everyone 
        uvm_config_db #(virtual quantum_gate_if)::set(null, "*", "qif", qif);
        run_test("tb_quantum_gates_base_tests");
    end

    initial begin
        $dumpfile("tb_quantum_gates_uvm.vcd");
        $dumpvars;
    end

endmodule 