import csv
import sys

TOLERANCE = 1e-6

def load_csv(path):
    with open(path) as f:
        return list(csv.DictReader(f))

cpp_results = load_csv(sys.argv[1])
qiskit_results = load_csv(sys.argv[2])

if len(cpp_results) != len(qiskit_results):
    print(f"FAIL: row count mismatch (C++: {len(cpp_results)}, Qiskit: {len(qiskit_results)})")
    sys.exit(1)

fields = ["alpha_real", "alpha_imag", "beta_real", "beta_imag"]
fail_count = 0

for i, (cpp, qsk) in enumerate(zip(cpp_results, qiskit_results)):
    state = cpp["state"]
    gate = cpp["gate"]
    errors = []
    for f in fields:
        diff = abs(float(cpp[f]) - float(qsk[f]))
        if diff > TOLERANCE:
            errors.append(f"{f}: C++={cpp[f]} Qiskit={qsk[f]} diff={diff:.2e}")
    if errors:
        fail_count += 1
        print(f"FAIL |{state}> + {gate}: {', '.join(errors)}")
    else:
        print(f"PASS |{state}> + {gate}")

print(f"\n{len(cpp_results) - fail_count}/{len(cpp_results)} tests passed")
sys.exit(1 if fail_count else 0)
