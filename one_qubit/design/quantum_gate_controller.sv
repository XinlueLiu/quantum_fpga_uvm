module quantum_gate_controller (
    input logic clk, rst_n,
    input logic load_en,                   // load initial qubit state from inputs
    input logic gate_evolve,               // pulse to apply gate to current state
    input logic [1:0] gate_select,         // which gate to apply
    input logic signed [15:0] alpha_real,  // initial state input
    input logic signed [15:0] alpha_imag,
    input logic signed [15:0] beta_real,
    input logic signed [15:0] beta_imag,
    output logic gate_done,                     // high when gate result is latched
    output logic signed [15:0] out_alpha_real,
    output logic signed [15:0] out_alpha_imag,
    output logic signed [15:0] out_beta_real,
    output logic signed [15:0] out_beta_imag
);

    // internal qubit state register
    logic signed [15:0] state_reg [3:0]; // [0]=a_r, [1]=a_i, [2]=b_r, [3]=b_i

    // combinational gate output
    logic signed [15:0] gate_out_alpha_real, gate_out_alpha_imag, gate_out_beta_real, gate_out_beta_imag;

    // instantiate combinational quantum gates
    quantum_gates u_quantum_gates (
        .gate_select    (gate_select),
        .in_alpha_real  (state_reg[0]),
        .in_alpha_imag  (state_reg[1]),
        .in_beta_real   (state_reg[2]),
        .in_beta_imag   (state_reg[3]),
        .out_alpha_real (gate_out_alpha_real),
        .out_alpha_imag (gate_out_alpha_imag),
        .out_beta_real  (gate_out_beta_real),
        .out_beta_imag  (gate_out_beta_imag)
    );

    // output current state
    assign out_alpha_real = state_reg[0];
    assign out_alpha_imag = state_reg[1];
    assign out_beta_real  = state_reg[2];
    assign out_beta_imag  = state_reg[3];

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 4; i++) begin
                state_reg[i] <= '0;
            end
            gate_done <= 1'b0;
        end else begin
            gate_done <= 1'b0;

            if (load_en) begin
                state_reg[0] <= alpha_real;
                state_reg[1] <= alpha_imag;
                state_reg[2] <= beta_real;
                state_reg[3] <= beta_imag;
            end else if (gate_evolve) begin
                state_reg[0] <= gate_out_alpha_real;
                state_reg[1] <= gate_out_alpha_imag;
                state_reg[2] <= gate_out_beta_real;
                state_reg[3] <= gate_out_beta_imag;
                gate_done <= 1'b1;
            end
        end
    end

endmodule
