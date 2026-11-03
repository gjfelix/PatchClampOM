# Tutorial: Step17 — Pacemaker Cell — Spontaneous Firing

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step16 tutorial](Step16_CardiacActionPotential_Tutorial.md).

## Learning objectives

- Build a current-clamp circuit in which the amplifier injects **no** current and the cell still fires.
- See the slow diastolic depolarization produced by the funny current `I_f` (HCN channels).
- Change the heart rate by scaling the `I_f` conductance `g_f`, as the autonomic nervous system does.

## 1. What you will build

`PacemakerCell` models a sinoatrial-node cell. Its funny current `I_f` is unusual: its gate opens on *hyper*polarization, so after each
spike it slowly depolarizes the cell until the calcium current triggers the next spike. The amplifier is set to inject 0 pA (the
pulse amplitude is zero), so everything you see is spontaneous. The cell is 20 pF and the pipette resistance is 5 MΩ.

Circuit: `amp` → `pip` → `cell` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep17` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `cell` | `PatchClamp → Cells → PacemakerCell` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `0.0` |
  | `t_pulse_start` | `0.500` |
  | `t_pulse_end` | `0.501` |
  | `R_bridge` | `0.0` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `R_pipette` | `5.0e6` |
  | `C_pipette` | `2.0e-12` |
  | `V_junction` | `0.0` |

- `cell`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `20.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `cell.membrane_p` |
| `cell.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 3.000, Interval = 1e-4, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `cell.V_m`, then `cell.y` (the `I_f` gate), `cell.I_f` and `cell.I_Ca` in a second window.

| What to read | Variable | Expected value |
|---|---|---|
| Number of spontaneous action potentials in 3 s | `cell.V_m` | **4** |
| Time of the first action potential | `cell.V_m` | **298 ms** (±30 ms) |
| Mean time between action potentials in the 3 s (cycle length) | `cell.V_m` | **0.86 s** (±0.03 s; it settles at 0.853 s, about 70 per minute) |
| Peak of the action potential | `cell.V_m` | **+9.4 mV** (±2 mV) |
| Most negative potential (maximum diastolic potential) | `cell.V_m` | **−71.7 mV** (±2 mV) |

The potential climbs slowly from about −72 mV, the diastolic depolarization, until a spike of about +9 mV fires; then it drops back and
repeats. `cell.y` and `cell.I_f` change on the same slow timescale. The cycle length of about 0.85 s corresponds to about 70 beats per
minute.

## 4. Explore

1. **Autonomic modulation.** Change the `I_f` conductance `cell.g_f` (default 0.014) and set the stop time to 12 s so that you can measure
   several cycles. Expected (checked), steady cycle lengths:

   | `cell.g_f` | Cycle length | Rate | Meaning |
   |---|---|---|---|
   | 0.040 | 0.627 s | about 96 per minute | sympathetic stimulation |
   | 0.014 (default) | 0.853 s | about 70 per minute | rest (0.85–0.87 s in the first beats) |
   | 0.006 | 1.082 s | about 55 per minute | parasympathetic stimulation |
   | 0 | 1.724 s | about 35 per minute | `I_f` blocked (ivabradine) |

   Notice that blocking `I_f` completely slows the heart a lot but does not stop it: which other currents keep the cell oscillating?
2. **Plot the gate.** Compare `cell.y` and `cell.V_m` over one cycle. Does the `I_f` gate open as the cell depolarizes or as it repolarizes? How does that explain the slow ramp?
3. **Compare with Step16.** A ventricular cell needs a stimulus to fire; what is the essential difference in the circuit you built (the amplifier current) and in the cell model (the funny current)?

## 5. Check your model

Open `PatchClamp → Examples → Step17_PacemakerAutorhythmicity`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step18 — On-cell patch](Step18_OnCellSingleChannel_Tutorial.md) goes from whole cells down to the patch of membrane under the pipette.
