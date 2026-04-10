module quantum_gates (
    input logic [1:0] gate_select,
    input logic signed [15:0] in_alpha_real,  // a+bj, value a
    input logic signed [15:0] in_alpha_imag,  // a+bj, value b
    input logic signed [15:0] in_beta_real,   // c+dj, value c
    input logic signed [15:0] in_beta_imag,   // c+dj, value d
    output logic signed [15:0] out_alpha_real,  // a+bj, value a
    output logic signed [15:0] out_alpha_imag,  // a+bj, value b
    output logic signed [15:0] out_beta_real,   // c+dj, value c
    output logic signed [15:0] out_beta_imag   // c+dj, value d
);

logic signed [31:0] tmp_val_ar;
logic signed [31:0] tmp_val_ai;
logic signed [31:0] tmp_val_br;
logic signed [31:0] tmp_val_bi;

logic signed [15:0] out_alpha_real_tmp;
logic signed [15:0] out_alpha_imag_tmp;
logic signed [15:0] out_beta_real_tmp;
logic signed [15:0] out_beta_imag_tmp;

assign tmp_val_ar = (in_alpha_real + in_beta_real)*16'sh5a82;
assign tmp_val_ai = (in_alpha_imag + in_beta_imag)*16'sh5a82;
assign tmp_val_br = (in_alpha_real - in_beta_real)*16'sh5a82;
assign tmp_val_bi = (in_alpha_imag - in_beta_imag)*16'sh5a82;

assign out_alpha_real_tmp = tmp_val_ar[30:15];
assign out_alpha_imag_tmp = tmp_val_ai[30:15];
assign out_beta_real_tmp = tmp_val_br[30:15];
assign out_beta_imag_tmp = tmp_val_bi[30:15];

always_comb begin
    out_alpha_real = '0;
    out_alpha_imag = '0;
    out_beta_real = '0;
    out_beta_imag = '0;

    case (gate_select)
        2'b00: begin
            // X gate. a 180 degree rotation on the X axis(+ and -). It acts like a bit flip
            /* 
                [0 1][a + bj]---> [c + dj] 
                [1 0][c + dj]     [a + bj] 
            */
            out_alpha_real = in_beta_real;
            out_alpha_imag = in_beta_imag;
            out_beta_real = in_alpha_real;
            out_beta_imag = in_alpha_imag;
        end
        2'b01: begin
            // Y gate. its like a combination of X gate and Z gate. 
            /*
                [0 -j][a + bj]---> [-jc + d] 
                [j 0 ][c + dj]     [aj - b ] 
            */
            out_alpha_real = in_beta_imag;
            out_alpha_imag = -1 * in_beta_real;
            out_beta_real = -1 * in_alpha_imag;
            out_beta_imag = in_alpha_real;
        end
        2'b10: begin
            // Z gate. a 180 degree rotation on the Z axis(0 and 1). It acts like a phase shift
            /*
                [1 0 ][a + bj]---> [a + bj] 
                [0 -1][c + dj]     [-c - dj] 
            */
            out_alpha_real = in_alpha_real;
            out_alpha_imag = in_alpha_imag;
            out_beta_real = -1 * in_beta_real;
            out_beta_imag = -1 * in_beta_imag;
        end
        2'b11: begin
            // H gate. it switch between axes and creates superposition
            /*
                1/sqrt(2) * [1 1 ][a + bj]---> 1/sqrt(2) * [a+c + (b+d)j] 
                1/sqrt(2) * [1 -1][c + dj]     1/sqrt(2) * [a-c + (b-d)j] 
            */
            
            out_alpha_real = out_alpha_real_tmp;
            out_alpha_imag = out_alpha_imag_tmp;
            out_beta_real = out_beta_real_tmp;
            out_beta_imag = out_beta_imag_tmp;
        end
        default: begin
            // no-op
            out_alpha_real = in_alpha_real;
            out_alpha_imag = in_alpha_imag;
            out_beta_real = in_beta_real;
            out_beta_imag = in_beta_imag;
        end
    endcase
end

endmodule 