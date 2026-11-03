# Tutorial: Step20 — Outside-Out Patch — an AMPA-Type Ligand-Gated Channel

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step19 tutorial](Step19_InsideOutSingleChannel_Tutorial.md).

## Learning objectives

- Build the outside-out configuration (`config` = 3), where the extracellular face of the channel is in the bath.
- Measure the reversal potential of a non-selective cation channel (about 0 mV, not −89 mV).
- Contrast ligand gating (glutamate present or absent) with the steep voltage gating of Step18.

## 1. What you will build

In an outside-out patch the extracellular face of the membrane faces the **bath**, the standard way to apply neurotransmitters to a receptor.
The channel is an AMPA-type glutamate receptor: non-selective for cations (so equal 130 mM solutions on both sides give a reversal
potential of 0 mV), small conductance (10 pS), 20 channels, and almost voltage independent (a very shallow gating curve, slope 100 mV). Here the effect of
glutamate is represented by `delta_V_half` = −0.5 V, which moves the half-activation voltage from +500 mV to 0 mV; setting it back to 0
means "no glutamate". The amplifier steps from −70 mV to +40 mV.

Circuit: `amp` → `pipette` → `patch` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep20` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → VoltageClampAmplifier` (voltage-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `patch` | `PatchClamp → Membranes → SingleChannelPatch` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `V_step` | `+0.040` |
  | `t_step_end` | `0.250` |
  | `V_ljp_correction` | `0.0` |

- `pipette`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `patch`:

  | Parameter | Value |
  |---|---|
  | `config` | `3` |
  | `c_pipette` | `130.0` |
  | `c_bath` | `130.0` |
  | `gamma` | `10.0e-12` |
  | `n_channels` | `20` |
  | `V_half` | `+0.500` |
  | `k_v` | `0.100` |
  | `tau_max` | `2.0e-3` |
  | `delta_V_half` | `-0.500` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pipette.p_amp` |
| `pipette.p_cell` | `patch.membrane_p` |
| `patch.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.300, Interval = 1.0e-5, Tolerance = 1.0e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `patch.I_patch` and `patch.P_open`.

| What to read | Variable | Expected value |
|---|---|---|
| Reversal potential | `patch.E_rev` | **0 mV** (equal solutions) |
| Unitary current at +40 mV | `patch.i_unitary` | **+0.4 pA** (±0.02 pA) |
| Open probability at the end of the step | `patch.P_open` | **0.6** (±0.02) |
| Patch current at the end of the step (+40 mV) | `patch.I_patch` | **+4.8 pA** (±0.2 pA) |
| Holding current at −70 mV (before the step) | `patch.I_patch` | **−4.6 pA** (inward; ±0.2 pA) |

At +40 mV (above the reversal potential) the current is outward (positive); at the −70 mV holding potential (below it) the current is inward
(negative). The channel is about one third open even at the holding potential, because gating is almost voltage independent.

## 4. Explore

1. **Reversal.** Set `amp.V_step` to −40 mV. Expected (checked): `patch.I_patch` at the end of the step is **−3.2 pA** (inward), against +4.8 pA at +40 mV.
   The current changes sign between −40 and +40 mV, as it must at a reversal potential of 0 mV.
2. **Remove the ligand.** Set `patch.delta_V_half` to 0 (no glutamate) with `V_step` = +40 mV. Expected (checked): `patch.P_open_inf` falls to 0.01 and the patch current to
   0.08 pA, about 60 times smaller. Is the channel closed because of the voltage or because of the missing ligand?
3. **Contrast with Step18.** The Kv channel of Step18 reverses near −89 mV and opens steeply with voltage. List two differences you can read from this tutorial's numbers.

## 5. Check your model

Open `PatchClamp → Examples → Step20_OutsideOutSingleChannel`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step21 — Stochastic single-channel recording](Step21_StochasticSingleChannel_Tutorial.md) replaces the smooth average by individual channel openings.
