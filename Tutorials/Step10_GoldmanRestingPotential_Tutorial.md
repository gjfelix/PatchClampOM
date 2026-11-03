# Tutorial: Step10 — Goldman Resting Potential with Realistic Solutions

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) and complete the [Step08 tutorial](Step08_NernstEquilibriumPotential_Tutorial.md).

## Learning objectives

- Assemble a membrane between a pipette (internal) and a bath (external) solution using the library's solution blocks.
- Read the four Nernst potentials and the multi-ion Goldman resting potential from one `GoldmanMembrane` block.
- Edit a solution (hyperkalemia, high chloride, temperature) and predict the change in each potential.

## 1. What you will build

Step08 computed the potentials from bare numbers. Here the concentrations live in two **solution blocks**, `int_sol` (the pipette
filling solution) and `ext_sol` (the bath), and a `GoldmanMembrane` reads them. The membrane has permeabilities to K⁺, Na⁺, Cl⁻ and
Ca²⁺ (K⁺ the largest) and returns the Nernst potential of every ion plus the Goldman resting potential. There is no amplifier:
the only connection is the membrane's bath side to ground, and `membrane_p` is deliberately left open.

The solutions also report their osmolarity. The defaults are not isotonic (160 mOsm inside, 262 mOsm outside), and the model raises
a warning flag for that, a reminder that real pipette and bath solutions must be osmotically matched.

Circuit: `int_sol` → `ext_sol` → `membrane` → `gnd`  (the amplifier and the pipette also return to the bath electrode, `gnd.n`).

## 2. Build it

1. Create a new model named `MyStep10` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Add the blocks, set their parameters, and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `int_sol` | `PatchClamp → Media → InternalSolution` (pipette (internal) solution) |
| 2 | `ext_sol` | `PatchClamp → Media → ExternalSolution` (bath (external) solution) |
| 3 | `membrane` | `PatchClamp → Membranes → GoldmanMembrane` |
| 4 | `gnd` | `PatchClamp → Electrodes → Ground` (ground) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `int_sol`: keep all defaults.

- `ext_sol`: keep all defaults.

- `membrane`:

  | Parameter | Value |
  |---|---|
  | `c_K_in` | `int_sol.c_K` |
  | `c_Na_in` | `int_sol.c_Na` |
  | `c_Cl_in` | `int_sol.c_Cl` |
  | `c_Ca_in` | `int_sol.c_Ca` |
  | `c_K_out` | `ext_sol.c_K` |
  | `c_Na_out` | `ext_sol.c_Na` |
  | `c_Cl_out` | `ext_sol.c_Cl` |
  | `c_Ca_out` | `ext_sol.c_Ca` |
  | `T` | `int_sol.T` |

- `gnd`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `gnd.p` | `membrane.membrane_n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 1.0, Interval = 1.0, Tolerance = 1e-8.

Type the expressions of the `membrane` table (for example `int_sol.c_K`) exactly as written: they link the membrane to the
concentrations of the solution blocks, so you only edit a concentration in one place.
The membrane block shows `membrane_p` on its left; leave that connector unconnected.

3. **Check Model**, then **Simulate**.

## 3. Expected results

The model is static: read the values in the **Variables Browser** (expand `membrane`, `int_sol` and `ext_sol`).

| What to read | Variable | Expected value |
|---|---|---|
| K⁺ equilibrium potential | `membrane.E_K` | **−89.1 mV** (±0.5 mV) |
| Na⁺ equilibrium potential | `membrane.E_Na` | **+71.5 mV** (±0.5 mV) |
| Cl⁻ equilibrium potential | `membrane.E_Cl` | **−64.1 mV** (±0.5 mV) |
| Ca²⁺ equilibrium potential | `membrane.E_Ca` | **+132.3 mV** (±0.5 mV) |
| Goldman resting potential | `membrane.V_Goldman` | **−67.3 mV** (±0.5 mV) |
| Internal osmolarity | `int_sol.osmolarity` | **160 mOsm** |
| External osmolarity | `ext_sol.osmolarity` | **262 mOsm** |

The values for K⁺, Na⁺ and Ca²⁺ are the same ones you obtained in Step08, now computed from the solution blocks. Note: in this model
read `V_Goldman` and the `E_…` values; do not use `membrane.V_m`, which stays at 0 V because nothing is connected to `membrane_p`.

## 4. Explore

1. **Hyperkalemia.** Set `ext_sol.c_K` to 20 mM. Expected (checked): `E_K` = −52.0 mV and `V_Goldman` = −49.1 mV (the other Nernst
   potentials do not change). The resting potential has depolarized by about 18 mV: this is why high blood potassium makes
   muscle and nerve cells depolarize.
2. **High intracellular chloride.** Set `int_sol.c_Cl` to 30 mM (as in immature neurons). Expected (checked): `E_Cl` moves from
   −64.1 mV to −34.7 mV and `V_Goldman` to −54.9 mV. If the resting potential is −55 mV and `E_Cl` is −35 mV, would GABA-activated chloride
   channels hyperpolarize or depolarize the cell?
3. **Temperature.** Set `T` to 293.15 K in `int_sol` and in `ext_sol` (the membrane follows `int_sol.T`). Expected (checked): `E_K` = −84.2 mV,
   `E_Na` = +67.6 mV, `E_Cl` = −60.6 mV, `E_Ca` = +125.1 mV and `V_Goldman` = −63.6 mV. Which ion's potential changes the most, and why?
4. **Permeability.** In the `membrane` block, double the Na⁺ permeability `P_Na`. Predict the direction of the change of `V_Goldman`, then check.

## 5. Check your model

Open `PatchClamp → Examples → Step10_GoldmanRestingPotential`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step11 — GHK I–V curve](Step11_GHK_IVCurve_Tutorial.md) drives the same membrane with a voltage ramp to trace its current–voltage relation.
