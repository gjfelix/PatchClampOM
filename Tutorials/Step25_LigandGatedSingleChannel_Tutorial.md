# Tutorial: Step25 — Ligand-Gated Single-Channel Recording — an Agonist Pulse on an Outside-Out Patch

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step21 tutorial](Step21_StochasticSingleChannel_Tutorial.md).

## Learning objectives

- Replace the voltage-gated stochastic channel by `LigandGatedChannel`, which opens in response to an agonist.
- Apply a rectangular agonist pulse at a constant holding potential and read the resulting single-channel current.
- Reproduce a dose–response (Hill) curve and the deactivation time constant from your own simulations.

## 1. What you will build

The circuit is the stochastic-patch circuit of Step21, but the channel is `LigandGatedChannel`: a nonselective cation channel (30 pS, reversal
potential 0 mV) opened by an **agonist** with EC50 = 10 µM and Hill coefficient 2, closing at 200 per second (mean open time 5 ms). The
membrane is held at −70 mV the whole time (the voltage never changes); a 30 µM agonist pulse is applied from 50 ms to 200 ms, mimicking
fast perfusion of an outside-out patch. With one channel you see an individual channel flickering; `chan.I_mean` is the smooth ensemble
average that the stochastic trace fluctuates around. The model has no desensitization.

Circuit: `amp` → `pipette` → `chan` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep25` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → VoltageClampAmplifier` (voltage-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `chan` | `PatchClamp → Membranes → LigandGatedChannel` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `V_step` | `-0.070` |
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

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.300, Interval = 5e-5, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `chan.I_patch`, `chan.I_mean` and `chan.c_L` (agonist concentration).

| What to read | Variable | Expected value |
|---|---|---|
| Unitary current at −70 mV (30 pS × −70 mV) | `chan.i_unitary` | **−2.1 pA** (±0.1 pA; inward) |
| Open probability expected during the pulse (Hill: 30²/(30² + 10²)) | `chan.P_open_inf` | **0.9** |
| Open probability expected outside the pulse | `chan.P_open_inf` | **0** |
| Fraction of the time the channel is open during the pulse (60–200 ms) | `chan.isOpen[1]` | **0.89** (random: 0.87–0.93 for ten seeds) |
| Number of openings and closings during the pulse | `chan.isOpen[1]` | **63** (random: 43 to 71 for ten seeds) |
| Ensemble-average current during the pulse | `chan.I_mean` | **−1.89 pA** (0.9 × −2.1 pA) |

Nothing happens until the agonist arrives at 50 ms: then the channel flickers between 0 and −2.1 pA, open about 90 % of the time, and closes
again within a few milliseconds when the agonist is removed at 200 ms. At any other holding voltage the same agonist would open the channel
with the same probability; only the size and sign of the current would change.

## 4. Explore

1. **Dose–response.** Set `chan.n_channels` to 20 (to reduce the sampling noise) and `chan.c_agonist` to 0.003, 0.010, 0.030 and 0.100 mM. Expected (checked):

   | Agonist | Hill prediction | Fraction open in your simulation |
   |---|---|---|
   | 3 µM | 0.083 | 0.075 |
   | 10 µM | 0.500 | 0.503 |
   | 30 µM | 0.900 | 0.891 |
   | 100 µM | 0.990 | 0.985 |

   (Your values will differ slightly if you change the seed.)
2. **Deactivation.** With `chan.n_channels` = 200, plot `chan.I_mean` after 200 ms: it decays exponentially with a time constant 1/`k_close` = 5 ms (checked: 5.0 ms for `chan.I_mean`; about 5.9 ms when fitted to the noisy stochastic trace).
3. **Voltage independence.** Set `amp.V_hold` and `amp.V_step` to +0.040 V. Expected (checked): the unitary current reverses to +1.2 pA while the open probability stays 0.90. What does that tell you about the difference between this channel and the Kv channel of Step21?

## 5. Check your model

Open `PatchClamp → Examples → Step25_LigandGatedSingleChannel` and simulate it with its own settings. The random numbers of a stochastic channel depend on the name of the model that contains it, so your `MyStep25` will not reproduce the library example's trace flip by flip, even with the same `fixedSeed`. What must agree is everything that is not random: the unitary current, the expected open probability, the current levels (0 pA and the unitary current) and the statistics in the table above (open fraction and number of flips within the ranges given).

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** You have now built every example of the package. Try the exercises of the earlier tutorials with other parameters, or combine blocks of different examples in new circuits.
