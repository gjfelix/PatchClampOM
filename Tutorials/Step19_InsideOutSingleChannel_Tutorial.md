# Tutorial: Step19 — Inside-Out Patch — a BK Channel and Intracellular Ca²⁺

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step18 tutorial](Step18_OnCellSingleChannel_Tutorial.md).

## Learning objectives

- Build the inside-out configuration (`config` = 2), in which the bath solution faces the intracellular side of the channel.
- Measure the large unitary current of a BK channel and its half-activation at +80 mV.
- Mimic intracellular Ca²⁺ by shifting the activation curve with `delta_V_half`.

## 1. What you will build

In an inside-out patch the membrane fragment is pulled off the cell so that the **bath** faces the cytoplasmic side of the channel. The
experimenter therefore controls the intracellular solution and can add ligands such as Ca²⁺. The block `SingleChannelPatch` is used with
`config` = 2 and a bath of 140 mM K⁺. The channel is a BK channel: very large conductance (200 pS), 5 channels in the patch, half-activation
at +80 mV with no Ca²⁺ and a slope of 15 mV. The model has no explicit Ca²⁺ concentration; `delta_V_half`, the shift of the half-activation
voltage, stands in for the effect of Ca²⁺ (more negative = more Ca²⁺). The amplifier steps from −70 mV to +80 mV.

Circuit: `amp` → `pipette` → `patch` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep19` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
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
  | `V_step` | `+0.080` |
  | `t_step_end` | `0.250` |
  | `V_ljp_correction` | `0.0` |

- `pipette`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `patch`:

  | Parameter | Value |
  |---|---|
  | `config` | `2` |
  | `c_bath` | `140.0` |
  | `gamma` | `200.0e-12` |
  | `n_channels` | `5` |
  | `V_half` | `+0.080` |
  | `k_v` | `0.015` |
  | `tau_max` | `3.0e-3` |

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

Plot `patch.I_patch`, `patch.P_open` and `patch.P_open_inf`.

| What to read | Variable | Expected value |
|---|---|---|
| K⁺ equilibrium potential of the patch | `patch.E_rev` | **−89.1 mV** (±1 mV) |
| Unitary current at +80 mV | `patch.i_unitary` | **33.8 pA** (±0.5 pA; 200 pS × 169 mV) |
| Effective half-activation voltage (no Ca²⁺) | `patch.V_half_eff` | **+80 mV** |
| Open probability at the end of the step | `patch.P_open` | **0.49** (0.5 by definition, since V_step = V_half) |
| Patch current at the end of the step | `patch.I_patch` | **83 pA** (±3 pA) |

At +80 mV the open probability is 0.5 because the voltage equals the half-activation voltage, so the five channels carry
5 × 0.5 × 33.8 pA = 83 pA.

## 4. Explore

1. **Add Ca²⁺.** Set `patch.delta_V_half` to −0.060 (about 10 µM Ca²⁺) and then −0.080 (about 100 µM). Expected (checked):

   | `delta_V_half` | Open probability at +80 mV | Patch current |
   |---|---|---|
   | 0 | 0.49 | 83 pA |
   | −0.060 V | 0.98 | 165 pA |
   | −0.080 V | 0.995 | 168 pA |

   The channel is now almost always open at +80 mV. What happens to the open probability at 0 mV, where there was none before? (Compute it with the Boltzmann
   formula using the new `V_half_eff`.)
2. **Why inside-out?** In the on-cell patch of Step18 you cannot change the intracellular solution. Explain what you gained here, and what you lost compared with the on-cell patch (the patch is no longer attached to a living cell).
3. **Coincidence detector.** BK channels are opened by both depolarization and Ca²⁺. Using the table above, at which voltage would a channel with 10 µM Ca²⁺ be half open?

## 5. Check your model

Open `PatchClamp → Examples → Step19_InsideOutSingleChannel`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step20 — Outside-out patch](Step20_OutsideOutSingleChannel_Tutorial.md) excises the patch the other way round, with the extracellular face in the bath.
