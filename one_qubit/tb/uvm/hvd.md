# Hardware Verification Plan — `quantum_gate_controller`

| | |
|--|--|
| Rev | 0.3 |
| Date | 2026-04-11 |
| DUT | `design/quantum_gate_controller.sv` |

---

## 1. Scope

### 1.1 DUT
`quantum_gate_controller.sv` — a sequential wrapper around the combinational `quantum_gates.sv` module. Holds a 1-qubit state vector in a local register and applies X/Y/Z/H gates in-place. This HVP covers the controller + the gate block it instantiates.

### 1.2 What is verified here
- `quantum_gate_controller.sv` (top)
- `quantum_gates.sv` (sub-module, compiled in)

### 1.3 What is **not** verified here
- `single_qubit.sv` measurement logic — separate HVP once the collapse bug is fixed
- `lfsr.sv` — exercised by `single_qubit` HVP
- Multi-qubit gates — future phase
- Power, area, timing, synthesis

### 1.4 Reference documents
| Doc | Role |
|--|--|
| `design/quantum_gate_controller.sv`, `design/quantum_gates.sv` | RTL |
| `model/ref_model_quantum_gates.cpp` | Golden reference (double precision), used via DPI-C |
| `tb/model_tb/qiskit_ref_model.py` | Cross-validation of the C++ reference against Qiskit |
| `tb/uvm/uvm_plan.md` | TB implementation / architecture spec |

### 1.5 Number format
- Amplitudes are **Q1.15 signed fixed-point**: value = raw / 32768. `0x5A82 ≈ 1/√2`.
- 1 LSB ≈ 3.05 × 10⁻⁵.

---

## 2. DUT Interface

| Signal | Dir | Width | Notes |
|--|--|--|--|
| `clk` | in | 1 | Positive-edge active |
| `rst_n` | in | 1 | Async active-low |
| `load_en` | in | 1 | Pulse to latch input α/β |
| `gate_evolve` | in | 1 | Pulse to apply `gate_select` to current state |
| `gate_select` | in | 2 | `00`=X, `01`=Y, `10`=Z, `11`=H |
| `alpha_real/imag`, `beta_real/imag` | in | 16 signed ea | Q1.15 input state |
| `gate_done` | out | 1 | Single-cycle pulse on the cycle `state_reg` updates from `gate_evolve` |
| `out_alpha_real/imag`, `out_beta_real/imag` | out | 16 signed ea | Combinational view of `state_reg` |

---

## 3. Features

### Control & handshake
| ID | Feature |
|--|--|
| F1 | Async reset clears `state_reg` to zero and deasserts `gate_done` |
| F2 | `load_en` pulse latches input α/β into `state_reg` with 1-cycle latency |
| F3 | `gate_evolve` pulse applies `gate_select` to current state with 1-cycle latency |
| F4 | `gate_done` is a single-cycle pulse asserted iff `gate_evolve` fired the previous cycle (no collision); low otherwise |
| F5 | `load_en` and `gate_evolve` are mutually exclusive — asserting both in the same cycle is illegal (SA1) |
| F6 | Outputs reflect `state_reg` combinationally; post-reset outputs are zero |
| F7 | Input state at `load_en` time must satisfy `|α|² + |β|² = 1` within Q1.15 tolerance (SA3) |

### Datapath — gate math
| ID | Feature |
|--|--|
| F8  | X gate: `(α, β) → (β, α)` — bit-exact |
| F9  | Y gate: `(α, β) → (−i·β, i·α)` — bit-exact |
| F10 | Z gate: `(α, β) → (α, −β)` — bit-exact |
| F11 | H gate: `(α, β) → ((α+β)/√2, (α−β)/√2)` — within ±1 LSB of ideal |

### Composition
| ID | Feature |
|--|--|
| F12 | Gate chaining: output of one gate is the input to the next without reload |
| F13 | Involution: X·X = Y·Y = Z·Z = I bit-exact; H·H = I within bounded drift |
| F14 | Known composite: H·Z·H·\|0⟩ = \|1⟩ within bounded drift |

---

## 4. Scenarios

**Random state generation:** random sequences draw `(θ, φ)` uniformly over the Bloch sphere, compute `α = cos(θ/2)`, `β = e^(iφ)·sin(θ/2)` as doubles, quantize to Q1.15. This satisfies SA3 (F7) by construction. ~5% of draws are biased to canonical angles to guarantee basis states are hit early.

### F1 — Reset
- **S1.1** Reset clears non-zero state
- **S1.2** Reset asserted mid-pulse drops the pulse and clears state
- **S1.3** Reset release with random inputs → DUT responds normally from cycle 0

### F2 / F7 — Load
- **S2.1** Load each of the 6 canonical states: `|0⟩`, `|1⟩`, `|+⟩`, `|−⟩`, `|+i⟩`, `|−i⟩`
- **S2.2** Load normalized random state
- **S2.3** Load `alpha_real = 0x8000` (−1.0 in Q1.15) — normalized, probes SA5 via Y/Z later

### F3, F4 — gate_evolve + handshake
- **S3.1** Single `gate_evolve` pulse → one `gate_done` pulse one cycle later
- **S3.2** `gate_evolve` held high across N cycles → N gate applications, N `gate_done` pulses (SA2)
- **S3.3** All 24 (state × gate) directed vectors from `test_ref_model.cpp`

### F8 — X gate
- **S8.1** X·\|0⟩ = \|1⟩, X·\|1⟩ = \|0⟩
- **S8.2** X·\|+⟩ = \|+⟩, X·\|−⟩ = −\|−⟩ (eigenstates)
- **S8.3** X on random state — bit-exact vs C++ model
- **S8.4** X·X = I

### F9 — Y gate
- **S9.1** Y·\|0⟩ = i·\|1⟩, Y·\|1⟩ = −i·\|0⟩
- **S9.2** Y·\|+i⟩ = \|+i⟩, Y·\|−i⟩ = −\|−i⟩
- **S9.3** Y on random state
- **S9.4** Y·Y = I
- **S9.5** Y with `0x8000` in any component — probes SA5

### F10 — Z gate
- **S10.1** Z·\|0⟩ = \|0⟩, Z·\|1⟩ = −\|1⟩
- **S10.2** Z·\|+⟩ = \|−⟩, Z·\|−⟩ = \|+⟩
- **S10.3** Z on random state
- **S10.4** Z·Z = I
- **S10.5** Z with `0x8000` in β components — probes SA5

### F11 — H gate
- **S11.1** H·\|0⟩ = \|+⟩ (expect `α_r = β_r = 0x5A82`)
- **S11.2** H·\|1⟩ = \|−⟩ (expect `α_r = 0x5A82, β_r = 0xA57E`)
- **S11.3** H·\|+⟩ = \|0⟩, H·\|−⟩ = \|1⟩ (±1 LSB)
- **S11.4** H applied N = 1..20 times on random state — measure maximum drift
- **S11.5** H·Z·H·\|0⟩ = \|1⟩ within bounded drift

### F12, F13 — Chaining
- **S12.1** Chain `|0⟩ → H → Z → H` → `|1⟩`
- **S12.2** Random gate chain length 2–20, per-step scoreboard check
- **S12.3** Every gate followed by every other gate at least once (4×4 pairs)

### Negative / probe scenarios
Driven by a dedicated `qubit_negative_seq`; constrained-random must never reach these.

- **SN.1** Assert `load_en` and `gate_evolve` in the same cycle → expect A5 to fire (F5, SA1)
- **SN.2** Load all-zero state → expect A7 to fire (F7, SA3)
- **SN.3** Load unnormalized state → expect A7 to fire
- **SN.4** **SA4 probe.** Disable A7 and scoreboard, load `α_r = β_r = 0x7FFF`, apply H, capture outputs. Decides empirically whether the 16-bit add in `quantum_gates.sv:23` wraps or is width-extended by the simulator

---

## 5. Coverage Plan

### 5.1 Functional coverage

**gate_cg** — sampled on every accepted `gate_evolve`
- `cp_gate`: {X, Y, Z, H}

**state_cg** — Bloch-angle bins, sampled on every accepted `gate_evolve`. The predictor holds a double-precision mirror; at sample time the scoreboard computes `(θ, φ)` from that mirror.
- `cp_theta`: 5 bins — `{pole_0, near_0, equator, near_1, pole_1}`
- `cp_canonical_state`: `{|0⟩, |1⟩, |+⟩, |−⟩, |+i⟩, |−i⟩, other}` matched by Q1.15 hex

**gate_x_state_cross** — `cp_gate × cp_canonical_state` — 4 × 7 = 28 bins, each ≥ 1 hit

**chain_cg** — sampled on `gate_evolve`, uses `prev_gate`
- `cp_chain_pair`: 16 bins for (prev_gate, this_gate), each ≥ 1 hit

### 5.2 Code coverage targets
| Metric | Target |
|--|--|
| Statement, branch, expression | 100% |
| Toggle (DUT ports) | 100% |

---

## 6. Spec Ambiguities And Assumptions

### SA1 — `load_en` + `gate_evolve` in the same cycle
**RTL:** `if (load_en) ... else if (gate_evolve)` → load wins, `gate_done` stays 0.
**Resolution:** Collision is illegal. Driver must place at least one idle cycle between `load_en` and `gate_evolve`. Enforced by A5. **Status: resolved.**

### SA2 — `gate_evolve` held high for multiple cycles
**RTL:** Gate applies on every cycle `gate_evolve` is high.
**Resolution:** Both single-pulse and held-high are legal. Held-high = throughput-oriented multi-apply. Covered by S3.1 and S3.2. **Status: resolved.**

### SA3 — Input normalization
**RTL:** No constraint.
**Resolution:** `|α|² + |β|² = 1` within Q1.15 tolerance is a load-time precondition. Enforced by A7; random sequences generate normalized states parametrically. Negative tests SN.2 / SN.3 confirm A7 fires. **Status: resolved.**

### SA4 — H gate 16-bit add overflow (deferred, potential bug)
**RTL:** `quantum_gates.sv:23`: `tmp_val_ar = (in_alpha_real + in_beta_real) * 16'sh5a82` into a 32-bit LHS. Whether `(α_r + β_r)` evaluates in 16 or 32 bits depends on SV context-propagation rules (LRM §11.8.3) and is simulator-dependent. Under SA3, `H|+⟩` has `α_r = β_r = 0x5A82` whose sum exceeds 16-bit signed range. SN.4 probes this corner and the observed output resolves the question. **Status: deferred — run SN.4.**

### SA5 — 2's complement negation on `0x8000` (deferred, potential bug)
**RTL:** Y and Z compute `-1 * value`. `-1 * 0x8000 = 0x8000` in 16-bit signed. `0x8000` encodes −1.0 which is legal and normalized. Probed by S9.5, S10.5. **Status: deferred — run probe tests.**

---

## 7. Assertions (SVA)

| ID | Property | Severity |
|--|--|--|
| A1 | `(gate_evolve && !load_en) \|=> gate_done` — gate_evolve causes gate_done next cycle | Error |
| A2 | `gate_done \|=> !gate_done` — gate_done is at most one cycle wide | Error |
| A3 | `!rst_n \|-> ##1 (all state_reg outputs == 0)` — reset clears state | Error |
| A4 | `$fell(gate_done) \|-> !$past(gate_evolve, 2)` (approx.) — gate_done only from gate_evolve | Error |
| A5 | `not (load_en && gate_evolve)` — collision is illegal (F5, SA1) | Error |
| A6 | `gate_select inside {2'b00, 2'b01, 2'b10, 2'b11}` — defensive check | Warn |
| A7 | On `load_en`: `abs((α_r² + α_i² + β_r² + β_i²) − 2^30) ≤ NORM_TOLERANCE`, products sign-extended to 32 bits. Input state normalized within Q1.15 limits (F7, SA3). `NORM_TOLERANCE` default ~16 (≈ 1.5e-8 in normalized units) | Error |

Clocked `@(posedge clk) disable iff (!rst_n)` unless they describe reset itself.

---

## 8. Checking Strategy

| Feature | Mechanism |
|--|--|
| F1, F6 (reset) | SVA A3 + scoreboard post-reset check |
| F2, F3, F4 | Scoreboard value check + SVA A1, A2, A4 + latency cycle-stamp |
| F5 | SVA A5 + SN.1 |
| F7 | SVA A7 + SN.2, SN.3 |
| F8–F11 | C++ reference model via DPI-C. Predictor → scoreboard double→Q1.15 conversion. Bit-exact on X/Y/Z; ≤1 LSB on H |
| F12–F14 | Predictor chains transactions without reload, per-step scoreboard comparison. H-chain drift budget TBD after SA4 |

---

## 9. Traceability Matrix

| Feature | Scenarios | Coverage | Assertion | Primary test |
|--|--|--|--|--|
| F1 | S1.1–S1.3 | — | A3 | `reset_test` |
| F2 | S2.1–S2.3 | state_cg | — | `load_test` |
| F3 | S3.1–S3.3 | gate_cg | A1 | all gate tests |
| F4 | S3.1, S3.2 | — | A2, A4 | all |
| F5 | SN.1 | — | A5 | `negative_collision_test` |
| F6 | every cycle | — | A3 | scoreboard passive check |
| F7 | SN.2, SN.3 | — | A7 | `negative_norm_test` |
| F8  | S8.1–S8.4 | gate_cg[X], gate_x_state_cross[X,*] | — | `directed_x_test`, `random_seq` |
| F9  | S9.1–S9.5 | gate_cg[Y], gate_x_state_cross[Y,*] | — | `directed_y_test`, `random_seq` |
| F10 | S10.1–S10.5 | gate_cg[Z], gate_x_state_cross[Z,*] | — | `directed_z_test`, `random_seq` |
| F11 | S11.1–S11.5 | gate_cg[H], gate_x_state_cross[H,*] | — | `directed_h_test`, `h_drift_test` |
| F12 | S12.1–S12.3 | chain_cg | — | `chain_test` |
| F13 | S8.4, S9.4, S10.4, S11.4 | chain_cg[X,X], [Y,Y], [Z,Z], [H,H] | — | `involution_test` |
| F14 | S12.1 | chain_cg[Z,H], [H,Z] | — | `known_chain_test` |
| SA4 probe | SN.4 | — | — | `sa4_probe_test` (scoreboard off) |
| SA5 probe | S9.5, S10.5 | — | — | `sa5_probe_test` |

Empty rows = unverified features. Empty coverage/assertion cells are acceptable when the check lives elsewhere (e.g. scoreboard).

---

## 10. Sign-off Criteria

1. **Functional coverage:** 100% of bins in §5.1
2. **Code coverage:** 100% statement, branch, expression; 100% toggle on DUT ports
3. **Assertions:** every property in §7 reached and passing in positive traffic
4. **Scoreboard:** 0 mismatches over ≥ 100 random seeds × ≥ 10k transactions each
5. **Directed tests:** every scenario in §4 passes
6. **Negative tests:** SN.1, SN.2, SN.3 each trigger the expected assertion; SN.4 captures output and resolves SA4
7. **Ambiguities:** SA1/2/3 resolved (done); SA4/5 closed by probe results
8. **Review:** HVP signed off by designer; TB architecture (`uvm_plan.md`) signed off by DV peer
