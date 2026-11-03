# Patch Clamp Tutorial — Step 3: The Passive Cell in Voltage-Clamp (Whole-Cell Configuration)

**Model:** `PatchClamp.Examples.Step03_PassiveCellVoltageClamp`
**Recommended simulation time:** 0.200 s | Interval: 100 µs | Tolerance: 1×10⁻⁸

---

## 1. The Moment of Breakthrough

In [Step 2 (Step02)](Step02_GigasealFormation_Tutorial.md), the gigaseal was formed and confirmed: R_seal > 1 GΩ, steady-state current ~5 pA. The pipette tip was sealed against a small patch of cell membrane, but the interior of the cell remained inaccessible.

To achieve the **whole-cell configuration**, the experimenter applies additional suction — or a brief high-voltage electrical pulse — through the back of the pipette. This ruptures the membrane patch enclosed within the pipette tip while leaving the gigaseal intact around the perimeter. The result is a direct, low-resistance electrical connection between the pipette solution and the cell cytoplasm.

At this moment, three things happen simultaneously:

1. **The circuit changes fundamentally.** R_patch and C_patch of the small membrane patch are replaced by R_m and C_m of the entire cell membrane.
2. **The cell capacitance appears.** A neuron or cardiac cell has C_m of 10–100 pF — orders of magnitude larger than C_patch (0.1 pF). This produces a large, visible capacitive transient in the current record.
3. **The amplifier mode shifts.** In Step02 the seal-test was sufficient; now the experimenter switches to a proper **voltage-clamp protocol**, commanding a specific membrane potential and recording the resulting current.

This tutorial covers that new state: the passive cell in voltage-clamp.

---

## 2. The Equivalent Circuit

After membrane breakthrough, the circuit is:

```
  Amplifier        Patch Pipette         Passive Cell        Bath
                                        ┌── C_m = 10 pF ──┐
  [V-clamp] ─── [R_pip = 4 MΩ] ─────── ┤                  ├── [R_bath = 100 Ω] ── GND
                [C_pip = 3 pF ]         └── R_m = 1 GΩ  ──┘
```

The cell is modeled as a **parallel RC circuit**: C_m (membrane capacitance) in parallel with R_m (membrane resistance). This is the simplest possible — and most important — model of a cell membrane.

### Component definitions

| Component | Symbol | Default value | Physical meaning |
|---|---|---|---|
| Pipette resistance | R_pip | 4 MΩ | Access resistance to the cell interior |
| Pipette capacitance | C_pip | 3 pF | Glass wall capacitance (unchanged) |
| **Membrane capacitance** | **C_m** | **10 pF** | Total capacitance of the cell membrane |
| **Membrane resistance** | **R_m** | **1 GΩ** | Resting conductance (leak + closed channels) |
| Liquid junction potential | LJP | −11 mV | Offset from pipette/bath solution mismatch |
| Bath resistance | R_bath | 100 Ω | Negligible as before |

> **Important note on R_pip in whole-cell:** In Step02, R_pip contributed only 0.4% of the total resistance. In whole-cell, R_pip becomes critical — it is now the **series resistance (R_s)** between the amplifier and the cell interior. Any voltage error, speed limitation, or current artifact in whole-cell recordings originates from R_pip.

---

## 3. The Voltage-Clamp Protocol

Rather than the seal-test pulses used in Step01 and Step02, the amplifier now applies a **voltage-clamp step protocol**:

| Phase | Time window | V_command | Purpose |
|---|---|---|---|
| Holding | 0 – 50 ms | −70 mV | Stable baseline at resting potential |
| Step | 50 – 150 ms | −50 mV | +20 mV depolarizing step |
| Return | 150 – 200 ms | −70 mV | Return to holding potential |

The liquid junction potential correction (−11 mV) is applied automatically by the amplifier, so the **true membrane voltage** during the step is:

$$V_m = V_{\text{command}} + \text{LJP correction} = -50 \text{ mV} + (-11 \text{ mV}) = -61 \text{ mV}$$

In practice, LJP arises from the ionic composition difference between the pipette solution (intracellular-like) and the bath solution (extracellular-like). Failing to correct for LJP causes a systematic offset in all voltage measurements.

---

## 4. Two Time Constants — A Critical Distinction

This is the most important conceptual point in the whole-cell voltage-clamp experiment. The circuit contains **two RC time constants** with very different meanings:

### 4.1 τ_pip — the charging transient visible in current

$$\tau_{\text{pip}} = R_{\text{pip}} \times C_m = 4 \times 10^6 \, \Omega \times 10 \times 10^{-12} \, \text{F} = 40 \text{ µs}$$

When the voltage-clamp amplifier steps the command voltage, it charges C_m through R_pip. This produces a large, fast capacitive current transient visible in `I_measured`. The transient decays with τ_pip = 40 µs.

### 4.2 τ_m — the membrane time constant (NOT visible here)

$$\tau_m = R_m \times C_m = 1 \times 10^9 \, \Omega \times 10 \times 10^{-12} \, \text{F} = 10 \text{ ms}$$

τ_m describes how quickly the cell membrane charges in response to an injected current — the quantity relevant to a neuron's integrative properties. **In voltage-clamp, the amplifier forces V_m to follow V_command, bypassing the natural R_m × C_m dynamics.** τ_m is therefore not visible in the current record; to observe it directly, switch to current-clamp (see Step05).

| Time constant | Formula | Value | Visible in voltage-clamp? |
|---|---|---|---|
| τ_pip (charging transient) | R_pip × C_m | 40 µs | **Yes** — in I_measured |
| τ_m (membrane) | R_m × C_m | 10 ms | **No** — seen in current-clamp |

### 4.3 Why is τ_pip ≪ τ_m?

Because R_pip (4 MΩ) ≪ R_m (1 GΩ). The amplifier charges C_m through the low-resistance access path of the pipette, not through the high-resistance leak of the membrane. This is precisely the advantage of voltage-clamp over current-clamp for studying fast membrane events.

---

## 5. Expected Signals and Key Calculations

### 5.1 Peak capacitive current (onset of step)

At the instant the voltage steps from −70 mV to −50 mV (ΔV = +20 mV), the voltage is effectively applied across R_pip (because C_m cannot change voltage instantaneously):

$$I_{\text{peak}} = \frac{\Delta V}{R_{\text{pip}}} = \frac{20 \text{ mV}}{4 \text{ MΩ}} = 5 \text{ nA}$$

This current then decays exponentially with τ_pip = 40 µs as C_m charges.

### 5.2 Steady-state resistive current

Once C_m is fully charged to the new command voltage, no further capacitive current flows. The only remaining current is the resistive leak through R_m:

$$I_{ss} = \frac{\Delta V}{R_m} = \frac{20 \text{ mV}}{1 \text{ GΩ}} = 20 \text{ pA}$$

This is nearly 250 times smaller than I_peak and requires careful attention to y-axis scaling to observe.

### 5.3 Return transient (end of step)

When the voltage returns to −70 mV at t = 150 ms, a symmetric negative peak of −5 nA occurs as C_m discharges back through R_pip with the same τ_pip = 40 µs.

### 5.4 Summary of expected values

| Quantity | Formula | Value |
|---|---|---|
| Voltage step | ΔV | +20 mV |
| Peak capacitive current | ΔV / R_pip | **+5 nA** |
| Capacitive decay time constant | R_pip × C_m | **40 µs** |
| Steady-state current | ΔV / R_m | **+20 pA** |
| Membrane time constant | R_m × C_m | 10 ms (not visible here) |

---

## 6. The Liquid Junction Potential

The **liquid junction potential (LJP)** arises at the interface between two solutions of different ionic composition — in this case, at the pipette tip where the intracellular-like pipette solution meets the extracellular bath solution. Common ion asymmetries (K⁺ vs. Na⁺, gluconate vs. Cl⁻) create a diffusion potential of typically −5 to −15 mV.

In this model, LJP = −11 mV is set in both the pipette component (`V_junction = -11.0e-3`) and compensated by the amplifier (`V_ljp_correction = -11.0e-3`). If the correction is not applied:

$$V_{m,\text{true}} = V_{\text{command}} - \text{LJP} = -70 \text{ mV} - (-11 \text{ mV}) = -59 \text{ mV (not −70 mV)}$$

All voltage protocols in the series use this correction. Experimentally, LJP is measured once per solution pair (using a flowing junction method) and subtracted from all voltage commands offline or online.

---

## 7. Variables to Plot

| Variable | Units | What to look for |
|---|---|---|
| `amplifier.V_command` | V | Step protocol: −70 → −50 → −70 mV |
| `amplifier.I_measured` | A | Large capacitive transient at nA scale; tiny I_ss at pA scale |
| `cell.V_m` | V | Membrane voltage (should follow V_command closely) |
| `cell.I_C_m` | A | Capacitive current through C_m alone |
| `cell.I_R_m` | A | Resistive current through R_m alone |
| `pipette.V_access` | V | Voltage drop across R_pip (series resistance error) |

---

<!-- build:start -->
## Build it yourself

Instead of opening the finished example you can build the model from an empty diagram, which is the best way to see how its blocks fit together. Read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) first.

1. Create a new model named `MyStep03` and open its **Diagram View**.
2. Add the blocks, set their parameters and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amplifier` | `PatchClamp → Amplifiers → VoltageClampAmplifier` (voltage-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `cell` | `PatchClamp → Cells → PassiveCell` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amplifier`: keep all defaults.

- `pipette`: keep all defaults.

- `cell`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `10.0e-12` |
  | `R_m` | `1.0e9` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amplifier.p` | `pipette.p_amp` |
| `pipette.p_cell` | `cell.membrane_p` |
| `cell.membrane_n` | `bath.p` |
| `amplifier.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-4, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

Compare your model with `PatchClamp → Examples → Step03_PassiveCellVoltageClamp`: the traces should overlay. From here on, the *Simulation Guide* below works with your `MyStep03` exactly as with the library example.
<!-- build:end -->

## 8. Step-by-Step Simulation Guide

1. Open `PatchClamp.Examples.Step03_PassiveCellVoltageClamp` in your Modelica environment.
2. Run with **Stop time:** 0.200 s, **Interval:** 1×10⁻⁴ s, **Tolerance:** 1×10⁻⁸.
3. Plot `amplifier.V_command` and `amplifier.I_measured` on the same time axis.
4. **Zoom into t = 49.9–50.3 ms** (step onset) to resolve the capacitive transient. Measure the peak amplitude and estimate the time constant from the decay.
5. **Zoom out to t = 50–150 ms** and change the y-axis to pA scale to observe I_ss ~ 20 pA.
6. Plot `cell.I_C_m` and `cell.I_R_m` separately to verify which component dominates at different time points.
7. Note the symmetric negative transient at t = 150 ms (step return).

---

## 9. Comparison Across the Three Steps

| Parameter | Step01 (Bath) | Step02 (Gigaseal) | **Step03 (Whole-cell)** |
|---|---|---|---|
| Dominant circuit | R_pip in series | R_pip + R_seal | R_pip + (C_m ‖ R_m) |
| Amplifier mode | Seal-test | Seal-test | Voltage-clamp |
| I at step onset | 1.25 nA (steady) | 5 pA (steady) | **5 nA (transient)** |
| I at steady state | 1.25 nA | ~5 pA | **20 pA** |
| Dominant time constant | τ_pip = 12 µs | τ_pip = 12 µs | **τ_pip = 40 µs** |
| Key new concept | R_pip | R_seal, C_patch | **C_m, R_m, LJP** |

Notice that the whole-cell peak current (5 nA) is actually *larger* than Step01 (1.25 nA) — not because R_m is low, but because C_m charges through R_pip instantaneously. The cell adds capacitance, not resistance, to the fast transient.

---

## 10. Exercises

### Exercise 1 — Verifying the Two Time Constants

**No parameter changes needed** — use default values (R_pip = 4 MΩ, C_m = 10 pF, R_m = 1 GΩ).

**Tasks:**
1. Run the simulation and zoom into the step onset at t = 50 ms. Measure τ_pip from the exponential decay of the capacitive transient. Compare with the theoretical value R_pip × C_m.
2. Calculate τ_m = R_m × C_m for the default parameters. Is this time constant visible anywhere in the `I_measured` trace? Why or why not?
3. Now look at the `cell.V_m` trace during the step. How quickly does V_m reach its new value? Is the transition governed by τ_pip or τ_m? Explain the difference between the amplifier forcing V_m (voltage-clamp) and V_m evolving naturally through R_m (current-clamp).
4. If the amplifier were suddenly switched off mid-step, which time constant would govern the subsequent voltage decay: τ_pip or τ_m? Why?

---

### Exercise 2 — Changing Membrane Capacitance

**Modify:** Change `cell.C_m` to the following values. Keep R_m = 1 GΩ and R_pip = 4 MΩ.

| Trial | C_m | Cell type analogy |
|---|---|---|
| A | 5 pF | Small neuron or HEK cell |
| B | 10 pF | Default (medium neuron) |
| C | 20 pF | Large neuron or cardiac myocyte |
| D | 50 pF | Cardiac ventricular cell |

**Tasks:**
1. For each trial, calculate the expected I_peak, τ_pip, and τ_m before simulating.
2. Run each simulation and measure I_peak and τ_pip from the capacitive transient. Do they match your predictions?
3. Does changing C_m affect I_ss? Calculate I_ss for each trial and explain your reasoning.
4. Plot the **charge** delivered during the capacitive transient (Q = C_m × ΔV). How does Q scale with C_m? This quantity is directly proportional to the total membrane area — explain why.
5. In practice, C_m is used to estimate cell surface area, with a specific membrane capacitance of ~1 µF/cm². Using this factor, estimate the membrane surface area for each C_m value in the table. Do the numbers seem realistic for the cell types listed?

---

### Exercise 3 — Changing Membrane Resistance

**Modify:** Keep C_m = 10 pF and R_pip = 4 MΩ. Change `cell.R_m` to:

| Trial | R_m | Physiological state |
|---|---|---|
| A | 100 MΩ | Leaky membrane (damaged cell or open channels) |
| B | 500 MΩ | Acceptable but not ideal |
| C | 1 GΩ | Default (good resting cell) |
| D | 5 GΩ | Very tight membrane (excellent cell) |

**Tasks:**
1. Calculate the expected I_ss for each trial.
2. Run simulations and verify I_ss from the plot. Note that for low R_m values you may need to zoom out the y-axis.
3. Does changing R_m affect I_peak or τ_pip? Explain why or why not using the circuit diagram.
4. Calculate τ_m for each trial. At which value of R_m does τ_m become comparable to τ_pip (40 µs)? What would the current transient look like in that case?
5. A cell with R_m = 100 MΩ is considered "leaky" in patch clamp. Using your I_ss result, explain the practical problem this creates when trying to measure small ionic currents (e.g., a 50 pA potassium tail current). What is the signal-to-noise ratio in this case?

---

### Exercise 4 — Series Resistance and Voltage Error

**This exercise introduces one of the most important sources of error in whole-cell voltage-clamp.**

When current flows through R_pip, it produces a voltage drop that means the actual membrane voltage V_m differs from the commanded voltage V_command:

$$V_{\text{error}} = I \times R_{\text{pip}}$$

**Tasks:**
1. Using the default parameters, calculate the maximum voltage error at the peak of the capacitive transient (I_peak = 5 nA, R_pip = 4 MΩ). Express your answer in mV. This is the "series resistance error."
2. Plot `pipette.V_access` (the voltage drop across R_pip) during the simulation. Does it match your calculation?
3. Now change `pipette.R_pipette` to **8 MΩ** (a high-resistance pipette). Recalculate and measure the peak voltage error.
4. Repeat with **R_pip = 2 MΩ** (a very low-resistance pipette). How does the error compare?
5. In experiments involving fast sodium currents (I_Na ≈ 2–5 nA), series resistance errors of even a few mV can shift the measured activation curve by tens of millivolts. Based on your results, what range of R_pip would you consider acceptable for whole-cell voltage-clamp of a cell with C_m = 10 pF? Justify your answer with calculations.

---

### Exercise 5 — The Liquid Junction Potential

**Modify the LJP correction to examine its effect.**

**Tasks:**
1. Run the default simulation and confirm that `cell.V_m` reaches −61 mV during the step (= −50 mV command + (−11 mV) LJP correction).
2. Now set `V_ljp_correction = 0` in the amplifier component (remove the LJP correction). Re-run. What is `cell.V_m` during the step now? What is the error in millivolts?
3. Common intracellular solutions (K-gluconate based) have LJP ≈ −11 to −14 mV vs. standard extracellular solutions. Why does the sign matter? If the LJP is negative and you fail to correct, are you clamping at a more depolarized or more hyperpolarized potential than intended?
4. Ion channel gating (activation and inactivation) is highly voltage-sensitive — a 5 mV shift in V_m can change channel open probability by 50% or more. Using this fact, explain why accurate LJP correction is not merely a bookkeeping exercise but a genuine experimental necessity.

---

### Exercise 6 — Connecting the Three Steps (Discussion)

No simulation required — a synthesis exercise.

1. Across the three models, `R_pip` has played three different roles:
   - **Step01:** The dominant resistance that determines I_steady.
   - **Step02:** A negligible series element (0.4% of R_total).
   - **Step03:** The access resistance that limits charging speed and causes voltage errors.

   Explain in your own words why the same physical component (the pipette tip) changes its functional role across these three configurations.

2. When the membrane is ruptured to achieve whole-cell access, the gigaseal (R_seal ≈ 1 GΩ) is maintained around the outside of the pipette tip. In the Step03 circuit, R_seal does not appear explicitly. Is it truly gone, or has it become negligible? Calculate what current would flow through a residual R_seal = 1 GΩ at ΔV = 20 mV and compare it with I_ss = 20 pA. What does this tell you about the importance of maintaining the gigaseal even after breakthrough?

3. In current-clamp (Step05), τ_m = R_m × C_m = 10 ms governs how quickly the membrane potential responds to an injected current step. In voltage-clamp (Step03), this 10 ms time constant is invisible. Describe an experimental situation where you would need to know τ_m and would therefore prefer current-clamp over voltage-clamp.

4. A student observes that after membrane breakthrough the seal-test current jumps from ~5 pA to ~5 nA. They conclude that the gigaseal was lost. Is this conclusion correct? What actually happened to the circuit at the moment of breakthrough?

---

## 11. Summary

| Quantity | Formula | Default value |
|---|---|---|
| Peak capacitive current | ΔV / R_pip | 5 nA |
| Charging time constant | R_pip × C_m | 40 µs |
| Steady-state current | ΔV / R_m | 20 pA |
| Membrane time constant | R_m × C_m | 10 ms (current-clamp) |
| Series resistance error | I × R_pip | Up to 20 mV at peak |

The whole-cell voltage-clamp configuration is the workhorse of cellular electrophysiology. Every subsequent experiment — Na⁺ channel activation curves, K⁺ current pharmacology, synaptic conductance measurements — is interpreted through this same RC framework. The passive cell model is not a simplification to be discarded once active channels are introduced; it is the **baseline** against which all active currents are measured and the conceptual scaffold on which all analysis rests.

---

*Tutorial based on model `PatchClamp.Examples.Step03_PassiveCellVoltageClamp` (Modelica). Part of a three-step patch clamp series: Step01 (pipette in bath) → Step02 (gigaseal) → **Step03 (whole-cell voltage-clamp)**.*
