# Tutorial: Step09_GHKReversalPotential — GHK I–V Curve and Reversal Potential

**Model path:** `PatchClamp.Examples.Step09_GHKReversalPotential`
**Recommended stop time:** 500 ms | **Interval:** 0.5 ms | **Tolerance:** 1 × 10⁻⁸
**Solver:** default (DASSL or Euler — purely algebraic model, no ODEs)

---

> **Relationship to prior models.**
> Step08 introduced the **Nernst equation** as a purely algebraic calculation of the
> equilibrium (reversal) potential for a single ion. Step09 extends that idea by
> sweeping the membrane voltage across a linear ramp from −100 mV to +60 mV and
> evaluating the **Goldman–Hodgkin–Katz (GHK) current equation** at every point.
> The result is a complete **I–V curve** whose zero-crossing coincides exactly with
> the Nernst potential computed in Step08. A new comparison variable `I_ohm` is added
> so the student can observe how the GHK I–V deviates from a simple ohmic (linear)
> relationship — the phenomenon known as **intrinsic rectification**.

---

## Learning Objectives

By the end of this tutorial, the student will be able to:

1. Apply the GHK current equation to calculate ionic current density $J_{GHK}$ at any membrane voltage, including the limiting case at $V_m = 0$.
2. Identify the reversal potential (zero-crossing of the I–V curve) and verify that it equals the Nernst potential for the permeant ion.
3. Explain intrinsic GHK rectification: why the I–V curve is non-linear around $E_{rev}$ even in the absence of voltage-gated channels.
4. Predict how changing extracellular ion concentration (e.g., hyperkalemia) shifts the reversal potential and interpret the clinical significance.
5. Construct an equivalent ohmic conductance from the GHK current and compare the two current expressions to quantify rectification.

---

## 1. Context

### Where this model fits

| Step in workflow | Model | Question answered |
|---|---|---|
| Passive RC cell | Step05 | How does the pipette charge the cell membrane? |
| Active AP | Step06 | How do HH conductances generate a spike? |
| Equilibrium potential | Step08 | What voltage does a single ion species impose? |
| **I–V curve (this model)** | **Step09** | **What current flows through a GHK channel at each voltage?** |
| Two-compartment GHK | Step10 | How do intra- and extracellular compartments interact? |

### Physical setup

In a real patch-clamp experiment the **voltage-clamp ramp protocol** is one of the
most common ways to record I–V curves. The amplifier imposes a voltage that increases
(or decreases) linearly with time. At the voltage where net current through a channel
is zero, the experimenter reads off the **reversal potential** $E_{rev}$.

This model performs that experiment *in silico*: `V_m` is driven by a linear
equation (not by a real amplifier), and the GHK current equation is evaluated
algebraically at each instant. Because there are **no differential equations**, the
simulation is purely algebraic — essentially a parametric plot of $I_{GHK}$ vs $V_m$.

### What changed from Step08

| Feature | Step08 | Step09 |
|---|---|---|
| Voltage | Fixed (one value) | Ramp −100 → +60 mV over 500 ms |
| Output | Scalar $E_{rev}$ | Full I–V curve |
| GHK evaluated? | No (only Nernst) | Yes — $J_{GHK}(V_m, t)$ |
| Ohmic comparison | No | Yes — `I_ohm` variable |
| Model type | Algebraic (0 states) | Algebraic (0 states) |

---

## 2. Equivalent Circuit

Because this model is purely algebraic (no capacitor, no resistor network), the
"circuit" is best described as a **current source controlled by membrane voltage**:

```
 ┌─────────────────────────────────────────────────────────────┐
 │                     Membrane patch                          │
 │                                                             │
 │   V_start ─────────────── ramp ─────────────── V_end        │
 │   (−100 mV)            V_m(t)                (+60 mV)       │
 │                           │                                 │
 │                    ┌──────┴──────┐                          │
 │                    │  GHK channel│  ← permeability P        │
 │                    │  (ion: z,   │     valence z            │
 │                    │   c_in,     │     area A               │
 │                    │   c_out, T) │                          │
 │                    └──────┬──────┘                          │
 │                           │                                 │
 │                      I_ghk (A)   ← positive = outward       │
 │                                                             │
 │   [comparison]  I_ohm = G_ohm × (V_m − E_rev)              │
 └─────────────────────────────────────────────────────────────┘
```

### Component table

| Symbol | Default value | Physical meaning |
|---|---|---|
| $V_{start}$ | −100 mV | Start voltage of ramp |
| $V_{end}$ | +60 mV | End voltage of ramp |
| $t_{ramp}$ | 500 ms | Ramp duration |
| $z$ | 1 | Ionic valence (K⁺ = 1) |
| **$P$** | **1 × 10⁻⁸ m/s** | **Membrane permeability (new concept)** |
| $c_{in}$ | 140 mM | Intracellular ion concentration |
| $c_{out}$ | 5 mM | Extracellular ion concentration |
| $A$ | 1000 µm² = 1×10⁻⁹ m² | Membrane area |
| $T$ | 310.15 K (37 °C) | Temperature (`PatchClamp.Constants.T_body`) |

**Bold** entries are introduced for the first time in this model.

---

## 3. Key Parameters and Equations

### 3.1 Ramp voltage

The membrane voltage is driven by a simple linear equation:

$$V_m(t) = V_{start} + (V_{end} - V_{start}) \cdot \frac{t}{t_{ramp}}$$

With default values:

$$V_m(t) = -0.100 + \frac{0.160}{0.500}\, t = -0.100 + 0.320\, t \quad [\text{V}]$$

At $t = 0$: $V_m = -100\,\text{mV}$; at $t = 500\,\text{ms}$: $V_m = +60\,\text{mV}$.

### 3.2 GHK current density

The **Goldman–Hodgkin–Katz current equation** for a monovalent cation ($z = 1$) is:

$$J_{GHK} = P \cdot z^2 \cdot \frac{F^2 V_m}{RT} \cdot \frac{c_{in} - c_{out}\,e^{-zFV_m/RT}}{1 - e^{-zFV_m/RT}}$$

where:
- $F = 96{,}485\,\text{C/mol}$ (Faraday constant)
- $R = 8.314\,\text{J/(mol·K)}$ (gas constant)
- $T = 310.15\,\text{K}$

**Thermal voltage:** $V_T = RT/(zF) = 8.314 \times 310.15 / 96{,}485 \approx 26.7\,\text{mV}$

**Limit at $V_m = 0$ (L'Hôpital):**

$$J_{GHK}(V_m = 0) = P \cdot z \cdot F \cdot (c_{in} - c_{out})$$

Substituting default K⁺ values:

$$J_{GHK}(0) = 1\times10^{-8} \times 1 \times 96{,}485 \times (140 - 5) = 1\times10^{-8} \times 96{,}485 \times 135$$

$$J_{GHK}(0) \approx 0.1303\,\text{A/m}^2 \quad (= 130.3\,\text{mA/m}^2)$$

**Total current at $V_m = 0$:**

$$I_{GHK}(0) = J_{GHK}(0) \times A = 0.1303 \times 1\times10^{-9} = 1.303\times10^{-10}\,\text{A} \approx 130\,\text{pA}$$

Because $c_{in} > c_{out}$, this current is **outward** (positive) — K⁺ leaves the cell.

### 3.3 Nernst / reversal potential

The reversal potential equals the Nernst potential:

$$E_{rev} = E_K = \frac{RT}{zF} \ln\frac{c_{out}}{c_{in}} = V_T \ln\frac{5}{140}$$

$$E_{rev} = 0.0267 \times \ln(0.03571) = 0.0267 \times (-3.332) \approx -89.0\,\text{mV}$$

This is the voltage at which $I_{GHK} = 0$ on the simulated I–V curve.

### 3.4 Equivalent ohmic conductance

The model defines an equivalent chord conductance anchored at $V_m = 0$:

$$G_{ohm} = \frac{|I_{GHK}(0)|}{|E_{rev}|} = \frac{130\,\text{pA}}{89.0\,\text{mV}} \approx 1.46\,\text{nS}$$

The ohmic comparison current is then:

$$I_{ohm} = G_{ohm} \cdot (V_m - E_{rev})$$

**This is a straight line through $(E_{rev},\, 0)$.** The difference $I_{GHK} - I_{ohm}$ reveals the rectification imposed by the concentration gradient alone.

### 3.5 Summary of calculated quantities (K⁺ defaults)

| Quantity | Formula | Default value |
|---|---|---|
| Thermal voltage $V_T$ | $RT/F$ | 26.7 mV (37 °C) |
| Reversal potential $E_{rev}$ | $(V_T)\ln(c_{out}/c_{in})$ | −89.0 mV |
| $J_{GHK}(V_m = 0)$ | $P \cdot F \cdot (c_{in}-c_{out})$ | +130.3 mA/m² |
| $I_{GHK}(V_m = 0)$ | $J_{GHK}(0) \cdot A$ | +130 pA |
| $G_{ohm}$ | $I_{GHK}(0) / |E_{rev}|$ | 1.46 nS |
| $I_{GHK}$ at $V_m = +60\,\text{mV}$ | evaluate GHK | ~+315 pA (outward) |
| $I_{GHK}$ at $V_m = -100\,\text{mV}$ | evaluate GHK | ~−1380 pA (inward) |

> **Note on sign convention:** positive current = outward (cation leaving the cell).

---

## 4. Expected Signals

### 4.1 Variables to plot

| Variable | Axis role | Expected scale | Description |
|---|---|---|---|
| `time` | X (time plot) | 0–500 ms | Simulation time |
| `V_m` | X (I–V plot) or Y (time plot) | −100 to +60 mV | Linear ramp |
| `I_ghk` | Y (I–V plot) | −1500 to +400 pA | GHK current — nonlinear, crosses 0 at $E_{rev}$ |
| `J_ghk` | Y (optional) | −1.5 to +0.4 A/m² | Current density (area-normalised) |
| `E_rev` | Y (time plot, constant) | −89 mV | Nernst potential — flat horizontal line |
| `I_ohm` | Y (I–V plot) | same range as I_ghk | Ohmic equivalent — straight line through $E_{rev}$ |
| `G_ohm` | Y (time plot, constant) | ~1.46 nS | Chord conductance — flat |

### 4.2 What to expect — I–V curve (I\_ghk vs V\_m)

```
 I_ghk (pA)
    ^
+400|                                         /  ← GHK (curved)
    |                                       /
+200|                                     /   .......  ← Ohmic (straight)
    |                                   /  ....
  0 |──────────────────────── X ──────/──────────────→  V_m (mV)
    |                        ↑      /  ....
    |                    E_rev    /  ..
    |                  (−89 mV)  /
-500|                           /
    |                 /        ← GHK much larger inward current
    |               /            than ohmic (rectification)
-1000|             /
    |           /
-1380|_________/
        -100   -60    -20    0   +20  +60
```

Key observations:
- The curve crosses I = 0 at exactly $V_m = E_{rev} \approx -89\,\text{mV}$.
- Inward current (negative, $V_m < E_{rev}$) is **much larger in magnitude** than the outward current at the same $|V - E_{rev}|$.
- This asymmetry is **intrinsic rectification** — the channel is more permeable in the inward direction because $c_{in} \gg c_{out}$.
- `I_ohm` is a straight line through the same zero-crossing but is symmetrical around $E_{rev}$.

### 4.3 Variables as functions of time

| Variable | Shape | Notes |
|---|---|---|
| `V_m` | Rising straight line, −100 → +60 mV | Ramp |
| `I_ghk` | Nonlinear S-shaped curve crossing 0 | Zero at t ≈ 342 ms when $V_m = E_{rev}$ |
| `E_rev` | Horizontal constant at −89 mV | Independent of voltage |
| `I_ohm` | Nearly linear, but not identical to I_ghk | Diverges most near the extremes |

---

## 5. Step-by-Step Simulation Guide

### 5.1 Open and verify the model

1. Launch **OMEdit** and open the `PatchClamp` library.
2. Navigate to `PatchClamp → Examples → Step09_GHKReversalPotential`.
3. Double-click to open. Confirm the parameters in the **Parameters** pane:
   - `V_start = -0.100` V, `V_end = 0.060` V, `t_ramp = 0.500` s
   - `z = 1`, `P = 1e-8` m/s, `c_in = 140`, `c_out = 5` mM
   - `A = 1000e-12` m², `T = 310.15` K

### 5.2 Configure the simulation

4. Open **Simulation → Simulation Setup** (or press F5).
5. Set:
   - **Stop Time:** `0.5` s
   - **Interval:** `5e-4` s (500 µs → 1001 data points)
   - **Tolerance:** `1e-8`
   - **Solver:** DASSL (default) or Euler (both work — no ODEs present)
6. Click **Simulate**.

### 5.3 Plot the I–V curve (most important)

7. In the **Variables Browser**, check `I_ghk`.
8. The default plot shows `I_ghk` vs `time`. To convert to an I–V curve:
   - Right-click the plot area → **Change X-Axis Variable** → select `V_m`.
9. Also add `I_ohm` to the same plot (check its box in the Variables Browser).
10. **Expected result:** Two curves sharing the same zero-crossing at $V_m \approx -89\,\text{mV}$. `I_ghk` is strongly curved (larger inward, smaller outward); `I_ohm` is a straight line.

### 5.4 Verify the reversal potential

11. Add `E_rev` to a time-domain plot — it should be a **flat constant** at approximately −0.089 V (−89 mV).
12. Zoom into the region around $t \approx 340\,\text{ms}$ in the `I_ghk` vs time plot. The current crosses zero here; verify that $V_m$ at that instant equals `E_rev`.

### 5.5 Zoom windows of interest

| Time window | What to observe |
|---|---|
| 0 – 500 ms | Full ramp; full I–V sweep |
| 300 – 380 ms | Zero-crossing region ($V_m$ near $E_{rev}$) |
| 0 – 50 ms | Inward current at most negative voltages |
| 430 – 500 ms | Outward current plateau |

### 5.6 XY plot tip

If OMEdit does not offer axis-swap directly, you can export results to CSV and plot `I_ghk` vs `V_m` in Python/MATLAB. Alternatively, the model's `Documentation` block contains guidance for OMEdit's plot menu.

---

## 6. Series Comparison Table

| Model | Driving force | Key resistance | Key capacitance | Visible τ | $I_{steady}$ |
|---|---|---|---|---|---|
| Step05 | Step current clamp | $R_{access}$ = 10 MΩ, $R_m$ = 500 MΩ | $C_m$ = 30 pF | $\tau \approx R \cdot C \approx 1\,\text{ms}$ | $V_{ss} = I \cdot R_m$ |
| Step06 | HH conductances (squid) | $g_{Na}$, $g_K$ (variable) | $C_m$ = 1 µF/cm² | AP ~1 ms | −65 mV resting |
| Step08 | Nernst (algebraic) | N/A | N/A | N/A (static) | N/A |
| **Step09** | **Voltage ramp (−100→+60 mV)** | **GHK permeability** $P$ | **None** | **N/A (algebraic)** | **$I=0$ at $E_{rev}$** |

> **Key distinction:** Step09 is purely algebraic — it generates not a single current value
> but an **entire I–V relationship** in one simulation. There is no time constant,
> no capacitor, and no differential equation.

---

## 7. Exercises

### Exercise 1 — Parameter sweep: extracellular K⁺ concentration (hyperkalemia)

**Background:** Clinical hyperkalemia (elevated plasma K⁺) depolarises cells by shifting $E_K$ toward 0 mV.

**Tasks:**

1. Using the Nernst equation, **predict** $E_{rev}$ for $c_{out}$ = 5, 10, 25, 50 mM (keep $c_{in}$ = 140 mM, $T$ = 310.15 K). Fill in the table:

   | $c_{out}$ (mM) | $E_{rev}$ predicted (mV) |
   |---|---|
   | 5 | −89.0 mV (default) |
   | 10 | ? |
   | 25 | ? |
   | 50 | ? |

   Formula: $E_{rev} = 26.7 \times \ln(c_{out}/140)$ mV

2. For each value of $c_{out}$, **simulate** Step09 and read the zero-crossing of `I_ghk` from the I–V curve. Compare with your predictions.

3. At $c_{out}$ = 50 mM (severe hyperkalemia), what happens to the amplitude of the inward current at $V_m = -100\,\text{mV}$? Does it increase or decrease? Explain using the GHK equation.

4. **Clinical reflection:** Muscle cells at rest sit near $E_K$. If $E_K$ shifts from −89 mV to −27 mV, describe what happens to resting membrane potential and why this can cause cardiac arrhythmias.

---

### Exercise 2 — Signal dissection: Na⁺ channel I–V curve

**Background:** The Na⁺ driving force is opposite to K⁺ ($c_{out} \gg c_{in}$), giving a positive reversal potential.

**Tasks:**

1. Change parameters to model a Na⁺ channel: `z = 1`, `c_in = 10` mM, `c_out = 145` mM, `P = 4e-10` m/s.

2. **Before simulating**, calculate:
   - $E_{rev}^{Na}$ using the Nernst equation
   - $J_{GHK}(0)$ using the L'Hôpital limit
   - $I_{GHK}(0) = J_{GHK}(0) \times A$

3. Simulate and plot `I_ghk` vs `V_m`. Identify:
   - The zero-crossing voltage (compare with your prediction)
   - The direction of current at $V_m = -70\,\text{mV}$ (resting potential): is it inward or outward? Why?
   - The asymmetry of the curve: now $c_{out} \gg c_{in}$, so which direction shows larger current?

4. On the same graph, overlay `I_ohm`. Where does the GHK curve deviate most from the ohmic line?

---

### Exercise 3 — Error analysis: ohmic approximation error

**Background:** Many textbooks treat ion channels as simple ohmic resistors ($I = G \cdot (V - E_{rev})$). This exercise quantifies the error of that approximation.

**Tasks:**

1. For the default K⁺ configuration, export or read from the simulation the values of `I_ghk` and `I_ohm` at the following voltages: −100, −60, −30, 0, +30, +60 mV.

2. Calculate the **relative error** of the ohmic approximation:

   $$\text{Error}(\%) = \frac{I_{ohm} - I_{GHK}}{|I_{GHK}|} \times 100$$

   Fill in the table:

   | $V_m$ (mV) | $I_{GHK}$ (pA) | $I_{ohm}$ (pA) | Error (%) |
   |---|---|---|---|
   | −100 | | | |
   | −60 | | | |
   | 0 | | | |
   | +30 | | | |
   | +60 | | | |

3. At which voltages is the ohmic approximation most accurate? At which is it worst?

4. **Discussion:** In a Hodgkin–Huxley model (Step06), the K⁺ current is written as $I_K = g_K \cdot (V - E_K)$, i.e., the ohmic form. Based on your error analysis, under what conditions is this a reasonable simplification for action potential modelling?

---

### Exercise 4 — Estimation: recover $P$ from simulated data

**Background:** In a real experiment, you would measure an I–V curve and recover the permeability $P$ from the data.

**Tasks:**

1. Run the simulation with default K⁺ parameters. Note the simulated value of `I_ghk` at $V_m = 0$ from the output (or read it as `I_ghk` at $t \approx 312.5\,\text{ms}$ when $V_m = 0$).

2. Using the L'Hôpital GHK limit:

   $$I_{GHK}(0) = P \cdot z \cdot F \cdot (c_{in} - c_{out}) \cdot A$$

   rearrange to solve for $P$:

   $$P = \frac{I_{GHK}(0)}{z \cdot F \cdot (c_{in} - c_{out}) \cdot A}$$

3. Substitute your simulated $I_{GHK}(0)$ into the formula and verify you recover $P = 1 \times 10^{-8}$ m/s.

4. **Experimental context:** In a real patch-clamp experiment, $c_{in}$ and $c_{out}$ are set by the solutions used, $A$ is estimated from capacitance ($C_m = C_{sp} \cdot A$, with $C_{sp} \approx 1\,\mu\text{F/cm}^2$), and $I_{GHK}(0)$ is read from the I–V curve. What sources of error would affect this $P$ estimate in practice?

---

### Exercise 5 — Conceptual: temperature and the GHK equation

**Background:** Both $E_{rev}$ and the shape of the GHK curve depend on temperature through the thermal voltage $V_T = RT/F$.

**Tasks:**

1. Calculate $V_T$ at 20 °C (293.15 K) and 37 °C (310.15 K).

2. **Predict** how $E_{rev}$ for K⁺ changes between these two temperatures. The shift is small — calculate it precisely.

3. The GHK equation contains $V_T$ in both numerator and denominator exponents. At higher temperature, does the I–V curve become more or less curved? Reason from the equation without simulating.

4. Simulate Step09 with `T = 293.15` and then `T = 310.15`. Compare:
   - $E_{rev}$ in both cases (check the `E_rev` variable)
   - The peak inward current at $V_m = -100\,\text{mV}$
   - The slope of `I_ohm` (which reflects $G_{ohm}$)

5. **Discussion:** In a warm-blooded mammal, does body temperature regulation have electrophysiological consequences? What would happen to $E_K$ and neuronal excitability if body temperature fell by 5 °C (hypothermia)?

---

### Exercise 6 — Synthesis: GHK reversal potentials across the series (Step08 → Step09 → Step06)

**Background:** Across the tutorial series, reversal potentials have appeared in three different contexts with subtly different values.

**Tasks:**

1. **Tabulate the reversal potentials** encountered so far:

   | Model | Ion | $c_{in}$ (mM) | $c_{out}$ (mM) | $T$ (K) | $E_{rev}$ computed (mV) |
   |---|---|---|---|---|---|
   | Step08 | K⁺ | 140 | 5 | 310.15 | ? |
   | Step09 (default) | K⁺ | 140 | 5 | 310.15 | ? |
   | Step06 (HH, squid) | K⁺ | — | — | 279.45* | −12 mV* |

   *HH uses a fixed $E_K = -12\,\text{mV}$ referenced to resting potential in squid, equivalent to absolute $\approx -77\,\text{mV}$ at 6.3 °C (279.45 K) with squid concentrations $c_{in} \approx 400\,\text{mM}$, $c_{out} \approx 20\,\text{mM}$.

2. Calculate the Nernst potential for squid K⁺ at 6.3 °C (279.45 K) with $c_{in} = 400\,\text{mM}$, $c_{out} = 20\,\text{mM}$:

   $$E_K^{squid} = \frac{R \cdot 279.45}{F} \ln\frac{20}{400} = ?$$

   Compare with the HH value used in Step06. Discuss any discrepancy (hint: HH values are empirical fits, not exact Nernst predictions).

3. Using Step09, set parameters to **squid conditions** ($z = 1$, $c_{in} = 400$, $c_{out} = 20$, `T = 279.45`). Simulate and read $E_{rev}$ from the I–V curve. Does the GHK zero-crossing match the Nernst prediction from step 2?

4. **Conceptual question:** In Step06, the HH model uses the ohmic form $I_K = g_K(V - E_K)$. You have now seen (Exercise 3) that the ohmic approximation has errors up to tens of percent at extreme voltages. Why did Hodgkin and Huxley use ohmic conductances rather than GHK currents, and what are the limitations of each approach?

5. Write a two-paragraph synthesis connecting Step08 (Nernst equilibrium), Step09 (GHK I–V curve), and Step06 (HH action potential model): explain the chain of reasoning from ion concentrations → equilibrium potentials → driving forces → action potential generation.

---

## 8. Summary Parameter Table

| Quantity | Formula | Default value (K⁺) |
|---|---|---|
| Ramp start $V_{start}$ | — | −100 mV |
| Ramp end $V_{end}$ | — | +60 mV |
| Ramp duration $t_{ramp}$ | — | 500 ms |
| Ion valence $z$ | — | 1 (K⁺) |
| Permeability $P$ | — | 1 × 10⁻⁸ m/s |
| Intracellular $c_{in}$ | — | 140 mM |
| Extracellular $c_{out}$ | — | 5 mM |
| Membrane area $A$ | — | 1000 µm² = 1 × 10⁻⁹ m² |
| Temperature $T$ | `PatchClamp.Constants.T_body` | 310.15 K (37 °C) |
| Thermal voltage $V_T$ | $RT/F$ | 26.7 mV |
| Reversal potential $E_{rev}$ | $(V_T)\ln(c_{out}/c_{in})$ | −89.0 mV |
| GHK density at $V_m=0$ | $P \cdot z \cdot F \cdot (c_{in}-c_{out})$ | +130.3 mA/m² |
| Total GHK current at $V_m=0$ | $J_{GHK}(0) \cdot A$ | +130 pA (outward) |
| Ohmic conductance $G_{ohm}$ | $I_{GHK}(0) / |E_{rev}|$ | 1.46 nS |
| Stop time | experiment annotation | 500 ms |
| Interval | experiment annotation | 0.5 ms |
| Tolerance | experiment annotation | 1 × 10⁻⁸ |
| Model type | — | Purely algebraic (0 ODEs) |

---

### Ion reference table (from model documentation)

| Ion | $z$ | $c_{in}$ (mM) | $c_{out}$ (mM) | $P$ (m/s) | $E_{rev}$ (approx) | Physiological context |
|---|---|---|---|---|---|---|
| K⁺ (default) | 1 | 140 | 5 | 1 × 10⁻⁸ | −89 mV | Neuronal resting potential |
| K⁺ hyperkalemia | 1 | 140 | 50 | 1 × 10⁻⁸ | −27 mV | Clinical hyperkalemia |
| Na⁺ | 1 | 10 | 145 | 4 × 10⁻¹⁰ | +70 mV | Na⁺ driving force (AP) |
| Ca²⁺ | 2 | 0.0001 | 2 | 1 × 10⁻¹¹ | +122 mV | Ca²⁺ driving force |
| Cl⁻ | −1 | 10 | 110 | 4.5 × 10⁻⁹ | −65 mV | Inhibitory potential (GABA) |

---

*This tutorial is part of the PatchClamp simulation series.*
*Cross-references:*
- *Preceding model: **Step08** — static Nernst potential (algebraic equilibrium calculation)*
- *Following model: **Step10** — two-compartment GHK model with explicit intra/extracellular spaces*
- *Related: **Step06** — Hodgkin–Huxley action potential (uses ohmic K⁺/Na⁺ currents whose driving forces are grounded in Step08/Step09)*
