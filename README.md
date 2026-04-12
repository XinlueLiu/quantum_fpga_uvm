# Quantum FPGA

A 1-qubit quantum state simulator in SystemVerilog with UVM verification.

## What's Here

All source lives under `one_qubit/`:

- **design/** — Qubit and quantum gate RTL (SystemVerilog)
- **model/** — C++ reference model for quantum gates
- **tb/**
  - `model_tb/` — Python verification of the C++ model against Qiskit
  - `sv_tb/` — SystemVerilog testbench for the 1-qubit system
  - `uvm/` — Full UVM environment: constrained-random tests, functional coverage, assertions, testplan

## Build & Simulate

Requires [Icarus Verilog](https://github.com/steveicarus/iverilog) and [GTKWave](https://gtkwave.sourceforge.net/).

```bash
cd one_qubit
make sim              # Compile and run SV testbench
make wave             # Run sim then open waveform in GTKWave
make verify_golden    # Build C++ model, run Qiskit reference, compare results
make clean
```
