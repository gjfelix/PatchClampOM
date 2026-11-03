# Tutorial: Step24 — Series-Resistance (R_s) Compensation

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step23 tutorial](Step23_WholeCellCapacitanceCompensation_Tutorial.md).

## Learning objectives

- Measure the voltage-clamp error produced by the series resistance in a leaky cell.
- Turn the R_s dial (`alpha`) up to 0.7 and 0.9 and see the cell approach the commanded voltage.
- Relate the correction to the larger transient currents it causes.

## 1. What you will build

Both capacitive transients are already compensated here (`frac_fast` = 1, `frac_slow` = 1), so what is left is a pure DC error. The cell
is small and leaky (`R_m` = 20 MΩ) and the total series resistance is 14 MΩ (4 MΩ pipette + 10 MΩ access). The amplifier command is −50 mV, but the
current flowing through the series resistance drops a large part of it before it reaches the membrane. The R_s dial, `alpha`, starts at
0 (off) and goes up to 0.9.

Circuit: `amp` → `pip` → `cell` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep24` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → Compensation → CompensatedVClampAmp` (voltage-clamp amplifier with compensation) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `cell` | `PatchClamp → Membranes → WholeCell` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `V_ljp_correction` | `0.0` |
  | `frac_fast` | `1.0` |
  | `C_slow` | `50.0e-12` |
  | `R_s_est` | `14.0e6` |
  | `frac_slow` | `1.0` |
  | `R_s` | `14.0e6` |
  | `tau_comp` | `50.0e-6` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `cell`:

  | Parameter | Value |
  |---|---|
  | `R_m` | `20.0e6` |
  | `V_m_init` | `-0.070` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `cell.p_pip` |
| `cell.p_ext` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-6, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `cell.V_m`, `amp.V_command` and `amp.I_measured`.

| What to read | Variable | Expected value |
|---|---|---|
| Cell potential at 149 ms, dial off | `cell.V_m` | **−29.4 mV** (only 59 % of the −50 mV command) |
| Steady-state current at 140 ms | `amp.I_measured` | **−1.47 nA** (±0.05 nA) |
| Largest (most negative) measured current after the step | `amp.I_measured` | **−2.06 nA** (±0.1 nA) |

The cell potential settles at a voltage divider of the command: −50 mV · 20 MΩ / (14 MΩ + 20 MΩ) = −29.4 mV. A 20 mV error is large; it is not
unusual for a small, leaky cell recorded with a pipette of a few megaohms.

## 4. Explore

1. **Dial up.** Simulate with `alpha` = 0.7 and then 0.9. Expected (checked):

   | `alpha` | `cell.V_m` at 149 ms | steady `amp.I_measured` | size of the peak of `amp.I_measured` |
   |---|---|---|---|
   | 0 | −29.4 mV | −1.47 nA | 2.06 nA |
   | 0.7 | −41.3 mV | −2.07 nA | 2.89 nA |
   | 0.9 | −46.7 mV | −2.34 nA | 3.27 nA |

   The error is cut roughly in half at 0.7 and to about a quarter of its original size at 0.9.
2. **Why not 1.0?** The dial is limited to 0.9. Using what you see in the table (larger currents, larger peaks), explain why pushing the correction to 100 % would make a real recording unstable.
3. **Leakier or tighter cells.** Change `cell.R_m` to 200e6 (a tight cell) with `alpha` = 0. Predict first whether the error will be larger or smaller than 20 mV, then check.

## 5. Check your model

Open `PatchClamp → Examples → Step24_AccessResistanceCompensation`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step14 — FitzHugh–Nagumo excitability](Step14_FitzHughNagumoExcitability_Tutorial.md) moves from the amplifier to simplified excitable cells.
