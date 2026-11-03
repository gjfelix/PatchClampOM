# Tutorial: Step11_GHK_IVCurve — Multi-Ion GHK I–V Curve via Voltage-Clamp Ramp Protocol

**Model path:** `PatchClamp.Examples.Step11_GHK_IVCurve`
**Recommended stop time:** 500 ms | **Interval:** 1 ms | **Tolerance:** 1 × 10⁻⁸
**Solver:** default (DASSL)

---

> **Relationship to prior models.**
> Step10 introduced two explicit ionic compartments and computed all four Nernst
> potentials plus the Goldman resting potential in open-circuit conditions
> (no external voltage imposed, $I_{total} = 0$, $V_m = V_{Goldman}$).
> Step11 now connects a **RampVoltageSource** amplifier to those same two compartments
> and the same `GoldmanMembrane` block, switching the experiment from open-circuit
> (What voltage does the cell rest at?) to **voltage clamp** (What current does the
> membrane produce at each imposed voltage?). The result is a complete multi-ion
> GHK I–V curve whose zero-crossing — the **reversal potential** — coincides
> exactly with $V_{Goldman}$ from Step10 and with the single-ion reversal potentials
> from Step08 and Step09.

---

## Learning Objectives

By the end of this tutorial, the student will be able to:

1. Explain the difference between open-circuit resting state (Step10) and voltage-clamp ramp protocol (Step11), and identify which circuit element changes between the two models.
2. Generate a multi-ion GHK I–V curve in OMEdit using a parametric (XY) plot of `membrane.I_total` vs `membrane.V_m`, and read the reversal potential from the zero-crossing.
3. Dissect the total GHK current into its four ionic components ($I_K$, $I_{Na}$, $I_{Cl}$, $I_{Ca}$) and identify the dominant contributor at each membrane voltage region.
4. Verify that blocking all but one permeability reduces the multi-ion reversal potential to the Nernst potential of that ion (validation checks G-1, G-2, G-3).
5. Predict how a change in extracellular ion concentration (e.g., hyperkalemia) shifts the zero-crossing of the I–V curve, and connect this to the resting potential shift observed in Step10.

---

## 1. Context

### Where this model fits in the series

| Step | Model | Experiment type | Question answered |
|---|---|---|---|
| Passive RC cell | Step05 | Current clamp | How does the pipette charge the membrane? |
| Active AP | Step06 | Current clamp | How do HH conductances generate a spike? |
| Single-ion equilibrium | Step08 | Algebraic | What voltage does one ion species impose? |
| GHK I–V (one ion) | Step09 | Voltage-clamp ramp (1 ion) | What current flows through one GHK channel at each voltage? |
| Two-compartment resting state | Step10 | Open-circuit (no clamp) | What are all four $E_{ion}$ and the resting $V_m$? |
| **Multi-ion I–V curve (this model)** | **Step11** | **Voltage-clamp ramp (4 ions)** | **What is the total GHK current at each imposed voltage?** |

### Physical setup

In a **voltage-clamp ramp** experiment, the patch-clamp amplifier forces the membrane
voltage to follow a pre-programmed linear trajectory while simultaneously recording
the current it must supply to maintain that voltage. The recorded current equals the
ionic current through the membrane (with opposite sign: the amplifier injects what
the membrane would otherwise lose).

This model implements that protocol exactly: `vClamp` (a `RampVoltageSource`)
imposes $V_m(t)$ from −100 mV to +60 mV over 500 ms, and `membrane` (the same
`GoldmanMembrane` block as Step10) returns the four GHK currents and their sum
`I_total` at each instant.

### The critical difference from Step10

| Feature | Step10 | Step11 |
|---|---|---|
| External circuit | `membrane_p` floating; only `gnd` on `membrane_n` | `vClamp` connected between `membrane_p` and `membrane_n` |
| $V_m$ | Endogenous — solver finds the root of $I_{total} = 0$ | Exogenous — imposed by `vClamp` ramp |
| $I_{total}$ | Zero by definition (open circuit) | Non-zero; the quantity of interest |
| Answers | "At what voltage does the cell rest?" | "How much current flows at each voltage?" |
| Same blocks? | Yes — `int_sol`, `ext_sol`, `membrane` identical | Yes — only `vClamp` and its connections are new |

This is the same distinction that separates a **current clamp** (Step05, Step06) from
a **voltage clamp** in real electrophysiology: the experimenter either injects
current and observes voltage, or controls voltage and observes current.

---

## 2. Equivalent Circuit

```
  ┌───────────────────────────────────────────────────────────────────────────┐
  │               Step11_GHK_IVCurve — voltage-clamp ramp circuit                 │
  │                                                                           │
  │   INTRACELLULAR              MEMBRANE                   EXTRACELLULAR     │
  │   (int_sol / pipette)   (GoldmanMembrane)               (ext_sol / bath) │
  │                                                                           │
  │   [K+]  = 140 mM  ──── P_K   = 1.00×10⁻⁸ m/s ───── [K+]  =   5 mM     │
  │   [Na+] =  10 mM  ──── P_Na  = 4.00×10⁻¹⁰ m/s ──── [Na+] = 145 mM     │
  │   [Cl-] =  10 mM  ──── P_Cl  = 4.50×10⁻⁹ m/s ───── [Cl-] = 110 mM     │
  │   [Ca²+]= 0.0001 mM ── P_Ca  = 1.00×10⁻¹¹ m/s ──── [Ca²+]=   2 mM     │
  │   T = 310.15 K                                                            │
  │                                                                           │
  │         membrane_p ──────────────────────── membrane_n ── gnd (0 V)      │
  │               │                                  │                        │
  │         ┌─────┴─────┐                      ┌────┴────┐                   │
  │         │  vClamp   │  V_ramp(t)           │  GHK   │ → I_K, I_Na,      │
  │         │ RampVolt. │ ─────────────────→   │ membrane│   I_Cl, I_Ca      │
  │         │  Source   │                      │         │ → I_total          │
  │         └─────┬─────┘                      └────┬────┘                   │
  │               │                                  │                        │
  │         vClamp.n ──────────────────────── membrane_n ── gnd (0 V)        │
  │                                                                           │
  │   V_m(t) = V_start + (V_end − V_start)·t/t_ramp                         │
  │          = −0.100 + 0.320·t   [V]                                        │
  │                                                                           │
  │   Ramp:  −100 mV ──────────────────────────────→ +60 mV                 │
  │           t = 0 s                              t = 0.5 s                  │
  └───────────────────────────────────────────────────────────────────────────┘
```

### Kirchhoff connections

| `connect()` statement | Physical meaning |
|---|---|
| `vClamp.p → membrane.membrane_p` | Amplifier positive terminal → intracellular node |
| `vClamp.n → membrane.membrane_n` | Amplifier negative terminal → extracellular node |
| `gnd.p → membrane.membrane_n` | Bath electrode fixes extracellular voltage to 0 V |

Because both `vClamp.n` and `gnd.p` connect to `membrane.membrane_n`, the node
equation gives $V_{membrane\_n} = 0\,\text{V}$, and therefore $V_m = V_{membrane\_p}
= V_{ramp}(t)$ at all times.

### Component table

| Symbol | Default value | Physical meaning |
|---|---|---|
| `int_sol.c_K` | 140 mM | Intracellular K⁺ |
| `int_sol.c_Na` | 10 mM | Intracellular Na⁺ |
| `int_sol.c_Cl` | 10 mM | Intracellular Cl⁻ |
| `int_sol.c_Ca` | 0.0001 mM | Intracellular Ca²⁺ |
| `ext_sol.c_K` | 5 mM | Extracellular K⁺ |
| `ext_sol.c_Na` | 145 mM | Extracellular Na⁺ |
| `ext_sol.c_Cl` | 110 mM | Extracellular Cl⁻ |
| `ext_sol.c_Ca` | 2 mM | Extracellular Ca²⁺ |
| $P_K$ | 1.00 × 10⁻⁸ m/s | K⁺ membrane permeability |
| $P_{Na}$ | 4.00 × 10⁻¹⁰ m/s | Na⁺ membrane permeability |
| $P_{Cl}$ | 4.50 × 10⁻⁹ m/s | Cl⁻ membrane permeability |
| $P_{Ca}$ | 1.00 × 10⁻¹¹ m/s | Ca²⁺ membrane permeability |
| $A$ | 1000 µm² = 1 × 10⁻⁹ m² | Membrane area |
| **`vClamp.V_start`** | **−100 mV** | **Ramp start voltage (new component)** |
| **`vClamp.V_end`** | **+60 mV** | **Ramp end voltage (new component)** |
| **`vClamp.t_ramp`** | **500 ms** | **Ramp duration (new component)** |
| $T$ | 310.15 K (37 °C) | Temperature |

**Bold** entries are the new `RampVoltageSource` parameters, which replace the
open-circuit condition of Step10.

---

## 3. Key Parameters and Equations

### 3.1 Ramp voltage (imposed by vClamp)

$$V_m(t) = V_{start} + (V_{end} - V_{start})\cdot\frac{t}{t_{ramp}}
= -0.100 + \frac{0.160}{0.500}\cdot t = -0.100 + 0.320\,t \quad [\text{V}]$$

| Time | $V_m$ |
|---|---|
| $t = 0$ | −100 mV |
| $t = 125$ ms | −60 mV |
| $t = 312.5$ ms | 0 mV |
| $t \approx 359$ ms | −65 mV (≈ $V_{Goldman}$, zero-crossing) |
| $t = 500$ ms | +60 mV |

### 3.2 Individual GHK current densities

For each ion $i$ with valence $z_i$, permeability $P_i$, intracellular concentration
$c_{i,in}$, and extracellular concentration $c_{i,out}$:

$$J_i = P_i \cdot z_i^2 \cdot \frac{F^2 V_m}{RT} \cdot
\frac{c_{i,in} - c_{i,out}\,e^{-z_i F V_m / RT}}{1 - e^{-z_i F V_m / RT}}$$

Limiting form at $V_m = 0$ (L'Hôpital):

$$J_i(0) = P_i \cdot z_i \cdot F \cdot (c_{i,in} - c_{i,out})$$

**Computed at $V_m = 0$, default parameters, $T = 310.15\,\text{K}$, $F = 96{,}485\,\text{C/mol}$:**

**K⁺** ($z = 1$, $c_{in} = 140$, $c_{out} = 5$ mM):
$$J_K(0) = 1\times10^{-8} \times 1 \times 96{,}485 \times (140 - 5) = +130.3\,\text{mA/m}^2$$
$$I_K(0) = J_K(0) \times A = +130.3\,\text{mA/m}^2 \times 10^{-9}\,\text{m}^2 \approx +130\,\text{pA}$$

**Na⁺** ($z = 1$, $c_{in} = 10$, $c_{out} = 145$ mM):
$$J_{Na}(0) = 4\times10^{-10} \times 1 \times 96{,}485 \times (10 - 145) = -5.21\,\text{mA/m}^2$$
$$I_{Na}(0) \approx -5.2\,\text{pA}$$

**Cl⁻** ($z = -1$, $c_{in} = 10$, $c_{out} = 110$ mM):
$$J_{Cl}(0) = 4.5\times10^{-9} \times (-1) \times 96{,}485 \times (10 - 110) = +43.4\,\text{mA/m}^2$$

> **Sign note for Cl⁻:** With $z = -1$, both the $z$ factor and the concentration
> difference $(c_{in} - c_{out}) = (10 - 110) = -100$ are negative, so their product
> is positive — meaning Cl⁻ current at $V_m = 0$ is outward (positive by convention:
> net negative charge moves inward, equivalent to net positive current outward).

$$I_{Cl}(0) \approx +43.4\,\text{pA}$$

**Ca²⁺** ($z = 2$, $c_{in} = 0.0001$, $c_{out} = 2$ mM):
$$J_{Ca}(0) = 1\times10^{-11} \times 2 \times 96{,}485 \times (0.0001 - 2) = -3.86\,\text{mA/m}^2$$
$$I_{Ca}(0) \approx -3.9\,\text{pA}$$

### 3.3 Total current at $V_m = 0$

$$I_{total}(0) = I_K(0) + I_{Na}(0) + I_{Cl}(0) + I_{Ca}(0)$$
$$\approx +130 - 5.2 + 43.4 - 3.9 \approx +164\,\text{pA} \quad\text{(outward at } V_m = 0\text{)}$$

Because $I_{total}(0) > 0$ and the total current is zero at $V_{Goldman} \approx -65\,\text{mV}$
(more negative than 0 V), the zero-crossing is indeed negative, consistent with
the open-circuit result from Step10.

### 3.4 Reversal potential

The reversal potential $V_{rev}$ is defined implicitly by:

$$I_{total}(V_{rev}) = \sum_i I_i(V_{rev}) = 0$$

For the multi-ion GHK case with K⁺, Na⁺, and Cl⁻ (Ca²⁺ negligible), this is
solved by the Goldman voltage equation:

$$V_{rev} = V_{Goldman} = V_T \ln\frac{P_K c_{K,out} + P_{Na} c_{Na,out} + P_{Cl} c_{Cl,in}}
{P_K c_{K,in} + P_{Na} c_{Na,in} + P_{Cl} c_{Cl,out}} \approx -65\,\text{mV}$$

(Full algebra given in Step10 tutorial, Section 3.3.)

The voltage-clamp ramp **measures** this zero-crossing directly from the I–V curve,
while Step10 **predicts** it analytically. Both methods must agree.

### 3.5 GHK rectification

The GHK current is **not linear** in $V_m$ even in the absence of voltage-gated
channels. For K⁺ (with $c_{in} \gg c_{out}$):

- At large negative voltages ($V_m \ll E_K$): the exponential denominator
  $1 - e^{-FV_m/RT}$ approaches $1 + e^{F|V_m|/RT} \to e^{F|V_m|/RT}$,
  so current grows approximately exponentially → **large inward current**.
- At large positive voltages ($V_m \gg E_K$): the exponential drives toward a
  finite saturating value → **smaller outward current** relative to the same
  $|V - E_K|$ on the negative side.

This asymmetry — larger inward than outward current at equal $|V - E_{rev}|$ — is
**intrinsic GHK rectification** (also called Goldman-Katz rectification), distinct
from rectification caused by voltage-gated channels.

### 3.6 Summary of key quantities

| Quantity | Formula / value |
|---|---|
| $V_m(t)$ | $-0.100 + 0.320\,t$ V |
| Ramp slope | $0.320$ V/s = $320$ mV/s |
| $t$ when $V_m = E_K$ (−89 mV) | $(−0.089 + 0.100)/0.320 = 34\,\text{ms}$ |
| $t$ when $V_m = V_{Goldman}$ (−65 mV) | $(−0.065 + 0.100)/0.320 \approx 109\,\text{ms}$ |
| $t$ when $V_m = 0$ | $0.100/0.320 = 312.5\,\text{ms}$ |
| $I_K(0)$ | +130 pA |
| $I_{Na}(0)$ | −5.2 pA |
| $I_{Cl}(0)$ | +43.4 pA |
| $I_{Ca}(0)$ | −3.9 pA |
| $I_{total}(0)$ | ≈ +164 pA |
| $V_{rev}$ (multi-ion) | ≈ −65 mV (= $V_{Goldman}$ from Step10) |
| $V_{rev}$ (K⁺ only, G-1 check) | ≈ −89 mV (= $E_K$ from Step10/Step08) |

---

## 4. Expected Signals

### 4.1 Variables to plot

| Variable | Recommended plot | Expected scale | Description |
|---|---|---|---|
| `membrane.V_m` | X-axis of I–V plot; or Y vs time | −100 to +60 mV | Imposed ramp voltage |
| `membrane.I_total` | Y-axis of I–V plot; or Y vs time | −2000 to +500 pA | Sum of all four GHK currents |
| `membrane.I_K` | Overlay on I–V plot | −1500 to +400 pA | K⁺ GHK current (dominant) |
| `membrane.I_Na` | Overlay on I–V plot | −10 to +25 pA | Na⁺ GHK current (small) |
| `membrane.I_Cl` | Overlay on I–V plot | −150 to +100 pA | Cl⁻ GHK current |
| `membrane.I_Ca` | Overlay on I–V plot | −5 to +1 pA | Ca²⁺ GHK current (tiny) |
| `membrane.V_Goldman` | Horizontal reference line | −65 mV | Predicted zero-crossing |
| `membrane.E_K` | Horizontal reference | −89 mV | K⁺ Nernst potential |
| `membrane.E_Na` | Horizontal reference | +71 mV | Na⁺ Nernst potential |
| `membrane.E_Cl` | Horizontal reference | −64 mV | Cl⁻ Nernst potential |
| `membrane.E_Ca` | Horizontal reference | +132 mV | Ca²⁺ Nernst potential |
| `vClamp.V_out` | Y vs time | −100 to +60 mV | Ramp command voltage (= $V_m$) |

### 4.2 The I–V curve: what to expect (parametric plot)

```
  I_total (pA)
       ^
  +500 |    \  ← I_K (outward K+ at +60 mV)
       |     \
  +200 |      \
       |       \
     0 |────────X──────────────────────────→  V_m (mV)
       |       ↑ \
  −200 |  V_rev  \
       |  ≈−65mV  \
  −500 |            \
       |              \
 −1000 |                \  ← total inward current
       |                  \    (mostly K+) at −100 mV
 −2000 |___________________\
     −100  −80  −60  −40  −20   0  +20  +40  +60
```

**Key observations:**
- The curve is **not a straight line** — this is GHK rectification.
- It crosses $I = 0$ at $V_m = V_{rev} \approx -65\,\text{mV}$, coinciding with $V_{Goldman}$ from Step10.
- Inward current (negative, left of $V_{rev}$) is much larger in magnitude than outward current (positive, right of $V_{rev}$) at the same $|V_m - V_{rev}|$ — because $c_{K,in} \gg c_{K,out}$ makes K⁺ influx much larger than efflux at equal electrochemical driving forces.
- $I_K$ dominates $I_{total}$ at all voltages due to $P_K \gg P_{Na}, P_{Ca}$.
- $I_{Cl}$ is the second-largest contributor and partially opposes $I_K$ on the positive-voltage side.

### 4.3 Time-domain plots

When plotted against time (not voltage), `I_total` shows:

| Time window | $V_m$ range | $I_{total}$ sign | Observation |
|---|---|---|---|
| 0 – 109 ms | −100 → −65 mV | Negative (inward) | Left of $V_{rev}$; large inward K⁺ current |
| ≈ 109 ms | −65 mV | Zero | Zero-crossing of total current |
| 109 – 500 ms | −65 → +60 mV | Positive (outward) | Right of $V_{rev}$; outward K⁺, small Na⁺/Cl⁻ |
| ≈ 312.5 ms | 0 mV | +164 pA | Computable from L'Hôpital limit (Section 3.3) |

---

## 5. Step-by-Step Simulation Guide

### 5.1 Open and verify the model

1. Launch **OMEdit** and open the `PatchClamp` library.
2. Navigate to `PatchClamp → Examples → Step11_GHK_IVCurve` and double-click to open.
3. In the diagram view, verify four blocks: `int_sol` (left), `ext_sol` (right),
   `membrane` (centre), `vClamp` (top), and `gnd` (bottom-right).
4. Confirm connections: `vClamp.p → membrane.membrane_p`;
   `vClamp.n → membrane.membrane_n`; `gnd.p → membrane.membrane_n`.
5. Double-click `vClamp` and confirm: `V_start = -0.100` V, `V_end = 0.060` V,
   `t_ramp = 0.500` s.
6. Double-click `membrane` and confirm all four permeabilities at default values.

### 5.2 Configure and run the simulation

7. Open **Simulation → Simulation Setup** (F5). Set:
   - **Stop Time:** `0.5` s
   - **Interval:** `0.001` s (1 ms → 501 points)
   - **Tolerance:** `1e-8`
   - **Solver:** DASSL
8. Click **Simulate**.

### 5.3 Generate the I–V curve (parametric plot — most important)

9. After simulation, open **Plot → Parametric Plot** (or "XY Parametric" in OMEdit).
10. Set **X-axis:** `membrane.V_m`; **Y-axis:** `membrane.I_total`.
11. The curve is the multi-ion GHK I–V relationship.
12. Add `membrane.I_K`, `membrane.I_Na`, `membrane.I_Cl`, `membrane.I_Ca` to the
    same Y-axis to see individual ion contributions.
13. **Read the reversal potential** ($V_{rev}$): zoom into the region around −70 to −55 mV
    and identify where `I_total = 0`. This should be ≈ −65 mV.

### 5.4 Validation check G-1 — single-ion K⁺

14. Double-click `membrane` → set `P_Na = 0`, `P_Cl = 0`, `P_Ca = 0`. Leave `P_K = 1e-8`.
15. Re-simulate. Generate the parametric I–V plot.
16. **Expected:** $V_{rev}$ shifts to ≈ −89 mV, matching `membrane.E_K`.
17. The curve shape is now identical to Step09 (single K⁺ channel).
18. Restore default permeabilities before proceeding.

### 5.5 Validation check G-2 — multi-ion reversal = V\_Goldman

19. With default permeabilities restored, confirm that the zero-crossing of
    `I_total` matches `membrane.V_Goldman` (read from Variables Browser).
20. **Expected:** both ≈ −65 mV, consistent with Step10.

### 5.6 Validation check G-3 — nonlinearity of I–V

21. On the parametric plot, add the ohmic reference line: a straight line
    through $(V_{rev},\, 0)$ with slope $G_{ohm}$ estimated as
    $I_{total}(0) / |V_{rev}|$ ≈ $164\,\text{pA} / 65\,\text{mV}$ ≈ 2.5 nS.
    (This can be overlaid using `membrane.I_ohm` if available, or computed externally.)
22. **Verify** that `I_total` deviates from the straight line: larger inward current
    at negative voltages, smaller outward current at positive voltages.

### 5.7 Time windows to zoom into

| Zoom window | What to observe |
|---|---|
| 0 – 50 ms ($V_m$ = −100 to −84 mV) | Peak inward current; K⁺ dominates |
| 90 – 130 ms ($V_m$ ≈ −65 mV) | Zero-crossing; $I_K + I_{Na} + I_{Cl} + I_{Ca} = 0$ |
| 290 – 330 ms ($V_m$ ≈ 0 mV) | L'Hôpital point; verify against +164 pA prediction |
| 460 – 500 ms ($V_m$ = +50 to +60 mV) | Outward current plateau; note small magnitude vs. inward |

---

## 6. Series Comparison Table

| Model | $V_m$ drive | Permeabilities / conductances | Capacitance | Visible τ | Output |
|---|---|---|---|---|---|
| Step05 | Step current clamp | $R_{access}$ = 10 MΩ, $R_m$ = 500 MΩ | $C_m$ = 30 pF | ≈ 1 ms | $V_m(t)$ exponential charging |
| Step06 | HH conductances (squid) | $g_{Na}(V,t)$, $g_K(V,t)$ | $C_m$ = 1 µF/cm² | AP ≈ 1 ms | Spike waveform |
| Step08 | None (algebraic) | N/A | N/A | N/A | Scalar $E_K(c_{out})$ |
| Step09 | Voltage ramp −100→+60 mV | GHK $P_K$ (one ion) | None | N/A | I–V curve (K⁺ only) |
| Step10 | None (open-circuit) | $P_K$, $P_{Na}$, $P_{Cl}$, $P_{Ca}$ | None | N/A | Scalar $V_{Goldman}$, $E_{ion}$ |
| **Step11** | **Voltage ramp −100→+60 mV** | **$P_K$, $P_{Na}$, $P_{Cl}$, $P_{Ca}$ (four ions)** | **None** | **N/A** | **Multi-ion I–V curve; $V_{rev}$ = $V_{Goldman}$** |

> **Key distinction:** Step11 is the first model in the series that combines
> (a) an **active voltage source** (the amplifier) with (b) a **multi-ion membrane**.
> Step09 had a voltage source but only one ion; Step10 had four ions but no voltage
> source. Step11 completes the matrix and demonstrates that $V_{Goldman}$ predicted
> algebraically in Step10 equals the $V_{rev}$ measured graphically from the I–V curve.

---

## 7. Exercises

### Exercise 1 — Parameter sweep: extracellular K⁺ and the I–V zero-crossing

**Background:** Raising extracellular [K⁺] (hyperkalemia) shifts $E_K$ toward 0 mV,
which shifts the zero-crossing of the I–V curve (observable directly in voltage clamp).

**Tasks:**

1. Using the Goldman voltage equation, **predict** $V_{rev}$ for the following
   values of `ext_sol.c_K`. Keep all other parameters at default values.

   The Goldman numerator changes only in the $P_K c_{K,out}$ term:

   $$\text{Num}(c_{K,out}) = P_K \cdot c_{K,out} + P_{Na} \cdot 145 + P_{Cl} \cdot 10$$

   $$V_{rev} = 26.7\,\text{mV} \times \ln\frac{\text{Num}(c_{K,out})}{\text{Den}}$$

   where $\text{Den} = P_K \cdot 140 + P_{Na} \cdot 10 + P_{Cl} \cdot 110 = 1.899\times10^{-6}$.

   Fill in the table:

   | `ext_sol.c_K` (mM) | Num (× 10⁻⁷) | $V_{rev}$ predicted (mV) |
   |---|---|---|
   | 5 (default) | 1.53 | −65 mV |
   | 8 | ? | ? |
   | 20 | ? | ? |
   | 50 | ? | ? |

2. **Simulate** each case. Generate the parametric I–V plot and read $V_{rev}$
   from the zero-crossing. Compare with predictions.

3. At `ext_sol.c_K = 50` mM, plot the individual currents `I_K`, `I_Na`, `I_Cl`.
   Which ion's contribution changes most? By how much does $I_K$ at $V_m = 0$ change
   compared to the default case? (Use the L'Hôpital formula: $I_K(0) = P_K F (c_{K,in} - c_{K,out}) A$.)

4. **Cross-check with Step10:** Change `ext_sol.c_K` in Step10 to 50 mM and read
   $V_{Goldman}$. Does it match the $V_{rev}$ you measured in Step11 at the same
   concentration? Should it?

---

### Exercise 2 — Signal dissection: ionic contributions to I\_total

**Background:** The total membrane current is the sum of four GHK terms. At any given
voltage, the relative contributions of K⁺, Na⁺, Cl⁻, and Ca²⁺ depend on both
permeability and concentration gradient.

**Tasks:**

1. At $V_m = -100\,\text{mV}$ (the start of the ramp), predict the sign and
   approximate magnitude of each ionic current. Use the GHK equation at
   $V_m = -100\,\text{mV}$, $z = 1$, noting that
   $e^{-FV_m/RT} = e^{+100/26.7} = e^{3.745} \approx 42.3$:

   $$J_K(-100\,\text{mV}) = P_K \cdot \frac{F^2 \cdot (-0.100)}{RT} \cdot
   \frac{140 - 5 \times 42.3}{1 - 42.3}$$

   Work through this for K⁺ and predict whether $I_K$ is inward or outward.
   (You do not need to compute Na⁺, Cl⁻, Ca²⁺ analytically — just estimate
   their sign from the direction each ion would flow at −100 mV vs. its $E_{ion}$.)

2. **Simulate** with default parameters. From the parametric plot or time-domain plot,
   read the values of `I_K`, `I_Na`, `I_Cl`, `I_Ca` at $V_m = -100\,\text{mV}$
   (i.e., at $t = 0$). Fill in the table:

   | Ion | $E_{ion}$ (mV) | $V_m - E_{ion}$ at −100 mV | Expected direction | $I$ (pA) simulated |
   |---|---|---|---|---|
   | K⁺ | −89 | ? | ? | ? |
   | Na⁺ | +71 | ? | ? | ? |
   | Cl⁻ | −64 | ? | ? | ? |
   | Ca²⁺ | +132 | ? | ? | ? |

3. At $V_m = +60\,\text{mV}$ ($t = 500\,\text{ms}$), repeat the table. Compare the
   current magnitudes at −100 mV and +60 mV. Which voltage produces larger total
   current in absolute value, and why?

4. Identify the voltage at which $I_{Cl}$ changes sign (its own reversal potential
   $E_{Cl}$). Read this from the `I_Cl` vs `V_m` parametric sub-curve and compare
   with `membrane.E_Cl` from the Variables Browser.

---

### Exercise 3 — Error analysis: series resistance artifact in voltage clamp

**Background:** In a real voltage-clamp experiment, the patch pipette has a series
resistance $R_s$ (also called $R_{access}$) of typically 5–20 MΩ. The amplifier
imposes the command voltage $V_{cmd}$ across both $R_s$ and the cell membrane, so the
actual membrane voltage is:

$$V_m^{actual} = V_{cmd} - I_{total} \cdot R_s$$

This model has no series resistance (ideal clamp). This exercise quantifies the
error that would arise if $R_s$ were not compensated.

**Tasks:**

1. From the simulation, read the maximum absolute value of `membrane.I_total`
   (this occurs at $t = 0$, $V_m = -100\,\text{mV}$). Call this $I_{max}$.

2. Compute the series-resistance voltage error for $R_s$ = 5, 10, 20 MΩ:

   $$\Delta V = I_{max} \cdot R_s$$

   | $R_s$ (MΩ) | $\Delta V$ (mV) |
   |---|---|
   | 5 | ? |
   | 10 | ? |
   | 20 | ? |

3. If the reversal potential is measured as $V_{rev}^{measured} = -65\,\text{mV}$
   under ideal clamp, and the actual membrane voltage at the zero-crossing point is
   shifted by $\Delta V = I(V_{rev}) \cdot R_s$, what is $\Delta V$ at $V_{rev}$?
   (Hint: $I_{total}(V_{rev}) \equiv 0$ by definition. What does this imply for the
   series-resistance error at the reversal potential specifically?)

4. The series-resistance error is largest far from $V_{rev}$ where $|I_{total}|$
   is largest. In which part of the I–V curve (negative or positive voltages) is
   the error largest for this K⁺-dominated membrane, and by how much does it
   distort the apparent curve shape?

5. **Discussion:** Real patch-clamp amplifiers include **series resistance
   compensation** circuits that electronically subtract $I \cdot R_s$ from the
   command voltage. What would happen to the measured I–V curve if $R_s$
   compensation were set to 100% but the estimate of $R_s$ was 10% too high?

---

### Exercise 4 — Estimation: recover permeability ratios from the I–V curve

**Background:** In a real experiment, $P_K$, $P_{Na}$, and $P_{Cl}$ are not known a
priori. The experimenter measures the reversal potential under different ionic
conditions and uses the Goldman equation to back-calculate permeability ratios.

**Tasks:**

1. From the default multi-ion simulation, note $V_{rev}^{default} \approx -65\,\text{mV}$.
   Now simulate a second condition with the Na⁺ gradient reversed:
   `ext_sol.c_Na = 10`, `int_sol.c_Na = 145` (swap intra and extra).
   Record the new $V_{rev}^{Na-rev}$.

2. In the Goldman voltage equation, write the expression for
   $V_{rev}$ in both conditions (default and Na⁺-reversed). Set up the ratio:

   $$\frac{e^{V_{rev}^{default}/V_T} \cdot \text{Den}^{default}}{e^{V_{rev}^{Na-rev}/V_T} \cdot \text{Den}^{Na-rev}}$$

   and solve for the ratio $P_K / P_{Na}$. (Keep $P_{Cl}$ as a third unknown or
   fix it to 0 for simplification.)

3. As a simpler estimation: run the **K⁺-only** check (G-1: set $P_{Na} = P_{Cl} = P_{Ca} = 0$).
   The zero-crossing gives $E_K$. Use the Nernst equation to verify that
   $E_K = 26.7\,\text{mV} \times \ln(c_{K,out}/c_{K,in})$ matches the observed
   $V_{rev}$.

4. Now vary $P_K$ across three values (0.5×, 1×, 2× the default $10^{-8}$ m/s)
   in the K⁺-only configuration. Measure $V_{rev}$ each time. Does $V_{rev}$
   change? Explain why or why not. (Hint: in the single-ion GHK, $P$ appears in
   both numerator and denominator of $I_{GHK}$ and cancels in the zero-crossing
   condition.)

---

### Exercise 5 — Conceptual: voltage clamp vs. open circuit — what the amplifier does

**Background:** The transition from Step10 (open circuit) to Step11 (voltage clamp) is
achieved by connecting `vClamp` to `membrane_p`. This exercise builds intuition for
what the amplifier current physically represents.

**Tasks:**

1. In Step10, $I_{total} = 0$ at all times (open-circuit). In Step11, $I_{total}$ is
   non-zero at all voltages except $V_{rev}$. Where does the current that flows
   through the membrane go? Trace the current path in the circuit diagram of
   Section 2: from `membrane_p` through the membrane, out `membrane_n`, through
   `gnd`, and back — via which path does current return to `membrane_p`?

2. The quantity recorded by the amplifier is $I_{clamp}$, the current it injects to
   maintain $V_m = V_{ramp}(t)$. By Kirchhoff's current law:
   $I_{clamp} + I_{total} = 0$, so $I_{clamp} = -I_{total}$. When the membrane
   produces large inward current (e.g., at $V_m = -100\,\text{mV}$), is the
   amplifier sourcing or sinking current?

3. At $V_m = V_{rev} \approx -65\,\text{mV}$, $I_{total} = 0$. What does the
   amplifier inject at this voltage? Does the cell at $V_{rev}$ behave identically
   to the open-circuit state of Step10? Explain any similarities and differences.

4. The ramp speed is 320 mV/s. If the cell had a membrane capacitance
   $C_m = 30\,\text{pF}$ (as in Step05), what capacitive current $I_C = C_m \cdot
   dV_m/dt$ would the amplifier need to supply in addition to $I_{ionic}$?
   Is this large or small compared to the GHK currents observed?

5. **Discussion:** In a real experiment, the amplifier records $I_{clamp} =
   -(I_{ionic} + I_{capacitive})$. Experimenters routinely subtract the capacitive
   component to isolate $I_{ionic}$. How would this capacitive current appear on
   the I–V curve, and what would happen to the apparent zero-crossing if it were
   not subtracted?

---

### Exercise 6 — Synthesis: connecting Step08 → Step09 → Step10 → Step11

**Background:** The four Step08 models form a progression from a single algebraic
equation to a complete voltage-clamp experiment. This exercise maps the connections
explicitly.

**Tasks:**

1. **Numerical cross-check table:** For K⁺ only (G-1 condition), extract $V_{rev}$
   from each model and verify they agree:

   | Model | Method to obtain $E_K$ / $V_{rev}$ | Value (mV) |
   |---|---|---|
   | Step08 | Nernst equation: $V_T \ln(c_{out}/c_{in})$, $c_{out}$ = 5 mM | ? |
   | Step09 | Zero-crossing of K⁺-only GHK I–V ramp | ? |
   | Step10 | `membrane.E_K` alias (Nernst inside GoldmanMembrane) | ? |
   | Step11 (G-1) | Zero-crossing with $P_{Na} = P_{Cl} = P_{Ca} = 0$ | ? |

   All four should give ≈ −89 mV. If any differ by more than 1 mV, identify the source.

2. **Multi-ion cross-check:** For the default four-ion configuration:

   | Model | Method to obtain $V_{Goldman}$ / $V_{rev}$ | Value (mV) |
   |---|---|---|
   | Step10 | `membrane.V_Goldman` (open-circuit algebraic root) | ≈ −65 mV |
   | Step11 (G-2) | Zero-crossing of `I_total` on I–V curve | ≈ −65 mV |

   Explain in one sentence why these two values must be identical in principle.

3. **From equilibrium to dynamics:** Step06 (Hodgkin–Huxley) uses fixed values
   $E_K \approx -77\,\text{mV}$ and $E_{Na} \approx +50\,\text{mV}$ (squid, absolute).
   Using Step11 in G-1 mode, find the value of `ext_sol.c_K` that gives
   $V_{rev}^{K^+} = -77\,\text{mV}$ (squid $E_K$). What extracellular [K⁺] does
   this correspond to? (Hint: Nernst equation, $c_{K,in} = 400\,\text{mM}$ for squid.)

4. **What Step11 adds over Step10:** Write a two-sentence statement (no simulation
   required) explaining what experimental information is available in Step11 that
   cannot be obtained from Step10 alone. Focus on the distinction between a scalar
   (one number) and a function (a curve).

5. **Design question:** You want to use voltage-clamp ramp to measure the Cl⁻
   reversal potential in isolation. What three permeabilities would you set to zero,
   and what would you expect $V_{rev}$ to be? Verify with a simulation and compare
   with `membrane.E_Cl` from Step10. Then explain why this experiment would be
   difficult to perform in a real patch-clamp setup (think about which ions carry
   the majority of the current and how you would eliminate them experimentally).

---

## 8. Summary Parameter Table

| Quantity | Formula / source | Default value |
|---|---|---|
| Ramp start $V_{start}$ | `vClamp.V_start` | −100 mV |
| Ramp end $V_{end}$ | `vClamp.V_end` | +60 mV |
| Ramp duration $t_{ramp}$ | `vClamp.t_ramp` | 500 ms |
| Ramp slope | $(V_{end}-V_{start})/t_{ramp}$ | 320 mV/s |
| Temperature $T$ | `PatchClamp.Constants.T_body` | 310.15 K (37 °C) |
| Thermal voltage $V_T$ | $RT/F$ | 26.7 mV |
| $P_K$ | `membrane.P_K` | 1.00 × 10⁻⁸ m/s |
| $P_{Na}$ | `membrane.P_Na` | 4.00 × 10⁻¹⁰ m/s |
| $P_{Cl}$ | `membrane.P_Cl` | 4.50 × 10⁻⁹ m/s |
| $P_{Ca}$ | `membrane.P_Ca` | 1.00 × 10⁻¹¹ m/s |
| Membrane area $A$ | `membrane.A` | 1000 µm² = 1 × 10⁻⁹ m² |
| $c_{K,in}$ / $c_{K,out}$ | `int_sol.c_K` / `ext_sol.c_K` | 140 / 5 mM |
| $c_{Na,in}$ / $c_{Na,out}$ | `int_sol.c_Na` / `ext_sol.c_Na` | 10 / 145 mM |
| $c_{Cl,in}$ / $c_{Cl,out}$ | `int_sol.c_Cl` / `ext_sol.c_Cl` | 10 / 110 mM |
| $c_{Ca,in}$ / $c_{Ca,out}$ | `int_sol.c_Ca` / `ext_sol.c_Ca` | 0.0001 / 2 mM |
| $E_K$ | $(V_T)\ln(c_{K,out}/c_{K,in})$ | −89 mV |
| $E_{Na}$ | $(V_T)\ln(c_{Na,out}/c_{Na,in})$ | +71 mV |
| $E_{Cl}$ | $(V_T/(-1))\ln(c_{Cl,out}/c_{Cl,in})$ | −64 mV |
| $E_{Ca}$ | $(V_T/2)\ln(c_{Ca,out}/c_{Ca,in})$ | +132 mV |
| $V_{rev}$ (multi-ion) | zero-crossing of $I_{total}$ = $V_{Goldman}$ | ≈ −65 mV |
| $V_{rev}$ (K⁺ only, G-1) | zero-crossing of $I_K$ = $E_K$ | ≈ −89 mV |
| $I_K(0)$ | $P_K F(c_{K,in} - c_{K,out})A$ | +130 pA |
| $I_{Na}(0)$ | $P_{Na} F(c_{Na,in} - c_{Na,out})A$ | −5.2 pA |
| $I_{Cl}(0)$ | $P_{Cl}(-1)F(c_{Cl,in} - c_{Cl,out})A$ | +43.4 pA |
| $I_{Ca}(0)$ | $P_{Ca}\cdot 2\cdot F(c_{Ca,in} - c_{Ca,out})A$ | −3.9 pA |
| $I_{total}(0)$ | $\sum_i I_i(0)$ | ≈ +164 pA |
| Stop time | experiment annotation | 500 ms |
| Interval | experiment annotation | 1 ms |
| Tolerance | experiment annotation | 1 × 10⁻⁸ |
| Model type | — | Algebraic (voltage-clamp; no ODEs, no $C_m$) |

---

*This tutorial is part of the PatchClamp simulation series.*
*Cross-references:*
- *Preceding model: **Step10** — two-compartment open-circuit model; computes $V_{Goldman}$ and all $E_{ion}$ algebraically without imposing $V_m$*
- *Preceding model: **Step09** — single-ion (K⁺) voltage-clamp ramp; the K⁺-only special case of Step11 (G-1 check)*
- *Upstream context: **Step08** — Nernst equation for a single ion; the single-ion, single-voltage special case*
- *Downstream: **Step06**, **Step15**, **Step16** — dynamic cell models whose resting conditions and driving forces are grounded in the equilibrium picture established across the Step08 series*
- *Reference: Goldman D (1943). Potential, impedance, and rectification in membranes. J Gen Physiol 27:37–60.*
