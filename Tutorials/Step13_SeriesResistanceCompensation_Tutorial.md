# Tutorial: Step13 — Electronic Compensation of a Passive Cell — the Three Dials

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step03 tutorial](Step03_PassiveCellVoltageClamp_Tutorial.md).

## Learning objectives

- Replace the plain voltage-clamp amplifier with `CompensatedVClampAmp`, which has the three compensation dials of a real amplifier (C-fast, C-slow, R_s).
- Measure the capacitive transient of a passive cell with all dials off, then switch the dials on.
- Learn which dial removes the large transient and why the series-resistance dial matters little at tiny currents.

## 1. What you will build

The circuit is the one of Step03 (amplifier, pipette, passive cell, bath) with a richer amplifier. `CompensatedVClampAmp` steps from −70 mV to
−50 mV at 50 ms and has three dials, each a parameter between 0 (off) and 1 (fully on): `frac_fast` (C-fast, cancels the pipette
capacitance), `frac_slow` (C-slow, cancels the cell's capacitive charging current) and `alpha` (series-resistance compensation, up to
0.9). In this tutorial all dials start **off** and you turn them on in Section 4. The passive cell is a 10 pF capacitor in
parallel with a 1 GΩ resistor, so its response is easy to predict: the cell charges through the 4 MΩ pipette with a time constant of
40 µs.

Circuit: `amp` → `pip` → `cell` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep13` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → Compensation → CompensatedVClampAmp` (voltage-clamp amplifier with compensation) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `cell` | `PatchClamp → Cells → PassiveCell` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `frac_fast` | `0` |
  | `frac_slow` | `0` |
  | `alpha` | `0` |
  | `tau_comp` | `10e-6` |

- `pip`: keep all defaults.

- `cell`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `10.0e-12` |
  | `R_m` | `1.0e9` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `cell.membrane_p` |
| `cell.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-6, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `amp.I_raw` and `amp.I_measured` (with the dials off they are identical), then zoom into 50.00–50.20 ms to see the transient.

| What to read | Variable | Expected value |
|---|---|---|
| Peak of the raw current right after the step (first 5 µs) | `amp.I_raw` | **4.99 nA** (±0.05 nA; 20 mV / 4 MΩ = 5 nA) |
| Raw current 30 µs after the step | `amp.I_raw` | **2.36 nA** (5 nA · e^(−30/40) = 2.4 nA) |
| Steady-state current at 140 ms | `amp.I_measured` | **14.9 pA** (±0.5 pA) |
| Voltage error caused by the series resistance | `amp.V_error` | **0.06 mV** (tiny at this current) |
| Cell membrane potential at 149 ms | `cell.V_m` | **−50.06 mV** (≈ −50 mV command) |

With every dial off, `amp.I_measured` equals `amp.I_raw`: a 5 nA spike that decays exponentially (τ = 40 µs) to a steady current of
only 15 pA. The spike is 300 times larger than the signal you want to measure, which is why capacitance compensation exists.

## 4. Explore

1. **C-slow.** Set `frac_slow` to 1 and simulate. Expected (checked): the peak of `amp.I_measured` in the first 5 µs drops from 5.0 nA to
   0.005 nA (5 pA) and, 30 µs after the step, the current is −1.5 pA instead of 2.4 nA. The steady-state current (14.9 pA)
   does not change. Plot `amp.I_comp_slow` as well: its peak is 5.0 nA, the current the amplifier injects to cancel the cell's charging.
2. **C-fast alone.** Set `frac_slow` back to 0 and `frac_fast` to 1. Expected (checked): nothing changes; `amp.I_comp_fast` stays at zero.
   The reason is that the command is an ideal, instantaneous step: the C-fast current is proportional to the *rate of change* of the
   command, which is zero everywhere except at one instant. (Step22 isolates this dial in a circuit where its effect can be seen.)
3. **All dials.** Set `frac_fast` = 1, `frac_slow` = 1 and `alpha` = 0.7. Expected (checked): the transient is cancelled (peak of `amp.I_measured`
   0.005 nA, 2.0 pA at 30 µs after the step), the steady current is 14.98 pA and the cell reaches −50.02 mV instead of −50.06 mV. The
   series-resistance error `amp.V_error` stays at 0.06 mV, because with 15 pA flowing through 4 MΩ there is almost nothing to correct.
   Step24 uses a leakier cell, where the error is large and the third dial matters.

## 5. Check your model

Open `PatchClamp → Examples → Step13_SeriesResistanceCompensation`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step22 — C-fast compensation, isolated](Step22_PipetteCapacitanceCompensation_Tutorial.md) shows the pipette-capacitance dial on its own.
