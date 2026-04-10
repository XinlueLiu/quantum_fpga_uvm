from qiskit.quantum_info import Statevector
from numpy import sqrt
from qiskit.circuit.library import XGate, YGate, ZGate, HGate

states = [
    ("0",  Statevector([1, 0])),
    ("1",  Statevector([0, 1])),
    ("+",  Statevector([1/sqrt(2), 1/sqrt(2)])),
    ("-",  Statevector([1/sqrt(2), -1/sqrt(2)])),
    ("i",  Statevector([1/sqrt(2), 1.0j/sqrt(2)])),
    ("-i", Statevector([1/sqrt(2), -1.0j/sqrt(2)])),
]

gates = [("X", XGate()), ("Y", YGate()), ("Z", ZGate()), ("H", HGate())]

print("state,gate,alpha_real,alpha_imag,beta_real,beta_imag")

for state_name, state in states:
    for gate_name, gate in gates:
        result = state.evolve(gate)
        alpha = result.data[0]
        beta = result.data[1]
        print(f"{state_name},{gate_name},{alpha.real:.10f},{alpha.imag:.10f},{beta.real:.10f},{beta.imag:.10f}")
