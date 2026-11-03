# Examples Reference

`PatchClamp.Examples` contains 25 ready-to-simulate models, `Step01` through
`Step25`. Eight of them — the ones that introduce a genuinely new circuit
topology a student should learn to assemble by hand — have a full,
build-it-yourself walkthrough in `Tutorials/`. The other seventeen reuse
circuit patterns already covered by those walkthroughs (current-clamp cell,
voltage-clamp cell, or single-channel patch) with a different cell model or
protocol, so instead of a from-scratch tutorial each gets a reference entry
below: what it demonstrates, what to look for, and how to run it.

**Use this page alongside:**
- [`getting-started.md`](getting-started.md) — hands-on walkthroughs for the introductory examples
- [`model-reference.md`](model-reference.md) — parameter/output reference for every block
- [`physics-background.md`](physics-background.md) — the underlying equations
- [`validation-results.md`](validation-results.md) — quantitative pass/fail checks (where they exist)

---

## Master index

| # | Model | Category | Documentation |
|---|-------|----------|----------------|
| 01 | `Step01_PipetteSealTest` | Patch clamp workflow | Getting Started §4 |
| 02 | `Step02_GigasealFormation` | Patch clamp workflow | Getting Started §4 |
| 03 | `Step03_PassiveCellVoltageClamp` | Passive cell | Getting Started §5 (brief) |
| 04 | `Step04_WholeCellBreakIn` | Patch clamp workflow | Reference (below) |
| 05 | `Step05_PassiveCellCurrentClamp` | Passive cell | Getting Started §5 |
| 06 | `Step06_HodgkinHuxleyActionPotential` | Excitable cell | Getting Started §6 |
| 07 | `Step07_RefractoryPeriod` | Excitable cell | Reference (below) |
| 08 | `Step08_NernstEquilibriumPotential` | Ion equilibrium | Reference (below) |
| 09 | `Step09_GHKReversalPotential` | Ion equilibrium | Getting Started §7 |
| 10 | `Step10_GoldmanRestingPotential` | Ion equilibrium | Reference (below) |
| 11 | `Step11_GHK_IVCurve` | Ion equilibrium | Reference (below) |
| 12 | `Step12_SodiumChannelIVCurve` | Voltage-clamp protocol | Reference (below) |
| 13 | `Step13_SeriesResistanceCompensation` | Voltage-clamp protocol | Reference (below) |
| 14 | `Step14_FitzHughNagumoExcitability` | Excitable cell | Reference (below) |
| 15 | `Step15_MorrisLecarExcitability` | Excitable cell | Reference (below) |
| 16 | `Step16_CardiacActionPotential` | Excitable cell | Reference (below) |
| 17 | `Step17_PacemakerAutorhythmicity` | Excitable cell | Reference (below) |
| 18 | `Step18_OnCellSingleChannel` | Single-channel patch | Reference (below) |
| 19 | `Step19_InsideOutSingleChannel` | Single-channel patch | Reference (below) |
| 20 | `Step20_OutsideOutSingleChannel` | Single-channel patch | Reference (below) |
| 21 | `Step21_StochasticSingleChannel` | Single-channel patch | Reference (below) |
| 22 | `Step22_PipetteCapacitanceCompensation` | Voltage-clamp protocol | Reference (below) |
| 23 | `Step23_WholeCellCapacitanceCompensation` | Voltage-clamp protocol | Reference (below) |
| 24 | `Step24_AccessResistanceCompensation` | Voltage-clamp protocol | Reference (below) |
| 25 | `Step25_LigandGatedSingleChannel` | Single-channel patch | Reference (below) |

---

## How to run any example

**In OMEdit:** Libraries panel → `PatchClamp` → `Examples` → double-click the
model → **Simulate** (▶). Each model ships its own default `stopTime`/
`interval`/`tolerance` (listed per entry below), so the default Simulation
Setup values work out of the box. Plot variables from the Variables Browser
after the run completes.

**Headlessly (no OMEdit):**
```bash
scripts/omc-sim.sh -c 'loadFile("/workspace/PatchClamp/package.mo"); getErrorString();
simulate(PatchClamp.Examples.StepNN_Name, stopTime=..., numberOfIntervals=...);
getErrorString();
val(someVariable, someTime);'
```

---

## Electrophysiology basics

### Step04 — Whole-Cell Break-In

**Model:** `PatchClamp.Examples.Step04_WholeCellBreakIn`
**Uses:** `Amplifiers.SealTest` → `Electrodes.PatchPipette` → `Membranes.WholeCell` → `Electrodes.BathElectrode`

The third and final patch-clamp workflow example, continuing from Step02: the membrane patch has just ruptured, putting the pipette interior in electrical continuity with the cytoplasm. `Membranes.CellAttachedPatch`'s `R_seal ‖ R_patch ‖ C_patch` (Step02's circuit) is replaced by `Membranes.WholeCell`'s `R_access` in series with `C_m ‖ R_m` — the standard whole-cell equivalent circuit reused throughout the rest of the package.

**Objectives**
- See the slow capacitive transient that confirms a successful whole-cell break-in — absent in cell-attached mode.
- Distinguish the three timescales visible on a single voltage-clamp step: the (nearly invisible) pipette transient, the membrane transient that dominates the trace, and the DC steady state.

**Simulation instructions**
Default `stopTime = 0.060 s`, `interval = 3e-6 s` (fine enough to resolve the fast pipette transient). Simulate at defaults and plot `seal_test.I_measured`, `cell.I_Cm`, and `cell.V_m`. Try `cell.R_access = 30e6` (degraded access) to see `V_m` stop tracking `V_cmd` well, or `cell.C_m = 0` to see what a perfectly-compensated trace would look like.

**Expected results (analytical):** `tau_fast = R_pip·C_pip = 4 MΩ × 3 pF ≈ 12 µs` (pipette transient, small); `tau_slow = R_access·C_m = 10 MΩ × 50 pF = 500 µs` (the transient to watch); `tau_membrane = R_m·C_m = 200 MΩ × 50 pF = 10 ms` (slow discharge at the end); `I_peak,slow ≈ V_pulse/R_access = 5 mV / 10 MΩ = 500 pA`; `I_steady = V_pulse/(R_pip+R_access+R_m) ≈ 23 pA`; `Q_Cm = C_m·V_pulse = 0.25 pC`. Not yet in `validation-results.md`.

**See also:** Step02 (the cell-attached circuit this replaces, before rupture); Step06 (the same post-break-in workflow endpoint, applied under current clamp to an excitable Hodgkin-Huxley neuron instead of this passive whole-cell model); Step22/Step23 (this circuit's fast and slow capacitive transients isolated and compensated).

---

### Step07 — Refractory Period (Two-Pulse Protocol)

**Model:** `PatchClamp.Examples.Step07_RefractoryPeriod`
**Uses:** `CurrentClampAmplifier` (extended with a second pulse) → `PatchPipette` → `HodgkinHuxleyNeuron` → `BathElectrode`

Delivers two identical 30 pA / 2 ms current pulses separated by a variable
delay (`t2_delay`) to the same HH neuron used in Step06, and shows whether
the second pulse can fire a second action potential.

**Objectives**
- Distinguish the absolute and relative refractory periods of an excitable membrane.
- Connect the refractory period to the time course of Na⁺ inactivation (`neuron.h`) and K⁺ activation (`neuron.n`).

**Simulation instructions**
Default `stopTime = 0.050 s`, `interval = 1e-5 s`. Vary the single parameter
`t2_delay`:
| `t2_delay` | Expected outcome |
|---|---|
| 3 ms | No second AP (absolute refractory, `h` ≈ 0.05) |
| 5 ms (default) | No second AP (`h` ≈ 0.15) |
| 8 ms | Reduced second AP (relative refractory, `h` ≈ 0.35) |
| 12 ms | Full second AP (`h` ≈ 0.55, recovered) |

Plot `neuron.V_m`, `neuron.h`, `neuron.n`.

**Expected results:** validated as checks **H-6** (t2_delay = 5 ms → no 2nd AP; t2_delay = 12 ms → full 2nd AP) and **H-7** (current-direction sanity check) in `validation-results.md`, both ✅ PASS.

**See also:** Step06 (same neuron/circuit, single-pulse case).

---

### Step08 — Nernst Equilibrium Potential

**Model:** `PatchClamp.Examples.Step08_NernstEquilibriumPotential`
**Uses:** standalone algebraic model — direct calls to `Media.Functions.nernstPotential`, no electrical circuit.

Computes the four physiological Nernst potentials (`E_K`, `E_Na`, `E_Cl`,
`E_Ca`) and a simplified two-ion Goldman resting potential from a single
sweepable parameter, `K_out`.

**Objectives**
- See how the Nernst equation converts an ion's concentration gradient into an equilibrium voltage.
- Understand why the resting potential tracks E_K more closely than the other E_ion values.

**Simulation instructions**
Default `stopTime = 1.0`, `interval = 1.0` (static model — any duration works, only the algebraic outputs matter). Sweep `K_out` from 1 to 150 mM (either by editing the parameter and re-simulating, or by the `for` loop shown in the model's own documentation) and read `E_K`/`V_Goldman` for each value:

| `K_out` (mM) | `E_K` (mV) | `V_Goldman` (mV) |
|---|---|---|
| 1 | −118 | −82 |
| 5 (default) | −89 | −65 |
| 50 | −28 | −38 |
| 150 | −1 | −20 |

**Expected results:** this model isn't itself exercised by `validation-results.md`, but the identical Nernst formula is validated to sub-mV accuracy via `Step10_GoldmanRestingPotential` (checks **N-1** to **N-5**). Numbers above should agree with those checks at `K_out = 5 mM`.

**See also:** Step09 (measures a reversal potential dynamically from a simulated I-V curve, rather than computing it algebraically); Step10 (multi-ion version with real solution blocks).

---

### Step10 — Goldman Resting Potential (Two-Compartment Model)

**Model:** `PatchClamp.Examples.Step10_GoldmanRestingPotential`
**Uses:** `InternalSolution` + `ExternalSolution` + `GoldmanMembrane` + `Ground` (membrane left electrically open — no amplifier — so the solver settles at `V_m = V_Goldman`).

The "full system" version of Step08: two real solution blocks (pipette/intracellular and bath/extracellular) feed a `GoldmanMembrane`, which reports all four Nernst potentials plus the Goldman resting potential and an osmotic-balance check in one place.

**Objectives**
- See all four ionic driving forces and the resting potential computed together from one consistent pair of solutions.
- Recognize that simple physiological solutions are usually not isosmotic, and why that matters for real pipette-solution recipes.

**Simulation instructions**
Default `stopTime = 1.0`, `interval = 1.0` (static). Nothing to connect —
just simulate and read the alias variables `E_K`, `E_Na`, `E_Cl`, `E_Ca`,
`V_Goldman`, plus `osm_in`/`osm_out`/`osm_warning`. Suggested edits:
`ext_sol.c_K = 8` or `50` (hyperkalemia), `int_sol.c_Cl = 30` (immature-neuron
chloride gradient, flips GABA from inhibitory to excitatory), `int_sol.T =
293.15` (room-temperature Nernst factor).

**Expected results (default):** `E_K ≈ −89 mV`, `E_Na ≈ +70 mV`, `E_Cl ≈ −65 mV`, `E_Ca ≈ +122 mV`, `V_Goldman ≈ −65 mV`. Formally validated as checks **N-1**–**N-5** (individual E_ion values, ✅ PASS) in `validation-results.md`; the multi-ion Goldman value is cross-checked against Step11's simulated I-V zero-crossing (checks **G-1**/**G-2**).

**See also:** Step08 (single-ion, parametric sweep); Step09/Step11 (reversal potential measured from a simulated I-V curve instead of computed algebraically).

---

### Step11 — Multi-Ion I-V Curve (GHK Voltage-Clamp Ramp)

**Model:** `PatchClamp.Examples.Step11_GHK_IVCurve`
**Uses:** `Media.InternalSolution` + `Media.ExternalSolution` + `Membranes.GoldmanMembrane` + `Amplifiers.RampVoltageSource` + `Electrodes.Ground`

The voltage-clamp counterpart to Step10. Step10 leaves the membrane open-circuit and lets `V_m` settle wherever `I_total = 0`, answering "what voltage does the cell rest at?" Here a linear ramp imposes `V_m(t)` from −100 mV to +60 mV over `t_ramp`, and the membrane's net GHK current `I_total(t)` is read off as a function of the imposed voltage — answering "how much current flows at each voltage?"

**Objectives**
- Trace a full GHK I-V curve and read its reversal potential off the zero-crossing, rather than computing it algebraically.
- See Goldman-Katz rectification directly: the curve is visibly non-ohmic (steeper outward than inward branch) purely from the exponential term in the GHK equation, with no voltage-gated channel involved.
- Cross-check the multi-ion reversal potential against Step10's algebraic `V_Goldman`, and the single-ion case against Nernst.

**Simulation instructions**
Default `stopTime = 0.5 s`, `interval = 1e-3 s` (must match `t_ramp = 0.5 s` — stopping later lets `V_m` keep ramping past +60 mV, the same caveat as Step09). Simulate, then in OMEdit use **Plot → Parametric Plot (XY Parametric)**: X = `membrana.V_m`, Y = `membrana.I_total`. For the single-ion case, set `membrana.P_Na = P_Cl = P_Ca = 0` (leaving only `P_K`) and re-simulate.

**Expected results:** with `P_Na = P_Cl = P_Ca = 0`, the I-V curve's zero-crossing ≈ `E_K ≈ −89 mV` (Nernst). With default permeabilities (`P_K=1.00e-8`, `P_Na=4.00e-10`, `P_Cl=4.50e-9`, `P_Ca=1.00e-11` m/s), the zero-crossing ≈ `V_Goldman ≈ −68 mV`, matching `membrana.V_Goldman` — a few mV below the two-ion approximation (≈ −65 mV) quoted in Step10, since this full 4-ion formula also includes Cl⁻. Validated as checks **G-1** (single-ion reversal), **G-2** (mixed-ion reversal), and **G-3** (rectification shape) in `validation-results.md`, all ✅ PASS.

**See also:** Step08/Step10 (the same Nernst/Goldman potentials computed algebraically instead of from a simulated I-V curve); Step09 (the same single-ion GHK ramp protocol computed directly from concentration/permeability parameters, without solution/membrane circuit blocks).

---

## Voltage-clamp protocols

### Step12 — Sodium Channel I-V Curve (Voltage-Step Ladder)

**Model:** `PatchClamp.Examples.Step12_SodiumChannelIVCurve`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `HodgkinHuxleyNeuron` → `BathElectrode`

Implements the classic voltage-ladder protocol: hold at −100 mV (150 ms, to
fully remove Na⁺ inactivation), then step to a test voltage (30 ms) selected
by the integer parameter `step_index` (0…12, mapping to −80…+40 mV).

**Objectives**
- Reproduce the gold-standard protocol used to characterize voltage-gated channel I-V relationships.
- Build a full I-V curve and extract a Boltzmann activation curve for g_Na(V).

**Simulation instructions**
Default `stopTime = 0.180 s`, `interval = 1e-5 s`. To build the full curve,
simulate 13 times with `step_index = 0…12` (or script it — see the model's
own documentation for an OMShell `for` loop), each time reading the peak of
`neuron.I_Na` (or `amplifier.I_measured`) during the test phase (t =
150–180 ms). Reference peak currents range from ≈ −0.01 nA at −80 mV to a
Na⁺ current peak of ≈ −1.2 nA near −20 mV, inverting sign close to `E_Na =
+50 mV`.

**Expected results:** not yet exercised by `validation-results.md` (no formal check assigned); the reference I-V table embedded in the model's `Documentation()` block gives the values above as design targets, not independently verified pass/fail bounds.

**See also:** Step06 (same HH neuron, current-clamp instead of voltage-clamp); Step18 (an analogous voltage-ladder protocol on an isolated Kv patch instead of the whole HH neuron).

---

### Step13 — Series Resistance Compensation Demo

**Model:** `PatchClamp.Examples.Step13_SeriesResistanceCompensation`
**Uses:** `Amplifiers.Compensation.CompensatedVClampAmp` → `PatchPipette` → `PassiveCell` → `BathElectrode`

Uses a passive (RC-only) cell so the raw and compensated current traces are
analytically predictable, and lets you switch on each compensation stage
(`frac_fast`, `frac_slow`, `alpha`) independently to see what artifact each
one removes.

**Objectives**
- Identify the two capacitive transients (pipette C-fast, membrane C-slow) that contaminate a raw voltage-clamp recording.
- Understand what series-resistance (R_s) compensation does to the voltage-clamp error, and why it can only ever be partial (`alpha < 1`).

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-6 s` (fine interval — needed to
resolve the fast capacitive transients). Suggested sequence: (1) simulate at
defaults (all compensation = 0) and note the double capacitive transient in
`amp.I_raw`; (2) set `frac_fast = 1.0` and re-simulate — the fast pipette
spike disappears from `amp.I_measured`; (3) set `frac_slow = 1.0` — the slow
membrane-capacitance exponential disappears; (4) set `alpha = 0.7` — compare
`amp.V_error` before/after (residual error drops to 30% of its uncompensated
value).

**Expected results:** analytical, not yet in `validation-results.md`. With defaults: `tau = R_pipette·C_m = 4 MΩ × 10 pF = 40 µs` (confirmed by simulation, ~39.8 µs), steady-state `I_ss ≈ 14.9 pA` (simulated — not simply `V_step/R_m`, since `PassiveCell`'s leak reversal `E_L = −65 mV` and `R_pipette`'s own share of the voltage divider both contribute).

**See also:** Step03/Step04 (introduce `PatchPipette` + `PassiveCell` without compensation); `model-reference.md` for the full `CompensatedVClampAmp` parameter list.

---

### Step22 — C-Fast Compensation, Isolated (Cell-Attached)

**Model:** `PatchClamp.Examples.Step22_PipetteCapacitanceCompensation`
**Uses:** `Amplifiers.Compensation.CompensatedVClampAmp` → `PatchPipette` → `CellAttachedPatch` → `BathElectrode`

The first of three examples that split Step13's combined demo into one
mechanism each, following the real order of operations on a rig: this one
reuses Step02's cell-attached (pre-break-in) circuit, where there is no
whole-cell capacitance at all to confound C-fast with.

**Objectives**
- See C-fast compensation in a circuit with nothing else for it to be confused with.
- Understand a real subtlety of this amplifier model: with an idealized (zero-rise-time) command step and `alpha = 0`, C-fast's target signal is a mathematically instantaneous impulse with nothing to cancel in a sampled trace — visible cancellation requires a small amount of R_s-compensation feedback (`alpha = 0.3` here, used purely as a numerical device) to give the command edge finite width.

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-6 s`. Simulate at defaults
(`frac_fast = 0.0`) and plot `amp.I_raw`; set `frac_fast = 1.0` and compare
`amp.I_measured` — a modest (~24%) reduction near the step edge, since most
of the visible transient is actually `C_patch` charging through
`R_pipette`, not `C_pipette`'s own current (see the model's own
documentation for the full derivation).

**Expected results:** analytical/simulated, not yet in `validation-results.md`. `amp.I_raw` peaks ≈ 6.4 nA just after the step (decaying with `tau ≈ R_pipette·C_patch ≈ 0.4 µs`); `amp.I_comp_fast` ≈ 1.5 nA at the same instant.

**See also:** Step02 (the same circuit without compensation); Step23 (C-slow, the next stage); `docs/compensation-guide.md` for the conceptual writeup.

---

### Step23 — C-Slow Compensation, Isolated (Whole-Cell, Just After Break-In)

**Model:** `PatchClamp.Examples.Step23_WholeCellCapacitanceCompensation`
**Uses:** `Amplifiers.Compensation.CompensatedVClampAmp` → `PatchPipette` → `WholeCell` → `BathElectrode`

Reuses Step04's break-in circuit. `frac_fast = 1.0` is set to continue
Step22's workflow order, but — as explained in Step22's own documentation —
it has no visible numerical effect in this circuit while `alpha = 0`: there
is only one real capacitive transient here (C_m charging through the total
series resistance R_pipette + R_access), and C-slow compensation is what
removes it.

**Objectives**
- Isolate and compensate the single whole-cell capacitive transient this circuit produces.
- See how compensation quality depends on `R_s_est` matching the real series resistance (R_pipette + R_access), not just R_access alone.

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-6 s`. Simulate at defaults
(`frac_slow = 0.0`) and plot `amp.I_raw` — a single ~650 µs exponential.
Set `frac_slow = 1.0` — most of it disappears, leaving mostly a flat
resistive step (a small residual remains from the gap between `R_s_est`'s
implied time constant and the true one).

**Expected results (simulated):** transient decay `tau ≈ 650 µs`, close to the `(R_pipette + R_access)·C_m = 14 MΩ × 50 pF = 700 µs` prediction (the gap comes from second-order effects the simple R·C estimate ignores).

**See also:** Step04 (the same circuit, introduced from scratch); Step22 (C-fast, the previous stage); Step24 (R_s, the next stage).

---

### Step24 — R_s (Access Resistance) Compensation, Isolated

**Model:** `PatchClamp.Examples.Step24_AccessResistanceCompensation`
**Uses:** `Amplifiers.Compensation.CompensatedVClampAmp` → `PatchPipette` → `WholeCell` → `BathElectrode`

Continues from Step22/Step23 with both capacitive transients
pre-compensated (`frac_fast = 1.0`, `frac_slow = 1.0`), isolating the pure
DC voltage-clamp error caused by series resistance. `R_m` is deliberately
lowered (20 MΩ, vs. Step23's 200 MΩ) to make the error large and easy to
see without an active channel model, and `tau_comp` is raised to 50 µs
(vs. the library default of 15 µs) — this cell's low `R_m` makes the R_s
positive-feedback loop harder to stabilize than Step13's passive cell, and
15 µs goes unstable before `alpha` reaches 0.9 here.

**Objectives**
- See a pure series-resistance voltage-clamp error and its partial correction by `alpha`.
- Understand why `R_s` compensation bandwidth (`tau_comp`) depends on the cell being recorded, not just the amplifier.

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-6 s`. Simulate at defaults
(`alpha = 0.0`) and compare `cell.V_m` to the commanded −50 mV. Set
`alpha = 0.7`, then `0.9`, and watch `cell.V_m` approach the command.

**Expected results (simulated):** commanded step −50 mV; `cell.V_m` → −29.4 mV at `alpha=0.0`, → −41.3 mV at `alpha=0.7`, → −46.7 mV at `alpha=0.9`.

**See also:** Step22/Step23 (the other two compensations); Step13 (all three combined on a passive cell); `docs/compensation-guide.md` for the conceptual writeup.

---

## Excitable cell models

### Step14 — FitzHugh-Nagumo Excitability

**Model:** `PatchClamp.Examples.Step14_FitzHughNagumoExcitability`
**Uses:** `CurrentClampAmplifier` → `PatchPipette` (0.5 pF, Sylgard-coated) → `FitzHughNagumoNeuron` → `BathElectrode`

The 2-state FitzHugh-Nagumo reduction of Hodgkin-Huxley — same qualitative
excitability, far cheaper to simulate and easier to visualize as a phase
plane.

**Objectives**
- See that a 2-ODE model reproduces the essential excitable/all-or-nothing behavior of the 4-ODE HH model.
- Locate the firing threshold and reproduce both single-spike and repetitive-firing regimes.

**Simulation instructions**
Default `stopTime = 0.100 s`, `interval = 1e-5 s`. Single-spike case ships as
default (`I_pulse = 50 pA`, 2 ms). For repetitive firing, set `t_pulse_end =
0.200` (continuous current) and raise `I_pulse` above ≈ 30 pA (threshold).
For a phase-plane view, plot `neuron.u` (fast variable) vs. `neuron.w`
(recovery variable) as an XY/parametric plot.

**Expected results:** validated as checks **F-1** (single AP with `I_pulse = 30 pA`, ✅ PASS) and **F-2** (all-or-nothing threshold behavior, ✅ PASS) in `validation-results.md`.

**See also:** Step06 (the 4-ODE HH model this reduces); Step15 (another reduced 2-ODE model, with a qualitatively different bifurcation type).

---

### Step15 — Morris-Lecar Excitability (Type I vs. Type II)

**Model:** `PatchClamp.Examples.Step15_MorrisLecarExcitability`
**Uses:** `CurrentClampAmplifier` → `PatchPipette` → `MorrisLecarNeuron` → `BathElectrode`

Another 2-ODE reduced model, built around a Ca²⁺/K⁺ conductance pair instead
of FHN's abstract variables. Ships in its Type II (Hopf bifurcation)
configuration by default; three parameters (`V3`, `V4`, `phi`) switch it to
Type I (SNIC).

**Objectives**
- Distinguish Type I (continuous f-I curve, frequency rises from 0 Hz) from Type II (discontinuous f-I curve, firing starts at a finite frequency) neuronal excitability.
- Connect each type to its underlying bifurcation (SNIC vs. Hopf).

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-5 s`, `I_pulse = 1000 pA`
(continuous from t = 10 ms). For Type II: sweep `I_pulse` near the ≈ 940 pA
bifurcation point and note the abrupt onset of ~40 Hz firing. For Type I: set
`neuron.V3 = 0.012`, `neuron.V4 = 0.0174`, `neuron.phi = 23.3`, then sweep
`I_pulse` across 300–1000 pA (near the ≈ 397 pA SNIC threshold) and note the
frequency rising continuously from 0 Hz.

**Expected results:** validated as checks **M-1** (Type II, bifurcation ≈ 940 pA, abrupt ~40 Hz onset, ✅ PASS) and **M-2** (Type I, threshold ≈ 400 pA, graded 0→8→12 Hz f-I curve, ✅ PASS) in `validation-results.md`.

**See also:** Step14 (FHN, another reduced excitable model); Step06 (full HH model, for comparison of fidelity vs. simulation cost).

---

### Step16 — Cardiac Ventricular Action Potential

**Model:** `PatchClamp.Examples.Step16_CardiacActionPotential`
**Uses:** `CurrentClampAmplifier` → `PatchPipette` → `CardiacVentricularCell` (simplified Beeler-Reuter) → `BathElectrode`

A brief 2 ms current pulse triggers a ~200–300 ms cardiac action potential
with the Ca²⁺-current plateau that distinguishes cardiac myocytes from
neurons.

**Objectives**
- Identify the five phases of a cardiac action potential (upstroke, notch/absent, plateau, repolarization, rest) and the current(s) responsible for each.
- Contrast cardiac AP duration/refractoriness with the HH neuronal AP (Step06).

**Simulation instructions**
Default `stopTime = 0.400 s`, `interval = 1e-5 s`, `tolerance = 1e-9`. Plot
`neuron.V_m`, `neuron.I_Na`, `neuron.I_Ca`, `neuron.I_K`. To see the
refractory period, add a second pulse during the plateau (`amp.I_pulse2`,
`amp.t_pulse2_start = 0.050`) — it should fail to trigger a second AP. To
model Ca²⁺-channel block (e.g. verapamil), set `neuron.g_Ca = 0` — the
plateau disappears and repolarization becomes immediate.

**Expected results:** validated as checks **C-1** (APD90 ≈ 320 ms at 10 nA stimulus, within the 200–350 ms tolerance band, ✅ PASS) and **C-2** (resting potential ≈ −84 mV, ✅ PASS) in `validation-results.md`.

**See also:** Step06 (neuronal AP, ~2 ms, no Ca²⁺ plateau); Step17 (spontaneously-firing cardiac pacemaker cell, vs. this stimulus-driven ventricular cell).

---

### Step17 — Pacemaker Autorhythmicity (Sinoatrial Node)

**Model:** `PatchClamp.Examples.Step17_PacemakerAutorhythmicity`
**Uses:** `CurrentClampAmplifier` (held at `I = 0`) → `PatchPipette` → `PacemakerCell` (SAN + HCN "funny" current) → `BathElectrode`

The only example in the package where the cell fires **without any external
stimulus** — the whole point is to demonstrate spontaneous automaticity
driven by the funny current, `I_f`.

**Objectives**
- See slow diastolic depolarization driven by `I_f` (HCN current) lead to spontaneous, regularly-spaced action potentials.
- Reproduce autonomic modulation of heart rate (tachycardia/bradycardia) by changing a single conductance parameter.

**Simulation instructions**
Default `stopTime = 3.0 s`, `interval = 1e-4 s` (long enough to capture
several beats). Plot `cell.V_m`, `cell.y` (HCN gate), `cell.I_f`, `cell.I_Ca`.
For simulated tachycardia (adrenergic effect), set `cell.g_f = 0.040`; for
bradycardia (cholinergic effect), set `cell.g_f = 0.006`; for pharmacological
`I_f` block (ivabradine), set `cell.g_f = 0` — automaticity stops.

**Expected results:** validated as checks **P-1** (spontaneous firing, period ≈ 0.8 s, ✅ PASS) and **P-2** (simulated tachycardia at `g_f = 0.040`, period drops to ≈ 0.5 s, a 37.5% reduction, ✅ PASS) in `validation-results.md`.

**See also:** Step16 (the non-pacemaker cardiac cell — needs external stimulation, unlike this one).

---

## Single-channel patch configurations

These four examples all use the same underlying voltage-ladder circuit
(`VoltageClampAmplifier` → `PatchPipette` → a single-channel membrane block →
`BathElectrode`) but vary the **patch configuration** (on-cell, inside-out,
outside-out) and the **channel type** (Kv, BK, AMPA) to show how the choice
of configuration determines which solution — and therefore which
physiology — the experimenter can control.

### Step18 — On-Cell Patch: Kv Channel Activation Curve

**Model:** `PatchClamp.Examples.Step18_OnCellSingleChannel`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `SingleChannelPatch` (`config = 1`, On-cell) → `BathElectrode`

The least invasive configuration: the pipette seals onto an intact cell, so
the intracellular face keeps its native (uncontrolled) composition. Models a
voltage-gated K⁺ (Kv) channel, 10 channels per patch.

**Objectives**
- Measure a channel's voltage-activation curve (P_open vs. V) directly from a simulated current trace.
- Understand what the On-cell configuration does and does not let you control.

**Simulation instructions**
Default `stopTime = 0.200 s`, `interval = 1e-5 s`, step from `V_hold = −70 mV`
to `V_step = +20 mV`. Plot `patch.I_patch`, `patch.P_open`, `patch.i_unitary`.
To build the full activation curve, sweep `amp.V_step` across −60…+20 mV and
read `patch.P_open_inf` at the end of each pulse; it should trace a Boltzmann
sigmoid with `V_half = −20 mV`, `k_v = 10 mV`.

**Expected results (default):** `E_rev ≈ −89 mV`, `i_unitary(+20 mV) ≈ +10.9 pA`, `P_open_inf(+20 mV) ≈ 0.982`, `I_patch ≈ +107 pA` (10 channels). Validated as check **SC-1** in `validation-results.md` (✅ PASS).

**See also:** Step19/Step20 (the other two patch configurations); Step21 (the same Kv channel and protocol, but with genuinely stochastic — not mean-field — gating).

---

### Step19 — Inside-Out Patch: BK Channel Modulated by Ca²⁺

**Model:** `PatchClamp.Examples.Step19_InsideOutSingleChannel`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `SingleChannelPatch` (`config = 2`, Inside-out) → `BathElectrode`

The pipette excises a patch so its **intracellular** face is exposed to the
bath — letting the student directly control Ca²⁺, ATP, pH, or other
intracellular ligands. Models a BK channel (largest known single-channel
conductance, 200 pS), which acts as a coincidence detector for voltage AND
Ca²⁺.

**Objectives**
- Understand what makes the inside-out configuration uniquely suited to studying intracellular ligand modulation.
- Show that raising intracellular Ca²⁺ shifts the BK activation curve to more negative voltages (`delta_V_half`).

**Simulation instructions**
Default `stopTime = 0.300 s`, `interval = 1e-5 s`, step from `V_hold = −70 mV`
to `V_step = +80 mV`, `delta_V_half = 0` (no Ca²⁺). Re-simulate with
`patch.delta_V_half = −0.060` (≈10 µM Ca²⁺) or `−0.080` (≈100 µM Ca²⁺) and
compare `patch.P_open_inf` at the same `V_step` — it should rise sharply as
`V_half_eff = V_half + delta_V_half` shifts toward (and past) the test
voltage.

**Expected results (default, no Ca²⁺):** `P_open_inf(+80 mV) = 0.50` (by definition, since `V_step = V_half`); with `delta_V_half = −0.080`: `P_open_inf(+80 mV) ≈ 1.00`. Validated as check **SC-2** in `validation-results.md` (✅ PASS).

**See also:** Step18 (On-cell, cannot access the intracellular face); Step20 (Outside-out, the complementary excision).

---

### Step20 — Outside-Out Patch: AMPA Receptor Reversal Potential

**Model:** `PatchClamp.Examples.Step20_OutsideOutSingleChannel`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `SingleChannelPatch` (`config = 3`, Outside-out) → `BathElectrode`

The excision leaves the **extracellular** face exposed to the bath — the
standard configuration for studying ligand-gated receptors, since that's
where neurotransmitter binding sites face. Models an AMPA receptor (a
non-selective cation channel, voltage-insensitive, ligand-gated).

**Objectives**
- Measure the reversal potential of a non-selective cation channel and contrast it with the ion-selective Kv channel of Step18 (E_rev ≈ 0 mV vs. ≈ −89 mV).
- See the difference between a voltage-gated channel's steep Boltzmann curve and a ligand-gated channel's nearly voltage-independent one.

**Simulation instructions**
Default `stopTime = 0.300 s`, `interval = 1e-5 s`, `delta_V_half = −0.500`
(glutamate present), step to `V_step = +40 mV`. To find E_rev, run twice at
`V_step = −40 mV` and `+40 mV` and confirm `patch.I_patch` changes sign. To
see ligand-gating (rather than voltage-gating), set `delta_V_half = 0`
(no glutamate) and confirm `I_patch` drops to near zero even at the same
voltage.

**Expected results (default, +40 mV, glutamate present):** `E_rev = 0 mV`, `i_unitary ≈ +0.4 pA`, `P_open_inf ≈ 0.60`, `I_patch ≈ +4.8 pA` (20 channels); without glutamate, `I_patch` drops to ≈ 0.08 pA (~60× smaller). Validated as check **SC-3** in `validation-results.md` (✅ PASS).

**See also:** Step18/Step19 (voltage-gated channels, for contrast); Step09 (reversal potential measured the same way — I-V zero-crossing — on a GHK conductance rather than a Boltzmann-gated patch).

---

### Step21 — Stochastic Single-Channel Recording

**Model:** `PatchClamp.Examples.Step21_StochasticSingleChannel`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `StochasticChannel` (`config = 1`, On-cell, `n_channels = 1`) → `BathElectrode`

Identical circuit and channel parameters to Step18 (same Kv channel,
`V_half`, `k_v`, `tau_max`, `gamma`), but with `n_channels = 1` and genuine
discrete-event stochastic gating instead of the deterministic mean-field
ODE — a true single-channel recording with random dwell times.

**Objectives**
- See a real single-channel current trace: rectangular jumps between 0 and `i_unitary` with random open/closed durations, rather than a smooth averaged curve.
- Connect the stochastic single-channel picture to the deterministic mean-field picture (Step18) via the law of large numbers.

**Simulation instructions**
Default `stopTime = 0.150 s`, `interval = 5e-5 s`. Plot `chan.I_patch` and
`chan.isOpen[1]` and compare side-by-side with Step18's smooth `patch.I_patch`
— Step18's curve is the average Step21's trace fluctuates around. Increase
`n_channels` to 5 or 20 and re-simulate to watch the trace smooth out toward
Step18's shape (law of large numbers). Change `chan.fixedSeed` to get a
different (but still reproducible) random realization.

**Expected results (default, fixedSeed = 42):** `i_unitary(+20 mV) ≈ 10.9 pA` (identical to Step18); the channel should be open roughly 98% of the time during the voltage step (matching Step18's `P_open_inf ≈ 0.982` statistically). Not yet exercised by `validation-results.md` — no formal statistical check (e.g. fraction-of-time-open over a fixed window) has been run yet; this is a good candidate for a future addition to the validation suite.

**See also:** Step18 (the deterministic counterpart — same channel, same protocol).

---

### Step25 — Ligand-Gated Single-Channel Recording

**Model:** `PatchClamp.Examples.Step25_LigandGatedSingleChannel`
**Uses:** `VoltageClampAmplifier` → `PatchPipette` → `LigandGatedChannel` (`n_channels = 1`, 30 pS, `E_rev = 0`) → `BathElectrode`

Same stochastic single-channel circuit as Step21, but the channel is opened by
an **agonist** instead of by voltage. The membrane is held at a constant
−70 mV and a 30 µM agonist pulse is applied from 0.05 to 0.20 s, mimicking a
fast-perfusion concentration jump on an outside-out patch. The opening rate
follows a Hill relationship, `k_open = k_close·(c_L/EC50)^n_hill`, so the
steady-state open probability is `c_L^n / (c_L^n + EC50^n)`.

**Objectives**
- See ligand-driven gating: no current flows without agonist at any voltage, discrete inward steps appear while it is present, and the channel closes again when it is removed.
- Connect the dose–response relationship to the Hill equation by repeating the pulse at several concentrations.
- See the law of large numbers: with more channels the stochastic trace converges to its ensemble average.

**Simulation instructions**
Default `stopTime = 0.300 s`, `interval = 5e-5 s`. Plot `chan.I_patch`
(discrete steps), `chan.I_mean` (smooth ensemble average), `chan.c_L`
(agonist concentration) and `chan.nOpenChannels`. Then:
- **Dose–response:** set `chan.c_agonist` to 0.003, 0.010, 0.030 and 0.100 mM and compare the fraction of time open with `chan.P_open_inf`.
- **Law of large numbers:** set `chan.n_channels` to 5, 20 and 200.
- **Deactivation:** after `t_agonist_off` the open fraction decays with time constant `1/k_close` (5 ms); this is clearest with many channels.
- **Voltage independence:** set `amp.V_hold` and `amp.V_step` to +0.040 V; gating is unchanged, but the unitary current reverses to +1.2 pA.
- **Amplitude histogram:** export `chan.I_patch` for t = 0.08–0.20 s; two peaks appear at 0 and ≈ −2.1 pA.

**Expected results (default, fixedSeed = 42):** `i_unitary = −2.1 pA` (30 pS × −70 mV); `P_open_inf = 0.90` during the pulse and 0 outside it; mean open time ≈ 5 ms; deactivation τ ≈ 5 ms. Validated by checks LG-1 to LG-6 in [`validation-results.md`](validation-results.md). The model has no desensitization, unlike real nAChR, AMPA or GABA-A receptors.

**See also:** Step21 (the voltage-gated stochastic counterpart); Step20 (outside-out patch with a ligand-dependent voltage shift rather than true agonist gating).
