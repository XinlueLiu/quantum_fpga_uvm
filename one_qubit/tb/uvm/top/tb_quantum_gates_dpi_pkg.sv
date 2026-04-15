package tb_quantum_gates_dpi_pkg;

import "DPI-C" function void sv_apply_quantum_gates(
    input int gate_select_int,
    input real alpha_real,
    input real alpha_imag,
    input real beta_real,
    input real beta_imag,
    output real out_alpha_real,
    output real out_alpha_imag,
    output real out_beta_real,
    output real out_beta_imag
);

endpackage : tb_quantum_gates_dpi_pkg