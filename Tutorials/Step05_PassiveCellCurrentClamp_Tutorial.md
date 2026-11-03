# Tutorial: Step05 — Passive Cell in Current-Clamp: Measuring the Membrane Time Constant τ_m

> **Model path:** `PatchClamp.Examples.Step05_PassiveCellCurrentClamp`
> **Recommended stop time:** 150 ms | **Interval:** 0.1 ms (1 × 10⁻⁴ s) | **Tolerance:** 1 × 10⁻⁸
>
> *This is the third model in the patch-clamp tutorial series. It follows
> `Step01_PipetteSealTest` (Step 1: pipette in bath) and `Step02_GigasealFormation`
> (Step 2: gigaseal formation). It is the companion experiment to `Step03_PassiveCellVoltageClamp`
> (voltage-clamp): where Step03 reveals the fast pipette time constant τ_pip ≈ 40 µs,
> Step05 reveals the slow membrane time constant τ_m = 10 ms — the same circuit, a
> different clamp mode.*

---

## Learning Objectives

By the end of this tutorial, the student will be able to:

1. Calculate the steady-state membrane voltage $V_{ss}$ reached during a square current pulse from Ohm's law, given $R_m$ and the injected current $I_{pulse}$.
2. Derive the membrane time constant $\tau_m = R_m C_m$ and predict the voltage at $t = \tau_m$ after pulse onset.
3. Extract $\tau_m$ graphically from a simulated $V_m(t)$ trace using the 63% criterion.
4. Explain why current-clamp mode reveals $\tau_m$ (milliseconds) while voltage-clamp mode reveals $\tau_{pip}$ (microseconds), and relate this difference to the circuit topology.
5. Predict how independent changes to $R_m$ and $C_m$ alter $\tau_m$ and $V_{ss}$ differently, and verify those predictions with parameter sweeps.

---

## 1. Context

### Where This Model Sits in the Experimental Workflow

| Step | Model | Configuration | What is measured |
|------|-------|--------------|-----------------|
| 1 | `Step01_PipetteSealTest` | Pipette in bath solution | Pipette resistance $R_{pip}$ |
| 2 | `Step02_GigasealFormation` | Gigaseal formed | Seal resistance $R_{seal}$ ≫ GΩ |
| **3a** | `Step03_PassiveCellVoltageClamp` | Whole-cell, **voltage-clamp** | $\tau_{pip}$, $C_{pip}$, access resistance |
| **3b** | **`Step05_PassiveCellCurrentClamp`** | Whole-cell, **current-clamp** | **$\tau_m = R_m C_m$**, $V_{ss}$, $\Delta V$ |

After rupturing the patch (whole-cell configuration), the experimenter can choose either voltage-clamp (VC) or current-clamp (CC). In VC the amplifier drives current to hold $V_m$ fixed; in CC the amplifier injects a prescribed current and $V_m$ is free to evolve. The present model switches the amplifier to CC mode.

### What Physically Changed from Step03

In `Step03` (voltage-clamp) the amplifier imposed a voltage step and measured the resulting current transient, dominated by $\tau_{pip} = R_{pip} C_{pip}$ because $R_{pip}$ is in series with the clamp. Here, a **20 pA square current pulse** is injected instead. The voltage $V_m$ across the membrane RC rises exponentially toward $V_{ss}$ with time constant $\tau_m = R_m C_m$ — three orders of magnitude slower than $\tau_{pip}$.

The pipette resistance $R_{pip} = 4\ \text{MΩ}$ is now negligible compared with $R_m = 1\ \text{GΩ}$ (ratio 1:250), so it contributes only a tiny ohmic offset to $V_m$, not a separate observable time constant.

---

## 2. Equivalent Circuit

### ASCII Diagram

```
                 R_bridge       R_pip         R_bath
 I_command ──┬──/\/\/\/──┬──/\/\/\/──┬──────/\/\/──── GND
             │  4 MΩ     │  4 MΩ     │      100 Ω
             │           │           │
          (amp)      C_pip ═        C_m ═    R_m
                      3 pF ═        10 pF═  /\/\/ 1 GΩ
                           │              │
                           │              │
                          GND            GND  (bath ground)

  V_m is measured across C_m // R_m  (cell membrane node to bath ground)
  V_pip is measured at the pipette tip node
```

### Component Table

| Symbol | Default Value | Physical Meaning |
|--------|--------------|-----------------|
| $I_{hold}$ | 0 pA | Baseline holding current (rest) |
| **$I_{pulse}$** | **20 pA** | **Injected square-pulse amplitude** |
| **$t_{pulse,start}$** | **10 ms** | **Pulse onset** |
| **$t_{pulse,end}$** | **110 ms** | **Pulse offset (100 ms duration)** |
| $R_{bridge}$ | 4 MΩ | Bridge/output resistance of CC amplifier |
| $R_{pip}$ | 4 MΩ | Pipette (access) resistance |
| $C_{pip}$ | 3 pF | Pipette stray capacitance |
| $V_{junction}$ | 0 mV | Liquid junction potential (zeroed for clarity) |
| **$C_m$** | **10 pF** | **Membrane capacitance (cell)** |
| **$R_m$** | **1 GΩ** | **Membrane resistance (cell)** |
| $R_{bath}$ | 100 Ω | Bath electrode resistance (negligible) |

**Bold** entries are the biologically relevant new components introduced in this model's measurement target.

---

## 3. Key Parameters and Equations

### 3.1 Membrane Time Constant

The membrane is modelled as a parallel RC:

$$\tau_m = R_m \cdot C_m$$

$$\tau_m = 1 \times 10^9\ \Omega \times 10 \times 10^{-12}\ \text{F} = 10 \times 10^{-3}\ \text{s} = \mathbf{10\ ms}$$

### 3.2 Steady-State Voltage Deflection

During the pulse, all injected current eventually flows through $R_m$ (capacitor fully charged). Using Ohm's law and the fact that $R_{pip} \ll R_m$:

$$V_{ss} = V_{rest} + I_{pulse} \cdot R_m$$

The model sets $V_{rest} = E_L = -65\ \text{mV}$ (the leak reversal potential):

$$V_{ss} = -0.065\ \text{V} + 20 \times 10^{-12}\ \text{A} \times 1 \times 10^9\ \Omega$$

$$V_{ss} = -0.065 + 0.020\ \text{V} = \mathbf{-45\ mV}$$

$$\Delta V = V_{ss} - V_{rest} = 20\ \text{pA} \times 1\ \text{G}\Omega = \mathbf{20\ mV}$$

*Small correction from $R_{pip}$:* The actual current through $R_m$ is slightly less than $I_{pulse}$ because a fraction drops across $R_{pip}$. At steady-state:

$$\Delta V_{actual} = I_{pulse} \cdot \frac{R_m}{R_m + R_{pip}} \approx 20\ \text{mV} \times \frac{1000}{1004} \approx 19.92\ \text{mV}$$

This 0.08 mV error is negligible; the ideal formula is used throughout.

### 3.3 Voltage Trajectory During the Pulse

Starting from $V_{rest}$ at $t = t_{start}$, the membrane charges exponentially:

$$V_m(t) = V_{ss} + (V_{rest} - V_{ss})\,e^{-(t - t_{start})/\tau_m} \quad \text{for } t \geq t_{start}$$

$$V_m(t) = -45\ \text{mV} + (-65 - (-45))\ \text{mV} \cdot e^{-(t-0.010)/0.010}$$

$$V_m(t) = -45\ \text{mV} - 20\ \text{mV} \cdot e^{-(t-0.010)/0.010}$$

### 3.4 Voltage at One Time Constant (63% Criterion)

At $t = t_{start} + \tau_m = 10\ \text{ms} + 10\ \text{ms} = 20\ \text{ms}$:

$$V_m(20\ \text{ms}) = V_{rest} + \Delta V \cdot \left(1 - e^{-1}\right)$$

$$= -65\ \text{mV} + 20\ \text{mV} \times 0.6321 = -65 + 12.64\ \text{mV} = \mathbf{-52.4\ mV}$$

This is the **graphical extraction point**: find the time at which $V_m = -52.4\ \text{mV}$; that time minus 10 ms equals $\tau_m$.

### 3.5 Pulse Duration vs. Time Constant

The pulse duration is 100 ms = $10 \times \tau_m$. After $5\tau_m$ the membrane is 99.3% charged, so $V_m$ is effectively at $V_{ss}$ for the final half of the pulse. The tail (repolarisation) after pulse offset is symmetric with time constant $\tau_m$.

### 3.6 Pipette Time Constant in This Circuit

For completeness:

$$\tau_{pip} = R_{pip} \cdot C_{pip} = 4 \times 10^6\ \Omega \times 3 \times 10^{-12}\ \text{F} = 12\ \mu\text{s}$$

This fast transient is present at pulse onset but decays within ~60 µs and is invisible at the 0.1 ms resolution of this simulation.

### Summary Table

| Quantity | Formula | Default Value |
|---------|---------|--------------|
| $\tau_m$ | $R_m C_m$ | 10 ms |
| $V_{rest}$ | $E_L$ | −65 mV |
| $\Delta V$ | $I_{pulse} \cdot R_m$ | 20 mV |
| $V_{ss}$ | $V_{rest} + \Delta V$ | −45 mV |
| $V_m(t_{start}+\tau_m)$ | $V_{rest} + \Delta V (1-e^{-1})$ | −52.4 mV |
| Pulse duration | $t_{end} - t_{start}$ | 100 ms |
| $\tau_{pip}$ | $R_{pip} C_{pip}$ | 12 µs |

---

## 4. Expected Signals

### 4.1 $V_m$ (cell.V\_m)

- **Before pulse (0–10 ms):** flat at −65 mV.
- **Pulse onset (10 ms):** begins exponential rise toward −45 mV with $\tau_m = 10\ \text{ms}$.
- **At 20 ms:** reaches −52.4 mV (63% of full deflection).
- **At ~60 ms** (i.e., $t_{start} + 5\tau_m$): plateau at approximately −45 mV.
- **Pulse offset (110 ms):** exponential decay back to −65 mV with $\tau_m = 10\ \text{ms}$.
- **At 120 ms:** −52.4 mV (63% of recovery).
- **After ~160 ms:** fully returned to −65 mV (outside simulation window; recovery is 99.3% complete by $t = 110 + 5 \times 10 = 160\ \text{ms}$, just beyond stop time).

### 4.2 $I_{cmd}$ (amplifier.I\_command or amplifier.I\_measured)

- **0–10 ms:** 0 pA.
- **10–110 ms:** square step to +20 pA.
- **110–150 ms:** returns to 0 pA.
- Shape is a perfect rectangle (ideal current source). No capacitive transient because CC measures $V_m$, not $I$.

### 4.3 $V_{pip}$ (pipette tip node, if accessible)

- Follows $V_m$ closely. Small additional ohmic offset $\approx I_{pulse} \times R_{pip} = 20\ \text{pA} \times 4\ \text{M}\Omega = 0.08\ \text{mV}$ above $V_m$ during pulse.
- Not the primary observable in CC.

### Variables to Plot

| Variable | Expected Range | Why Plot It |
|----------|---------------|-------------|
| `cell.V_m` | −65 mV to −45 mV | Primary observable: exponential charge/discharge |
| `amplifier.I_command` | 0 / +20 pA | Confirms pulse timing; serves as reference baseline |
| `cell.I_membrane` (if exposed) | 0 → 20 pA (transient) → 0 | Shows capacitive vs. resistive current split |
| `pipette.V_pip` (if exposed) | ~−65 to ~−45 mV | Check pipette voltage drop (should be < 0.1 mV) |

---

## 5. Step-by-Step Simulation Guide

1. **Open the model** in OpenModelica (OMEdit) by navigating to
   `PatchClamp > Examples > Step05_PassiveCellCurrentClamp`.

2. **Set simulation parameters** via *Simulation → Simulation Setup*:
   - Stop Time: `0.150` (s)
   - Number of intervals: `1500` (giving Interval = 0.1 ms = 1 × 10⁻⁴ s)
   - Tolerance: `1e-8`
   - Solver: Dassl or Cvode (stiff solver recommended)

3. **Click Simulate.** The run should complete in under 5 seconds.

4. **Add variables to the plot:**
   - Right-click `cell.V_m` in the Variables Browser → *Add to Active Plot*.
   - Add `amplifier.I_command` to a **second y-axis** (or separate plot window) to align timing.

5. **Verify baseline (0–10 ms):**
   - Zoom into 0–15 ms. Confirm $V_m = -65\ \text{mV}$ before $t = 10\ \text{ms}$.

6. **Verify pulse onset (10–20 ms):**
   - Zoom to 8–25 ms. Confirm $V_m$ begins rising at exactly $t = 10\ \text{ms}$.
   - At $t = 20\ \text{ms}$, read $V_m$; it should equal $-52.4\ \text{mV}$.

7. **Extract τ_m graphically:**
   - In OMEdit, use the cursor/data tip on the $V_m$ trace.
   - Find $t_{63}$ such that $V_m(t_{63}) = -52.4\ \text{mV}$.
   - Compute $\tau_m = t_{63} - 0.010\ \text{s}$. Expected: **10 ms**.

8. **Verify steady-state plateau (60–110 ms):**
   - Zoom to 60–115 ms. Confirm $V_m \approx -45\ \text{mV}$ (within 0.1 mV).

9. **Verify pulse offset (110–130 ms):**
   - Zoom to 108–130 ms. At $t = 120\ \text{ms}$, $V_m$ should be at $-52.4\ \text{mV}$ again (63% of return). Measure this to confirm symmetry.

10. **Full-trace view:**
    - Zoom out to show 0–150 ms. The trace should display a smooth, symmetric
      RC charging waveform.

---

## 6. Comparison Table — Model Series to Date

| Model | Clamp Mode | Dominant R | Dominant C | Visible τ | $I_{steady}$ / $V_{steady}$ |
|-------|-----------|-----------|-----------|----------|--------------------------|
| `Step01_PipetteSealTest` | N/A (open circuit) | $R_{pip} = 4\ \text{MΩ}$ | $C_{pip} = 3\ \text{pF}$ | $\tau_{pip} = 12\ \mu\text{s}$ | $V = I \cdot R_{pip}$ |
| `Step02_GigasealFormation` | N/A (gigaseal) | $R_{seal} \gg 1\ \text{GΩ}$ | $C_{pip} = 3\ \text{pF}$ | $\tau_{seal} \gg \text{ms}$ | $I \approx 0$ |
| `Step03_PassiveCellVoltageClamp` | Voltage-clamp | $R_{access} = R_{pip} = 4\ \text{MΩ}$ | $C_m = 10\ \text{pF}$ | $\tau_{pip} = 40\ \mu\text{s}^*$ | $I_{ss} = \Delta V / R_m$ |
| **`Step05_PassiveCellCurrentClamp`** | **Current-clamp** | **$R_m = 1\ \text{GΩ}$** | **$C_m = 10\ \text{pF}$** | **$\tau_m = 10\ \text{ms}$** | **$V_{ss} = -45\ \text{mV}$** |

*\*In Step03 the voltage-clamp topology puts $R_{pip}$ in series with $C_m$, giving $\tau_{VC} = R_{pip} \cdot C_m = 4\ \text{MΩ} \times 10\ \text{pF} = 40\ \mu\text{s}$. In Step05 the CC topology lets $V_m$ evolve freely, exposing $\tau_m = R_m \cdot C_m$.*

---

## 7. Exercises

### Exercise 1 — Parameter Sweep: $R_m$ (Series Resistance Error and $V_{ss}$)

**Background:** Membrane resistance varies enormously across cell types (100 MΩ – 10 GΩ). Both $\tau_m$ and $V_{ss}$ depend on $R_m$.

**Tasks:**

1. Before simulating, complete the table below using the formulas $\tau_m = R_m C_m$ and $\Delta V = I_{pulse} \cdot R_m$:

| $R_m$ | $\tau_m$ (ms) | $\Delta V$ (mV) | $V_{ss}$ (mV) |
|-------|-------------|----------------|--------------|
| 250 MΩ | ? | ? | ? |
| 500 MΩ | ? | ? | ? |
| 1000 MΩ (default) | 10 | 20 | −45 |
| 2000 MΩ | ? | ? | ? |

2. Run four simulations (change only `cell.R_m`; keep all other parameters at default).

3. For each run, extract $\tau_m$ graphically using the 63% criterion. Compare to your predictions.

4. At $R_m = 250\ \text{MΩ}$, $\Delta V = 5\ \text{mV}$. If your amplifier noise floor is 0.5 mV (rms), what is the signal-to-noise ratio for $\tau_m$ extraction?

5. What happens to the voltage response waveform when $R_m \to \infty$ (purely capacitive cell)? State your prediction, then test by setting `cell.R_m = 1e15`.

---

### Exercise 2 — Parameter Sweep: $C_m$ (Capacitance and Charge)

**Background:** $C_m$ scales with membrane area. Larger cells have larger $C_m$.

**Tasks:**

1. Predict $\tau_m$ for $C_m \in \{5, 10, 20, 50\}\ \text{pF}$ (keep $R_m = 1\ \text{GΩ}$).

2. Predict $V_{ss}$ for each case. Note that $V_{ss}$ is *independent* of $C_m$. Explain why.

3. Simulate and overlay all four $V_m$ traces. Verify that all four plateau at the same $V_{ss}$ while the charging speed changes.

4. To deposit the same charge $Q = C_m \Delta V$ on a larger cell ($C_m = 50\ \text{pF}$) in the same $5\tau_m$, what current pulse amplitude $I_{pulse}$ would be required to achieve $\Delta V = 20\ \text{mV}$? (Hint: $I_{pulse} = \Delta V / R_m$; the answer is independent of $C_m$.)

5. A neuron has $\tau_m = 30\ \text{ms}$ and $R_{in} = 500\ \text{MΩ}$. Calculate its $C_m$.

---

### Exercise 3 — Signal Dissection: Resistive vs. Capacitive Current Components

**Background:** Although $V_m$ is the observable in CC mode, current still flows through both $C_m$ and $R_m$ inside the cell compartment.

**Tasks:**

1. Write expressions for the capacitive current $I_C(t)$ and resistive current $I_R(t)$ flowing into the cell immediately after pulse onset ($t = 10\ \text{ms}^+$), at $t = t_{start} + \tau_m$, and at $t_{ss}$ (steady-state):

$$I_C(t) = C_m \frac{dV_m}{dt}, \quad I_R(t) = \frac{V_m - E_L}{R_m}$$

Evaluate numerically at each time point.

2. Confirm that $I_C + I_R = I_{pulse} = 20\ \text{pA}$ at all three time points (Kirchhoff's current law).

3. At what time after pulse onset has *half* the injected current been diverted from capacitor to resistor? (Hint: set $I_C = I_R$ and solve for $t$. Answer should be $\tau_m \ln 2 \approx 6.93\ \text{ms}$.)

4. In a voltage-clamp experiment (Step03), the capacitive transient current is large and fast. In this CC experiment, the capacitive current starts at $I_{pulse} = 20\ \text{pA}$ at $t = 0^+$ and decays exponentially. Why is the CC capacitive current *not* a brief spike as in VC? (Hint: consider what the amplifier controls in each mode.)

---

### Exercise 4 — Estimation/Extraction: Recovering Cell Parameters from the Trace

**Background:** In real experiments, $R_m$, $C_m$, and $\tau_m$ are extracted directly from the current-clamp response — there is no other way to measure them in a living cell.

**Tasks:**

1. Simulate with default parameters. Treat the $V_m$ trace as if it were real experimental data (i.e., pretend you don't know the parameters).

2. **Extract $\Delta V$** by reading $V_{ss}$ at plateau and $V_{rest}$ before the pulse. Compute:
   $$\Delta V_{measured} = V_{ss} - V_{rest}$$

3. **Extract $R_{in}$** (input resistance, ≈ $R_m$ here) from:
   $$R_{in} = \frac{\Delta V_{measured}}{I_{pulse}}$$
   Compare to the true $R_m = 1\ \text{GΩ}$.

4. **Extract $\tau_m$** using the 63% method described in Section 5, step 7.

5. **Compute $C_m$** from:
   $$C_m = \frac{\tau_m}{R_{in}}$$

6. Tabulate your extracted values vs. the model's true parameter values. Quantify the percentage error in each extracted quantity. What is the dominant source of error?

---

### Exercise 5 — Conceptual/Discussion: Why Current-Clamp Reveals τ_m But Not τ_pip

**Background:** The identical physical circuit (same $R_{pip}$, $C_{pip}$, $R_m$, $C_m$) gives a $\tau \approx 40\ \mu\text{s}$ response in voltage-clamp (Step03) and a $\tau = 10\ \text{ms}$ response in current-clamp (Step05). This is not paradoxical — it follows from circuit analysis.

**Tasks (no simulation required):**

1. In voltage-clamp, the amplifier acts as a **voltage source** (low output impedance) driving a step $\Delta V$ into the circuit. Draw the simplified Thevenin equivalent seen by $C_m$. Identify the series resistance that determines $\tau_{VC}$.

2. In current-clamp, the amplifier acts as a **current source** (high output impedance) injecting $I_{pulse}$ into the circuit. Draw the Norton equivalent seen by $C_m$. Identify the parallel resistance that determines $\tau_{CC}$.

3. Explain in one sentence why $R_{pip} = 4\ \text{MΩ}$ dominates in VC while $R_m = 1\ \text{GΩ}$ dominates in CC.

4. In a real whole-cell patch-clamp experiment, series resistance ($R_s \approx R_{pip}$) causes a voltage error in current-clamp recordings. The command voltage seen by the soma is reduced by:
   $$\Delta V_{error} = I_{pulse} \cdot R_s$$
   Calculate $\Delta V_{error}$ for $R_{pip} = 4\ \text{MΩ}$, $I_{pulse} = 20\ \text{pA}$. Is this error significant for a 20 mV step? When would it become problematic?

5. What physiological or experimental scenarios would make $\tau_{pip}$ *visible* in a current-clamp recording?

---

### Exercise 6 — Synthesis: Connecting Step01, Step02, Step03, and Step05

**Background:** The four models in this series represent the sequential steps of a patch-clamp experiment. Each step adds a component and reveals a different time constant.

**Tasks:**

1. Without running any new simulation, complete the following table entirely from first principles (use parameter values defined across all four models):

| Quantity | Step01 | Step02 | Step03 (VC) | Step05 (CC) |
|---------|-------|-------|-----------|-----------|
| Circuit dominant τ | ? | ? | ? | ? |
| Observable | $V_{pip}$ | $I_{leak}$ | $I_{measured}$ | $V_m$ |
| $\tau$ formula | ? | ? | ? | ? |
| $\tau$ value | ? | ? | ? | ? |

2. The "ladder" of time constants in this series spans six orders of magnitude. Sketch (on paper) a log-scale timeline from 1 µs to 100 ms and place each $\tau$ on it. Label the physical component pair responsible for each.

3. An experimenter applies a 20 pA, 100 ms current pulse as in Step05 but records an unexpected *additional* fast deflection ($\sim 5\ \text{mV}$, $\tau \approx 12\ \mu\text{s}$) at the very start of the pulse. Which circuit element is responsible? How would you reduce this artifact? (Hint: consider $C_{pip}$.)

4. If you could set $R_{pip} = 0$ (ideal whole-cell access), which time constants in the series would be affected and how? Discuss in terms of both VC and CC modes.

5. Summarise in three sentences the conceptual progression from Step01 to Step05: what problem each model solves and what new observable it exposes.

---

## 8. Summary Table

| Quantity | Symbol | Formula | Default Value |
|---------|--------|---------|--------------|
| Injected current (pulse) | $I_{pulse}$ | — | 20 pA |
| Pulse start | $t_{start}$ | — | 10 ms |
| Pulse end | $t_{end}$ | — | 110 ms |
| Pulse duration | $\Delta t$ | $t_{end} - t_{start}$ | 100 ms |
| Pipette resistance | $R_{pip}$ | — | 4 MΩ |
| Pipette capacitance | $C_{pip}$ | — | 3 pF |
| Bridge resistance | $R_{bridge}$ | — | 4 MΩ |
| Membrane capacitance | $C_m$ | — | 10 pF |
| Membrane resistance | $R_m$ | — | 1 GΩ |
| Resting potential | $V_{rest}$ | $E_L$ | −65 mV |
| Membrane time constant | $\tau_m$ | $R_m C_m$ | 10 ms |
| Voltage deflection | $\Delta V$ | $I_{pulse} \cdot R_m$ | 20 mV |
| Steady-state voltage | $V_{ss}$ | $V_{rest} + \Delta V$ | −45 mV |
| 63% voltage | $V_{63}$ | $V_{rest} + 0.6321\,\Delta V$ | −52.4 mV |
| Time to 63% | $t_{63}$ | $t_{start} + \tau_m$ | 20 ms |
| Pipette time constant | $\tau_{pip}$ | $R_{pip} C_{pip}$ | 12 µs |
| Bath resistance | $R_{bath}$ | — | 100 Ω |
| Simulation stop time | — | — | 150 ms |
| Simulation interval | — | — | 0.1 ms |
| Solver tolerance | — | — | 1 × 10⁻⁸ |

---

*Cross-references: see `Step01_PipetteSealTest` (Step 1), `Step02_GigasealFormation` (Step 2),
and `Step03_PassiveCellVoltageClamp` (Step 3a, voltage-clamp companion) for preceding models in this series.*
