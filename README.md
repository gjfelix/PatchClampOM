# PatchClamp — OpenModelica Package for Patch Clamp Teaching

> A drag-and-drop block-based modeling package for learning the **patch clamp** technique
> using OpenModelica 4.x. No manual equation writing required for students.

## What is this?

PatchClamp is an educational OpenModelica package that lets students simulate
electrophysiology experiments by connecting graphical blocks in OMEdit — the same
way they would set up a real patch clamp rig. The physics (Nernst, Goldman-Hodgkin-Katz,
Hodgkin-Huxley, amplifier compensation) is implemented inside the blocks, not exposed
as raw equations.

**Target audience:** Neuroscience / physiology students with basic circuit knowledge.
**Level:** Equivalent circuit models + ionic permeability (no quantum mechanics,
no detailed channel gating kinetics beyond HH/Boltzmann formalism).

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/gjfelix/PatchClampOM.git
cd PatchClampOM

# 2. Open in OMEdit
#    File → Open Model/Library File → select PatchClamp/package.mo

# 3. In the Libraries panel, expand:
#    PatchClamp → Examples → Step03_PassiveCellVoltageClamp

# 4. Double-click Step03_PassiveCellVoltageClamp → click Simulate
#    StopTime: 0.2 s  |  Interval: 1e-5 s
```

See [docs/getting-started.md](docs/getting-started.md) for a detailed walkthrough.

## Package Structure

```
PatchClamp/
├── Constants.mo          ← R, F, T_body (physiological constants)
├── Interfaces/           ← Electrical/ionic connectors (pin_p, pin_n, IonPort, SolutionPort)
├── Media/                ← Physiological solutions + Nernst / GHK functions
├── Electrodes/           ← PatchPipette, BathElectrode, Ag/AgCl electrode, Ground
├── Cells/                ← Seven excitable cell models (see table below)
├── Amplifiers/           ← VoltageClamp, CurrentClamp, SealTest, Ramp source,
│                            + Compensation/ (C-fast, C-slow, R_s compensation)
├── Membranes/             ← Channel-level models: GHK/Goldman conductance, whole-cell
│                            break-in, cell-attached patch, single-channel
│                            (deterministic + stochastic gating), Markov channel
└── Examples/              ← 24 ready-to-simulate experiments, Step01 – Step24
```

## Cell Models

| Model | Key equations | Resting V | Notes |
|---|---|---|---|
| `PassiveCell` | RC circuit | –65 mV | Starting point |
| `SimplifiedNeuron` | LIF (leaky integrate-and-fire) | –65 mV | Fastest intro |
| `HodgkinHuxleyNeuron` | Full HH (1952), squid axon | –65 mV | Classic reference |
| `FitzHughNagumoNeuron` | FHN 2-variable reduction | –1.2 (norm.) | Phase-plane analysis |
| `MorrisLecarNeuron` | Ca²⁺ + K⁺, Type I/II | –60 mV | Bifurcation demo |
| `CardiacVentricularCell` | Na⁺ + Ca²⁺ + K⁺ + leak (simplified Beeler-Reuter) | –80 mV | Long plateau AP |
| `PacemakerCell` | HCN (I_f) + I_Ca + I_Kr | –60 mV | Spontaneous firing |

All models extend `Cells.Interfaces.PartialExcitableCell` — they share the same
`membrane_p` / `membrane_n` connectors and can be swapped without rewiring.

## Examples

`PatchClamp.Examples` contains 24 ready-to-simulate models (`Step01`–`Step24`),
documented in [`docs/examples-reference.md`](docs/examples-reference.md) and,
for the first eight steps, walked through hands-on in
[`docs/getting-started.md`](docs/getting-started.md).

| Category | Examples | Covers |
|---|---|---|
| Patch clamp workflow | Step01–Step02, Step04 | Seal test → gigaseal → whole-cell break-in |
| Passive cell | Step03, Step05 | Voltage-clamp / current-clamp of a passive RC cell |
| Ion equilibrium | Step08–Step11 | Nernst, GHK, Goldman resting potential, I-V curves |
| Excitable cell | Step06–Step07, Step14–Step17 | HH action potential, refractory period, FitzHugh-Nagumo, Morris-Lecar, cardiac AP, pacemaker |
| Voltage-clamp protocol | Step12–Step13, Step22–Step24 | Na⁺ channel I-V ladder, combined and isolated C-fast/C-slow/R_s compensation |
| Single-channel patch | Step18–Step21 | On-cell (Kv), inside-out (BK+Ca²⁺), outside-out (AMPA), stochastic gating |

## Physics Implemented

$$E_\text{ion} = \frac{RT}{zF} \ln\frac{[\text{ion}]_\text{out}}{[\text{ion}]_\text{in}}$$

$$J_\text{GHK} = P_\text{ion} \cdot z^2 \cdot \frac{VF^2}{RT} \cdot \frac{c_\text{in} - c_\text{out}\,e^{-zVF/RT}}{1 - e^{-zVF/RT}}$$

$$C_m \frac{dV}{dt} = -g_\text{Na}m^3h(V-E_\text{Na}) - g_\text{K}n^4(V-E_\text{K}) - g_L(V-E_L) + I_\text{ext}/A$$

$$I_\text{comp,fast} = f_\text{fast} \cdot C_\text{fast} \cdot \frac{d(p.v - n.v)}{dt}$$

See [docs/physics-background.md](docs/physics-background.md) for derivations and
typical values, and [docs/compensation-guide.md](docs/compensation-guide.md) for
the amplifier-compensation math specifically.

## Requirements

| Dependency | Version | Required? |
|---|---|---|
| OpenModelica | ≥ 4.3.0 | **Yes** |
| PhysioLibrary | 3.0.0 | Optional (for extensions) |

## Documentation

- [Getting Started](docs/getting-started.md) — installation, first simulation, tips
- [Physics Background](docs/physics-background.md) — Nernst, GHK, HH equations
- [Model Reference](docs/model-reference.md) — parameters and expected results for each model
- [Compensation Guide](docs/compensation-guide.md) — how C-fast, C-slow, and R_s compensation work in `Amplifiers.Compensation`
- [Acausal Modeling Guide](docs/acausal-modeling-guide.md) — how the graphical blocks become equation systems, and how to decide what to plot
- [Examples Reference](docs/examples-reference.md) — description, objectives, and simulation instructions for every `Step01`–`Step24` example
- [Validation Results](docs/validation-results.md) — quantitative pass/fail checks against the underlying physics
- [Contributing](CONTRIBUTING.md) — coding conventions for adding new models

## References

- Hodgkin AL, Huxley AF (1952). A quantitative description of membrane current... *J Physiol* 117:500–544
- Goldman DE (1943). Potential, impedance, and rectification in membranes. *J Gen Physiol* 27:37–60
- Neher E, Sakmann B (1976). Single-channel currents recorded from membrane of denervated frog muscle fibres. *Nature* 260:799–802
- Morris C, Lecar H (1981). Voltage oscillations in the barnacle giant muscle fiber. *Biophys J* 35:193–213

## License

MIT — see [LICENSE](LICENSE) for details.
