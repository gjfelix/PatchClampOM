# Physics Background

This document explains the three core equations implemented in the PatchClamp
package. The goal is to connect the math to the biology — and to the Modelica
code you can inspect in each block.

---

## 1. The Nernst Equation

### What it describes

Every ion species (K⁺, Na⁺, Cl⁻, Ca²⁺) has a **equilibrium potential** E_ion:
the membrane voltage at which the electrical force on the ion exactly cancels
its concentration gradient. At that voltage, no net ion flow occurs.

### Derivation sketch

For an ion with valence *z* crossing a membrane, the electrochemical potential
difference is zero at equilibrium:

$$\mu_\text{in} = \mu_\text{out}$$

$$RT \ln c_\text{in} + zFV_\text{in} = RT \ln c_\text{out} + zFV_\text{out}$$

Defining $V_m = V_\text{in} - V_\text{out}$ and solving:

$$\boxed{E_\text{ion} = \frac{RT}{zF} \ln \frac{c_\text{out}}{c_\text{in}}}$$

| Symbol | Meaning | Value |
|---|---|---|
| R | Universal gas constant | 8.314 J mol⁻¹ K⁻¹ |
| T | Temperature | 310.15 K (37 °C) |
| z | Ion valence | K⁺: +1, Ca²⁺: +2, Cl⁻: −1 |
| F | Faraday constant | 96485 C mol⁻¹ |
| c_out / c_in | Extra / intracellular concentration | mol m⁻³ |

### Typical values (mammalian neuron at 37 °C)

| Ion | c_in (mM) | c_out (mM) | E_ion |
|---|---|---|---|
| K⁺ | 140 | 5 | −89 mV |
| Na⁺ | 10 | 145 | +70 mV |
| Cl⁻ | 10 | 110 | −65 mV |
| Ca²⁺ | 0.0001 | 2 | +122 mV |

### Key insight — the 60 mV rule

At 37 °C, RT/F ≈ 26.7 mV. For a monovalent cation (z = 1):

$$E_\text{ion} \approx 60\,\text{mV} \times \log_{10}\frac{c_\text{out}}{c_\text{in}}$$

Every **10-fold** change in concentration ratio shifts E_ion by ~60 mV.
This is directly observable in **Step08_NernstEquilibriumPotential**.

### In the code

```modelica
// PatchClamp/Media/Functions/nernstPotential.mo
E = (R * T / (z * F)) * log(c_out / c_in);
```

---

## 2. The Goldman-Hodgkin-Katz (GHK) Equation

### What it describes

The Nernst equation assumes only one ion. In reality, several ions cross
the membrane simultaneously through their own channels. The
**Goldman-Hodgkin-Katz voltage equation** generalizes Nernst to a membrane
permeable to K⁺, Na⁺ and Cl⁻:

$$\boxed{V_m = \frac{RT}{F} \ln \frac{P_K[K]_\text{out} + P_{Na}[Na]_\text{out} + P_{Cl}[Cl]_\text{in}}{P_K[K]_\text{in} + P_{Na}[Na]_\text{in} + P_{Cl}[Cl]_\text{out}}}$$

> **Note the Cl⁻ inversion:** the in/out labels for Cl⁻ are swapped because
> it carries negative charge. This is not a typo — it follows directly from
> the GHK derivation.

### Why Cl⁻ is inverted

Starting from the GHK current equation for Cl⁻ (z = −1) and setting the
total current to zero, the sign flip of the valence reverses the logarithm
argument. The net result: high [Cl⁻]_out *hyperpolarizes* (makes E_Cl more
negative), just as high [K⁺]_out *depolarizes*.

### Resting membrane potential

With typical mammalian neuron permeabilities at rest (P_K : P_Na : P_Cl = 1 : 0.04 : 0.45):

$$V_\text{Goldman} \approx -65\,\text{mV}$$

The resting potential is dominated by K⁺ because P_K >> P_Na at rest.
During an action potential P_Na spikes transiently >> P_K, pulling V_m
toward +70 mV.

### GHK current density

For a single ion species, the GHK **current density** through the membrane is:

$$\boxed{J_\text{ion} = P_\text{ion} \cdot z^2 \cdot \frac{VF^2}{RT} \cdot \frac{c_\text{in} - c_\text{out}\,e^{-zVF/RT}}{1 - e^{-zVF/RT}}}$$

This is what each channel block computes. It predicts:
- **Inward rectification** for large negative V
- **Linear region** near the reversal potential E_rev
- **Outward saturation** for large positive V

### Numerical protection near V = 0

When V → 0, both numerator and denominator → 0 (0/0 form). The limit by
L'Hôpital's rule is:

$$J = P_\text{ion} \cdot z \cdot F \cdot (c_\text{in} - c_\text{out})$$

The code applies this approximation when |zVF/RT| < 10⁻⁶:

```modelica
// PatchClamp/Media/Functions/ghkCurrentDensity.mo
if abs(x) < 1e-6 then
  J := P * z * F * (c_in - c_out);   // L'Hopital limit
else
  J := P * z^2 * (V * F^2 / (R * T)) * (c_in - c_out * exp(-x)) / (1 - exp(-x));
end if;
```

### Observable in examples

| Example | What it shows |
|---|---|
| `Step09_GHKReversalPotential` | Full I-V curve; crossing at E_rev |
| `Step10_GoldmanRestingPotential` | Goldman V_m from all four ions simultaneously |

---

## 3. The Hodgkin-Huxley Model

### Historical context

Alan Hodgkin and Andrew Huxley recorded ionic currents from squid giant axon
in 1952 using voltage clamp — essentially the same technique this package
simulates. Their model earned the 1963 Nobel Prize in Physiology or Medicine.

### The membrane equation

$$\boxed{C_m \frac{dV_m}{dt} = -g_{Na}\,m^3 h\,(V_m - E_{Na}) - g_K\,n^4\,(V_m - E_K) - g_L\,(V_m - E_L) + \frac{I_\text{ext}}{A}}$$

| Term | Meaning |
|---|---|
| $C_m$ | Membrane capacitance (F) |
| $g_{Na}, g_K, g_L$ | Maximum conductance densities (S m⁻²) |
| $m, h$ | Na⁺ channel activation / inactivation gates |
| $n$ | K⁺ channel activation gate |
| $E_{Na}, E_K, E_L$ | Reversal potentials (from Nernst) |
| $I_\text{ext}/A$ | Applied current density |

### Gate kinetics

Each gate variable *x* ∈ {m, h, n} obeys a first-order ODE:

$$\frac{dx}{dt} = \alpha_x(V_m)(1-x) - \beta_x(V_m)\,x$$

Equivalently:

$$\frac{dx}{dt} = \frac{x_\infty(V_m) - x}{\tau_x(V_m)}$$

where $x_\infty = \alpha_x / (\alpha_x + \beta_x)$ is the steady-state value
and $\tau_x = 1/(\alpha_x + \beta_x)$ is the time constant.

### Rate functions (squid axon, HH 1952)

$$\alpha_m = \frac{0.1(V+40)}{1 - e^{-(V+40)/10}}, \quad \beta_m = 4\,e^{-(V+65)/18}$$

$$\alpha_h = 0.07\,e^{-(V+65)/20}, \quad \beta_h = \frac{1}{1 + e^{-(V+35)/10}}$$

$$\alpha_n = \frac{0.01(V+55)}{1 - e^{-(V+55)/10}}, \quad \beta_n = 0.125\,e^{-(V+65)/80}$$

*(V in mV, rates in ms⁻¹; original HH convention with V positive inside = shifted)*

### Action potential sequence

1. **Depolarizing stimulus** → V_m rises above threshold (~−55 mV)
2. **Na⁺ activation** (fast): *m* gates open → inward I_Na → rapid depolarization
3. **Na⁺ inactivation + K⁺ activation** (slower): *h* closes, *n* opens → repolarization
4. **Afterhyperpolarization**: *n* still open → V_m dips below rest → refractory period
5. **Recovery**: *n* closes, *h* recovers → cell ready for next AP

Observable in **Step06_HodgkinHuxleyActionPotential** by plotting m, h, n alongside V_m.

---

## 4. Extended Models

### FitzHugh-Nagumo (Step14)

A 2-variable reduction of HH:

$$\frac{dv}{dt} = v - \frac{v^3}{3} - w + I_\text{ext}$$
$$\frac{dw}{dt} = \epsilon(v + a - bw)$$

*v* represents membrane voltage (normalized), *w* is a recovery variable
(slow outward current). Used for phase-plane analysis: draw nullclines to see
fixed points and limit cycles.

### Morris-Lecar (Step15)

Two-variable model with Ca²⁺ and K⁺:

$$C_m \frac{dV}{dt} = -g_{Ca}\,m_\infty(V)(V-E_{Ca}) - g_K\,w\,(V-E_K) - g_L(V-E_L) + I_\text{ext}$$
$$\frac{dw}{dt} = \phi \cdot \frac{w_\infty(V)-w}{\tau_w(V)}$$

Ca²⁺ activation $m_\infty$ is instantaneous (algebraic).  
K⁺ activation $w$ is the single ODE.  
Parameter $\phi$ controls **Type I** (saddle-node bifurcation) vs. **Type II** (Hopf bifurcation) excitability.

### Hodgkin-Huxley variants (Step16, Step17)

`CardiacVentricularCell` and `PacemakerCell` use Boltzmann functions for
steady-state gates instead of HH α/β rates, which is more common in cardiac
modeling:

$$x_\infty(V) = \frac{1}{1 + e^{-(V - V_\text{half})/k}}$$

This avoids the singularities in α/β formulas and is numerically cleaner.

**Pacemaker If current.** The funny current (I_f) is *hyperpolarization-activated*.
Its steady-state gate uses a *positive* sign in the exponent:

$$y_\infty(V) = \frac{1}{1 + e^{+(V - V_{f,\text{half}})/k_f}}$$

so that $y_\infty \to 1$ as $V \to -\infty$ (more open at more negative voltages).
The dominant chronotropic parameter is the HCN conductance density `g_f`:

$$\frac{dV_m}{dt}\bigg|_\text{diastole} \propto g_f \cdot y \cdot (V_m - E_f) / C_m$$

The activation time constant $\tau_y = 600$ ms greatly exceeds the diastolic
depolarization duration (~400 ms), so the y gate cannot track its steady state
during diastole. As a result, shifting $V_{f,\text{half}}$ has minimal effect
on cycle period; scaling `g_f` is the effective chronotropic parameter.

---

## 5. Single-Channel Recording and Patch Configurations

### Historical context

Erwin Neher and Bert Sakmann developed the patch clamp technique in 1976,
earning the 1991 Nobel Prize in Physiology or Medicine. The key innovation
was the formation of a gigaohm seal (≥1 GΩ) between a fire-polished glass
micropipette and a cell membrane. This seal reduces background noise by
~250× relative to a freely immersed pipette, enabling resolution of the
pA-scale currents through individual ion channels.

### Unitary current and conductance

A single open ion channel carries a current:

$$i = \gamma \cdot (V - E_\text{rev})$$

where $\gamma$ is the single-channel conductance (typically 1–300 pS) and
$E_\text{rev}$ is the reversal potential (Nernst equilibrium potential for
the permeant ion). This linear (ohmic) relationship holds for most
voltage-independent channels over the physiological voltage range.

### Nernst reversal potential for a patch

The reversal potential is computed from the concentrations on each face of
the patch. For a K⁺-selective channel:

$$E_\text{rev} = \frac{RT}{F} \ln \frac{[\text{K}^+]_\text{extracellular face}}{[\text{K}^+]_\text{intracellular face}}$$

The "extracellular face" and "intracellular face" of the patch depend on
the patch configuration (see below).

### Macroscopic patch current (mean-field)

For a patch containing $N$ channels, the ensemble mean current is:

$$I_\text{patch} = N \cdot P_\text{open}(t) \cdot \gamma \cdot (V - E_\text{rev})$$

where $P_\text{open}(t)$ is the fraction of channels in the open state.
This mean-field expression is exact in the limit $N \to \infty$ and is the
approximation used in `SingleChannelPatch`. Real recordings of small $N$
show discrete stochastic transitions that require Gillespie or Markov
chain simulations to reproduce.

### Boltzmann voltage-dependent gating

For a voltage-gated channel, the steady-state open probability follows a
Boltzmann distribution:

$$P_{\text{open},\infty}(V) = \frac{1}{1 + e^{-(V - V_\text{half})/k_v}}$$

| Symbol | Meaning |
|---|---|
| $V_\text{half}$ | Voltage of half-maximal activation |
| $k_v$ | Slope factor (larger $k_v$ = shallower voltage-dependence) |

The time course of channel opening follows first-order kinetics:

$$\frac{dP_\text{open}}{dt} = \frac{P_{\text{open},\infty}(V) - P_\text{open}}{\tau(V)}$$

The time constant is often described as:

$$\tau(V) = \frac{\tau_\text{max}}{\cosh((V - V_\text{half})/(2k_v))}$$

This is maximal at $V = V_\text{half}$ and decreases symmetrically on
both sides, reflecting the voltage-dependence of the opening and closing rates.

### Ligand-dependent gating shift ($\delta V_\text{half}$)

Many channels are modulated by intracellular ligands (Ca²⁺, cyclic nucleotides,
phosphorylation) or extracellular neurotransmitters. Ligand binding typically
shifts the Boltzmann curve along the voltage axis without changing its slope:

$$V_\text{half,eff} = V_\text{half} + \delta V_\text{half}$$

For a Ca²⁺-activated BK channel, $\delta V_\text{half}$ decreases (becomes
more negative) as [Ca²⁺] increases, shifting activation toward more negative
voltages and increasing P_open at physiological potentials. For a glutamate-gated
AMPA receptor, $\delta V_\text{half} = -500$ mV effectively moves
V_half from +500 mV (channel always closed) to 0 mV (channel available),
mimicking neurotransmitter binding.

### Patch configurations

The three excised-patch configurations differ in which solution contacts each
face of the membrane patch after gigaseal formation:

```
On-cell (cell-attached):      [Pipette] | membrane | [Native cytoplasm]
Inside-out (excised):         [Pipette] | membrane | [Bath (controlled)]
Outside-out (excised):        [Bath (controlled)] | membrane | [Pipette]
```

| Configuration | Extracellular face | Intracellular face | Access |
|---|---|---|---|
| On-cell | Pipette | Native cytoplasm | Native intracellular signaling preserved |
| Inside-out | Pipette | Bath | Direct control of intracellular ligands |
| Outside-out | Bath | Pipette | Rapid application of neurotransmitters |

In the `SingleChannelPatch` model, the configuration is selected with the
integer parameter `config = 1, 2, 3`. The Nernst reversal potential is
automatically recomputed for each configuration from `c_pipette`,
`c_bath`, and `c_cell_native`.

### Observable in examples

| Example | Configuration | Channel | What it shows |
|---|---|---|---|
| `Step18_OnCellSingleChannel` | On-cell | Kv (100 pS, z=1) | Kv activation curve; E_rev = −89 mV |
| `Step19_InsideOutSingleChannel` | Inside-out | BK (200 pS, z=1) | Ca²⁺ shift of V_half; P_open change |
| `Step20_OutsideOutSingleChannel` | Outside-out | AMPA (10 pS, z=1) | E_rev = 0 mV; glutamate gating |
| `Step21_StochasticSingleChannel` | On-cell | Kv (100 pS, z=1) | Same channel as Step18, but genuine discrete stochastic gating instead of the mean-field ODE |

---

## Constants in the Code

All physical constants live in `PatchClamp.Constants`:

```modelica
constant Real R = 8.314;    // J/(mol*K)
constant Real F = 96485;    // C/mol
constant Modelica.Units.SI.Temperature T_body = 310.15;  // 37 °C in K
```

Never use numeric literals for these in model equations — always reference
`PatchClamp.Constants.R`, etc.

---

## Further Reading

- Hille B (2001). *Ion Channels of Excitable Membranes*, 3rd ed. Sinauer.
- Johnston D, Wu SM (1995). *Foundations of Cellular Neurophysiology*. MIT Press.
- Keener J, Sneyd J (2009). *Mathematical Physiology*, Vol. 1. Springer.
- Hodgkin AL, Huxley AF (1952). A quantitative description of membrane current and its application to conduction and excitation in nerve. *J Physiol* 117:500–544.
- Hodgkin AL, Katz B (1949). The effect of sodium ions on the electrical activity of the giant axon of the squid. *J Physiol* 108:37–77.
- Goldman DE (1943). Potential, impedance, and rectification in membranes. *J Gen Physiol* 27:37–60.
- Neher E, Sakmann B (1976). Single-channel currents recorded from membrane of denervated frog muscle fibres. *Nature* 260:799–802.
- Morris C, Lecar H (1981). Voltage oscillations in the barnacle giant muscle fiber. *Biophys J* 35:193–213.
- FitzHugh R (1961). Impulses and physiological states in theoretical models of nerve membrane. *Biophys J* 1:445–466.
- Hamill OP, Marty A, Neher E, Sakmann B, Sigworth FJ (1981). Improved patch-clamp techniques for high-resolution current recording from cells and cell-free membrane patches. *Pflügers Arch* 391:85–100.
