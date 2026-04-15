#include "ref_model_quantum_gates.h"
#include <math.h>

QubitState apply_quantum_gate(QuantumGates gate_select, QubitState input_qubit){
    QubitState out_state;

    switch (gate_select) {
        case QuantumGates::X_gate: 
        out_state.alpha = input_qubit.beta;
        out_state.beta = input_qubit.alpha;
        break;
        case QuantumGates::Y_gate:
        out_state.alpha = {input_qubit.beta.imag(), -1 * input_qubit.beta.real()}; 
        out_state.beta = {-1 * input_qubit.alpha.imag(), input_qubit.alpha.real()};
        break;
        case QuantumGates::Z_gate: 
        out_state.alpha = input_qubit.alpha;
        out_state.beta = {-1 * input_qubit.beta.real(), -1 * input_qubit.beta.imag()};
        break;
        case QuantumGates::H_gate: 
        out_state.alpha = {1.0/sqrt(2) * (input_qubit.alpha.real() + input_qubit.beta.real()), 1.0/sqrt(2) * (input_qubit.alpha.imag() + input_qubit.beta.imag())};
        out_state.beta = {1.0/sqrt(2) * (input_qubit.alpha.real() - input_qubit.beta.real()), 1.0/sqrt(2) * (input_qubit.alpha.imag() - input_qubit.beta.imag())};
        break;
        default:
        out_state.alpha = input_qubit.alpha;
        out_state.beta = input_qubit.beta;
    }

    return out_state;
}

// DPI-C wrapper
extern "C" {
    void sv_apply_quantum_gates(
        int gate_select_int,
        double alpha_real,
        double alpha_imag,
        double beta_real,
        double beta_imag,
        double *out_alpha_real,
        double *out_alpha_imag,
        double *out_beta_real,
        double *out_beta_imag
    ){
        // assign back in_state of QubitState type
        QubitState in_state = {
            std::complex<double>(alpha_real, alpha_imag),
            std::complex<double>(beta_real, beta_imag)
        };
        QuantumGates gate_select = static_cast<QuantumGates>(gate_select_int);
        // call calculation function
        QubitState out_state = apply_quantum_gate(gate_select, in_state);
        *out_alpha_real = out_state.alpha.real();
        *out_alpha_imag = out_state.alpha.imag();
        *out_beta_real = out_state.beta.real();
        *out_beta_imag = out_state.beta.imag();
    }
}