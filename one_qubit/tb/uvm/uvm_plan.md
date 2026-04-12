# UVM Plan — `quantum_gate_controller` DUT

## 1. Directory Structure

```
tb/uvm/
├── tb_top.sv                   # Top-level: clock, reset, DUT, interface, run_test()
├── tb_quantum_gates_pkg.sv                # Package: imports UVM, includes all UVM files below
├── tb_quantum_gates_if.sv                 # Interface matching quantum_gate_controller ports
├── tb_quantum_gates_seq_item.sv           # Transaction object
├── tb_quantum_gates_base_seq.sv           # Base sequence (single gate operation)
├── tb_quantum_gates_random_seq.sv         # Constrained-random sequence
├── tb_quantum_gates_directed_seq.sv       # Corner-case directed sequence
├── tb_quantum_gates_driver.sv             # Drives load_en, gate_evolve, gate_select, state inputs
├── tb_quantum_gates_sequencer.sv          # Routes seq_items to driver
├── tb_quantum_gates_monitor.sv            # Samples interface, emits transactions on analysis ports
├── tb_quantum_gates_predictor.sv          # Calls C++ ref model via DPI-C, emits expected output
├── tb_quantum_gates_scoreboard.sv         # Compares RTL output vs predictor, double→Q conversion
├── tb_quantum_gates_coverage.sv           # Functional coverage collector
├── tb_quantum_gates_agent.sv              # Builds driver, sequencer, monitor
├── tb_quantum_gates_env_config.sv         # Config object (Q-format params, tolerance)
├── tb_quantum_gates_env.sv                # Builds agent, predictor, scoreboard, coverage, wiring
├── tb_quantum_gates_base_test.sv          # Base test class
└── Makefile                    # Compile & run targets
```

Reference model (already exists, just needs DPI-C wrapper):

```
model/
├── ref_model_quantum_gates.cpp   # Existing — pure double math
├── ref_model_quantum_gates.h     # Existing
└── ref_model_dpi.cpp             # NEW — thin DPI-C wrapper
```

## 2. Interface — `tb_quantum_gates_if.sv`

Mirrors `quantum_gate_controller` ports:

- `clk`, `rst_n`
- `load_en`, `gate_evolve`, `gate_select[1:0]`
- `alpha_real[15:0]`, `alpha_imag[15:0]`, `beta_real[15:0]`, `beta_imag[15:0]`
- `gate_done`
- `out_alpha_real[15:0]`, `out_alpha_imag[15:0]`, `out_beta_real[15:0]`, `out_beta_imag[15:0]`

Two clocking blocks:

- **driver_cb** `@(posedge clk)` — drives inputs
- **monitor_cb** `@(posedge clk)` — samples all signals

## 3. Sequence Item — `tb_quantum_gates_seq_item.sv`

Fields:

- `logic [1:0] gate_select` — X(00), Y(01), Z(10), H(11)
- `logic signed [15:0] alpha_real, alpha_imag, beta_real, beta_imag` — initial state (used only on load)
- `bit is_load` — 1 = load initial state, 0 = apply gate
- **Output side** (filled by monitor, used by scoreboard):
  - `logic signed [15:0] out_alpha_real, out_alpha_imag, out_beta_real, out_beta_imag`

Constraints:

- `gate_select` inside `{2'b00, 2'b01, 2'b10, 2'b11}`
- When `is_load == 0`, input state fields are don't-care (state comes from internal register)

## 4. Sequences

**`tb_quantum_gates_base_seq`** — abstract parent, provides `body()` framework

**`tb_quantum_gates_directed_seq`** — explicit test vectors:

- Load |0⟩ → apply each gate → check known results
- Load |1⟩ → apply each gate
- Load |+⟩, |−⟩ → apply each gate
- Identity checks: X→X, H→H (should return to original state)
- Chain: load |0⟩ → H → Z → H → should give |1⟩

**`tb_quantum_gates_random_seq`** — N iterations:

- First item: `is_load = 1` with random initial state
- Remaining items: `is_load = 0`, random `gate_select`
- Configurable chain length before reloading

## 5. Driver — `tb_quantum_gates_driver.sv`

Gets `tb_quantum_gates_seq_item` from sequencer. Two modes based on `is_load`:

**Load transaction:**

1. Drive `alpha_real/imag`, `beta_real/imag` onto interface
2. Assert `load_en` for one clock cycle
3. Deassert, `item_done()`

**Gate transaction:**

1. Drive `gate_select`
2. Assert `gate_evolve` for one clock cycle
3. Wait for `gate_done` to go high (next cycle)
4. Deassert, `item_done()`

## 6. Monitor — `tb_quantum_gates_monitor.sv`

Two analysis ports:

- **`input_ap`** — emits transaction with (gate_select, current state *before* gate) on every `gate_evolve`
- **`output_ap`** — emits transaction with (output state) when `gate_done` goes high

Key detail: on `gate_evolve`, the monitor must capture the current output signals (which reflect `state_reg` = the input to the gate) *before* the clock edge latches the new result. On the next cycle when `gate_done` is high, capture the new outputs.

Also monitors `load_en` transactions — sends these to the predictor so it can track internal state.

## 7. Predictor — `tb_quantum_gates_predictor.sv`

- Subscribes to monitor's `input_ap`
- Maintains its own copy of the qubit state as **doubles**
- On load transaction: stores the loaded state (converting Q1.15 → double)
- On gate transaction: calls C++ ref model via DPI-C with current double state + gate_select, updates its internal state with the result
- Sends expected output as doubles to scoreboard via `expected_ap`

## 8. DPI-C Wrapper — `ref_model_dpi.cpp`

Thin layer:

- DPI-C exported function: `void apply_gate_dpi(int gate_select, double in_ar, double in_ai, double in_br, double in_bi, double* out_ar, double* out_ai, double* out_br, double* out_bi)`
- Maps `gate_select` int → `QuantumGates` enum
- Calls existing `apply_quantum_gate()`
- Returns results through output pointers

## 9. Scoreboard — `tb_quantum_gates_scoreboard.sv`

Two TLM input ports:

- From predictor: expected state as **doubles**
- From monitor's `output_ap`: actual state as **Q1.15**

On comparison:

1. Convert predictor doubles → Q1.15 (multiply by 2^15, truncate toward zero, clamp to signed 16-bit)
2. Compare all 4 components bit-exact (or within configured LSB tolerance)
3. On mismatch, log both formats: `"expected 0.7071 (Q: 0x5A82), got Q: 0x5A80"`
4. Track pass/fail counts, report in `report_phase`

## 10. Coverage — `tb_quantum_gates_coverage.sv`

Subscribes to monitor's `input_ap`.

Covergroups:

- **gate_cg** — all 4 gate types hit
- **state_cg** — bins for |0⟩, |1⟩, |+⟩, |−⟩, random
- **gate_cross_state** — gate_type × input_state
- **chain_cg** — consecutive gate pairs (X→H, H→Z, etc.) to catch state-dependent bugs
- **load_then_gate** — that every gate type is tested after a fresh load

## 11. Agent — `tb_quantum_gates_agent.sv`

- Active mode: builds driver + sequencer + monitor
- Passive mode: monitor only
- Connects sequencer to driver, exposes monitor's analysis ports

## 12. Environment — `tb_quantum_gates_env.sv`

Builds and wires:

```
Agent → Monitor ──[input_ap]──→ Predictor ──[expected_ap]──→ Scoreboard
                 ──[output_ap]────────────────────────────→ Scoreboard
                 ──[input_ap]──→ Coverage
```

Takes `tb_quantum_gates_env_config` from config_db.

## 13. Env Config — `tb_quantum_gates_env_config.sv`

- `int frac_bits = 15` — Q-format fractional bits
- `int tolerance_lsb = 0` — 0 for sign-off, >0 for bring-up debug
- `bit has_coverage = 1` — enable/disable coverage collector
- `bit is_active = 1` — agent mode

## 14. Base Test — `tb_quantum_gates_base_test.sv`

- Creates env config, sets in config_db
- Creates env
- Default: runs `tb_quantum_gates_directed_seq` then `tb_quantum_gates_random_seq`
- `report_phase`: check scoreboard pass/fail

## 15. tb_top.sv

- Clock generation (10ns period or whatever you prefer)
- Reset sequence (active-low, hold for N cycles)
- `tb_quantum_gates_if` instantiation, connected to clock
- `quantum_gate_controller` DUT instantiation, connected to interface
- `uvm_config_db#(virtual tb_quantum_gates_if)::set` for the agent
- `run_test()`

## 16. Build Order

| Step | What | Validates |
|------|-------|-----------|
| 1 | `tb_quantum_gates_if.sv` + `tb_top.sv` | DUT compiles and connects |
| 2 | `tb_quantum_gates_seq_item.sv` | Transaction compiles |
| 3 | `tb_quantum_gates_driver.sv` + `tb_quantum_gates_sequencer.sv` | Can drive load + gate_evolve, check waveforms |
| 4 | `tb_quantum_gates_monitor.sv` | Transactions printed to log, verify timing |
| 5 | `ref_model_dpi.cpp` | DPI-C links and returns correct values |
| 6 | `tb_quantum_gates_predictor.sv` | Expected values match hand calculations |
| 7 | `tb_quantum_gates_scoreboard.sv` | Automated pass/fail, double→Q conversion correct |
| 8 | `tb_quantum_gates_agent.sv` + `tb_quantum_gates_env.sv` + `tb_quantum_gates_base_test.sv` | Full end-to-end run |
| 9 | `tb_quantum_gates_directed_seq.sv` | Known-answer tests pass |
| 10 | `tb_quantum_gates_random_seq.sv` + `tb_quantum_gates_coverage.sv` | Coverage closure |

## 17. What Transfers to Multi-Qubit

| Component | Reuse | Change needed |
|-----------|-------|---------------|
| Scoreboard | Direct reuse | Widen comparison to N-qubit state vector |
| Predictor + DPI-C | Direct reuse | Extend C++ model for multi-qubit gates |
| Agent/env/test hierarchy | Direct reuse | Unchanged |
| Seq item | Extend | Add qubit index, multi-qubit gate types |
| Driver/monitor | Modify | New interface signals for multi-qubit controller |
| Coverage | Extend | Add multi-qubit cross coverage |
