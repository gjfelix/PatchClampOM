# Tutorial: Step15 — Morris–Lecar Excitability (Type II and Type I)

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step14 tutorial](Step14_FitzHughNagumoExcitability_Tutorial.md).

## Learning objectives

- Drive the Morris–Lecar neuron (a calcium and a potassium conductance) with a sustained current.
- Observe the abrupt onset of repetitive firing that defines Type II excitability.
- Switch three parameters to obtain Type I excitability, in which the firing rate rises continuously from zero.

## 1. What you will build

`MorrisLecarNeuron` has two variables: the membrane potential, driven by a fast calcium current, a potassium current and a leak, and a
potassium gating variable `w`. With the default parameters it is a **Type II** neuron: as the injected current increases, firing starts
abruptly at a finite rate. The amplifier injects a sustained 1 nA current from 10 ms to 200 ms into a 200 pF cell.

Circuit: `amp` → `pip` → `neuron` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep15` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → MorrisLecarNeuron` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `1000.0e-12` |
  | `t_pulse_end` | `0.200` |
  | `R_bridge` | `0.0` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `neuron`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `200.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `neuron.membrane_p` |
| `neuron.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-5, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `neuron.V_m` and `neuron.w`, and `amp.I_command`.

| What to read | Variable | Expected value |
|---|---|---|
| Resting potential | `neuron.V_m` | **−60 mV** (initial value) |
| Peak of the spikes | `neuron.V_m` | **+40.7 mV** (±2 mV) |
| Time of the first spike (upward crossing of 0 mV) | `neuron.V_m` | **26.2 ms** (±2 ms) |
| Number of spikes between 10 and 200 ms | `neuron.V_m` | **3** |
| Time between spikes | `neuron.V_m` | **86 ms** (about 11–12 Hz; ±5 ms) |

The cell fires three spikes during the 190 ms of current, about 86 ms apart, and returns to rest after the current ends.

## 4. Explore

1. **Type II threshold.** Change `I_pulse` and count the spikes between 10 and 200 ms. Expected (checked):

   | `I_pulse` | Spikes | Time between spikes |
   |---|---|---|
   | 850 pA | 1 | one transient spike, then silence |
   | 900 pA | 2 | 105 ms |
   | 940 pA | 2 | 95 ms |
   | 1000 pA | 3 | 86 ms |

   The cell goes from one transient spike to repetitive firing at about 9–11 Hz: the onset is abrupt and at a finite frequency.
2. **Type I.** Set `neuron.V3` = 0.012, `neuron.V4` = 0.0174 and `neuron.phi` = 23.3, and set `t_pulse_end` and the stop time to 1.0 s. Expected (checked):

   | `I_pulse` | Firing rate |
   |---|---|
   | 300 pA | none |
   | 400 pA | 5.5 Hz |
   | 500 pA | 8.7 Hz |
   | 1000 pA | 11.6 Hz |

   Now the rate rises smoothly from zero. How does this f–I curve differ from the Type II table above?
3. **Why it matters.** Type I neurons can encode a stimulus strength in a graded firing rate, whereas Type II neurons act more like switches. Which type would you expect for a cell that must signal intensity, such as a sensory neuron?

## 5. Check your model

Open `PatchClamp → Examples → Step15_MorrisLecarExcitability`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step16 — Cardiac action potential](Step16_CardiacActionPotential_Tutorial.md) moves to a cell with a calcium plateau.
