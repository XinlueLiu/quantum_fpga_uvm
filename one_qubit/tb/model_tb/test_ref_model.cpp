#include <stdio.h>
#include "ref_model_quantum_gates.h"

const char* gate_names[] = {"X", "Y", "Z", "H"};

struct NamedState {
    const char* name;
    std::complex<double> alpha;
    std::complex<double> beta;
};

int main(){
    NamedState states[] = {
        {"0",  {1, 0},              {0, 0}},
        {"1",  {0, 0},              {1, 0}},
        {"+",  {1.0/sqrt(2), 0},    {1.0/sqrt(2), 0}},
        {"-",  {1.0/sqrt(2), 0},    {-1.0/sqrt(2), 0}},
        {"i",  {1.0/sqrt(2), 0},    {0, 1.0/sqrt(2)}},
        {"-i", {1.0/sqrt(2), 0},    {0, -1.0/sqrt(2)}},
    };

    // CSV header
    printf("state,gate,alpha_real,alpha_imag,beta_real,beta_imag\n");

    for(auto& s : states){
        QubitState input_qubit;
        input_qubit.alpha = s.alpha;
        input_qubit.beta = s.beta;
        for(int i = 0; i < 4; i++){
            QubitState out = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
            printf("%s,%s,%.10f,%.10f,%.10f,%.10f\n",
                s.name, gate_names[i],
                out.alpha.real(), out.alpha.imag(),
                out.beta.real(), out.beta.imag());
        }
    }
}