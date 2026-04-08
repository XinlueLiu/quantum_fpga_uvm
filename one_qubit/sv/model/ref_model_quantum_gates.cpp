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