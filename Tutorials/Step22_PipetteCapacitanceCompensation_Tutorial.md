# Tutorial: Step22 — C-fast Compensation in the Cell-Attached Configuration

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step02 tutorial](Step02_GigasealFormation_Tutorial.md) and the [Step13 tutorial](Step13_SeriesResistanceCompensation_Tutorial.md).

## Learning objectives

- Build a cell-attached circuit (gigaseal) driven by the compensated voltage-clamp amplifier.
- Apply C-fast compensation and measure how much of the capacitive transient it removes.
- Understand what the transient in this circuit really is.

## 1. What you will build

After forming a gigaseal (Step02) the first dial an experimenter adjusts is C-fast, which cancels the capacitance of the pipette wall.
The circuit has no cell capacitance yet: `CellAttachedPatch` represents the sealed patch (1 GΩ seal, 50 GΩ patch, 0.1 pF). The amplifier
steps from −70 mV to −50 mV at 50 ms. The compensation dials start **off** (`frac_fast` = 0); the library example keeps
`alpha` = 0.3, a small numerical setting that the amplifier model needs in this configuration, so keep it too.

Circuit: `amp` → `pip` → `patch` → `bath`  (the amplifier and the pipette also return to the bath electrode, `bath.n`).

## 2. Build it

1. Create a new model named `MyStep22` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `amp` | `PatchClamp → Amplifiers → Compensation → CompensatedVClampAmp` (voltage-clamp amplifier with compensation) |
| 2 | `pip` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `patch` | `PatchClamp → Membranes → CellAttachedPatch` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `amp`:

  | Parameter | Value |
  |---|---|
  | `V_ljp_correction` | `0.0` |
  | `alpha` | `0.3` |

- `pip`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `patch`: keep all defaults.

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `amp.p` | `pip.p_amp` |
| `pip.p_cell` | `patch.p_pip` |
| `patch.p_ext` | `bath.p` |
| `amp.n` | `bath.n` |
| `pip.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.200, Interval = 1e-6, Tolerance = 1e-8.

3. **Check Model**, then **Simulate**.

## 3. Expected results

Plot `amp.I_raw` and `amp.I_measured`, then zoom into 50.00–50.01 ms. The transient decays in about a microsecond, so zoom in strongly.

| What to read | Variable | Expected value |
|---|---|---|
| Peak of the raw current after the step (first 0.3 ms) | `amp.I_raw` | **6.51 nA** (±0.1 nA) |
| Peak of the measured current (dial off, same as raw) | `amp.I_measured` | **6.51 nA** (±0.1 nA) |
| Steady-state current at 140 ms | `amp.I_measured` | **−50.9 pA** (−50 mV across about 1 GΩ; sign follows the library convention) |

The spike is several nanoamperes tall and about a microsecond wide, while the steady current through the 1 GΩ seal is only about
50 pA. It is tempting to call the spike "the pipette capacitance", but in this model the pipette's own charging current is an
instantaneous impulse (the command is an ideal step) and is not visible. What you see is mainly the 0.1 pF patch capacitance charging through
the 4 MΩ pipette (time constant 0.4 µs).

## 4. Explore

1. **Switch C-fast on.** Set `frac_fast` to 1 and simulate again. Expected (checked): the peak of `amp.I_measured` falls from 6.51 nA to
   4.93 nA (a reduction of 24 %), `amp.I_raw` is unchanged (6.51 nA) and the steady current does not change. Plot `amp.I_comp_fast`:
   it is the current the amplifier subtracts.
2. **Why only 24 %?** Using the description above, explain why C-fast can remove only part of this transient. Which capacitance would you have to compensate to remove the rest, and which circuit element would that correspond to in a real recording after break-in? (Step23 answers this.)

## 5. Check your model

Open `PatchClamp → Examples → Step22_PipetteCapacitanceCompensation`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step23 — C-slow compensation, isolated](Step23_WholeCellCapacitanceCompensation_Tutorial.md) continues after break-in.
