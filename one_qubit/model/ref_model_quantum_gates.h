#include <complex>

struct QubitState {
    std::complex<double> alpha;
    std::complex<double> beta;
};

enum class QuantumGates {X_gate, Y_gate, Z_gate, H_gate};

QubitState apply_quantum_gate(QuantumGates gate_select, QubitState input_qubit);