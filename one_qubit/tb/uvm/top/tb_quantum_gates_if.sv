// interface file
interface quantum_gate_if(
    input logic clk,
    input logic rst_n
);

    logic load_en;                   // load initial qubit state from inputs
    logic gate_evolve;               // pulse to apply gate to current state
    logic [1:0] gate_select;         // which gate to apply
    logic signed [15:0] alpha_real;  // initial state input
    logic signed [15:0] alpha_imag;
    logic signed [15:0] beta_real;
    logic signed [15:0] beta_imag;
    logic gate_done;                     // high when gate result is latched
    logic signed [15:0] out_alpha_real;
    logic signed [15:0] out_alpha_imag;
    logic signed [15:0] out_beta_real;
    logic signed [15:0] out_beta_imag;

    // driver clocking block

    clocking driver_cb @(posedge clk);
        // input #1step so we read input right before sampling
        // output #1ns, assuming our clock period is 10ns. this simulates the output settles
        default input #1step output #1ns;

        output load_en;
        output gate_evolve;
        output gate_select;
        output alpha_real;
        output alpha_imag;
        output beta_real;
        output beta_imag;

        input gate_done;

    endclocking 

    clocking mon_cb @(posedge clk);
        // nothing to output
        default input #1step;

        input load_en;
        input gate_evolve;
        input gate_select;
        input alpha_real;
        input alpha_imag;
        input beta_real;
        input beta_imag;

        input gate_done;
        input out_alpha_real;
        input out_alpha_imag;
        input out_beta_real;
        input out_beta_imag;
    endclocking

endinterface : quantum_gate_if