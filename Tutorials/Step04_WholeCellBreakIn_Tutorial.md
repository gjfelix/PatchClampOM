# Patch Clamp Tutorial — Step 4: Whole-Cell Configuration and Capacitive Transients

**Model:** `PatchClamp.Examples.Step04_WholeCellBreakIn`
**Recommended simulation time:** 0.060 s | Interval: 3 µs | Tolerance: 1×10⁻⁸

> **Relationship to Step03_PassiveCellVoltageClamp:** Both models represent the whole-cell configuration, but they complement each other. `Step03_PassiveCellVoltageClamp` uses a voltage-clamp step protocol (−70 → −50 mV) to study membrane RC parameters in isolation. This model (`Step04_WholeCellBreakIn`) uses the **seal-test** (the same −5 mV pulse protocol from Step01 and Step02), making it the natural bridge from the gigaseal step. It also introduces **R_access** as an explicit circuit element and uses more realistic cell parameters (C_m = 50 pF, R_m = 200 MΩ). Use both models together for a complete picture.

---

## 1. What Changed at the Moment of Breakthrough?

In [Step 2 (Step02)](Step02_GigasealFormation_Tutorial.md), the membrane patch enclosed within the pipette tip was intact. The dominant resistance was R_seal ≈ 1 GΩ, and the steady-state current was ~5 pA.

When the patch is ruptured — by additional suction, a brief voltage zap, or both — the small disc of membrane is torn open. The pipette lumen now connects directly to the cell cytoplasm. The circuit transforms:

**Before (cell-attached, Step02):**
```
[V_pulse] ─── [R_pip + C_pip] ─── R_seal ─── GND
                                   R_patch
                                   C_patch
```

**After (whole-cell, this model):**
```
[V_pulse] ─── [R_pip + C_pip] ─── [R_access] ─┬─ C_m ─── GND
                                                └─ R_m ─── GND
```

Three things change simultaneously:
1. R_seal (1 GΩ) and C_patch (0.1 pF) **disappear** — the seal is now in parallel with the entire cell, making it electrically negligible.
2. R_access (10 MΩ) **appears** — the resistance of the ruptured patch opening, also called whole-cell access resistance.
3. C_m (50 pF) and R_m (200 MΩ) **appear** — the capacitance and resting resistance of the entire cell membrane.

The immediately visible consequence: a large, slow capacitive transient appears in the current record that was absent in Step02.

---

## 2. The Equivalent Circuit in Detail

```
  Seal-test        Patch Pipette          Whole-Cell              Bath
                                        ┌─── C_m = 50 pF ───┐
  [V_pulse] ─── [R_pip = 4 MΩ] ─── [R_access = 10 MΩ] ─── ┤           ├─── [R_bath = 100 Ω] ─── GND
                [C_pip = 3 pF ]                              └─── R_m = 200 MΩ ──┘
```

### Component definitions

| Component | Symbol | Default value | Physical meaning |
|---|---|---|---|
| Pipette resistance | R_pip | 4 MΩ | Tip geometry; same as all prior steps |
| Pipette capacitance | C_pip | 3 pF | Glass wall capacitance; same as before |
| **Access resistance** | **R_access** | **10 MΩ** | Resistance of the ruptured patch opening |
| **Membrane capacitance** | **C_m** | **50 pF** | Total capacitance of the whole cell membrane |
| **Membrane resistance** | **R_m** | **200 MΩ** | Resting leak conductance of the cell |
| Bath resistance | R_bath | 100 Ω | Negligible |

### R_access vs. R_pip: a critical distinction

In `Step03_PassiveCellVoltageClamp`, the pipette resistance R_pip played the role of series resistance. Here, R_access is modeled as a **separate component** that appears only after membrane breakthrough. In reality:

$$R_{\text{series}} = R_{\text{pip}} + R_{\text{access}}$$

R_access reflects the resistance of the ruptured membrane opening itself — typically 5–20 MΩ — and can degrade over time as the opening partially reseals or becomes blocked by cellular debris. Monitoring R_access throughout an experiment is essential quality control.

---

## 3. Three Time Constants

This model is the first in the series where **three distinct time constants** coexist and are all potentially visible. Understanding each one is the core learning objective.

### 3.1 τ_fast — pipette capacitance charging

$$\tau_{\text{fast}} = R_{\text{pip}} \times C_{\text{pip}} = 4 \times 10^6 \times 3 \times 10^{-12} = 12 \text{ µs}$$

Same as in Step01 and Step02. This is the fast transient from C_pip charging through R_pip. At the scale of whole-cell currents it is nearly invisible — it peaks at ~1 nA and decays in ~60 µs. In a real experiment it is cancelled by analog fast capacitance compensation before membrane breakthrough.

### 3.2 τ_slow — membrane capacitance charging (the main event)

$$\tau_{\text{slow}} = R_{\text{access}} \times C_m = 10 \times 10^6 \times 50 \times 10^{-12} = 500 \text{ µs}$$

This is the **whole-cell capacitive transient** — the diagnostic signature that confirms successful membrane breakthrough. C_m charges through R_access (not R_pip, and not R_m, because R_m ≫ R_access during the transient). The peak current is:

$$I_{\text{peak,slow}} \approx \frac{V_{\text{pulse}}}{R_{\text{access}}} = \frac{-5 \text{ mV}}{10 \text{ MΩ}} = -500 \text{ pA}$$

The transient decays with τ_slow = 500 µs and carries a total charge:

$$Q_{C_m} = C_m \times V_{\text{pulse}} = 50 \times 10^{-12} \times 5 \times 10^{-3} = 0.25 \text{ pC}$$

This integral — the area under the slow transient — is the primary method for estimating C_m in real experiments.

### 3.3 τ_membrane — resting membrane discharge

$$\tau_{\text{membrane}} = R_m \times C_m = 200 \times 10^6 \times 50 \times 10^{-12} = 10 \text{ ms}$$

This is the natural membrane time constant — how quickly the cell would charge or discharge through its own resting conductance in the absence of the amplifier. In voltage-clamp it is not the dominant transient (because R_access ≪ R_m), but it governs the very slow tail of the current after the fast capacitive transient has subsided. It is most relevant in current-clamp (Step05).

### Summary table

| Time constant | Formula | Default value | Visible in this model? | Dominant current |
|---|---|---|---|---|
| τ_fast | R_pip × C_pip | **12 µs** | Barely (large but very brief) | ~1 nA spike |
| **τ_slow** | **R_access × C_m** | **500 µs** | **Yes — main feature** | ~500 pA transient |
| τ_membrane | R_m × C_m | 10 ms | As a slow tail | ~23 pA DC |

---

## 4. Steady-State Current

After all capacitive transients have decayed, the steady-state current flows through the full resistive path in series:

$$I_{ss} = \frac{V_{\text{pulse}}}{R_{\text{pip}} + R_{\text{access}} + R_m} = \frac{-5 \text{ mV}}{4 \text{ MΩ} + 10 \text{ MΩ} + 200 \text{ MΩ}} \approx -23 \text{ pA}$$

This is much smaller than I_peak,slow (500 pA) and nearly invisible at the scale used to observe the transients. Notice that R_m (200 MΩ) now dominates the denominator — quite different from Step01 where R_pip dominated.

Compare with previous steps:

| Step | I_steady | Dominant R |
|---|---|---|
| Step01 (bath) | ~1.25 nA | R_pip = 4 MΩ |
| Step02 (gigaseal) | ~5 pA | R_seal = 1 GΩ |
| **Step04_WholeCellBreakIn** | **~23 pA** | **R_m = 200 MΩ** |

The current in whole-cell is larger than the gigaseal state (Step02) because R_m (200 MΩ) < R_seal (1 GΩ), but still much smaller than the bath state (Step01) because R_m ≫ R_pip.

---

## 5. Experimental Criteria for Confirming Successful Breakthrough

In the real lab, the experimenter watches the oscilloscope and confirms whole-cell access by checking all of the following:

| Criterion | What to look for | This model |
|---|---|---|
| Slow transient appears | New exponential decay with τ ~ 100 µs–2 ms | τ_slow = 500 µs |
| I_steady changes from Step02 | Increases from ~5 pA toward ~10–50 pA | I_ss ~ 23 pA |
| R_access estimate | `R_seal_est` now reflects R_access + R_m | ~210 MΩ |
| C_m estimate | Integral of slow transient ÷ V_pulse | Q / V = 50 pF |

The appearance of the slow capacitive transient is the most reliable visual indicator. It is absent in Step02 (the patch is intact) and appears abruptly at the moment of breakthrough.

---

## 6. Variables to Plot

| Variable | Units | What to look for |
|---|---|---|
| `seal_test.V_command` | V | −5 mV square pulses (same as Step01/b) |
| `seal_test.I_measured` | A | Fast spike + slow 500 µs transient + ~23 pA DC |
| `cell.I_Cm` | A | The slow capacitive transient alone |
| `cell.I_Rm` | A | The DC resistive current alone (~23 pA) |
| `cell.V_m` | V | Membrane voltage (quality of clamp) |
| `seal_test.R_seal_est` | Ω | Now reflects R_access + R_m ≈ 210 MΩ |

---

## 7. Step-by-Step Simulation Guide

1. Open `PatchClamp.Examples.Step04_WholeCellBreakIn` in your Modelica environment.
2. Run with **Stop time:** 0.060 s, **Interval:** 3×10⁻⁶ s, **Tolerance:** 1×10⁻⁸.
   The 3 µs interval is necessary to resolve both τ_fast (12 µs) and τ_slow (500 µs).
3. Plot `seal_test.I_measured`. You should see a complex waveform at each pulse edge.
4. **Zoom into t = 2.000–2.005 ms** (first pulse onset). Identify the fast spike (τ_fast) and the slower decaying component (τ_slow).
5. **Zoom out to t = 2.0–3.0 ms** to see the full slow transient decay to steady state.
6. Plot `cell.I_Cm` and `cell.I_Rm` separately. Verify that I_Cm carries the transient and I_Rm carries the DC.
7. Plot `cell.V_m`. At what time does V_m finish charging to V_pulse? How does this compare to τ_slow?
8. Plot `seal_test.R_seal_est` and confirm it converges to ~210 MΩ (R_access + R_m in series, R_m dominant).

---

## 8. Exercises

### Exercise 1 — Identifying the Three Time Constants

**No parameter changes** — use default values (R_pip = 4 MΩ, C_pip = 3 pF, R_access = 10 MΩ, C_m = 50 pF, R_m = 200 MΩ).

**Tasks:**
1. Calculate all three time constants (τ_fast, τ_slow, τ_membrane) before simulating. Show your work.
2. Run the simulation and zoom into the first pulse edge (t = 2.000–2.100 ms). Can you visually identify two separate exponential decays? Estimate their time constants from the plot.
3. Zoom further to t = 2.000–2.020 ms. Can you resolve τ_fast (12 µs)? Explain why it is difficult to see at this scale despite having a large peak current.
4. At t = 5–9 ms (mid-pulse), plot `cell.I_Cm`. Is it still decaying? Calculate how many time constants have elapsed since the pulse onset. Is this consistent with what you observe?
5. Where in the simulation would you expect to see τ_membrane manifested? Hint: look at the behavior of `cell.V_m` after the pulse ends.

---

### Exercise 2 — Simulating Different Cell Sizes

The model comments describe two reference cell configurations. Reproduce them and compare.

**Trial A — Small cell (default-like):**
`R_access = 10 MΩ, C_m = 20 pF, R_m = 200 MΩ`

**Trial B — Default (medium cell):**
`R_access = 10 MΩ, C_m = 50 pF, R_m = 200 MΩ`

**Trial C — Large neuron:**
`R_access = 10 MΩ, C_m = 100 pF, R_m = 500 MΩ`

**Tasks:**
1. For each trial, calculate τ_slow, I_peak,slow, Q_Cm, and I_ss before simulating.
2. Run each simulation and measure τ_slow and I_peak,slow from the `cell.I_Cm` trace.
3. For Trial C (large neuron), describe qualitatively how the current waveform differs from Trial A. Pay particular attention to: the duration of the slow transient, the steady-state current, and whether τ_membrane is now more visible.
4. The charge Q_Cm = C_m × V_pulse is the integral of the slow capacitive transient. For each trial, verify this relationship by integrating `cell.I_Cm` numerically over the transient duration. Does the result match C_m × V_pulse?
5. In a real experiment, C_m is estimated from this integral. Using Q_Cm and a specific membrane capacitance of 1 µF/cm², estimate the surface area of each cell. Do the values seem reasonable for the cell types described?

---

### Exercise 3 — Access Resistance and Voltage-Clamp Quality

This exercise demonstrates the most important practical consequence of R_access in whole-cell recordings.

**Keep C_m = 50 pF and R_m = 200 MΩ. Vary `cell.R_access`:**

| Trial | R_access | Clinical description |
|---|---|---|
| A | 5 MΩ | Excellent access (freshly broken, clean pipette) |
| B | 10 MΩ | Default (good access) |
| C | 20 MΩ | Moderate degradation |
| D | 40 MΩ | Poor access (partially resealed or debris) |

**Tasks:**
1. For each trial, calculate τ_slow and I_peak,slow.
2. Plot `cell.V_m` for each trial. The voltage-clamp command is V_pulse = −5 mV. How closely does V_m follow this command during the capacitive transient? Define a "clamp error" as the maximum deviation of V_m from V_pulse during the transient.
3. Calculate the theoretical maximum voltage error: V_error = I_peak × R_access. Verify against your plot.
4. At R_access = 40 MΩ and V_pulse = −5 mV, what fraction of the command voltage actually reaches the membrane at the peak of the transient?
5. In real experiments with fast ionic currents (e.g., Na⁺ channels activating in <1 ms), poor R_access means the membrane is never truly clamped at the command voltage. Explain how this could lead to incorrect measurement of channel activation kinetics or current-voltage relationships.

---

### Exercise 4 — Estimating C_m and R_access from the Transient

In the laboratory, C_m and R_access cannot be read directly — they must be **extracted from the current transient** itself. This exercise simulates that process.

**Use the default model (R_access = 10 MΩ, C_m = 50 pF, R_m = 200 MΩ).**

The standard method uses two measurable quantities from the capacitive transient:
- **Q** = total charge (integral of the transient current)
- **τ_slow** = time constant of the exponential decay
- **I_peak** = peak current at pulse onset

From these, the parameters can be recovered:

$$C_m = \frac{Q}{V_{\text{pulse}}} \qquad R_{\text{access}} = \frac{\tau_{\text{slow}}}{C_m} \qquad R_m = \frac{V_{\text{pulse}}}{I_{ss}} - R_{\text{access}} - R_{\text{pip}}$$

**Tasks:**
1. Run the simulation. From `cell.I_Cm`, measure τ_slow by fitting (or reading the time to decay to 1/e of peak). Measure I_peak and I_ss.
2. Use the formulas above to estimate C_m, R_access, and R_m. Compare with the known values set in the model.
3. Now deliberately introduce a 20% error: run the model with `C_m = 60 pF` (unknown to you as the experimenter). Apply the extraction procedure to your measurement and see whether you can recover the correct value.
4. Explain why this extraction procedure requires the capacitive transient to be **fully resolved** (i.e., the simulation interval must be much shorter than τ_slow). What would happen to your estimate if the time resolution were 1 ms?

---

### Exercise 5 — Simulated Capacitance Compensation

In a real patch clamp amplifier, a dedicated circuit injects an equal and opposite current to cancel the slow capacitive transient — a procedure called **whole-cell capacitance compensation**. This allows the amplifier to focus on the residual ionic currents without saturation from the large C_m transient.

A simple way to simulate "perfect compensation" is to set `C_m = 0`. This is not physically realistic, but it shows what the current record would look like after ideal compensation.

**Tasks:**
1. Run the default model (C_m = 50 pF). Note the amplitude and duration of the slow transient in `seal_test.I_measured`.
2. Set `cell.C_m = 0` and re-run. Describe what changes in the current record.
3. With C_m = 0, what is the remaining current waveform? Calculate its expected amplitude and time constant.
4. The real compensation circuit works by measuring τ_slow and I_peak, then generating an exponential injection current with matching parameters. Based on Exercise 4, explain why the experimenter must first accurately know C_m and R_access before the compensation can work correctly.
5. Even with perfect C_m compensation, a residual fast transient from C_pip remains. Why is this transient handled separately (with fast capacitance compensation, done during cell-attached before breakthrough) rather than together with the slow transient?

---

### Exercise 6 — The Full Progression: Step01 → Step02 → Step04_WholeCellBreakIn

This final exercise asks you to consolidate all four models into a single conceptual framework.

**Tasks:**
1. Fill in the following table from your simulations and calculations across all three models:

| Quantity | Step01 | Step02 | Step04_WholeCellBreakIn |
|---|---|---|---|
| I_steady (pA) | | | |
| Dominant resistance (MΩ) | | | |
| Dominant capacitance (pF) | | | |
| Visible τ (µs) | | | |
| `R_seal_est` reading | | | |

2. At each transition (Step01 → Step02, Step02 → Step03), one component disappears from the circuit and another appears. Identify which component appears and disappears at each step, and explain the physical event that causes the change.

3. The `seal_test.R_seal_est` variable reads ~4 MΩ in Step01, ~1 GΩ in Step02, and ~210 MΩ in Step04_WholeCellBreakIn. A student says: *"The seal got worse after the whole-cell breakthrough."* Is this correct? What is the estimator actually measuring at each step, and why does the reading drop after breakthrough?

4. Across all three steps, the seal-test uses exactly the same voltage pulse (−5 mV, 50 Hz). Yet the current record looks completely different at each step. Without changing the stimulus, the circuit itself encodes all the information about what has happened to the preparation. Describe, in one paragraph, what an experienced electrophysiologist would conclude about the state of their preparation just by watching `I_measured` change from step to step.

---

## 9. Summary

| Quantity | Formula | Default value |
|---|---|---|
| Fast transient τ | R_pip × C_pip | 12 µs |
| **Slow transient τ** | **R_access × C_m** | **500 µs** |
| Membrane time constant | R_m × C_m | 10 ms |
| Peak slow current | V_pulse / R_access | ~500 pA |
| Charge delivered to C_m | C_m × V_pulse | 0.25 pC |
| Steady-state current | V_pulse / (R_pip + R_access + R_m) | ~23 pA |

The whole-cell capacitive transient is simultaneously a nuisance (it saturates the amplifier and masks fast ionic currents) and an invaluable diagnostic tool (it encodes C_m and R_access in its shape and area). Every whole-cell recording begins with reading this transient — estimating cell size from its integral, assessing clamp quality from its time constant, and deciding whether to proceed or discard the cell. Learning to interpret it quantitatively, as this model makes possible, is one of the most practical skills in experimental electrophysiology.

---

*Tutorial based on model `PatchClamp.Examples.Step04_WholeCellBreakIn` (Modelica). Part of a four-model patch clamp series: Step01 (pipette in bath) → Step02 (gigaseal) → Step03_PassiveCellVoltageClamp (voltage-clamp step) / **Step04_WholeCellBreakIn (seal-test in whole-cell)** → Step05 (current-clamp).*
