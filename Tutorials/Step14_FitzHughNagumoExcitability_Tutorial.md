# Tutorial: Step14 — FitzHugh–Nagumo Excitability

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step06 tutorial](Step06_HodgkinHuxleyActionPotential_Tutorial.md).

## Learning objectives

- Swap the Hodgkin–Huxley neuron of Step06 for the two-variable FitzHugh–Nagumo model without rewiring anything.
- Find the firing threshold with brief current pulses and see the all-or-nothing response.
- Obtain repetitive firing with a sustained current and view the phase plane.

## 1. What you will build

This is exactly the Step06 circuit with a different cell block. `FitzHughNagumoNeuron` reduces the four equations of Hodgkin–Huxley
to two: a fast variable `u` (excitation) and a slow recovery variable `w`. The membrane potential `neuron.V_m` is a scaled version of
`u`, so you still see a spike, but neither variable corresponds to a specific ion channel. The pipette here is a low-capacitance one
(0.5 pF) and the cell is small (1 pF). The amplifier delivers a 2 ms, 50 pA pulse at 10 ms.

Circuit: `amp` → `pip` → `neuron` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep14` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → FitzHughNagumoNeuron` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `50.0e-12` |
  | `t_pulse_end` | `0.012` |
  | `R_bridge` | `0.0` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `C_pipette` | `0.5e-12` |
  | `V_junction` | `0.0` |

- `neuron`:

  | Parameter | Value |
  |---|---|
  | `C_m` | `1.0e-12` |

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `neuron.membrane_p` |
| `neuron.membrane_n` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.100, Interval = 1e-5, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `neuron.V_m` and `amp.I_command`; then make a second plot of `neuron.u` against `neuron.w` (see the basics page, *New Parametric Plot Window*, x = `neuron.w`, y = `neuron.u`) to see the phase-plane loop.

| What to read | Variable | Expected value |
|---|---|---|
| Resting potential | `neuron.V_m` | **−65 mV** (initial value) |
| Peak of the spike | `neuron.V_m` | **+81.7 mV** (±2 mV) |
| Time of the peak | `neuron.V_m` | **18.5 ms** (±1 ms) |
| Lowest potential after the spike (undershoot) | `neuron.V_m` | **−105.6 mV** (±2 mV) |
| Maximum of the fast variable | `neuron.u` | **1.73** (dimensionless) |
| Maximum of the recovery variable | `neuron.w` | **1.06** (dimensionless) |

One spike, much wider than the Hodgkin–Huxley spike of Step06 (the potential stays above 0 mV for about 26 ms, against 1.0 ms in Step06), followed by an undershoot and a slow return to rest. In the phase
plane the trajectory leaves the resting point, makes a large excursion and comes back: that loop is the action potential.

## 4. Explore

1. **Threshold.** Change `I_pulse` (2 ms pulse) to 10, 20, 25, 30 and 50 pA. Expected (checked):

   | `I_pulse` | Peak `V_m` | Response |
   |---|---|---|
   | 10 pA | −52.8 mV | small bump, no spike |
   | 20 pA | −38.7 mV | larger bump, no spike |
   | 25 pA | +71.3 mV | spike |
   | 30 pA | +77.1 mV | spike |
   | 50 pA | +81.7 mV | spike |

   Between 20 and 25 pA the response jumps from a graded bump to a full spike: this is the all-or-nothing threshold.
2. **Repetitive firing.** Set `t_pulse_end` and the simulation stop time to 0.6 and apply a sustained `I_pulse` of 12, 20 and 30 pA. Expected (checked): the
   neuron fires repeatedly with a steady period of about 89.5 ms (12 pA), 81.5 ms (20 pA) and 86.3 ms (30 pA), that is, 11–12 Hz.
   With 50 pA the neuron fires once and then stays depolarized. Why can too much current *stop* the firing?
3. **Compare with Step06.** The Hodgkin–Huxley spike stays above 0 mV for about 1 ms (Step06), this one for about 26 ms. What else differs in this model's spike, and what does it tell you about what a reduced model keeps and what it throws away?

## 5. Check your model

Open `PatchClamp → Examples → Step14_FitzHughNagumoExcitability`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step15 — Morris–Lecar excitability](Step15_MorrisLecarExcitability_Tutorial.md) is another reduced model, with channels (Ca²⁺ and K⁺) in its equations.
