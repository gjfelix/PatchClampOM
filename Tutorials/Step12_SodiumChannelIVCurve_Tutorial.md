# Tutorial: Step12 — Sodium-Channel I–V Curve with a Voltage-Step Ladder

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step06 tutorial](Step06_HodgkinHuxleyActionPotential_Tutorial.md) and the [Step03 tutorial](Step03_PassiveCellVoltageClamp_Tutorial.md).

## Learning objectives

- Build the standard voltage-step protocol: hold at −100 mV, then step to a test voltage.
- Separate the fast inward Na⁺ current from the slower outward K⁺ current in one recording.
- Recognize the distortion of an I–V curve by the series resistance of the pipette.

## 1. What you will build

A voltage-clamp amplifier holds the Hodgkin–Huxley neuron at −100 mV for 150 ms, which removes sodium inactivation (`h` goes to 1),
and then steps to a test voltage for 30 ms. After the capacitive transient you see a fast **inward** Na⁺ current followed by a slower
**outward** K⁺ current. The full I–V curve needs one simulation per test voltage; here you build the circuit for one step
(−20 mV) and then repeat it by changing a single parameter.

The amplifier applies the test step relative to the −11 mV liquid-junction correction that the library uses by default, so
`amplifier.V_command` is 11 mV above the nominal test voltage; use the nominal values of the tables.

Circuit: `amplifier` → `pipette` → `neuron` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep12` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amplifier` | `PatchClamp → Amplifiers → VoltageClampAmplifier` (voltage-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → HodgkinHuxleyNeuron` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amplifier`:

  | Parameter | Value |
  |---|---|
  | `V_hold` | `-0.1` |
  | `V_step` | `-0.02` |
  | `t_step_start` | `0.15` |
  | `t_step_end` | `0.18` |

- `pipette`: keep all defaults.

- `neuron`: besides the parameters, set the initialization attribute `V_m(fixed = false)` (see the note below).

  | Parameter | Value |
  |---|---|
  | `C_m` | `10.0e-12` |
  | `A` | `1000.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amplifier.p` | `pipette.p_amp` |
| `pipette.p_cell` | `neuron.membrane_p` |
| `neuron.membrane_n` | `bath.p` |
| `amplifier.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.180, Interval = 1e-5, Tolerance = 1e-8.

The `neuron` block also needs the initialization attribute `V_m(fixed = false)`, so that the cell starts at the holding potential
instead of at −65 mV. In the **Parameters** window of `neuron`, look for the group *Initialization*, find `V_m`, and untick
*fixed*. If you cannot find it, switch to the Text View and write `V_m(fixed = false)` as one more entry inside the parentheses
of the `neuron` declaration, after `E_L = ...`.

The library example also defines a Boolean `in_test_phase` that only labels the test phase in the plots; you do not need it.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `neuron.I_Na`, `neuron.I_K`, `amplifier.I_measured` and `neuron.V_m`. Zoom into 150–155 ms to see the fast Na⁺ current.

| What to read | Variable | Expected value |
|---|---|---|
| Peak Na⁺ current during the test step | `neuron.I_Na` | **−12.6 nA** (inward, ±0.5 nA) |
| K⁺ current at the end of the step | `neuron.I_K` | **4.4 nA** (outward, ±0.3 nA) |
| Na⁺ inactivation gate just before the step | `neuron.h` | **1** (fully de-inactivated) |
| Membrane potential at the end of the step | `neuron.V_m` | **−34.7 mV** (not −20 mV: see below) |

The cell does **not** reach the commanded −20 mV: at the end of the step `V_m` is −34.7 mV, about 15 mV short, and during the
sodium peak the error is much larger (12 nA through 4 MΩ is a drop of about 48 mV). This series-resistance error grows with the
current and is what Step13 and Step24 correct.

## 4. Explore

1. **The ladder.** Change `V_step` (amplifier) to each nominal test voltage below, simulate, and read the peak of `neuron.I_Na` and
   the potential `neuron.V_m` at 179 ms. Expected (checked):

   | Nominal V_test (mV) | Peak I_Na (nA) | V_m at 179 ms (mV) |
   |---|---|---|
   | −80 | ≈ 0 | −79.7 |
   | −60 | −0.11 | −60.3 |
   | −50 | −15.6 | −51.9 |
   | −40 | −15.1 | −44.9 |
   | −30 | −13.9 | −39.4 |
   | −20 | −12.6 | −34.7 |
   | −10 | −11.3 | −30.5 |
   | 0 | −10.3 | −26.7 |
   | +20 | −8.5 | −19.4 |
   | +40 | −6.9 | −12.4 |

   Plot peak I_Na against V_m. Does the current ever reverse sign? Why not, given that `E_Na` = +50 mV?
2. **Holding potential.** Set `V_hold` to −0.065 V and repeat the −20 mV step. Expected (checked): peak I_Na falls from −12.6 nA to −11.0 nA, and `neuron.h` just before the step is 0.60 instead of 1.00. Why does holding at −65 mV reduce the sodium current?
3. **Isolate the currents.** Set `neuron.g_K_max` to 0, then `neuron.g_Na_max` to 0 (one at a time). Expected (checked): without K⁺ conductance the late outward current disappears and the membrane ends at −18.6 mV; without Na⁺ conductance the inward peak disappears and only the K⁺ current remains (4.0 nA at 180 ms). Which of the two settings makes the clamp error smaller, and why?
4. **Series resistance.** Set `pipette.R_pipette` to 1e6 (1 MΩ). Expected (checked): the peak Na⁺ current grows to −21.0 nA, because the cell is now closer to the commanded voltage (V_m ends at −26.7 mV instead of −34.7 mV). Why does a better clamp give a larger current?

## 5. Check your model

Open `PatchClamp → Examples → Step12_SodiumChannelIVCurve`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step13 — Series-resistance compensation](Step13_SeriesResistanceCompensation_Tutorial.md) shows how an amplifier corrects exactly this error.
