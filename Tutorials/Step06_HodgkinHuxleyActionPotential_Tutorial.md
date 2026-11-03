# Tutorial Step06 — Hodgkin-Huxley Action Potential in Current-Clamp

> **Model path:** `PatchClamp.Examples.Step06_HodgkinHuxleyActionPotential`
> **Recommended stop time:** 50 ms | **Interval:** 10 µs | **Tolerance:** 1 × 10⁻⁸
>
> *This model follows Step03a and Step05 (passive cell in current-clamp). It introduces
> active membrane conductances. The pipette and amplifier components are identical to
> the previous tutorials; what changes is the cell model: the passive RC membrane is
> replaced by a full Hodgkin-Huxley neuron. See the cross-reference footer.*

---

## Learning Objectives

By the end of this tutorial, the student will be able to:

1. Identify the three Hodgkin-Huxley ionic conductances ($g_{Na}$, $g_K$, $g_L$) in
   an equivalent circuit and write the total membrane current equation.
2. Calculate the expected resting potential from the steady-state values of the gating
   variables and predict the threshold current analytically.
3. Describe the sequence of gating-variable changes ($m$, $h$, $n$) that produce the
   depolarisation, repolarisation, and after-hyperpolarisation phases of an action
   potential.
4. Extract the action-potential peak voltage, duration, and after-hyperpolarisation
   depth directly from a simulation trace and compare them to the canonical HH values.
5. Predict the outcome of stimulating during the refractory period and explain the
   ionic mechanism responsible for refractoriness.

---

## 1. Context

### Where this experiment fits

| Step | Model | What is new |
|------|-------|-------------|
| Step03a | `Step03a_PassiveCell_CC` | Passive RC cell; no ion channels |
| Step05 | `Step05_PassiveCellCurrentClamp` | Passive cell with pipette artefacts (C_pip, LJP) |
| **Step06** | **`Step06_HodgkinHuxleyActionPotential`** | **Active HH neuron; voltage-gated Na⁺ and K⁺ conductances** |

In Step03a/b the cell membrane was a simple RC circuit and the voltage response to a
current step was a smooth exponential charging curve. Here the *same* current-clamp
protocol is applied, but the cell is now a **Hodgkin-Huxley (HH) neuron**. Above a
critical threshold current (~29 pA in the default configuration) the membrane does not
simply charge; instead it fires an **action potential** — a self-amplifying, stereotyped
voltage transient that reverses sign before returning to rest.

### Physical change from the previous step

The passive `RC` cell block is replaced by `PatchClamp.Cells.HodgkinHuxleyNeuron`. The
pipette and amplifier are unchanged. The neuron block adds:

- Three **voltage-dependent conductances** in parallel with $C_m$.
- Three **gating variables** ($m$, $h$, $n$) with their own ODEs.
- Three **reversal potentials** ($E_{Na}$, $E_K$, $E_L$).

---

## 2. Equivalent Circuit

### ASCII diagram

```
 Current-clamp         Pipette             Hodgkin-Huxley Neuron          Bath
 amplifier

  ┌─────────┐        ┌──R_pip──┐     ┌──────────────────────────┐
  │         │        │         │     │                          │
  │ I_hold  ├──────►─┤    ├────┼─────┤──┬── C_m ──┬────────────┼───── R_bath ─── GND
  │ I_pulse │        │  C_pip  │     │  │          │            │
  └────┬────┘        └────┬────┘     │  ├─[g_Na·m³h]──E_Na(+50 mV)─┤
       │                 │          │  │                          │
       └─────────────────┴──────────┴──┴─[g_K·n⁴]────E_K(−77 mV)──┤
                                        │                          │
                                        └─[g_L]──────E_L(−54.4 mV)─┘
```

### Component table

| Symbol | Default value | Physical meaning |
|--------|--------------|-----------------|
| $I_{hold}$ | 0 pA | Baseline current from the amplifier |
| $I_{pulse}$ | **30 pA** | Supra-threshold current injection |
| $t_{pulse}$ | **10–15 ms** | Duration of the stimulus pulse |
| $R_{bridge}$ | 4 MΩ | Bridge-balance resistor (amplifier) |
| $R_{pip}$ | 4 MΩ | Patch pipette access resistance |
| $C_{pip}$ | 3 pF | Pipette stray capacitance |
| $V_{junction}$ | −11 mV | Liquid junction potential (LJP) |
| **$C_m$** | **10 pF** | **Membrane capacitance of the HH neuron** |
| **$A$** | **1000 pF** | **Membrane area scaling factor (see §3)** |
| **$g_{Na,max}$** | **1200 pS** | **Peak Na⁺ conductance (HH canonical)** |
| **$g_{K,max}$** | **360 pS** | **Peak K⁺ conductance (HH canonical)** |
| **$g_L$** | **3 pS** | **Leak conductance** |
| **$E_{Na}$** | **+50 mV** | **Na⁺ reversal potential** |
| **$E_K$** | **−77 mV** | **K⁺ reversal potential** |
| **$E_L$** | **−54.4 mV** | **Leak reversal potential** |
| $R_{bath}$ | 100 Ω | Bath electrode resistance (negligible) |

**Bold entries are new components introduced for the first time in this model.**

---

## 3. Key Parameters and Equations

### 3.1 Total membrane current

The HH formalism decomposes the ionic current into three branches:

$$I_{ion}(t) = I_{Na}(t) + I_K(t) + I_L(t)$$

$$I_{Na} = g_{Na,max} \cdot m^3 h \cdot (V_m - E_{Na})$$

$$I_K = g_{K,max} \cdot n^4 \cdot (V_m - E_K)$$

$$I_L = g_L \cdot (V_m - E_L)$$

The membrane equation (Kirchhoff's current law at the intracellular node):

$$C_m \frac{dV_m}{dt} = I_{inj}(t) - I_{Na}(t) - I_K(t) - I_L(t)$$

where $I_{inj}(t)$ is the current injected by the pipette (approximately equal to
$I_{pulse}$ after subtracting the small drop across $R_{pip}$).

### 3.2 Gating variable ODEs

Each variable obeys a first-order kinetic equation:

$$\frac{dq}{dt} = \alpha_q(V_m)\,(1-q) - \beta_q(V_m)\,q, \quad q \in \{m, h, n\}$$

At steady state: $q_\infty = \dfrac{\alpha_q}{\alpha_q + \beta_q}$, with time constant
$\tau_q = \dfrac{1}{\alpha_q + \beta_q}$.

### 3.3 Resting potential and initial conditions

The original HH equations are defined relative to the **resting displacement** from
$V_{rest} = -65$ mV. The model sets all three gating variables to their steady-state
values at $V_{rest}$, which are (HH 1952 canonical values at 6.3 °C):

| Variable | $q_\infty(V_{rest})$ | Physical meaning |
|----------|---------------------|-----------------|
| $m_0$ | ≈ 0.053 | Fraction of Na⁺ activation gates open at rest |
| $h_0$ | ≈ 0.596 | Fraction of Na⁺ inactivation gates *not* blocked at rest |
| $n_0$ | ≈ 0.318 | Fraction of K⁺ activation gates open at rest |

At rest the leak sets the equilibrium:

$$V_{rest} = -65 \text{ mV} \quad \text{(imposed by initial conditions)}$$

A check: the resting leak current is:

$$I_L = g_L (V_{rest} - E_L) = 3 \times 10^{-12} \times (-0.065 - (-0.0544))$$
$$= 3 \times 10^{-12} \times (-0.0106) \approx -31.8 \text{ fA}$$

This is negligible compared to $I_{pulse} = 30$ pA, confirming that the resting
membrane is stable.

### 3.4 Threshold current estimate

Below threshold, the membrane behaves approximately as an RC circuit with time constant:

$$\tau_m = R_{in} \cdot C_m$$

The input resistance is dominated by the leak:

$$R_{in} = \frac{1}{g_L} = \frac{1}{3 \times 10^{-12}} \approx 333 \text{ G}\Omega$$

> **Assumption:** $g_L = 3$ pS is the dominant resting conductance since $m^3 h$ and
> $n^4$ are small at $V_{rest}$. In a real neuron $R_{in}$ would be lower due to
> background synaptic conductances.

The threshold voltage (depolarisation needed to trigger a regenerative Na⁺ current) is
approximately:

$$\Delta V_{threshold} \approx -55 - (-65) = 10 \text{ mV}$$

The minimum charge needed:

$$Q_{threshold} = C_m \cdot \Delta V_{threshold} = 10 \times 10^{-12} \times 10 \times 10^{-3}
= 100 \text{ fC}$$

For a 5 ms pulse:

$$I_{threshold} = \frac{Q_{threshold}}{t_{pulse}} = \frac{100 \times 10^{-15}}{5 \times 10^{-3}}
= 20 \text{ pA (analytical lower bound)}$$

The model documentation states the actual threshold is ~29 pA, reflecting that during
the pulse the leak conductance (and a small outward $K^+$ current) partially opposes
the depolarisation. The 30 pA default is supra-threshold.

### 3.5 Expected peak voltages and currents

| Quantity | Formula | Value |
|---------|---------|-------|
| $V_{rest}$ | Initial condition | −65 mV |
| $V_{threshold}$ | Approx. from HH rate functions | ≈ −55 mV |
| $V_{peak}$ | $V_m$ when $dV_m/dt = 0$ during upstroke | ≈ +35 mV |
| $\Delta V_{AP}$ | $V_{peak} - V_{rest}$ | ≈ 100 mV |
| $I_{Na,peak}$ | $g_{Na,max} \cdot m^3 h \cdot (V_{peak} - E_{Na})$ | Order of −1 to −3 nA (inward) |
| $I_{K,peak}$ | $g_{K,max} \cdot n^4 \cdot (V_{peak} - E_K)$ | Order of +0.5 to +1 nA (outward) |
| AP duration (FWHM) | Read from trace | ≈ 2–3 ms (at 6.3 °C equivalent) |
| After-hyperpolarisation | Below $V_{rest}$ | ≈ −68 to −72 mV |

### 3.6 Capacitive artefact at pulse onset

Because the pipette has $C_{pip} = 3$ pF and the step $I_{pulse} = 30$ pA is applied
at $t = 10$ ms, there is a transient charge redistribution. The time constant of the
artefact is:

$$\tau_{pip} = R_{pip} \cdot C_{pip} = 4 \times 10^6 \times 3 \times 10^{-12} = 12 \text{ µs}$$

This is far below the AP time scale (milliseconds) and will appear as a very brief
spike on $V_m$ at $t = 10$ ms and $t = 15$ ms.

### 3.7 Series resistance voltage error

During peak $I_{Na}$ (~1–3 nA), the voltage drop across $R_{pip} = 4$ MΩ is:

$$\Delta V_{Rs} = I_{Na,peak} \times R_{pip} \approx 2 \times 10^{-9} \times 4 \times 10^6
= 8 \text{ mV}$$

This is a significant systematic error; in real experiments it is partially compensated
by series resistance compensation circuitry.

### 3.8 Summary of key quantities

| Quantity | Formula | Default value |
|---------|---------|--------------|
| $V_{rest}$ | HH initial condition | −65 mV |
| $V_{threshold}$ | From rate functions | ≈ −55 mV |
| $V_{peak}$ | Simulation | ≈ +35 mV |
| AP duration | Simulation (FWHM) | ≈ 2–3 ms |
| After-hyperpolarisation | Simulation | ≈ −68 to −72 mV |
| $\tau_{pip}$ | $R_{pip} \cdot C_{pip}$ | 12 µs |
| $\Delta V_{Rs}$ | $I_{Na,peak} \cdot R_{pip}$ | ≈ 4–8 mV |
| $Q_{threshold}$ (analytical) | $C_m \cdot \Delta V_{th}$ | 100 fC |
| $I_{threshold}$ (analytical) | $Q_{th}/t_{pulse}$ | ~20 pA (lower bound) |
| $I_{threshold}$ (model) | From model documentation | ~29 pA |
| $I_{pulse}$ | Model parameter | 30 pA |
| $g_{Na,max}$ | Model parameter | 1200 pS |
| $g_{K,max}$ | Model parameter | 360 pS |
| $g_L$ | Model parameter | 3 pS |

---

## 4. Expected Signals

### 4.1 Narrative description

**Membrane potential $V_m$** is the central observable. During the first 10 ms ($I = 0$)
it sits at −65 mV. When $I_{pulse}$ is applied at $t = 10$ ms, $V_m$ rises slowly
until it crosses $V_{threshold} \approx -55$ mV at which point $m$ gates open rapidly,
$g_{Na}$ shoots up, and the membrane self-regeneratively depolarises to ~+35 mV in
< 1 ms. Then $h$ (inactivation) closes Na⁺ channels and $n$ (K⁺ activation) opens K⁺
channels, driving $V_m$ back below $V_{rest}$ to produce an
**after-hyperpolarisation (AHP)** near −70 mV. $V_m$ returns to rest by ~25 ms.

**Gating variables** ($m$, $h$, $n$) are dimensionless numbers between 0 and 1:

- $m$ rises first and fastest during the upstroke (ms timescale).
- $h$ falls during the upstroke (Na⁺ inactivation), causing the plateau to terminate.
- $n$ rises more slowly (K⁺ activation), peaks near the repolarisation, then decays.

**Ionic currents** ($I_{Na}$, $I_K$) are in the nA range:

- $I_{Na}$ is large and inward (negative) during the upstroke.
- $I_K$ is outward (positive) during repolarisation.

### 4.2 Variables to plot

| Variable | Unit | Expected range | When to see |
|---------|------|--------------|------------|
| `neuron.V_m` | mV | −70 to +40 mV | Throughout; AP fires ~10–12 ms |
| `neuron.m` | — | 0 to 1 | Peaks during upstroke (~10–11 ms) |
| `neuron.h` | — | 0 to 1 | Falls during upstroke, recovers by ~20 ms |
| `neuron.n` | — | 0 to 1 | Peaks during repolarisation (~12–14 ms) |
| `neuron.I_Na` | nA | −3 to 0 nA | Inward peak ~10–11 ms |
| `neuron.I_K` | nA | 0 to +1 nA | Outward peak ~12–13 ms |
| `amplifier.V_m_measured` | mV | −70 to +40 mV | Slightly distorted by $R_{pip}$ drop |

> **Note on $I_{Na}$ sign convention:** Inward current (Na⁺ rushing in) is plotted as
> *negative* in the conventional electrophysiology notation used by this model.

---

<!-- build:start -->
## Build it yourself

Instead of opening the finished example you can build the model from an empty diagram, which is the best way to see how its blocks fit together. Read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) first.

1. Create a new model named `MyStep06` and open its **Diagram View**.
2. Add the blocks, set their parameters and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amplifier` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → HodgkinHuxleyNeuron` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amplifier`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `30.0e-12` |

- `pipette`: keep all defaults.

- `neuron`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `10.0e-12` |
  | `A` | `1000.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amplifier.p` | `pipette.p_amp` |
| `pipette.p_cell` | `neuron.membrane_p` |
| `neuron.membrane_n` | `bath.p` |
| `amplifier.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.050, Interval = 1e-5, Tolerance = 1e-8.

The amplifier is a **current-clamp** amplifier (it injects current and reports voltage).

3. **Check Model**, then **Simulate**.

Compare your model with `PatchClamp → Examples → Step06_HodgkinHuxleyActionPotential`: the traces should overlay. From here on, the *Simulation Guide* below works with your `MyStep06` exactly as with the library example.
<!-- build:end -->

## 5. Step-by-Step Simulation Guide

1. **Open OMEdit** and load `PatchClamp.Examples.Step06_HodgkinHuxleyActionPotential`.

2. **Set simulation parameters** (Simulate → Simulation Setup):
   - Stop time: `0.050` s (50 ms)
   - Interval: `1e-5` s (10 µs) — needed to resolve the fast AP upstroke
   - Solver: DASSL or CVODE
   - Tolerance: `1e-8`

3. **Run** the simulation.

4. **First plot — membrane potential:**
   - Plot `neuron.V_m` (convert to mV by multiplying by 1000 in the plot tool, or
     check if the model already outputs in V).
   - You should see: flat baseline at −65 mV → small linear ramp from t = 10 ms →
     explosive upstroke → repolarisation → AHP → return to −65 mV.

5. **Zoom into the action potential** (t = 9 ms to 20 ms):
   - Measure $V_{peak}$: the maximum voltage during the upstroke.
   - Measure $V_{AHP}$: the minimum voltage after repolarisation.
   - Measure AP duration at half-maximal amplitude (FWHM).

6. **Second plot — gating variables:**
   - Plot `neuron.m`, `neuron.h`, `neuron.n` on the same axes (range 0–1).
   - Observe that $m$ rises first (fastest), $h$ falls as $m$ rises, and $n$ lags
     behind both.
   - Zoom into t = 10–18 ms.

7. **Third plot — ionic currents:**
   - Plot `neuron.I_Na` and `neuron.I_K` (in A; rescale to nA × 10⁻⁹).
   - Note: $|I_{Na,peak}| > |I_{K,peak}|$ — the inward Na⁺ current dominates the
     upstroke.

8. **Fourth plot — artefact inspection:**
   - Zoom to t = 9.9 ms to 10.1 ms (around pulse onset).
   - Identify the 12 µs capacitive artefact from $C_{pip}$.

9. **Compare measured vs. true membrane potential:**
   - Plot both `amplifier.V_m_measured` and `neuron.V_m` on the same axes.
   - The difference at AP peak is the series resistance error $\Delta V_{Rs}$.

10. **Below-threshold test** (optional, see Exercise 1):
    - Change `I_pulse` to `8e-12` (8 pA). Re-simulate. Verify that only a passive
      charging curve is seen — no AP fires.

---

## 6. Comparison Table — Series Context

| Model | Dominant resistance | Dominant capacitance | Visible time constant | $V_{steady}$ / peak response | Active currents |
|-------|--------------------|--------------------|----------------------|------------------------------|----------------|
| Step03a (`PassiveCell_CC`) | $R_{in}$ (passive) | $C_m$ | $\tau = R_{in} C_m$ | Subthreshold plateau | None |
| Step05 (`PassiveCell_CC` + pipette) | $R_{pip}$ + $R_{in}$ | $C_m$ + $C_{pip}$ | $\tau_{pip} = R_{pip} C_{pip}$ | Subthreshold + artefact | None |
| **Step06 (`HHActionPotential`)** | **$g_{Na}^{-1}$ (peak, ~0.8 GΩ)** | **$C_m = 10$ pF** | **AP upstroke < 1 ms** | **$V_{peak} \approx +35$ mV** | **$I_{Na}$, $I_K$, $I_L$** |

---

## 7. Exercises

### Exercise 1 — Parameter Sweep: Threshold Current (Parameter sweep)

The model fires an action potential at $I_{pulse} = 30$ pA. The documentation states
the threshold is ~29 pA.

**Pre-simulation calculation:**

Using the charge-threshold estimate:

$$I_{th} = \frac{C_m \cdot \Delta V_{th}}{t_{pulse}} = \frac{10 \times 10^{-12} \times 10 \times 10^{-3}}{5 \times 10^{-3}} = 20 \text{ pA}$$

This is a lower bound. The actual threshold is higher because the leak and early K⁺
current continuously drain charge during the pulse.

**Tasks:**

1. Predict whether an AP fires for $I_{pulse} \in \{5, 15, 25, 35\}$ pA. Justify each
   prediction using the charge estimate.
2. Simulate each value. Record: (a) whether an AP fires, (b) the peak $V_m$ reached.
3. Determine the threshold current to the nearest 1 pA by binary search (simulate a
   few intermediate values). Compare to the 29 pA value in the documentation.
4. Plot $V_{peak}$ vs. $I_{pulse}$ for all tested values. Does the peak voltage change
   above threshold, or is it truly "all-or-none"? What does this tell you about the
   regenerative nature of the Na⁺ current?

---

### Exercise 2 — Signal Dissection: Gating Variable Kinetics (Signal dissection)

The speed hierarchy of the HH gating variables ($m$ fastest, $h$ and $n$ slower)
determines the AP waveform.

**Tasks:**

1. In the simulation, plot $m$, $h$, and $n$ together (t = 10–20 ms). Rank the three
   variables by the time from pulse onset to their respective peak or trough.
2. The Na⁺ conductance is $G_{Na}(t) = g_{Na,max} \cdot m(t)^3 \cdot h(t)$.
   Reconstruct this product numerically from the $m$ and $h$ traces. At what time
   (relative to pulse onset) does $G_{Na}$ peak? What causes it to fall?
3. The K⁺ conductance is $G_K(t) = g_{K,max} \cdot n(t)^4$.
   At what time does $G_K$ peak relative to $G_{Na}$? By how many milliseconds does
   $G_K$ lag behind $G_{Na}$?
4. Using only the $G_{Na}$ and $G_K$ traces (not $V_m$), explain qualitatively the
   sequence: upstroke → repolarisation → AHP.

---

### Exercise 3 — Error Analysis: Series Resistance Artefact (Error analysis)

During an action potential, the large ionic current through $R_{pip}$ creates a
systematic voltage error.

**Pre-simulation calculation:**

Estimate $\Delta V_{Rs}$ at peak Na⁺ current:

$$\Delta V_{Rs} = I_{Na,peak} \times R_{pip}$$

Assume $I_{Na,peak} \approx -2$ nA (typical for HH at these parameters):

$$\Delta V_{Rs} = -2 \times 10^{-9} \times 4 \times 10^6 = -8 \text{ mV}$$

**Tasks:**

1. From the simulation, read $I_{Na}(t)$ at the time of its peak. Calculate the actual
   $\Delta V_{Rs}$ using the formula above.
2. Plot both `amplifier.V_m_measured` and `neuron.V_m` on the same axes. What is the
   maximum discrepancy, and at what time during the AP does it occur?
3. Does the series resistance error *increase* or *decrease* the apparent peak voltage
   as seen by the amplifier? Explain the sign of the error.
4. If the experimenter used 80% series resistance compensation (reducing the effective
   $R_{pip}$ to 20% of its value), what would $\Delta V_{Rs}$ become? Would this
   be sufficient for a faithful AP recording?

---

### Exercise 4 — Estimation/Extraction: Recovering Parameters from the AP Waveform (Estimation)

In a real patch-clamp experiment, the biophysicist extracts biophysical parameters
from the AP waveform without direct access to the underlying conductances.

**Tasks:**

1. From the `neuron.V_m` trace, measure:
   - $V_{rest}$: the baseline voltage before the pulse.
   - $V_{threshold}$: the voltage at which $dV_m/dt$ first exceeds 10 mV/ms
     (use the rate-of-rise criterion).
   - $V_{peak}$: the maximum voltage during the AP.
   - $t_{upstroke}$: the time from threshold crossing to $V_{peak}$.
   - AP duration at half-maximum amplitude (FWHM).
   - $V_{AHP}$: the minimum voltage after repolarisation.

2. Using $V_{threshold}$ and $V_{peak}$, estimate the average rate of rise:

   $$\left.\frac{dV_m}{dt}\right|_{mean} = \frac{V_{peak} - V_{threshold}}{t_{upstroke}}$$

   Compare this to the maximum $dV_m/dt$ from the simulation (the peak of the
   numerical derivative of `neuron.V_m`).

3. The maximum $dV_m/dt$ is proportional to $I_{Na,peak}/C_m$. Using your measured
   $dV_m/dt|_{max}$ and the known $C_m = 10$ pF, estimate $I_{Na,peak}$:

   $$I_{Na,peak} \approx C_m \times \left.\frac{dV_m}{dt}\right|_{max}$$

   Compare to the directly plotted `neuron.I_Na` peak.

---

### Exercise 5 — Conceptual: The Refractory Period (Conceptual/discussion)

The refractory period is a fundamental property of excitable membranes that limits the
maximum firing rate of neurons.

**Tasks (no simulation required for parts 1–3):**

1. Immediately after an action potential, explain in terms of $m$, $h$, and $n$ why
   a second identical stimulus at $t = 17$ ms (2 ms after AP onset) would fail to
   trigger another AP. This is the **absolute refractory period**.
2. Between $t = 20$ ms and $t = 30$ ms, $h$ is partially recovered but $n$ is still
   elevated. Why would a second stimulus during this window elicit an AP, but with a
   higher threshold current? This is the **relative refractory period**.
3. Predict: if you applied a 30 pA pulse starting at $t = 18$ ms (duration 5 ms),
   would a second AP fire? What about at $t = 25$ ms?
4. **Simulation verification:** Add a second pulse by modifying the amplifier
   parameters (or by summing two pulse signals). Test your predictions at $t = 18$ ms
   and $t = 25$ ms. Record whether an AP fires and, if so, what is $V_{peak}$
   compared to the first AP.

---

### Exercise 6 — Synthesis: From Passive to Active Membrane (Synthesis)

This exercise integrates all three models in the series (Step03a, Step05, Step06).

**Tasks:**

1. In Step03a/b, the voltage response to a 30 pA step was a simple RC exponential. In
   Step06, the response is qualitatively different above threshold. Quantify the
   difference: what is the peak voltage in Step03a/b for a 30 pA, 5 ms pulse
   (calculate analytically), and what is it in Step06 (from simulation)?

2. The series resistance $R_{pip} = 4$ MΩ and $C_{pip} = 3$ pF appear in both
   Step05 and Step06. In Step05, the dominant effect of $R_{pip}$ is the voltage divider
   attenuation of the *steady-state* response. In Step06, the dominant effect is the
   *transient* voltage error during the AP. Explain why the same physical component
   causes different practical problems in the two settings.

3. In Step05, the liquid junction potential (LJP = −11 mV) shifts the apparent
   resting potential. In Step06, does the LJP affect the *threshold* for AP generation
   (as seen by the amplifier)? Explain your reasoning and verify with a simulation
   using $V_{junction} = 0$ mV vs. $-11$ mV.

4. Construct a unified comparison table for Step03a, Step05, and Step06 showing: resting
   $V_m$ (measured), threshold for a response, peak $V_m$ after a 30 pA pulse, and
   the dominant source of measurement error. Use values from simulations and
   calculations performed in this and previous tutorials.

---

## 8. Summary Table

| Quantity | Formula | Default value |
|---------|---------|--------------|
| $V_{rest}$ | HH initial condition | −65 mV |
| $V_{threshold}$ | From rate functions | ≈ −55 mV |
| $\Delta V_{th}$ | $V_{th} - V_{rest}$ | ≈ 10 mV |
| $Q_{threshold}$ | $C_m \cdot \Delta V_{th}$ | ≈ 100 fC |
| $I_{threshold}$ (lower bound) | $Q_{th}/t_{pulse}$ | ≈ 20 pA |
| $I_{threshold}$ (model) | Documentation value | ≈ 29 pA |
| $I_{pulse}$ | Model parameter | 30 pA |
| $t_{pulse}$ | $t_{end} - t_{start}$ | 5 ms (10–15 ms) |
| $V_{peak}$ | Simulation | ≈ +35 mV |
| $\Delta V_{AP}$ | $V_{peak} - V_{rest}$ | ≈ 100 mV |
| AP duration (FWHM) | Simulation | ≈ 2–3 ms |
| $V_{AHP}$ | Simulation | ≈ −68 to −72 mV |
| $C_m$ | Model parameter | 10 pF |
| $g_{Na,max}$ | Model parameter | 1200 pS |
| $g_{K,max}$ | Model parameter | 360 pS |
| $g_L$ | Model parameter | 3 pS |
| $E_{Na}$ | Model parameter | +50 mV |
| $E_K$ | Model parameter | −77 mV |
| $E_L$ | Model parameter | −54.4 mV |
| $R_{pip}$ | Model parameter | 4 MΩ |
| $C_{pip}$ | Model parameter | 3 pF |
| $\tau_{pip}$ | $R_{pip} \cdot C_{pip}$ | 12 µs |
| $V_{junction}$ (LJP) | Model parameter | −11 mV |
| $\Delta V_{Rs}$ (at AP peak) | $I_{Na,peak} \cdot R_{pip}$ | ≈ 4–8 mV |
| $R_{bath}$ | Model parameter | 100 Ω |
| Stop time | `experiment()` annotation | 50 ms |
| Interval | `experiment()` annotation | 10 µs |
| Tolerance | `experiment()` annotation | 1 × 10⁻⁸ |

---

*Cross-reference: This tutorial (Step06) follows Step05 (`Step05_PassiveCellCurrentClamp`), which
introduced the passive cell with pipette artefacts. The passive RC membrane of Step03a/b
is replaced here by a Hodgkin-Huxley active neuron. The amplifier and pipette
components ($R_{pip}$, $C_{pip}$, LJP) carry over unchanged from Step05. The model is
based on: Hodgkin AL, Huxley AF (1952). A quantitative description of membrane current
and its application to conduction and excitation in nerve. J Physiol 117:500–544.*
