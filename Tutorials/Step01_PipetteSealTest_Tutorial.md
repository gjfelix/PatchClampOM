# Patch Clamp Tutorial — Step 1: Pipette Resistance Measurement in Bath

**Model:** `PatchClamp.Examples.Step01_PipetteSealTest`
**Recommended simulation time:** 0.060 s | Interval: 6 µs | Tolerance: 1×10⁻⁶

---

## 1. Introduction to Patch Clamp Electrophysiology

The **patch clamp technique**, developed by Neher and Sakmann in the late 1970s (Nobel Prize, 1991), is the gold-standard method for measuring electrical currents across cell membranes with picoampere resolution. It allows researchers to study the behavior of individual ion channels, characterize whole-cell membrane properties, and understand the electrical excitability of neurons, muscle cells, and many other cell types.

A typical patch clamp setup consists of:

- A **glass micropipette** filled with an intracellular-like solution, pulled to a very fine tip (1–3 µm diameter).
- A **bath electrode** immersed in the extracellular solution, connected to ground.
- A **feedback amplifier** (patch clamp amplifier) that imposes voltage commands and measures the resulting current with high fidelity.

Before any cell contact is made, the experimenter must verify the **quality and resistance of the pipette** itself. This is the purpose of the **seal-test** protocol — a series of small, repetitive voltage pulses that allow the amplifier to estimate the resistance "seen" at the pipette tip in real time.

This tutorial focuses on the very first step of the patch clamp workflow: **the pipette freely submerged in the bath solution, with no cell contact**. Understanding this baseline state is essential before interpreting the more complex signals observed during gigaseal formation and whole-cell breakthrough.

---

## 2. The Equivalent Circuit

When the pipette is submerged in the bath but has not contacted a cell, the electrical circuit is straightforward:

```
  Amplifier         Patch Pipette             Bath Electrode
  [V_pulse] ──── [R_pip = 4 MΩ] ──── [R_bath = 100 Ω] ──── GND
                 [C_pip = 3 pF ]
```

| Component | Symbol | Typical Value | Physical meaning |
|---|---|---|---|
| Pipette resistance | R_pip | 3–8 MΩ | Determined by tip geometry and solution |
| Pipette capacitance | C_pip | 2–10 pF | Glass wall capacitance to bath solution |
| Bath resistance | R_bath | 100 Ω | Resistance of extracellular solution to ground |
| Command voltage | V_pulse | −5 mV | Seal-test pulse amplitude |

> **Key insight:** Because R_bath (100 Ω) ≪ R_pip (4 MΩ), essentially all of the voltage drop occurs across the pipette tip. The bath electrode is effectively at ground potential.

---

## 3. The Seal-Test Protocol

The seal-test applies **repetitive square voltage pulses** at a fixed frequency. In this model:

| Parameter | Value | Description |
|---|---|---|
| V_pulse | −5 mV | Amplitude of each pulse |
| t_period | 20 ms | Period (50 Hz repetition) |
| t_pulse_width | 10 ms | Duration of each pulse |
| t_start | 2 ms | Delay before first pulse |

The amplifier continuously monitors the resulting current and computes a **real-time estimate of the seal resistance** (`R_seal_est`), which in this configuration reflects R_pip.

---

## 4. Expected Signals and Key Calculations

### 4.1 Steady-state current

`I_measured` follows Ohm's law and steps directly to this value the instant each pulse turns on — there is no transient to wait out:

$$I_{\text{steady}} = \frac{V_{\text{pulse}}}{R_{\text{pip}}} = \frac{-5 \text{ mV}}{4 \text{ MΩ}} = -1.25 \text{ nA}$$

This is the **background current** flowing freely through the open pipette tip into the bath.

### 4.2 Why there is no visible capacitive transient here

`PatchPipette` does include a pipette capacitance `C_pipette` (3 pF), and in general an RC pair like `R_pipette` + `C_pipette` should produce a transient with $\tau_{\text{pip}} = R_{\text{pip}} \times C_{\text{pip}} = 12\ \mu\text{s}$. But in *this* circuit that transient is not observable in `I_measured`: `SealTest` is modeled as an **ideal, zero-output-impedance voltage source**, and `C_pipette` sits directly in parallel with that source's output node. A capacitor wired straight across an ideal voltage source has no charging dynamics of its own — the source dictates its voltage instantly, so there is no series resistance for it to charge through, and its current is (ideally) an instantaneous impulse at each edge rather than a decaying exponential.

A genuine, visible $R \times C$ transient requires the capacitance to sit *downstream* of `R_pipette`, so the ideal source has to charge it *through* that resistor. That is exactly the situation in **Step03** ($\tau_{\text{pip}} = R_{\text{pip}} \times C_m = 40\ \mu\text{s}$, using the cell's membrane capacitance) — compare `I_measured` there with what you see here.

### 4.3 Variables to plot

After running the simulation, examine the following signals:

| Variable | Units | What to look for |
|---|---|---|
| `seal_test.V_command` | V | The square pulse waveform (−5 mV pulses) |
| `seal_test.I_measured` | A | Clean plateau at ~−1.25 nA, stepping instantly at each edge |
| `seal_test.R_seal_est` | Ω | ~4 MΩ during each pulse; idles at `R_pipette_nom` (4 MΩ by default) between pulses |

---

<!-- build:start -->
## Build it yourself

Instead of opening the finished example you can build the model from an empty diagram, which is the best way to see how its blocks fit together. Read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) first.

1. Create a new model named `MyStep01` and open its **Diagram View**.
2. Add the blocks, set their parameters and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `seal_test` | `PatchClamp → Amplifiers → SealTest` (seal-test amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `seal_test`: keep all defaults.

- `pipette`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `seal_test.p` | `pipette.p_amp` |
| `pipette.p_cell` | `bath.p` |
| `seal_test.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.060, Interval = 6e-6, Tolerance = 1e-6.

3. **Check Model**, then **Simulate**.

Compare your model with `PatchClamp → Examples → Step01_PipetteSealTest`: the traces should overlay. From here on, the *Simulation Guide* below works with your `MyStep01` exactly as with the library example.
<!-- build:end -->

## 5. Step-by-Step Simulation Guide

1. Open the model `PatchClamp.Examples.Step01_PipetteSealTest` in your Modelica environment (e.g., OpenModelica or Dymola).
2. Run the simulation with:
   - **Stop time:** 0.060 s
   - **Number of intervals:** 10,000 (or interval = 6×10⁻⁶ s)
   - **Tolerance:** 1×10⁻⁶
3. Plot `seal_test.V_command` and `seal_test.I_measured` on the same time axis.
4. Zoom into the first 0–0.5 ms of the simulation and confirm `I_measured` jumps straight to its plateau with no decaying transient (see §4.2 for why).
5. Measure the steady-state current plateau (e.g., at t = 5–9 ms within the first pulse).
6. Plot `seal_test.R_seal_est` and verify it converges to ~4 MΩ.

---

## 6. Comparison with Later Patch Clamp Steps

Understanding the Step01 baseline puts subsequent steps in context:

| Step | Model | I_steady | Dominant resistance | Physical state |
|---|---|---|---|---|
| **Step01** | Pipette in bath | ~1.25 nA | R_pip = 4 MΩ | Free pipette, no cell |
| **Step02** | Gigaseal formed | ~5 pA | R_seal = 1 GΩ ≫ R_pip | Tight seal on cell membrane |
| **Step03** | Whole-cell | RC transient | R_m ‖ R_pip, C_m | Membrane ruptured, full access |

When a gigaseal forms (Step02), R_seal jumps from ~4 MΩ to >1 GΩ, reducing the current by a factor of ~250. This dramatic drop in `I_measured` — and the corresponding rise in `R_seal_est` — is the experimenter's real-time cue that a successful gigaseal has been achieved.

---

## 7. Exercises

The following exercises use **only the Step01 model**. For each one, change the indicated parameter, re-run the simulation, and answer the questions.

---

### Exercise 1 — Verifying Ohm's Law with Different Pipette Resistances

**Modify:** Change `R_pipette` in the `pipette` component to each of the following values. Also update `R_pipette_nom` in `seal_test` to the same value (this is the nominal value the estimator uses).

| Trial | R_pipette | Expected I_steady |
|---|---|---|
| A | 3 MΩ | ? |
| B | 5 MΩ | ? |
| C | 8 MΩ | ? |

**Tasks:**
1. For each trial, calculate the expected I_steady before simulating. Show your work using I = V/R.
2. Run the simulation and measure I_steady from the `I_measured` plot. Compare with your prediction.
3. Which pipette resistance gives the largest current? Which gives the smallest?
4. In whole-cell patch clamp, pipettes of 3–5 MΩ are generally preferred over higher resistances. Based on your results, propose at least **two reasons** why a very high R_pip (e.g., 8 MΩ) might be disadvantageous.

---

### Exercise 2 — Observing the Capacitive Transient

**No parameter changes needed** — use the default model (R_pip = 4 MΩ, C_pip = 3 pF).

**Tasks:**
1. Zoom into the time window **t = 2.000–2.200 ms** (the leading edge of the first pulse). Sketch or describe the shape of `I_measured`.
2. Estimate the time constant τ of the decaying transient from the plot. Compare with the theoretical value τ = R_pip × C_pip.
3. Now modify `C_pipette` to **6 pF** (double the default). Re-run the simulation.
   - How does the transient amplitude change?
   - How does τ change?
   - Does the steady-state current change? Why or why not?
4. In a real experiment, large pipette capacitance is undesirable. Based on this exercise, explain what problem it creates during rapid voltage steps.

---

### Exercise 3 — Effect of Bath Resistance

**Modify:** Change `R_bath` in the `bath` component from 100 Ω to the following values:

| Trial | R_bath | Notes |
|---|---|---|
| A | 100 Ω | Default (typical clean bath) |
| B | 10,000 Ω (10 kΩ) | Partially blocked bath electrode |
| C | 500,000 Ω (500 kΩ) | Severely compromised bath |

**Tasks:**
1. For each trial, calculate the **total series resistance** (R_total = R_pip + R_bath) and the expected I_steady.
2. Run the simulation for each trial and measure I_steady from the plot. Does the result match your prediction?
3. At what value of R_bath does the error in the R_pip estimate exceed 10%?
4. In the lab, a bad bath electrode (corroded silver/silver-chloride wire, clogged agar bridge) can increase R_bath substantially. Based on this exercise, explain why a high-quality, low-resistance bath electrode is important for accurate R_pip measurement.

---

### Exercise 4 — Real-Time Resistance Estimation

**No parameter changes needed** — use the default model.

**Tasks:**
1. Plot `seal_test.R_seal_est` for the full 60 ms simulation. Describe qualitatively how it evolves over the first fraction of a millisecond of each pulse, and what value it idles at between pulses.
2. `R_seal_est` is computed two different ways depending on the phase: during a pulse it is `|V_pulse / I_steady|`, derived entirely from the *actual* current flowing through the *actual* `R_pipette` — it never reads `R_pipette_nom`. Between pulses, with `V_command = 0` there is no current to estimate anything from, so the model just displays `R_pipette_nom` as a placeholder reading. Change `R_pipette_nom` to **2 MΩ** while keeping `R_pipette = 4 MΩ` (i.e., introduce a mismatch between the value written on the pipette's label and its true resistance). Predict, then verify: does the *during-pulse* converged value change? Does the *between-pulses* idle value change? Why do they behave differently?
3. Explain in your own words why the seal-test estimate is considered a **real-time** measurement. What does the amplifier need to assume to compute R_seal_est from a single pulse?

---

### Exercise 5 — Connecting to Physiology (Discussion)

No simulation required — this is a conceptual exercise based on what you have observed.

1. The liquid junction potential (LJP) is set to `V_junction = 0` in this model. In a real experiment, why might the pipette and bath solutions generate a small offset voltage at their interface? How would a non-zero LJP affect the current measured during the seal-test?
2. The seal-test pulse amplitude is only −5 mV. Why is it important to keep this pulse **small** when approaching a cell, even though a larger pulse would give a bigger, easier-to-measure current?
3. Imagine you are performing a patch clamp experiment and your seal-test shows `I_measured ≈ −0.6 nA` at steady state (with V_pulse = −5 mV). What is the pipette resistance? Is this a good pipette for a whole-cell recording? Justify your answer.

---

## 8. Summary

| Concept | Key equation | Typical value |
|---|---|---|
| Steady-state bath current | I = V_pulse / R_pip | ~1.25 nA at 4 MΩ |
| Capacitive time constant | τ = R_pip × C_pip | ~12 µs at 4 MΩ, 3 pF |
| Gigaseal criterion | R_seal > 1 GΩ | Reduces I by ×250 |
| Acceptable R_pip range (whole-cell) | 3–5 MΩ | Compromise: access vs. noise |

The Step01 model captures the **reference state** of every patch clamp experiment. Before a cell is touched, the experimenter calibrates their intuition: how large is the background current, how clean is the capacitive transient, and how fast does the resistance estimator converge? Only with this baseline in hand can subsequent changes — gigaseal formation, membrane breakthrough — be correctly interpreted.

---

*Tutorial based on model `PatchClamp.Examples.Step01_PipetteSealTest` (Modelica). Exercises are designed for an introductory electrophysiology or bioelectrical modeling course.*
