#include <stdio.h>
#include "ref_model_quantum_gates.h"

int main(){
    QubitState input_qubit;
    QubitState output_qubit;
    input_qubit.alpha = {1, 0}; // 0
    input_qubit.beta = {0, 0}; // 0
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
    input_qubit.alpha = {0, 0}; // 1
    input_qubit.beta = {1, 0}; // 1
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
    input_qubit.alpha = {1.0/sqrt(2), 0}; // +
    input_qubit.beta = {1.0/sqrt(2), 0}; // +
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
    input_qubit.alpha = {1.0/sqrt(2), 0}; // -
    input_qubit.beta = {-1.0 * 1.0/sqrt(2), 0}; // -
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
    input_qubit.alpha = {1.0/sqrt(2), 0}; // i
    input_qubit.beta = {0, 1.0/sqrt(2)}; // i
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
    input_qubit.alpha = {1.0/sqrt(2), 0}; // -i
    input_qubit.beta = {0, -1.0/sqrt(2)}; // -i
    for(int i = 0; i < 4; i++){
        output_qubit = apply_quantum_gate(static_cast<QuantumGates>(i), input_qubit);
        printf("alpha: (%f, %f) beta: (%f, %f)\n",                                                                                       
        output_qubit.alpha.real(), output_qubit.alpha.imag(),                                                                        
        output_qubit.beta.real(), output_qubit.beta.imag()); 
    }
}