from qiskit import __version__
import numpy as np
from qiskit.visualization import array_to_latex

# verison check
print(__version__)

# ket0 and ket1
# [[1],
#  [0]]
ket0 = np.array([[1], [0]])
# [[0],
#  [1]]
ket1 = np.array([[0], [1]])
#[[0.5]
# [0.5]]
superposition = (ket0 / 2 + ket1 / 2)
print(superposition)

M1 = np.array([[1, 1], [0, 0]])
M2 = np.array([[1, 0], [0, 1]])
M = M1 / 2 + M2 / 2
print(M1)
print(M2)
print(M)

print("matrix multiplication")
print(np.matmul(M1, ket1))
print(array_to_latex(np.matmul(M1, ket1)))
print(np.matmul(M1, M2))
print(array_to_latex(np.matmul(M1, M2)))
print(np.matmul(M,M))
print(array_to_latex(np.matmul(M,M)))