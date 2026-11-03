# Model Reference

Complete parameter and output reference for every cell model and example
in the PatchClamp package. Use this alongside OMEdit's **View Documentation**
(right-click any block) for in-context explanations.

---

## Cell Models

All cell models are in `PatchClamp.Cells` and extend
`Cells.Interfaces.PartialExcitableCell`. They share two connectors:

| Connector | Side | Domain |
|---|---|---|
| `membrane_p` | Left | Electrical (positive pin) |
| `membrane_n` | Right | Electrical (negative pin, ground) |

The base interface defines `V_m` (membrane voltage, V), `C_m` (capacitance, F),
and `A` (membrane area, m²).

---

### PassiveCell

> `PatchClamp.Cells.PassiveCell`

The simplest possible cell: a resistor R_m in parallel with the inherited
capacitor C_m. No active channels. Used to measure the membrane time constant
and as a reference for amplifier calibration.

**Equivalent circuit:** $I = C_m \dot{V}_m + V_m / R_m$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `R_m` | 1×10⁹ | Ω | Membrane resistance (1 GΩ) |
| `C_m` | (from base) | F | Membrane capacitance |

**Key output:** `V_m` — exponential approach to steady state.

**What to vary:** Increase `R_m` → longer τ and higher final voltage.
Decrease `C_m` → faster charging.

**Expected simulation:** StopTime = 0.5 s, Interval = 1×10⁻⁵ s.
τ = R_m · C_m. With default R_m = 1 GΩ and C_m from base (~10 pF): τ = 10 ms.

---

### SimplifiedNeuron (LIF)

> `PatchClamp.Cells.SimplifiedNeuron`

Leaky integrate-and-fire model. Fires an instantaneous reset when V_m reaches
threshold. No gate dynamics — fastest introduction to neural firing.

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `R_m` | 10×10⁶ | Ω | Membrane resistance (10 MΩ) |
| `V_threshold` | −0.055 | V | Firing threshold |
| `V_reset` | −0.070 | V | Post-spike reset voltage |
| `V_rest` | −0.065 | V | Resting potential |
| `C_m` | 10×10⁻¹² | F | Membrane capacitance (10 pF) |
| `A` | (from base) | m² | Membrane area |

**Key outputs:** `V_m`, `spike` (Boolean).

**What to vary:** Increase injected current → higher firing frequency.
Raise `V_threshold` → harder to fire (higher rheobase).

**Expected simulation:** StopTime = 0.2 s, Interval = 1×10⁻⁵ s.

---

### HodgkinHuxleyNeuron

> `PatchClamp.Cells.HodgkinHuxleyNeuron`

Full Hodgkin-Huxley (1952) model from squid giant axon. Three ODEs for gate
variables m, h, n. The canonical reference for action potential dynamics.

**Equations:**
- $C_m \dot{V}_m = -g_{Na,\max}m^3h(V_m-E_{Na}) - g_{K,\max}n^4(V_m-E_K) - g_L(V_m-E_L) + I_{ext}/A$
- $\dot{m} = \alpha_m(V_m)(1-m) - \beta_m(V_m)m$
- $\dot{h} = \alpha_h(V_m)(1-h) - \beta_h(V_m)h$
- $\dot{n} = \alpha_n(V_m)(1-n) - \beta_n(V_m)n$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `g_Na_max` | 1200.0 | S m⁻² | Max Na⁺ conductance density |
| `g_K_max` | 360.0 | S m⁻² | Max K⁺ conductance density |
| `g_L` | 3.0 | S m⁻² | Leak conductance density |
| `E_Na` | +0.050 | V | Na⁺ reversal potential (+50 mV) |
| `E_K` | −0.077 | V | K⁺ reversal potential (−77 mV) |
| `E_L` | −0.0544 | V | Leak reversal potential |
| `C_m` | (from base) | F | Membrane capacitance |

**Key outputs:** `V_m`, `m`, `h`, `n`, `I_Na`, `I_K`, `I_L`.

**What to vary:**
- `g_Na_max` ↓ → smaller AP peak, eventually subthreshold
- `E_K` → shifts afterhyperpolarization depth
- `g_L` ↑ → raises threshold, requires more current to fire

**Expected simulation (Step06):** StopTime = 0.050 s, Interval = 1×10⁻⁵ s.
Single AP shortly after the 10 ms pulse onset. Peak V_m ≈ +34 mV.

---

### FitzHughNagumoNeuron

> `PatchClamp.Cells.FitzHughNagumoNeuron`

Two-variable reduction of Hodgkin-Huxley. Uses normalized (dimensionless)
voltage. Ideal for phase-plane analysis and studying excitability classes.

**Equations:**
- $\dot{v} = (v - v^3/3 - w + I_{ext}) / \tau_u$
- $\dot{w} = \epsilon(v + a - bw) / \tau_u$
- $V_m = V_{rest} + v \cdot V_{scale}$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `a` | 0.7 | — | Recovery variable offset |
| `b` | 0.8 | — | Recovery variable slope |
| `epsilon` | 0.08 | — | Time-scale ratio (slow/fast) |
| `tau_u` | 2×10⁻³ | s | Fast time constant (2 ms) |
| `V_rest` | −0.065 | V | Resting voltage (for display) |
| `V_scale` | 0.100 | V | Voltage normalization scale |
| `C_m` | 10×10⁻¹² | F | |

**Key outputs:** `V_m`, `v` (normalized), `w` (recovery).

**What to vary:**
- `I_ext` above/below threshold → limit cycle vs. fixed point
- `epsilon` → smaller = slower recovery = longer AP duration
- `a`, `b` → shift bifurcation point (excitability class)

**Expected simulation (Step14):** StopTime = 0.100 s, Interval = 1×10⁻⁵ s.
Plot `v` vs `w` for phase portrait.

---

### MorrisLecarNeuron

> `PatchClamp.Cells.MorrisLecarNeuron`

Morris-Lecar (1981) barnacle muscle fiber model. Ca²⁺ activation is
instantaneous (algebraic); K⁺ activation is the single ODE.
Default parameters → **Type II** neuron (Hopf bifurcation).

**Equations:**
- $C_m \dot{V}_m = -g_{Ca}m_\infty(V_m)(V_m-E_{Ca}) - g_K w(V_m-E_K) - g_L(V_m-E_L) + I_{ext}/A$
- $\dot{w} = \phi \cdot (w_\infty(V_m) - w) / \tau_w(V_m)$
- $m_\infty = \tfrac{1}{2}(1 + \tanh((V_m-V_1)/V_2))$
- $w_\infty = \tfrac{1}{2}(1 + \tanh((V_m-V_3)/V_4))$
- $\tau_w = 1 / (\phi \cosh((V_m-V_3)/(2V_4)))$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `g_Ca` | 44.0 | S m⁻² | Max Ca²⁺ conductance (Type II default) |
| `g_K` | 80.0 | S m⁻² | Max K⁺ conductance |
| `g_L` | 2.0 | S m⁻² | Leak conductance |
| `E_Ca` | +0.120 | V | Ca²⁺ reversal (+120 mV) |
| `E_K` | −0.084 | V | K⁺ reversal (−84 mV) |
| `E_L` | −0.060 | V | Leak reversal (−60 mV) |
| `V1` | −0.0012 | V | Ca²⁺ half-activation voltage |
| `V2` | 0.018 | V | Ca²⁺ activation slope |
| `V3` | 0.002 | V | K⁺ half-activation voltage |
| `V4` | 0.030 | V | K⁺ activation slope |
| `phi` | 40.0 | s⁻¹ | K⁺ rate scaling factor |
| `C_m` | 20×10⁻¹² | F | Membrane capacitance (20 pF) |

**Type I configuration:** Set `g_Ca=20, g_K=80, V3=-0.001, V4=0.015, phi=0.067`
→ saddle-node bifurcation → graded frequency response.

**Key outputs:** `V_m`, `w`, `m_inf`, `I_Ca`, `I_K`.

**Expected simulation (Step15):** StopTime = 0.200 s, Interval = 1×10⁻⁵ s.
Type II: repetitive firing at fixed frequency above threshold.

---

### CardiacVentricularCell

> `PatchClamp.Cells.CardiacVentricularCell`

Simplified ventricular myocyte. Four ionic currents with Boltzmann gates.
Produces a long-plateau action potential (~200 ms) characteristic of cardiac muscle.

**Equations (membrane):**
- $I_{Na} = g_{Na} \cdot m_{Na}^3 \cdot h_{Na} \cdot (V_m-E_{Na}) \cdot A$
- $I_{Ca} = g_{Ca} \cdot d_\infty(V_m) \cdot (V_m-E_{Ca}) \cdot A$ *(algebraic gate)*
- $I_K = g_K \cdot n_K \cdot (V_m-E_K) \cdot A$
- $I_L = g_L \cdot (V_m-E_L) \cdot A$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `g_Na` | 23.0 | S m⁻² | Fast Na⁺ conductance |
| `g_Ca` | 0.5 | S m⁻² | L-type Ca²⁺ conductance |
| `g_K` | 2.0 | S m⁻² | Rapid K⁺ conductance (IKr) |
| `g_L` | 0.2 | S m⁻² | Leak conductance |
| `E_Na` | +0.050 | V | Na⁺ reversal (+50 mV) |
| `E_Ca` | +0.120 | V | Ca²⁺ reversal (+120 mV) |
| `E_K` | −0.084 | V | K⁺ reversal (−84 mV) |
| `E_L` | −0.060 | V | Leak reversal (−60 mV) |
| `tau_m` | 0.5×10⁻³ | s | Na⁺ activation time constant (0.5 ms) |
| `tau_h` | 8.0×10⁻³ | s | Na⁺ inactivation time constant (8 ms) |
| `tau_n` | 200×10⁻³ | s | K⁺ activation time constant (200 ms) |
| `C_m` | 100×10⁻¹² | F | Membrane capacitance (100 pF) |
| `A` | 1500×10⁻¹² | m² | Membrane area |
| `V_m(start)` | −0.080 | V | Initial condition |

**Key outputs:** `V_m`, `m_Na`, `h_Na`, `n_K`, `d_inf`, `I_Na`, `I_Ca`, `I_K`.

**What to vary:**
- `tau_n` ↓ → shorter plateau (faster repolarization)
- `g_Ca` ↑ → taller, longer plateau
- `g_K` ↑ → faster repolarization, shorter QT equivalent

**Expected simulation (Step16):** StopTime = 0.400 s, Interval = 1×10⁻⁵ s, Tolerance = 1×10⁻⁹.
1 ms stimulus → AP with plateau ~200 ms. V_m peak ≈ +30 mV.

---

### PacemakerCell

> `PatchClamp.Cells.PacemakerCell`

Simplified sinoatrial node pacemaker. No stable resting state — fires
spontaneously. Models the HCN/If "funny current" that drives diastolic
depolarization.

**Three currents:**
- **If (HCN):** $I_f = g_f \cdot y \cdot (V_m - E_f)$ — activates on *hyperpolarization*
- **ICa (L-type):** $I_{Ca} = g_{Ca} \cdot d_\infty(V_m) \cdot (V_m - E_{Ca})$ — algebraic
- **IKr:** $I_K = g_K \cdot n \cdot (V_m - E_K)$ — delayed rectifier

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `g_f` | 0.014 | S m⁻² | HCN/If conductance (calibrated: period ≈ 0.80 s) |
| `E_f` | −0.020 | V | If reversal (−20 mV, mixed Na⁺/K⁺) |
| `V_f_half` | −0.058 | V | If half-activation voltage |
| `k_f` | 0.007 | V | If activation slope (7 mV) |
| `tau_y` | 600×10⁻³ | s | If activation time constant (600 ms) |
| `g_Ca` | 0.5 | S m⁻² | L-type Ca²⁺ conductance |
| `E_Ca` | +0.060 | V | Ca²⁺ reversal (+60 mV) |
| `V_d_half` | −0.030 | V | Ca²⁺ half-activation (−30 mV, Cav1.3-like) |
| `k_d` | 0.008 | V | Ca²⁺ activation slope (8 mV) |
| `g_K` | 4.0 | S m⁻² | IKr conductance |
| `E_K` | −0.080 | V | K⁺ reversal (−80 mV) |
| `V_n_half` | −0.020 | V | IKr half-activation voltage |
| `k_n` | 0.012 | V | IKr activation slope (12 mV) |
| `tau_n` | 150×10⁻³ | s | IKr time constant (150 ms) |
| `g_L` | 0.02 | S m⁻² | Leak conductance |
| `E_L` | −0.080 | V | Leak reversal (−80 mV = E_K) |
| `C_m` | 20×10⁻¹² | F | Membrane capacitance (20 pF) |
| `A` | 1000×10⁻¹² | m² | Membrane area (1000 µm²) |
| `V_m(start)` | −0.065 | V | Initial membrane potential |

> **Key sign:** `y_inf = 1 / (1 + exp(+(V_m - V_f_half)/k_f))` — the **positive** exponent
> means y_inf increases as V_m decreases (hyperpolarization-activated).

> **Chronotropic parameter:** The effective modulator of cycle length is **g_f**,
> not `V_f_half`. Because `tau_y = 600 ms` greatly exceeds the diastolic depolarization
> duration (~400 ms), the y gate cannot track `y_inf` during diastole, so shifting
> `V_f_half` has minimal effect on rate. Scaling `g_f` directly scales the diastolic
> depolarization rate and thus the cycle period: T ≈ 0.0056/g_f + 0.44 s.

**Validated cycle periods:**

| g_f (S m⁻²) | Cycle period | Physiological analogue |
|---|---|---|
| 0.006 | ~1.37 s (≈44 bpm) | Parasympathetic inhibition / bradycardia |
| 0.014 (default) | ~0.80 s (≈75 bpm) | Normal sinus rhythm |
| 0.040 | ~0.58 s (~103 bpm) | Sympathetic stimulation / tachycardia |

**Autonomic modulation protocol:**

| Signal | Parameter change | Mechanism |
|---|---|---|
| Adrenaline (β₁ agonist) | `g_f` → 0.040 | PKA phosphorylates HCN → higher I_f density |
| Acetylcholine (M₂) | `g_f` → 0.006 | PIP2 depletion reduces HCN availability |
| Ivabradine (I_f blocker) | `g_f` → 0 | Selective HCN block → bradycardia without inotropy |

**Expected simulation (Step17):** StopTime = 3.0 s, Interval = 1×10⁻⁴ s.
Spontaneous firing at ~70 bpm (period 0.853 s) with default `g_f = 0.014`.

---

## Examples

All examples are in `PatchClamp.Examples`.

---
### Step01_PipetteSealTest

**Type:** ODE (RC seal-test circuit)  
**Simulation:** StopTime = 0.060 s, Interval = 6×10⁻⁶ s (10000 intervals)

Models the first physical step of patch clamp: a glass pipette (4 MΩ) immersed
freely in the bath. The `SealTest` amplifier delivers a −5 mV square pulse.

| Variable | Expected value | Notes |
|---|---|---|
| `seal_test.I_measured` (steady state) | ≈ −1.25 nA | V_pulse / R_pipette = −5 mV / 4 MΩ |

**Teaching point:** This background current level (~1 nA) would completely
obscure any single-channel signals (≈1 pA). A gigaohm seal is essential.

---

### Step02_GigasealFormation

**Type:** ODE (RC seal circuit)  
**Simulation:** StopTime = 0.060 s, Interval = 6×10⁻⁶ s (10000 intervals)

Models gigaseal formation (R_seal = 1 GΩ). The `CellAttachedPatch` block adds
R_seal in parallel with R_patch and C_patch.

| Variable | Expected value | Notes |
|---|---|---|
| `seal_test.I_measured` (steady state) | ≈ −5 pA | ~250× reduction from Step01 |

**Teaching point:** The 1 GΩ seal reduces background current below the pA
noise floor, enabling resolution of individual channel events.

---
### Step05_PassiveCellCurrentClamp

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.150 s, Interval = 1×10⁻⁴ s (1500 intervals)

Connects a `CurrentClampAmplifier` to a `PassiveCell`. Demonstrates the
membrane time constant τ = R_m · C_m.

| Key variable | Expected value |
|---|---|
| `cell.V_m` plateau | Determined by I × R_m |
| Rise time (10–90%) | ≈ 2.2 · τ |

**Teaching point:** τ governs how fast a neuron integrates synaptic currents.
Large R_m (high input resistance) → slow and sensitive.

**See also:** `Step03_PassiveCellVoltageClamp` — the same passive cell under
voltage clamp instead of current clamp.

---

### Step06_HodgkinHuxleyActionPotential

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.050 s, Interval = 1×10⁻⁵ s

Brief current pulse → single action potential. Plot `neuron.V_m`, `neuron.m`,
`neuron.h`, `neuron.n` together to see the gate sequence.

| Event | Time (approx.) |
|---|---|
| Stimulus onset | 10 ms |
| AP peak (+35 mV) | ~11 ms |
| Repolarization | ~13 ms |
| Afterhyperpolarization | ~15 ms |
| Refractory period ends | ~25 ms |

**Teaching point:** Na⁺ inactivation (h gate) causes the refractory period —
not just repolarization alone.

---

### Step07_RefractoryPeriod

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.050 s, Interval = 1×10⁻⁵ s

Delivers two identical current pulses through a single `CurrentClampAmplifier`
with dual-pulse parameters. The inter-pulse interval is controlled by `t2_delay`.

| `t2_delay` | Second AP? | Explanation |
|---|---|---|
| 5 ms (default) | No | Absolute refractory period: Na⁺ channels still inactivated (h ≈ 0) |
| 7 ms | Partial (smaller peak) | Relative refractory: partial h recovery |
| 12 ms | Yes (full amplitude) | Na⁺ channels fully recovered (h near 1) |

**Key variables:** `neuron.V_m`, `neuron.h`, `neuron.m`, `amp.I_command`.

**Teaching point:** The refractory period is a direct consequence of Na⁺
inactivation kinetics, not of repolarization *per se*. Plot the h gate
alongside V_m to see that h recovers on the timescale of the refractory period.

---

### Step08_NernstEquilibriumPotential

**Type:** Algebraic (no ODEs)  
**Simulation:** StopTime = 1.0 s, Interval = 1.0 s

Sweeps extracellular [K⁺] (parameter `K_out`) from 1 mM to 150 mM by
re-simulating with a different value each time (see the model's own
documentation for an OMShell `for` loop), and computes E_K algebraically at
each value. Demonstrates the 60 mV/decade rule.

| [K⁺]_out | E_K |
|---|---|
| 5 mM (normal) | −89 mV |
| 50 mM | −29 mV |
| 150 mM | −2 mV |

**Teaching point:** Hyperkalemia (elevated [K⁺]_out) depolarizes the cell.
This is the clinical mechanism of hyperkalemia-induced arrhythmias.

---

### Step09_GHKReversalPotential

**Type:** Algebraic (no ODEs, but time-driven — see note below)  
**Simulation:** StopTime = 0.5 s, Interval = 5×10⁻⁴ s

`V_m` is a linear function of `time` (a voltage ramp from −100 mV to +60 mV
over `t_ramp = 0.5 s`), so this model has no differential equations but is
**not** time-invariant like Step08/Step10 — it must be simulated for the
full 0.5 s to sweep the whole range; a shorter or longer stop time makes
`V_m` stop short of, or overshoot past, +60 mV. Computes GHK current through
a K⁺ channel. Plots I_ghk (nonlinear) vs V_m alongside an Ohmic reference line.

| Variable | Expected value |
|---|---|
| `E_rev` | −89 mV (E_K with default [K⁺]) |
| I_ghk at −100 mV | Inward (negative) |
| I_ghk at 0 mV | Near zero |
| I_ghk at +60 mV | Outward (positive) |

**Teaching point:** The reversal potential is where net ion flow switches
direction — it equals E_K for a K⁺-selective channel.

---

### Step10_GoldmanRestingPotential

**Type:** Algebraic (no ODEs)  
**Simulation:** StopTime = 1.0 s, Interval = 1.0 s

Shows both compartments (pipette solution `int_sol` and bath `ext_sol`)
simultaneously. Computes all four Nernst potentials, Goldman V_rest, and
osmolarity balance.

| Variable | Default value |
|---|---|
| `E_K` | −89 mV |
| `E_Na` | +70 mV |
| `E_Cl` | −65 mV |
| `E_Ca` | +122 mV |
| `V_Goldman` | −65 mV |
| `osm_in` | ~160 mOsm |
| `osm_out` | ~262 mOsm |
| `osm_warning` | `true` |

**Teaching point:** Default ionic compositions are NOT isosmotic —
in real experiments, HEPES, gluconate, or sucrose is added to reach
~295 mOsm without altering the ion of interest.

---

### Step12_SodiumChannelIVCurve

**Type:** ODE (dynamic — full `HodgkinHuxleyNeuron` under voltage clamp)  
**Simulation:** StopTime = 0.180 s, Interval = 1×10⁻⁵ s

Classic voltage-ladder protocol: hold at −100 mV for 150 ms (fully removes
Na⁺ inactivation), then step to a test voltage for 30 ms (selected by the
integer parameter `step_index`, 0…12, mapping to −80…+40 mV). Simulate 13
times (`step_index = 0…12`) and read the peak of `neuron.I_Na` during each
test phase to build the full I-V curve.

**Teaching point:** I-V curves reveal channel conductance, reversal potential,
and rectification properties. Unlike Step09/Step11 (single-ion GHK, purely
algebraic), this uses the full dynamic Hodgkin-Huxley gating kinetics.

---

### Step13_SeriesResistanceCompensation

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.200 s, Interval = 1×10⁻⁶ s

Demonstrates the effect of uncompensated series resistance (R_s) on
voltage-clamp recordings. With high R_s, the true membrane voltage differs
from the command voltage during fast currents.

| Condition | Voltage error |
|---|---|
| R_s = 0 (ideal) | 0 mV |
| R_s = 5 MΩ, I = 1 nA | 5 mV error |
| R_s = 20 MΩ, I = 1 nA | 20 mV error |

**Teaching point:** 80% R_s compensation reduces error by 4×, but overcorrection
causes oscillations. Never compensate >80% without a stability test.

---

### Step14_FitzHughNagumoExcitability

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.100 s, Interval = 1×10⁻⁵ s

FitzHugh-Nagumo neuron with current clamp. Plot `v` vs `w` for the phase
portrait, and overlay nullclines (v-nullcline: cubic; w-nullcline: linear).

**Teaching point:** Above threshold → limit cycle (repetitive firing).
Below → stable fixed point (quiescence). The phase plane makes the bifurcation
visually clear.

---

### Step15_MorrisLecarExcitability

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.200 s, Interval = 1×10⁻⁵ s

Morris-Lecar neuron, default = Type II. Demonstrates repetitive firing above
a sharp threshold (Hopf bifurcation). Change parameters in the model to
switch to Type I (saddle-node bifurcation → graded frequency response).

| Parameter set | Firing type | f-I relationship |
|---|---|---|
| Default (g_Ca=44) | Type II | All-or-none onset |
| g_Ca=20, V3=−1mV, V4=15mV, phi=0.067 | Type I | Graded, arbitrarily low f |

**Teaching point:** Type I neurons can fire arbitrarily slowly; Type II neurons
have a minimum firing frequency and show a discontinuous f-I jump.

---

### Step16_CardiacActionPotential

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.400 s, Interval = 1×10⁻⁵ s, Tolerance = 1×10⁻⁹

Brief 1 ms stimulus → cardiac ventricular action potential with long plateau.

| Phase | Duration | Dominant current |
|---|---|---|
| Phase 0 (upstroke) | ~1 ms | I_Na (fast inward) |
| Phase 2 (plateau) | ~150 ms | I_Ca (maintains depolarization) |
| Phase 3 (repolarization) | ~50 ms | I_K (delayed rectifier) |
| Phase 4 (resting) | − | I_L (leak) |

**Teaching point:** The long plateau prevents tetanic contractions (the heart
cannot be re-stimulated during systole) — a crucial cardiac safety feature.

---

### Step17_PacemakerAutorhythmicity

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 3.0 s, Interval = 1×10⁻⁴ s

Spontaneous pacing — no external current needed. The If current provides
diastolic depolarization that triggers Ca²⁺-driven action potentials.

| Configuration | Approximate period | Approximate rate |
|---|---|---|
| Default (`g_f = 0.014`) | 0.853 s | ~70 bpm |
| Sympathetic (`g_f = 0.040`) | 0.627 s | ~96 bpm |
| Parasympathetic (`g_f = 0.006`) | 1.082 s | ~55 bpm |
| Ivabradine (`g_f = 0`) | 1.724 s (slower, does not stop) | ~35 bpm |

**Teaching point:** Heart rate is controlled by scaling I_f conductance,
which directly modulates the diastolic depolarization rate.

---

### Step18_OnCellSingleChannel

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.200 s, Interval = 1×10⁻⁵ s

On-cell patch clamp of a voltage-gated K⁺ channel (Kv). The intracellular face
contacts native cytoplasm ([K⁺]_in = 140 mM, not dialyzable). A voltage step
from −70 mV to +20 mV activates Kv channels.

| Variable | Expected value | Notes |
|---|---|---|
| `patch.E_rev` | ≈ −89 mV | Nernst K⁺: 5 mM pipette / 140 mM native |
| `patch.P_open_inf` at +20 mV | ≈ 0.98 | V_step >> V_half (−20 mV) |
| `patch.i_unitary` at +20 mV | ≈ +10.9 pA | 100 pS × (20−(−89)) mV |
| `patch.I_patch` (plateau) | ≈ +107 pA | 0.98 × 10 ch × 10.9 pA |
| Activation τ | ~5 ms | tau_max / cosh(2) at V_step |

**Key variables:** `patch.I_patch`, `patch.P_open`, `patch.P_open_inf`,
`patch.i_unitary`, `amp.I_measured`.

**What to vary:**
- `V_step` in steps of −70 to +40 mV → reconstruct P_open(V) Boltzmann curve
- `n_channels = 1` → demonstrates mean-field (non-stochastic) single-channel mode
- `gamma` → change conductance class (e.g., 20 pS for physiological Kv)

---

### Step19_InsideOutSingleChannel

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.300 s, Interval = 1×10⁻⁵ s

Inside-out patch of a BK (large-conductance Ca²⁺-activated K⁺) channel.
The intracellular face is exposed to the bath, allowing manipulation of
intracellular modulators via `c_bath` and `delta_V_half`.

| Condition | `delta_V_half` | P_open_inf at +80 mV | Notes |
|---|---|---|---|
| No Ca²⁺ (default) | 0 V | 0.50 | V_step = V_half by definition |
| ≈10 µM Ca²⁺ | −0.060 V | ~0.98 | V_half_eff = +20 mV |
| ≈100 µM Ca²⁺ | −0.080 V | ~0.995 | V_half_eff = 0 mV, near-maximal activation |

**Key variables:** `patch.P_open_inf`, `patch.I_patch`, `patch.E_rev`.

**What to vary:**
- `delta_V_half` over −0.150 to 0 V → Ca²⁺ dose-response curve
- `V_step` → full I-V curve at each Ca²⁺ level

---

### Step20_OutsideOutSingleChannel

**Type:** ODE (dynamic)  
**Simulation:** StopTime = 0.300 s, Interval = 1×10⁻⁵ s

Outside-out patch of an AMPA receptor (non-selective cation channel,
γ = 10 pS, E_rev ≈ 0 mV). The extracellular face contacts the bath,
enabling glutamate application via `delta_V_half`.

| Condition | `delta_V_half` | V_step | I_patch | Notes |
|---|---|---|---|---|
| No glutamate | 0 V | +40 mV | ~0.08 pA | P_open ≈ 1% (V_half = +500 mV) |
| Glutamate present | −0.500 V | −40 mV | < 0 | Inward (V < E_rev = 0 mV) |
| Glutamate present | −0.500 V | +40 mV | ~4.8 pA | Outward (V > E_rev = 0 mV) |

**E_rev = 0 mV** because solutions are symmetric (130 mM on both sides).

**Key variables:** `patch.I_patch`, `patch.E_rev`, `patch.P_open_inf`.

**What to vary:**
- `delta_V_half` over −0.6 to 0 V → glutamate concentration-response
- `V_step` from −60 to +60 mV → AMPA I-V curve under glutamate

---

## Membrane Blocks

### GHKConductance

> `PatchClamp.Membranes.GHKConductance`

Single-ion conductance block based on the GHK current equation. Can be
connected between two electrical pins to model a membrane permeable to
one ion species.

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `z` | 1 | — | Ion valence |
| `P` | 1×10⁻⁸ | m s⁻¹ | Membrane permeability |
| `c_in` | 140.0 | mol m⁻³ | Intracellular concentration (mM) |
| `c_out` | 5.0 | mol m⁻³ | Extracellular concentration (mM) |
| `A` | 1000×10⁻¹² | m² | Membrane area |
| `T` | 310.15 | K | Temperature |

**Key outputs:** `V_m`, `I_ghk` (current, A), `E_rev` (reversal potential, V), `J_ghk` (current density, A m⁻²).

**Numerical note:** L'Hôpital protection active when |zVF/RT| < 10⁻⁶
to avoid 0/0 at V_m = 0.

---

### SingleChannelPatch

> `PatchClamp.Membranes.SingleChannelPatch`

Deterministic mean-field model of a membrane patch containing N identical ion
channels under voltage clamp. Supports three patch configurations via the
`config` integer parameter. The Nernst reversal potential is computed
automatically from the concentrations assigned to each face according to the
active configuration.

**Total patch current:**
$$I_\text{patch} = P_\text{open}(t) \cdot N \cdot \gamma \cdot (V - E_\text{rev})$$

**Open-probability kinetics:**
$$\tau \cdot \frac{dP_\text{open}}{dt} = P_{\text{open},\infty}(V) - P_\text{open}$$
$$P_{\text{open},\infty}(V) = \frac{1}{1+e^{-(V - V_\text{half} - \delta V_\text{half})/k_v}}$$

| Parameter | Default | Unit | Description |
|---|---|---|---|
| `config` | 1 | — | Patch configuration: 1=OnCell, 2=InsideOut, 3=OutsideOut |
| `z` | 1 | — | Ion valence |
| `gamma` | 100×10⁻¹² | S | Single-channel conductance (pS) |
| `n_channels` | 10 | — | Number of channels in patch |
| `V_half` | −0.020 | V | Boltzmann half-activation voltage |
| `k_v` | 0.010 | V | Boltzmann slope factor |
| `tau_max` | 5×10⁻³ | s | Maximum activation time constant |
| `delta_V_half` | 0.0 | V | Ligand/modulator gating shift |
| `c_pipette` | 5.0 | mol m⁻³ | Pipette solution concentration (mM) |
| `c_bath` | 5.0 | mol m⁻³ | Bath solution concentration (mM) |
| `c_cell_native` | 140.0 | mol m⁻³ | Native intracellular concentration (config=1 only) |
| `T` | 310.15 | K | Temperature |

**Configuration logic (which face contacts which solution):**

| `config` | Name | Extracellular face | Intracellular face | Typical use |
|---|---|---|---|---|
| 1 | On-cell | Pipette | Native cytoplasm | Record channels in situ |
| 2 | Inside-out | Pipette | Bath (dialyzed) | Study intracellular modulators |
| 3 | Outside-out | Bath | Pipette | Apply neurotransmitters / toxins |

**Key outputs:** `I_patch` (A), `P_open` (—), `P_open_inf` (—),
`i_unitary` (A), `E_rev` (V).

**What to vary:**
- `delta_V_half` → simulate Ca²⁺, ligand, or pharmacological gating shift
- `c_bath` (config=2) → change intracellular ligand concentration
- `c_bath` (config=3) → apply external neurotransmitter
- `n_channels = 1` → single-channel mean-field mode

---

| Example | StopTime | Interval | Tolerance | Notes |
|---|---|---|---|---|
| Step01 | 0.060 s | 6×10⁻⁶ s | default | RC seal-test circuit |
| Step02 | 0.060 s | 6×10⁻⁶ s | default | RC seal circuit |
| Step05 | 0.150 s | 1×10⁻⁴ s | default | |
| Step06 | 0.050 s | 1×10⁻⁵ s | default | |
| Step07 | 0.050 s | 1×10⁻⁵ s | default | Two-pulse refractory protocol |
| Step08, Step10 | 1.0 s | 1.0 s | default | Purely algebraic (time-invariant) |
| Step09 | 0.5 s | 5×10⁻⁴ s | default | Time-driven voltage ramp — stop time must match `t_ramp` |
| Step12 | 0.180 s | 1×10⁻⁵ s | default | Full HH neuron, voltage-ladder protocol |
| Step13 | 0.200 s | 1×10⁻⁶ s | default | Fast transients |
| Step14 | 0.100 s | 1×10⁻⁵ s | default | |
| Step15 | 0.200 s | 1×10⁻⁵ s | default | |
| Step16 | 0.400 s | 1×10⁻⁵ s | 1×10⁻⁹ | Stiff: use dassl |
| Step17 | 3.0 s | 1×10⁻⁴ s | default | Long run; coarse interval sufficient |
| Step18 | 0.200 s | 1×10⁻⁵ s | default | Single-channel on-cell |
| Step19 | 0.300 s | 1×10⁻⁵ s | default | Single-channel inside-out |
| Step20 | 0.300 s | 1×10⁻⁵ s | default | Single-channel outside-out |
| Step25 | 0.300 s | 5×10⁻⁵ s | default | Ligand-gated stochastic channel (interval = `chan.dt`) |

For examples not covered above (Step03, Step04, Step11, Step21, Step25), see the
[Examples Reference](examples-reference.md).
