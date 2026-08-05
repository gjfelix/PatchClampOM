# Getting Started with PatchClamp

This guide walks you through installing OpenModelica, loading the package,
and running your first simulation — from zero to action potential in under
15 minutes.

---

## 1. Install OpenModelica

Download **OpenModelica ≥ 4.3.0** from the official site:
[https://openmodelica.org/download/](https://openmodelica.org/download/)
(available for Windows, macOS Intel/ARM, and Linux).

The installer includes **OMEdit** (the graphical IDE) — that is all you need
for this package. No command-line compiler is required for the examples.

> **Tip:** On macOS, after installing, run OMEdit at least once so it
> creates its configuration directory before loading external packages.
> On Apple Silicon, use OMEdit 4.4+ for a native ARM build, or run
> the x86_64 build under Rosetta 2 for earlier versions.

---

## 2. Get the Package

```bash
git clone https://github.com/gjfelix/PatchClampOM.git
cd PatchClampOM
```

Or download the ZIP from GitHub: **Code → Download ZIP**, then unzip it.

---

## 3. Load the Package in OMEdit

1. Open **OMEdit**.
2. Menu: **File → Open Model/Library File…**
3. Navigate to the cloned folder and select `PatchClamp/package.mo`.
4. The `PatchClamp` library will appear in the **Libraries** panel on the left.

> If the library panel is not visible: **View → Windows → Libraries**.

---

## 4. Simulate the Patch Clamp Workflow — Step01 and Step02

Before simulating neurons, start with the two physical steps that precede
every patch clamp experiment.

### Step01 — Pipette in bath (seal test)

In the Libraries panel, open:
```
PatchClamp → Examples → Step01_PipetteSealTest
```

Simulate with **Stop time = 0.060 s**, **Intervals = 10000** (the model's
own defaults). Plot `seal_test.I_measured`.

| Variable | Expected | Explanation |
|---|---|---|
| `seal_test.I_measured` (steady state) | ≈ −1.25 nA | V_pulse / R_pipette = −5 mV / 4 MΩ |

This is the **seal test** signal with a freely immersed pipette. The current
is limited only by pipette resistance (4 MΩ). At this noise level, no
single-channel signal would be detectable.

### Step02 — Gigaseal formation

Open `PatchClamp → Examples → Step02_GigasealFormation`. Simulate with the
same settings (**Stop time = 0.060 s**, **Intervals = 10000**). Plot
`seal_test.I_measured`.

| Variable | Expected | Explanation |
|---|---|---|
| `seal_test.I_measured` (steady state) | ≈ −5 pA | Current now limited by R_seal = 1 GΩ |

The gigaohm seal reduces background current by ~250×, revealing the
pA-scale signals of individual ion channels. This is why the gigaseal is
the technical prerequisite for single-channel recording.

---

## 5. Run Your First Simulation — Step05 Passive Cell (Current Clamp)

In the Libraries panel:

```
PatchClamp
  └── Examples
        └── Step05_PassiveCellCurrentClamp   ← double-click
```

This opens the diagram view. You will see a simple circuit:
a current-clamp amplifier connected to a passive cell (resistor + capacitor).

### Simulate

1. Click **Simulation → Simulate** (or press **F8**).
2. Use these settings (the model's own defaults):
   - **Stop time:** `0.150`
   - **Interval:** `1e-4` (1500 intervals)
   - **Method:** `dassl` (default)
3. Click **OK**.

### What to observe

After the simulation finishes, the **Variables** panel lists all outputs.
Click on `cell.V_m` to plot the membrane voltage.

| What you see | Why |
|---|---|
| Exponential rise in V_m | Charging of membrane capacitor C_m |
| Plateau at a fixed voltage | Steady-state: all current through R_m |
| Time to plateau ≈ τ | τ = R_m · C_m (membrane time constant) |

Try changing `cell.R_m` (double-click the cell block → Parameters):
a larger R_m → longer τ and higher final voltage.

> **Voltage-clamp version:** `Step03_PassiveCellVoltageClamp` uses the same
> passive cell under voltage clamp instead of current clamp — useful for
> comparing the two clamp modes on identical membrane properties.

---

## 6. Run Your First Action Potential — Step06

Open `PatchClamp → Examples → Step06_HodgkinHuxleyActionPotential` and
simulate with its own defaults:
- **Stop time:** `0.050` s
- **Interval:** `1e-5` (5000 intervals)

Plot `neuron.V_m`. You should see a classic action potential spike shortly
after the 10 ms current pulse begins (`t_pulse_start = 0.010 s`).

Try increasing the stimulus current (`amplifier.I_pulse` parameter) — at
some threshold the neuron fires; below it, only a subthreshold deflection
occurs.

### Step07 — Refractory period

Open `PatchClamp → Examples → Step07_RefractoryPeriod`. This experiment
delivers two current pulses in succession using a single `CurrentClampAmplifier`
with dual-pulse parameters. Simulate with **Stop time = 0.050 s**, **Interval = 1e-5** (5000 intervals).

| `t2_delay` value | Result | Explanation |
|---|---|---|
| 5 ms (default) | Second pulse produces no AP | Refractory period: Na⁺ channels still inactivated |
| 12 ms | Second pulse produces a full AP | Na⁺ channels have recovered |

Change `t2_delay` in the model parameters to observe the recovery.

---

## 7. Explore Ionic Equilibrium — Step08–Step10

Three experiments build on each other:

| Experiment | What to plot | Key result | Stop time / Interval |
|---|---|---|---|
| `Step08_NernstEquilibriumPotential` | `E_K` vs. `time` | E_K shifts ~60 mV per 10× change in [K⁺]_out | 1 / 1 (static) |
| `Step09_GHKReversalPotential` | `I_ghk` vs. `V_m` | I-V curve crosses zero at E_rev | **0.5 / 5e-4** (voltage ramp — must match `t_ramp`, do not use 1/1) |
| `Step10_GoldmanRestingPotential` | `E_K`, `E_Na`, `V_Goldman` | All Nernst potentials + Goldman V_rest | 1 / 1 (static) |

Step08 and Step10 have no differential equations, so any stop time works —
their outputs are constant in time. Step09 is different: `V_m` is a linear
ramp driven directly by `time`, so it must be simulated for its full
`t_ramp = 0.5 s` to sweep from −100 mV to +60 mV; stopping later would let
`V_m` keep ramping past +60 mV.

---

## 8. Single-Channel Patch Configurations — Step18–Step21

Three experiments demonstrate the three excised-patch configurations.
All use `PatchClamp.Membranes.SingleChannelPatch` with `config = 1, 2, 3`.

### Step18 — On-cell (cell-attached), Kv channel

Open `PatchClamp → Examples → Step18_OnCellSingleChannel`. Simulate with
**Stop time = 0.200 s**, **Interval = 1e-5**.

| Variable | Expected value | Notes |
|---|---|---|
| `patch.E_rev` | ≈ −89 mV | Nernst K⁺: 5 mM pipette / 140 mM native |
| `patch.P_open_inf` at +20 mV | ≈ 0.98 | Well above V_half = −20 mV |
| `patch.I_patch` at +20 mV | ≈ +107 pA | 10 × 100 pS × (20−(−89)) mV × 0.98 |

The intracellular side is never dialyzed in on-cell mode — `c_cell_native`
cannot be changed by the experimenter.

### Step19 — Inside-out, BK channel (Ca²⁺-activated)

Open `PatchClamp → Examples → Step19_InsideOutSingleChannel`. Simulate with
**Stop time = 0.300 s**, **Interval = 1e-5**.

Run twice:
1. Default: `delta_V_half = 0` → P_open_inf(+80 mV) = 0.50
2. Ca²⁺ present: `delta_V_half = −0.080` → P_open_inf(+80 mV) ≈ 1.00

The inside-out configuration exposes the intracellular face to the bath,
allowing you to change `c_bath` to mimic different cytoplasmic Ca²⁺ levels.

### Step20 — Outside-out, AMPA receptor

Open `PatchClamp → Examples → Step20_OutsideOutSingleChannel`. Simulate with
**Stop time = 0.300 s**, **Interval = 1e-5**.

| `delta_V_half` | V_step | I_patch | Interpretation |
|---|---|---|---|
| 0 (no glutamate) | +40 mV | ~0.08 pA | P_open ≈ 1% (channel closed) |
| −0.500 (glutamate) | −40 mV | < 0 | Inward current (V < E_rev = 0 mV) |
| −0.500 (glutamate) | +40 mV | > 0 | Outward current (V > E_rev = 0 mV) |

The outside-out configuration exposes the extracellular face to the bath,
allowing rapid application of neurotransmitters.

### Step21 — Stochastic single-channel recording

Open `PatchClamp → Examples → Step21_StochasticSingleChannel`. Simulate with
**Stop time = 0.150 s**, **Interval = 5e-5**. Plot `chan.I_patch`.

Same circuit and channel parameters as Step18 (on-cell Kv, `config = 1`),
but with `n_channels = 1` and genuine discrete-event stochastic gating
instead of the deterministic mean-field ODE — rectangular jumps between 0
and the unitary current, with random open/closed durations, rather than a
smooth averaged curve. Increase `n_channels` to 5 or 20 and re-simulate to
watch the trace smooth out toward Step18's shape (law of large numbers).

---

## 9. Isolating the Three Amplifier Compensations — Step22–Step24

`Step13_SeriesResistanceCompensation` demonstrates C-fast, C-slow, and R_s
compensation together on one passive cell. Step22–Step24 split that demo
into one mechanism each, following the real order of operations on a rig,
each using `Amplifiers.Compensation.CompensatedVClampAmp`:

| Experiment | Circuit | What to plot | Stop time / Interval |
|---|---|---|---|
| `Step22_PipetteCapacitanceCompensation` | Cell-attached (Step02's circuit) | `amp.I_raw` vs. `amp.I_measured` at `frac_fast = 0` vs. `1` | 0.200 / 1e-6 |
| `Step23_WholeCellCapacitanceCompensation` | Whole-cell, just after break-in (Step04's circuit) | `amp.I_raw` at `frac_slow = 0` vs. `1` | 0.200 / 1e-6 |
| `Step24_AccessResistanceCompensation` | Whole-cell, both capacitive transients pre-compensated | `cell.V_m` vs. commanded step, at `alpha = 0`, `0.7`, `0.9` | 0.200 / 1e-6 |

Step22 isolates C-fast in a circuit with no whole-cell capacitance to
confuse it with; Step23 isolates C-slow (the single whole-cell capacitive
transient); Step24 isolates the pure series-resistance DC voltage-clamp
error once both capacitive transients are already compensated. See
[Examples Reference](examples-reference.md) for full parameter/result
tables, and [Compensation Guide](compensation-guide.md) for the
conceptual writeup.

---

## 10. OMEdit Tips

### Changing parameters

- Double-click any block in Diagram view → **Parameters** dialog.
- Changes apply to the current simulation only unless you save the model.

### Multiple plots

- Right-click a variable in the Variables panel → **Add to new plot**.
- Use the plot toolbar to overlay variables with different y-axes.

### Resetting a simulation

- **Simulation → Re-simulate** reruns with the same settings after a
  parameter change.

### Viewing equations

- Right-click a block → **View Documentation** to read the physics
  explanation written for students.
- Right-click → **Open in Text View** to see the Modelica equations directly.

---

## 11. Recommended Experiment Order

For a course following the patch clamp technique from first principles:

| Session | Experiments | Concepts |
|---|---|---|
| 1 | Step01, Step02 | Seal test, gigaohm seal, noise floor |
| 2 | Step03, Step05 | RC circuit, membrane time constant (voltage- and current-clamp) |
| 3 | Step08, Step09, Step10 | Nernst equation, GHK I-V curve, Goldman equation |
| 4 | Step06, Step07 | Hodgkin-Huxley, threshold, refractory period |
| 5 | Step12 | Voltage-gated Na⁺ I-V curve under voltage clamp |
| 6 | Step13 | Series resistance artifact and compensation |
| 7 | Step22, Step23, Step24 | Isolated C-fast, C-slow, and R_s compensation stages |
| 8 | Step14, Step15 | Reduced neuron models, excitability classes |
| 9 | Step16, Step17 | Cardiac AP plateau, pacemaker automaticity |
| 10 | Step18, Step19, Step20, Step21 | Single-channel recording, patch configurations, ligand gating, stochastic gating |

For every example beyond this guide, see the full
[Examples Reference](examples-reference.md) — objectives and simulation
instructions for all 24.

---

## 12. Troubleshooting

**"Model not found" when opening package.mo**
→ Make sure you open `PatchClamp/package.mo`, not the root folder.

**Simulation fails with "singular Jacobian"**
→ Check that Stop time and Interval are set correctly. For the purely
algebraic examples (Step08, Step10) use Stop time = 1, Interval = 1; Step09
needs Stop time = 0.5 to match its voltage ramp (see Section 7).

**Step18/19/20 fail with "under-determined system" or voltage warnings**
→ The circuit ground is provided by the `BathElectrode` block. Verify that
`PatchClamp.Electrodes.BathElectrode bath` is present in the model and that
`connect(amp.n, bath.n)` appears in the equation section. If you accidentally
deleted the `bath` instance, reload the file from the repository.

**Plots look flat at zero**
→ The variable may be in a sub-component. Expand the tree in the Variables
panel: `neuron → V_m` instead of just `V_m`.

**Pacemaker (Step17) does not oscillate — converges to a fixed point**
→ Verify `g_f = 0.014` (not 0.08), `g_L = 0.02` (not 0.08), `E_L = −0.080` (not −0.062),
and `V_d_half = −0.030` (not −0.010). The old parameter set has a stable
fixed point at approximately −52 mV that prevents oscillation.

**Step17 fires too fast (period << 0.5 s)**
→ Default `g_f = 0.014` gives a period of ~0.80 s at 37 °C. If the period
is much shorter, check that `g_f` has not been accidentally left at the old
value of 0.08 S m⁻².

**OMEdit crashes on macOS with Apple Silicon**
→ Use OMEdit 4.4+ for native ARM. Earlier builds run correctly under Rosetta 2.

---

## Next Steps

- [Physics Background](physics-background.md) — derivations of Nernst, GHK, HH, and single-channel gating
- [Model Reference](model-reference.md) — parameters and expected outputs for every model and example
- [Examples Reference](examples-reference.md) — description, objectives, and simulation instructions for every Step01–Step24 example
- [Contributing](../CONTRIBUTING.md) — how to add new cell models or experiments
