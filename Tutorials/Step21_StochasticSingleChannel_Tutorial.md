# Tutorial: Step21 — A True Single-Channel Recording

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step18 tutorial](Step18_OnCellSingleChannel_Tutorial.md).

## Learning objectives

- Replace the mean-field patch of Step18 with `StochasticChannel`, in which every channel opens and closes at random.
- Recognize the two-level (closed/open) trace of one channel and measure its unitary current.
- See how the discrete trace approaches the smooth average when you add channels.

## 1. What you will build

The circuit and the Kv channel are those of Step18 (on-cell, 5 mM K⁺ in the pipette, 100 pS), with the block `StochasticChannel` instead of
`SingleChannelPatch`. There is now **one** channel, and it flips between closed (0 pA) and open (about 10.9 pA at +20 mV) at random times
with probabilities set by the same voltage-dependent rates. The random numbers come from a generator with a fixed seed (`fixedSeed` = 42),
so you obtain the same trace every time; change the seed to get a different one. The amplifier steps from −70 mV to +20 mV at 20 ms and back at 120 ms.

Circuit: `amp` → `pipette` → `chan` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep21` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → VoltageClampAmplifier` (voltage-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `chan` | `PatchClamp → Membranes → StochasticChannel` |
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

- `chan`:

  | Parameter | Value |
  |---|---|
  | `fixedSeed` | `42` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pipette.p_amp` |
| `pipette.p_cell` | `chan.membrane_p` |
| `chan.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.150, Interval = 5e-5, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `chan.I_patch` and `chan.isOpen[1]`. Zoom into 20–60 ms.

| What to read | Variable | Expected value |
|---|---|---|
| Unitary current at +20 mV | `chan.i_unitary[1]` | **10.9 pA** (same as Step18) |
| Open probability expected from the Boltzmann curve at +20 mV | `chan.P_open_inf` | **0.98** |
| Fraction of the time the channel is open during the step (20–120 ms) | `chan.isOpen[1]` | **0.91** (random: between 0.94 and 1.0 for ten different seeds; the library example gives 0.91) |
| Number of openings and closings during the step | `chan.isOpen[1]` | **9** (random: 1 to 5 for ten different seeds; the library example has 9) |

The current is a rectangular trace jumping between 0 pA and 10.9 pA. The channel is open most of the time during the step (the Boltzmann
probability is 0.98) with brief closings; at −70 mV it is almost always closed, with rare short openings (you may see small steps of
about 1.9 pA: the unitary current at −70 mV).

## 4. Explore

1. **More channels.** Set `chan.n_channels` to 5 and then 20 and plot `chan.nOpenChannels`. Expected (checked): the number of open channels takes integer values (0 to 5 with
   5 channels, up to 19 simultaneously with 20), and the patch current is that number times 10.9 pA. The more channels, the more the trace looks like the smooth curve of Step18.
2. **Another random realization.** Change `chan.fixedSeed` to 7. Is the trace the same? Are the mean open fraction and the unitary current the same?
3. **Compare with Step18.** Run Step18 and overlay its `patch.I_patch` for 10 channels with this model for `n_channels` = 10. Why do they agree on average but not point by point?

## 5. Check your model

Open `PatchClamp → Examples → Step21_StochasticSingleChannel` and simulate it with its own settings. The random numbers of a stochastic channel depend on the name of the model that contains it, so your `MyStep21` will not reproduce the library example's trace flip by flip, even with the same `fixedSeed`. What must agree is everything that is not random: the unitary current, the expected open probability, the current levels (0 pA and the unitary current) and the statistics in the table above (open fraction and number of flips within the ranges given).

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step25 — Ligand-gated single channel](Step25_LigandGatedSingleChannel_Tutorial.md) opens a stochastic channel with an agonist instead of voltage.
