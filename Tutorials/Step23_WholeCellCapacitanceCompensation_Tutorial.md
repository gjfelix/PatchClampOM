# Tutorial: Step23 — C-slow Compensation after Break-In

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step04 tutorial](Step04_WholeCellBreakIn_Tutorial.md) and the [Step22 tutorial](Step22_PipetteCapacitanceCompensation_Tutorial.md).

## Learning objectives

- Build the whole-cell circuit (access resistance in series with the cell's capacitance and resistance) with the compensated amplifier.
- Measure the slow capacitive transient and switch C-slow on.
- See how the estimate of the series resistance `R_s_est` affects the residual transient.

## 1. What you will build

After break-in (Step04) the `WholeCell` block represents the opened cell: a 10 MΩ access resistance in series with a 50 pF capacitance
in parallel with a 200 MΩ membrane resistance. The amplifier steps from −70 mV to −50 mV at 50 ms with C-fast already on
(`frac_fast` = 1, as after Step22). C-slow starts **off** (`frac_slow` = 0). The C-slow estimator needs the cell capacitance
(`C_slow` = 50 pF) and an estimate of the total series resistance, 4 MΩ pipette plus 10 MΩ access: `R_s_est` = 14 MΩ.

Circuit: `amp` → `pip` → `cell` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep23` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
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

- `pip`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `cell`:

  | Parameter | Value |
  |---|---|
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

Plot `amp.I_raw` and `amp.I_measured`, then zoom into 50.0–52.5 ms to see the whole transient.

| What to read | Variable | Expected value |
|---|---|---|
| Peak of the raw current after the step (first 0.3 ms) | `amp.I_raw` | **1.1 nA** (±0.05 nA) |
| Raw current 100 µs after the step | `amp.I_raw` | **912 pA** (±30 pA) |
| Steady-state current at 140 ms | `amp.I_measured` | **−234 pA** (−50 mV across 214 MΩ) |
| Cell potential at 149 ms | `cell.V_m` | **−46.7 mV** (−50 mV · 200 MΩ / 214 MΩ) |

After a very brief initial spike you see one slow exponential: fitting the decay between 20 µs and 0.8 ms gives a time constant of
about 654 µs, close to the 700 µs predicted by (R_pipette + R_access) · C_m = 14 MΩ · 50 pF. The current ends at a steady
−234 pA, which is just −50 mV divided by 14 MΩ + 200 MΩ.

## 4. Explore

1. **Switch C-slow on.** Set `frac_slow` to 1. Expected (checked): the peak of `amp.I_measured` in the first 0.3 ms falls from 1.10 nA to
   0.33 nA and most of the slow transient disappears, leaving mainly the flat resistive step (−234 pA); `amp.I_raw` does not
   change. A small residual remains because C-slow's internal estimator is an approximation.
2. **A worse estimate.** Keep `frac_slow` = 1 and set `R_s_est` to 10e6 (access resistance only). Expected (checked): the peak of `amp.I_measured` is now 0.90 nA instead of 0.33 nA. Why does a poor estimate of the series resistance leave a larger residual?
3. **A bigger cell.** With `frac_slow` = 0, set `cell.C_m` to 150e-12. Expected (checked): the current 100 µs after the step rises from 912 pA to 1035 pA, because the transient decays more slowly. What would you also have to change in the amplifier to compensate this larger cell?

## 5. Check your model

Open `PatchClamp → Examples → Step23_WholeCellCapacitanceCompensation`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step24 — Series-resistance compensation, isolated](Step24_AccessResistanceCompensation_Tutorial.md) tackles the error that remains in the steady state.
