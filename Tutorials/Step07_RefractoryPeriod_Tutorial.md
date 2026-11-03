# Tutorial: Step07 — Refractory Period of the Hodgkin–Huxley Neuron

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step06 tutorial](Step06_HodgkinHuxleyActionPotential_Tutorial.md).

## Learning objectives

- Build a two-pulse current-clamp protocol with a single current-clamp amplifier.
- Distinguish the **absolute** refractory period (no second action potential) from the **relative** one (a smaller second action potential).
- Link the refractory period to the slow recovery of sodium-channel inactivation (`neuron.h`) and to the lingering potassium activation (`neuron.n`).

## 1. What you will build

This is the Step06 circuit with one change: the current-clamp amplifier delivers **two** identical 300 pA pulses of 2 ms. The
first pulse starts at 10 ms and fires an action potential. The second pulse starts `t2_delay` later, and the question is whether
the neuron can fire again. Immediately after a spike the sodium channels are inactivated (`h` is close to 0) and the potassium
channels are still open (`n` is high), so a second stimulus fails or gives a smaller spike until both gates have recovered.

In the tables below the second pulse is already set for the default delay of 5 ms (it runs from 15 ms to 17 ms, that is,
10 ms + 5 ms to 12 ms + 5 ms). Section 4 shows how to change the delay.

Circuit: `amplifier` → `pipette` → `neuron` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep07` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amplifier` | `PatchClamp → Amplifiers → CurrentClampAmplifier` (current-clamp amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `neuron` | `PatchClamp → Cells → HodgkinHuxleyNeuron` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amplifier`:

  | Parameter | Value |
  |---|---|
  | `I_pulse` | `300.0e-12` |
  | `t_pulse_end` | `0.012` |
  | `I_pulse2` | `300.0e-12` |
  | `t_pulse2_start` | `0.015` |
  | `t_pulse2_end` | `0.017` |

- `pipette`: keep all defaults.

- `neuron`:

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

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.050, Interval = 1e-5, Tolerance = 1e-8.

Pulse 1 keeps its default start time of 10 ms, so `t_pulse_start` does not appear in the table.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `neuron.V_m`, `neuron.h` and `neuron.n` (use two plot windows: voltage in one, the gates in the other).

| What to read | Variable | Expected value |
|---|---|---|
| Resting potential before the first pulse | `neuron.V_m` | **−65 mV** (initial value) |
| Peak of the first action potential (10–16 ms) | `neuron.V_m` | **40.9 mV** (±1 mV) |
| Highest V_m after the second pulse starts (15–25 ms) | `neuron.V_m` | **−65.8 mV** (no second spike) |
| Na⁺ inactivation gate when the second pulse starts (15 ms) | `neuron.h` | **0.21** (still low; resting value 0.60) |
| Number of action potentials (upward crossings of 0 mV) | `neuron.V_m` | **1** |

With the default 5 ms delay you see **one** action potential (its upstroke crosses 0 mV at about 11 ms) and, at 15 ms, only a small bump that does not
reach threshold. During the spike `h` falls to near zero and recovers over the next ten milliseconds or so; `n` rises and decays
more slowly.

## 4. Explore

1. **Delay sweep.** Change the start and end of the second pulse to `0.010 + d` and `0.012 + d` for d = 3, 5, 8 and 12 ms (for
   example `0.018` and `0.020` for 8 ms) and simulate each time. Expected (checked):

   | Delay d | Second pulse starts | `h` at that moment | Result |
   |---|---|---|---|
   | 3 ms | 13 ms | 0.08 | no second spike (absolute refractory) |
   | 5 ms | 15 ms | 0.21 | no second spike (absolute refractory) |
   | 8 ms | 18 ms | 0.43 | **reduced** spike, peak about +27 mV (relative refractory) |
   | 12 ms | 22 ms | 0.57 | **full** spike, peak about +40 mV (recovered) |
2. **Gates.** For the 8 ms delay, plot `neuron.h` and `neuron.n` together with `neuron.V_m`. Which gate is closer to its resting value (`h` = 0.60, `n` = 0.32) when the second pulse arrives? How does that explain a smaller spike?
3. **Stimulus strength** (checked; first pulse stays 300 pA, only `I_pulse2` changes). With the 5 ms delay set `I_pulse2` to 100, 200, 300, 500 and 1000 pA: the highest V_m after the second pulse stays below −45 mV every time (the neuron cannot fire, whatever the stimulus). With the 8 ms delay, 100 and 200 pA give no spike, but 300, 500 and 1000 pA give spikes of about +27, +30 and +32 mV, never as large as the first (+41 mV). Which of these two behaviors is the *absolute* and which the *relative* refractory period?

## 5. Check your model

Open `PatchClamp → Examples → Step07_RefractoryPeriod`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step08 — Nernst equilibrium potential](Step08_NernstEquilibriumPotential_Tutorial.md) moves from excitability to ion electrochemistry.
