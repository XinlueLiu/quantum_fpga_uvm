#ifndef REF_MODEL_QUANTUM_GATES_H
#define REF_MODEL_QUANTUM_GATES_H
#include <complex>

struct QubitState {
    std::complex<double> alpha;
    std::complex<double> beta;
};

enum class QuantumGates {X_gate = 0, Y_gate = 1, Z_gate = 2, H_gate = 3};

QubitState apply_quantum_gate(QuantumGates gate_select, QubitState input_qubit);

#endif