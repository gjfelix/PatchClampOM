# Tutorial: Step16 — Cardiac Ventricular Action Potential

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step06 tutorial](Step06_HodgkinHuxleyActionPotential_Tutorial.md).

## Learning objectives

- Trigger a ventricular action potential with a brief current pulse.
- Identify the upstroke, the plateau and the repolarization, and the current responsible for each.
- Measure the action-potential duration (APD90) and see what happens when the calcium current is blocked.

## 1. What you will build

`CardiacVentricularCell` has a fast sodium current (upstroke), an L-type calcium current (plateau), a delayed-rectifier potassium
current (repolarization), an inward-rectifier and a leak. A 5 nA pulse of 2 ms at 5 ms depolarizes the 100 pF cell past the sodium
threshold; the action potential then lasts a third of a second, hundreds of times longer than a nerve spike. The simulation uses a tight
tolerance (`1e-9`), which the recipe sets for you.

Circuit: `amp` → `pip` → `neuron` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep16` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → CardiacVentricularCell` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `5000.0e-12` |
  | `t_pulse_start` | `0.005` |
  | `t_pulse_end` | `0.007` |
  | `R_bridge` | `0.0` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `R_pipette` | `3.0e6` |
  | `C_pipette` | `2.0e-12` |
  | `V_junction` | `0.0` |

- `neuron`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `100.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `neuron.membrane_p` |
| `neuron.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.400, Interval = 1e-5, Tolerance = 1e-9.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `neuron.V_m` first (stop time 0.4 s), then `neuron.I_Na`, `neuron.I_Ca` and `neuron.I_K` in a second window.

| What to read | Variable | Expected value |
|---|---|---|
| Resting potential | `neuron.V_m` | **−84 mV** (±1 mV) |
| Peak of the action potential | `neuron.V_m` | **+49.4 mV** (±3 mV) |
| Time of the peak | `neuron.V_m` | **10.2 ms** (±1 ms) |
| Potential at 100 ms (plateau) | `neuron.V_m` | **+26.6 mV** (±3 mV) |
| Potential at 200 ms | `neuron.V_m` | **+12.9 mV** (±3 mV) |
| Action-potential duration APD90 (upstroke to 90 % repolarization) | `neuron.V_m` | **343 ms** (validated band 200–350 ms) |
| Largest inward sodium current | `neuron.I_Na` | **−4.28 nA** (±0.3 nA) |
| Largest inward calcium current | `neuron.I_Ca` | **−0.46 nA** (±0.05 nA) |

After the upstroke the potential does not fall back: it declines slowly through a plateau (a slow ramp from about +49 mV towards
0 mV in this simplified model) held by the calcium current, and returns to about −84 mV only after about 340 ms. The sodium current is a
brief, very large inward spike; the calcium current is small but sustained.

## 4. Explore

1. **Stimulus strength.** Set `I_pulse` to 2 nA, 5 nA and 10 nA (checked). With 2 nA the cell does *not* fire (the potential peaks at −50.5 mV and returns to rest);
   with 5 nA it fires (+49.4 mV, APD90 343 ms); with 10 nA the spike is larger (+89.2 mV) and the duration is almost the same (341 ms). What does this
   tell you about the threshold and about whether a bigger stimulus makes a longer action potential?
2. **Calcium-channel block.** Set `neuron.g_Ca` to 0 (as with verapamil). Expected (checked): the upstroke is still there (+47.5 mV at 9.5 ms) but
   the plateau disappears: the potential is −22.2 mV at 60 ms and back at −83.9 mV by 100 ms. Compare the duration with the normal cell.
3. **Compare with Step06.** The Hodgkin–Huxley spike lasts about 1 ms. By roughly what factor is the cardiac action potential longer, and which current makes the difference?

## 5. Check your model

Open `PatchClamp → Examples → Step16_CardiacActionPotential`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step17 — Pacemaker autorhythmicity](Step17_PacemakerAutorhythmicity_Tutorial.md) shows a cardiac cell that fires with no stimulus at all.
