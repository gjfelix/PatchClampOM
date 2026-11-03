# Testing Guide: Step01–Step25 in OMEdit

Quick reference for running each example in OMEdit and knowing what to look
at. Covers `Step01` through `Step25`.

## Common procedure (do this once per example)

1. **Launch OMEdit** (skip if already open):
   ```bash
   scripts/omedit-gui.sh
   ```
   Wait for the window to appear (starts Docker/XQuartz if needed).

2. **Load the package** (skip if already loaded): `File → Open Model/Library
   File...` → `/workspace/PatchClamp/package.mo`.

3. **Find the model**: Libraries tree → `PatchClamp` → `Examples` →
   double-click the `StepNN_Name` you want.

4. **Simulate**: select the model, click **Simulate** (▶). Each model ships
   its own `StopTime`/`Interval`/`Tolerance` via its `experiment` annotation,
   so the Simulation Setup dialog is pre-filled — just click OK/Simulate.

5. **Plot**: when the run finishes, the Variables Browser opens
   automatically. Check the boxes for the variables listed below for that
   step; they plot together in the Plotting window.

6. **Zoom** to the time window noted below when a transient is too brief to
   see at the full simulation timescale (right-click-drag a rectangle on the
   plot to zoom; right-click → `Auto Scale` to reset).

---

## Per-example quick reference

| # | Model | Plot these | What you should see |
|---|-------|-----------|----------------------|
| 01 | `Step01_PipetteSealTest` | `seal_test.I_measured`, `seal_test.V_command` | Free-bath seal test; `I_steady ≈ -1.25 nA`, set by `R_pipette` alone. |
| 02 | `Step02_GigasealFormation` | `seal_test.I_measured`, `patch.I_seal` | Gigaseal formed; `I_steady` drops to `≈ 5 pA` (limited by `R_seal = 1 GΩ` instead of `R_pipette`). Try lowering `patch.R_seal` to see the transition from a leaky seal. |
| 03 | `Step03_PassiveCellVoltageClamp` | `amplifier.I_measured`, `cell.V_m` | Voltage step at `t=50 ms`: a fast capacitive spike (`I_peak ≈ 5 nA`, `tau_pip ≈ 40 µs`) settling to a resistive `I_ss ≈ 20 pA`. Zoom to `0.050–0.0505 s` to resolve the transient. |
| 04 | `Step04_WholeCellBreakIn` | `seal_test.I_measured`, `cell.I_Cm`, `cell.V_m` | Patch just ruptured: a slow `R_access·C_m` transient (`tau_slow ≈ 500 µs`, `I_peak ≈ 500 pA`) now visible on top of the much smaller/faster pipette transient (`tau_fast ≈ 12 µs`). Zoom to a few ms around each pulse. |
| 05 | `Step05_PassiveCellCurrentClamp` | `cell.V_m` | Current-clamp charging transient, `tau_m = R_m·C_m = 10 ms` — much slower than Step03's voltage-clamp `tau_pip`. `V_m` rises from `-65 mV` toward `-45 mV` (`V_m ≈ -52.4 mV` at `t = 20 ms`, one `tau_m` after pulse onset). |
| 06 | `Step06_HodgkinHuxleyActionPotential` | `neuron.V_m`, `neuron.m`, `neuron.h`, `neuron.n` | Full Hodgkin-Huxley action potential from a 30 pA / 5 ms pulse: threshold ≈ -55 mV, peak ≈ +35 mV, ~2–3 ms duration, followed by an after-hyperpolarization. Try `I_pulse = 5` and `8` pA to see the all-or-nothing threshold. |
| 07 | `Step07_RefractoryPeriod` | `neuron.V_m`, `neuron.h`, `neuron.n` | Two-pulse protocol on the same HH neuron. At default `t2_delay = 5 ms`, no second AP fires (absolute refractory). Try `t2_delay = 12 ms` for a full second AP. |
| 08 | `Step08_NernstEquilibriumPotential` | `E_K`, `E_Na`, `E_Cl`, `E_Ca`, `V_Goldman` | Static/algebraic — no transient to watch. At default `K_out = 5 mM`: `E_K ≈ -89 mV`. Edit `K_out` (try 1, 50, 150 mM) and re-simulate to see `E_K` shift. |
| 09 | `Step09_GHKReversalPotential` | `I_ghk` vs. `V_m` (XY/parametric plot) | Full I-V curve from one ramp simulation. Default K⁺ channel crosses `I=0` at `E_rev ≈ -89 mV`; curve is visibly nonlinear (GHK rectification), unlike a straight ohmic line. |
| 10 | `Step10_GoldmanRestingPotential` | `E_K`, `E_Na`, `E_Cl`, `E_Ca`, `V_Goldman`, `osm_in`/`osm_out` | Static — no amplifier, membrane floats to `V_m = V_Goldman ≈ -65 mV`. All four Nernst potentials computed together from one consistent solution pair. |
| 11 | `Step11_GHK_IVCurve` | `membrana.V_m` vs. `membrana.I_total` (XY/parametric plot) | Multi-ion I-V ramp; `I_total = 0` crossing (reversal potential) at `V_Goldman ≈ -65 mV`. Zero out permeabilities (`P_Na=P_Cl=P_Ca=0`) to isolate K⁺ alone and see the crossing move to `E_K ≈ -89 mV`. |
| 12 | `Step12_SodiumChannelIVCurve` | `neuron.I_Na` (or `amplifier.I_measured`) | Voltage-ladder protocol (hold at -100 mV, step to test voltage). Sweep `step_index = 0…12` and record the peak current each time to build the I-V curve; peak Na⁺ current ≈ -1.2 nA near -20 mV. |
| 13 | `Step13_SeriesResistanceCompensation` | `amp.I_raw`, `amp.I_measured`, `amp.I_comp_fast`, `amp.I_comp_slow`, `amp.V_error` | All compensation off by default: `I_raw` shows the double capacitive transient. Toggle `frac_fast=1`, `frac_slow=1`, `alpha=0.7` one at a time (see the model's own doc) to watch each artifact disappear. |
| 14 | `Step14_FitzHughNagumoExcitability` | `neuron.u` vs. `neuron.w` (phase plane), or `neuron.u` vs. time | Reduced 2-variable excitability model. Default single-spike case; set `t_pulse_end=0.200` and raise `I_pulse` above ~30 pA for repetitive firing. |
| 15 | `Step15_MorrisLecarExcitability` | `neuron.V_m` | Type II (Hopf) spiking by default — abrupt firing onset near `I_pulse ≈ 940 pA`. Set `V3`, `V4`, `phi` per the model's doc to switch to Type I (SNIC, graded onset). |
| 16 | `Step16_CardiacActionPotential` | `neuron.V_m`, `neuron.I_Na`, `neuron.I_Ca`, `neuron.I_K` | Cardiac AP with a long plateau (`APD90 ≈ 320 ms`), unlike the ~2 ms neuronal AP. Set `neuron.g_Ca = 0` to see the plateau disappear (simulated Ca²⁺ channel block). |
| 17 | `Step17_PacemakerAutorhythmicity` | `cell.V_m`, `cell.I_f` | Spontaneous firing with **no** external stimulus (`I=0`), period ≈ 0.85 s. Try `cell.g_f = 0.040` (tachycardia) or `0.006` (bradycardia). Needs the full 3 s `StopTime` to see several beats. |
| 18 | `Step18_OnCellSingleChannel` | `patch.I_patch`, `patch.P_open`, `patch.i_unitary` | On-cell Kv channel, voltage step to +20 mV: `i_unitary ≈ +10.9 pA`, `P_open_inf ≈ 0.982`, `I_patch ≈ +107 pA` (10 channels). |
| 19 | `Step19_InsideOutSingleChannel` | `patch.P_open`, `patch.I_patch` | Inside-out BK channel; default has no Ca²⁺ (`delta_V_half=0`). Set `patch.delta_V_half = -0.060` or `-0.080` and compare `P_open_inf` at the same voltage — it rises sharply with simulated intracellular Ca²⁺. |
| 20 | `Step20_OutsideOutSingleChannel` | `patch.I_patch` | Outside-out AMPA receptor; run at `V_step = -40` and `+40 mV` to confirm `I_patch` reverses sign at `E_rev = 0 mV`. Set `delta_V_half = 0` (no glutamate) to see the ligand-gating drop `I_patch` to near zero. |
| 21 | `Step21_StochasticSingleChannel` | `chan.I_patch`, `chan.isOpen[1]` | Genuine single-channel trace: random rectangular jumps between 0 and `i_unitary`, unlike Step18's smooth average. Increase `n_channels` (5, 20) to watch it converge toward Step18's smooth curve. |
| 22 | `Step22_PipetteCapacitanceCompensation` | `amp.I_raw`, `amp.I_measured`, `amp.I_comp_fast` | Cell-attached (pre-break-in), C-fast isolated. Default `frac_fast=0`: `I_raw` peaks ≈ 6.4 nA just after the step. Set `frac_fast=1`: only a modest (~24%) reduction — most of the visible transient is `C_patch` charging through `R_pipette`, not `C_pipette`'s own current (see the model's own doc for why). Zoom to `0.050000–0.050005 s`. |
| 23 | `Step23_WholeCellCapacitanceCompensation` | `amp.I_raw`, `amp.I_measured`, `amp.I_comp_slow` | Whole-cell, just after break-in, C-slow isolated. Default `frac_slow=0`: single ~650 µs exponential in `I_raw`. Set `frac_slow=1`: most of it disappears, leaving mostly a flat resistive step. Zoom to `0.050–0.053 s`. |
| 24 | `Step24_AccessResistanceCompensation` | `cell.V_m`, `amp.V_m_estimated` | Whole-cell, both capacitive transients pre-compensated, R_s isolated. Default `alpha=0`: `cell.V_m` only reaches ≈ -29.4 mV of the commanded -50 mV step. Set `alpha=0.7` then `0.9`: `cell.V_m` approaches -41.3 mV, then -46.7 mV. |
| 25 | `Step25_LigandGatedSingleChannel` | `chan.I_patch`, `chan.I_mean`, `chan.c_L`, `chan.nOpenChannels` | Agonist-gated stochastic channel at −70 mV: no current before 0.05 s, discrete steps of `i_unitary = −2.1 pA` during the 30 µM pulse (`P_open_inf = 0.90`), closing again after 0.20 s. Set `chan.c_agonist` to 0.003 / 0.010 / 0.030 / 0.100 mM to follow the Hill dose–response; raise `chan.n_channels` to see the trace converge to `chan.I_mean`. |

---

**More detail on any step:** see `docs/examples-reference.md` (full
objectives/expected-results writeups) or the model's own `Documentation`
block in OMEdit (visible in the Documentation tab when the model is
selected).
