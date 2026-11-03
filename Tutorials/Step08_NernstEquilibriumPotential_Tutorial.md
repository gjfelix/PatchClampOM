# Tutorial: Step08 — Nernst Equilibrium Potential

**Before you start:** read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md).

## Learning objectives

- Compute the four physiological Nernst potentials (K⁺, Na⁺, Cl⁻, Ca²⁺) from ion concentrations with the library function `nernstPotential`.
- See how raising extracellular K⁺ depolarizes `E_K` and the Goldman resting potential.
- Understand why the resting potential lies close to `E_K` but not equal to it.

## 1. What you will build

This is the only tutorial (together with Step09) without a circuit: the model is a small set of equations. It calls the library
function `PatchClamp.Media.Functions.nernstPotential` once per ion, using typical intracellular and extracellular concentrations,
and adds a simplified Goldman resting potential in which K⁺, Na⁺ and Cl⁻ contribute in proportion to relative permeabilities
(1 : 0.04 : 0.45). Everything is a parameter, so the "experiment" is to change a parameter and read the outputs.

## 2. Build it

1. Create a new model named `MyStep08` (see *Create a new, empty model* in the basics page) and open its **Diagram View**.
2. Switch to the **Text View**, select everything, and replace it with this code (see *Typing code instead of dragging* in the basics page):

```modelica
model MyStep08
  "Nernst equilibrium potential as a function of extracellular [K+]"
  parameter Real K_out(unit = "mol/m3", min = 0.5) = 5.0
    "Extracellular K+ concentration [mM] -- sweep 1 to 150 mM for the curve";
  parameter Real K_in(unit = "mol/m3")   = 140.0
    "Intracellular K+ concentration [mM] (typical pipette-filling value)";
  parameter Real Na_in(unit = "mol/m3")  = 10.0
    "Intracellular Na+ concentration [mM]";
  parameter Real Cl_in(unit = "mol/m3")  = 10.0
    "Intracellular Cl- concentration [mM]";
  parameter Real Ca_in(unit = "mol/m3")  = 1.0e-4
    "Intracellular Ca2+ concentration [mM] (free fraction, at rest)";
  parameter Real Na_out(unit = "mol/m3") = 145.0
    "Extracellular Na+ concentration [mM] (typical Ringer/ACSF)";
  parameter Real Cl_out(unit = "mol/m3") = 110.0
    "Extracellular Cl- concentration [mM]";
  parameter Real Ca_out(unit = "mol/m3") = 2.0
    "Extracellular Ca2+ concentration [mM]";
  parameter Real T(unit = "K") = PatchClamp.Constants.T_body
    "Temperature [K] (default: 37 degC = 310.15 K)";
  Real E_K(unit  = "V")  "K+ equilibrium potential [V] -- follows Nernst with K_out";
  Real E_Na(unit = "V")  "Na+ equilibrium potential [V]";
  Real E_Cl(unit = "V")  "Cl- equilibrium potential [V]";
  Real E_Ca(unit = "V")  "Ca2+ equilibrium potential [V]";
  parameter Real P_K  = 1.0   "Relative K+ permeability (normalized)";
  parameter Real P_Na = 0.04  "Relative Na+ permeability at rest";
  parameter Real P_Cl = 0.45  "Relative Cl- permeability at rest";
  Real V_Goldman(unit = "V") "Resting membrane potential via the Goldman equation [V]";
equation
  E_K  = PatchClamp.Media.Functions.nernstPotential(T,  1, K_out,  K_in);
  E_Na = PatchClamp.Media.Functions.nernstPotential(T,  1, Na_out, Na_in);
  E_Cl = PatchClamp.Media.Functions.nernstPotential(T, -1, Cl_out, Cl_in);
  E_Ca = PatchClamp.Media.Functions.nernstPotential(T,  2, Ca_out, Ca_in);
  V_Goldman = (PatchClamp.Constants.R * T / PatchClamp.Constants.F) *
              log((P_K * K_out  + P_Na * Na_out + P_Cl * Cl_in) /
                  (P_K * K_in   + P_Na * Na_in  + P_Cl * Cl_out));
end MyStep08;
```

3. Switch back to the Diagram View, **Check Model**, then follow Section 3.

## 3. Expected results

The model is static, so nothing changes with time. Simulate (any stop time works), then read the values in the **Variables Browser**, or plot a variable and hover over the flat line.

| What to read | Variable | Expected value |
|---|---|---|
| K⁺ equilibrium potential | `E_K` | **−89.1 mV** (±0.5 mV) |
| Na⁺ equilibrium potential | `E_Na` | **+71.5 mV** (±0.5 mV) |
| Cl⁻ equilibrium potential | `E_Cl` | **−64.1 mV** (±0.5 mV) |
| Ca²⁺ equilibrium potential | `E_Ca` | **+132.3 mV** (±0.5 mV) |
| Goldman resting potential | `V_Goldman` | **−67.3 mV** (±0.5 mV) |

The ordering matters: `E_K` is the most negative, `E_Cl` is close to the resting potential, and `E_Na` and `E_Ca` are positive. The
Goldman potential lies between `E_K` and `E_Na`, much closer to `E_K` because the K⁺ permeability is 25 times the Na⁺ permeability.

## 4. Explore

1. **Extracellular potassium sweep.** Change `K_out` (default 5 mM) and read `E_K` and `V_Goldman` after each simulation. Expected:

   | `K_out` (mM) | `E_K` (mV) | `V_Goldman` (mV) |
   |---|---|---|
   | 1 | −132.1 | −75.4 |
   | 5 (default) | −89.1 | −67.3 |
   | 20 | −52.0 | −49.1 |
   | 50 | −27.5 | −30.7 |
   | 150 | +1.8 | −4.5 |

   Which one moves more when `K_out` changes, `E_K` or `V_Goldman`? Why?
2. **The 61.5 mV rule.** From the table, how much does `E_K` change for a tenfold increase in `K_out` (for example 5 to 50 mM)? Compare with `(R·T/F)·ln(10)` at 37 °C, which is 61.5 mV.
3. **Temperature.** Set `T` to 293.15 K (20 °C) with `K_out` = 5 mM. `E_K` should become −84.2 mV. Why is the change small, and why do real recordings at room temperature still need a correction?
4. **Permeabilities.** Set `P_Na` to 1 (as permeable as K⁺). Predict first, then read `V_Goldman`: should it move toward `E_K` or toward `E_Na`?

## 5. Check your model

Open `PatchClamp → Examples → Step08_NernstEquilibriumPotential`, simulate it with its own settings, and compare. Your traces should overlay the example's.

If something does not look right:

- compare the parameter tables above with each block's **Parameters** window;
- check every connection in the table (a missing ground return, `….n` to `bath.n`, changes the result);
- check the exponents: all values are SI units.

**Next:** [Step09 — GHK reversal potential](Step09_GHKReversalPotential_Tutorial.md) measures a reversal potential from a current–voltage curve instead of computing it.
