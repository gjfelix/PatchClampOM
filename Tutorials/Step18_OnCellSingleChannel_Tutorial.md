# Tutorial: Step18 — On-Cell Patch — Activation of a Kv Channel

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step03 tutorial](Step03_PassiveCellVoltageClamp_Tutorial.md) (voltage-clamp circuit).

## Learning objectives

- Assemble a voltage-clamp circuit around a patch of 10 voltage-gated potassium (Kv) channels in the **on-cell** configuration.
- Read the channel's open probability and unitary current from a voltage step.
- Relate the Boltzmann activation curve (`V_half`, `k_v`) and the Nernst potential to the measured current.

## 1. What you will build

In the on-cell (cell-attached) configuration the pipette seals onto an intact cell, so the amplifier controls the voltage across
the **patch** but not the cell's interior, which keeps its native composition (140 mM K⁺ inside, 5 mM K⁺ in the pipette). The
block `SingleChannelPatch` describes the patch with its default settings: configuration 1 (on-cell), a K⁺ channel with a
unitary conductance of 100 pS, `V_half` = −20 mV and `k_v` = 10 mV. This is a mean-field (ensemble-average) model: the current
is the number of channels times the open probability times the unitary current, so you see a smooth curve, not single-channel jumps
(Step21 and Step25 show those).

The amplifier holds the patch at −70 mV, steps it to +20 mV at 20 ms and returns it to −70 mV at 120 ms.

Circuit: `amp` → `pipette` → `patch` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep18` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
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
  | `V_step` | `+0.020` |
  | `t_step_start` | `0.020` |
  | `t_step_end` | `0.120` |
  | `V_ljp_correction` | `0.0` |

- `pipette`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `patch`:

  | Parameter | Value |
  |---|---|
  | `n_channels` | `10` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pipette.p_amp` |
| `pipette.p_cell` | `patch.membrane_p` |
| `patch.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-5, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `patch.I_patch`, `patch.P_open` and `amp.V_command` (voltage and current need separate plot windows).

| What to read | Variable | Expected value |
|---|---|---|
| K⁺ equilibrium (reversal) potential | `patch.E_rev` | **−89.1 mV** (±1 mV) |
| Unitary current at +20 mV | `patch.i_unitary` | **10.9 pA** (±0.2 pA) |
| Open probability at the end of the step | `patch.P_open` | **0.98** (the Boltzmann curve gives 0.982) |
| Steady-state patch current at the end of the step | `patch.I_patch` | **107 pA** (±5 pA) |
| Channel gating time constant at +20 mV | `patch.tau_channel` | **1.36 ms** (±0.1 ms) |
| Patch current before the step (−70 mV) | `patch.I_patch` | **0.13 pA** (channels almost closed) |

The current rises within a few milliseconds (the gating time constant is about 1.4 ms at +20 mV) when the voltage steps to +20 mV, levels off near 107 pA, and
falls back to about zero when the voltage returns to −70 mV. The current is **positive** (outward) at +20 mV because +20 mV is
far above the K⁺ reversal potential (−89 mV): the driving force is about +109 mV.

## 4. Explore

1. **Activation curve.** Run the protocol with `V_step` = −40, −20, 0 and +20 mV and read `patch.P_open` at the end of each step. You should obtain about 0.12, 0.50, 0.88 and 0.98, the Boltzmann curve `1 / (1 + exp(−(V + 20 mV) / 10 mV))`.
2. **Reversal potential.** Set `patch.T` to 293.15 K (20 °C). By how many millivolts does `patch.E_rev` move? (Expected: from −89.1 mV to about −84.2 mV.)
3. **One channel.** Set `patch.n_channels` to 1. Is the trace now made of discrete current jumps? Why not? (Hint: read the model description at the start of this tutorial, then try Step21.)

## 5. Check your model

Open `PatchClamp → Examples → Step18_OnCellSingleChannel`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step19 — Inside-out patch](Step19_InsideOutSingleChannel_Tutorial.md) lets you control the intracellular face and add Ca²⁺.
