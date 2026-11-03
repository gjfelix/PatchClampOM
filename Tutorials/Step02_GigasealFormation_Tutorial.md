# Patch Clamp Tutorial — Step 2: Gigaseal Formation and the Cell-Attached Configuration

**Model:** `PatchClamp.Examples.Step02_GigasealFormation`
**Recommended simulation time:** 0.060 s | Interval: 6 µs | Tolerance: 1×10⁻⁶

---

## 1. From Bath to Cell: What Changed?

In [Step 1 (Step01)](Step01_PipetteSealTest_Tutorial.md), the pipette was freely submerged in the bath solution. The steady-state current was ~1.25 nA — governed entirely by R_pip. No cell was present.

In **Step 2**, the experimenter has:

1. Navigated the pipette tip toward a cell under visual control (typically using a micromanipulator and an inverted microscope).
2. Made **gentle mechanical contact** between the fire-polished glass tip and the cell membrane.
3. Applied a brief **negative pressure** (light suction) through the back of the pipette.

This suction causes the cell membrane to deform slightly into the pipette tip. The lipid bilayer adheres tightly to the clean glass surface, forming a high-resistance electrical seal between the glass wall and the membrane. When this seal resistance exceeds ~1 GΩ (1,000 MΩ), it is called a **gigaseal** — and it is the defining criterion of a successful patch clamp experiment.

The immediate consequence is dramatic: the steady-state seal-test current drops from **~1.25 nA** (Step 1) to **~5 pA** (Step 2) — a reduction of approximately **250-fold**.

---

## 2. The Equivalent Circuit

Once the gigaseal forms, the circuit at the pipette tip is no longer a simple R_pip–R_bath series connection. The membrane patch adds three parallel electrical pathways:

```
  Amplifier         Patch Pipette              Cell-Attached Patch           Bath
                                             ┌─── R_seal = 1 GΩ ──────────┐
  [V_pulse] ─── [R_pip = 4 MΩ] ─────────── ┼─── R_patch = 50 GΩ ─────── ┼─── GND
                [C_pip = 3 pF ]             └─── C_patch = 0.1 pF ────────┘
```

### Component definitions

| Component | Symbol | Default value | Physical meaning |
|---|---|---|---|
| Pipette resistance | R_pip | 4 MΩ | Tip geometry; unchanged from Step01 |
| Pipette capacitance | C_pip | 3 pF | Glass wall to bath; unchanged |
| **Seal resistance** | **R_seal** | **1 GΩ** | Glass-to-membrane junction; the key quality indicator |
| Patch resistance | R_patch | 50 GΩ | Ion channels in the membrane patch (all closed here) |
| Patch capacitance | C_patch | 0.1 pF | Capacitance of the small membrane area under the pipette tip |
| Bath resistance | R_bath | 100 Ω | Negligible as before |

The three parallel paths (R_seal, R_patch, C_patch) are connected **between the pipette tip and ground**. They replace the direct connection to the bath electrode that existed in Step01.

---

## 3. The Seal Resistance: Why It Matters

### 3.1 What is the seal?

The seal is an extremely tight mechanical junction between the lipid bilayer of the cell membrane and the borosilicate glass of the pipette tip. Its formation is still not fully understood at the molecular level, but it depends on:

- **Clean glass:** Pipettes must be freshly pulled and not touched or exposed to dust.
- **Clean membrane:** The cell surface must be free of debris; enzyme treatment is sometimes used.
- **Suction:** Negative pressure pulls the membrane into the pipette tip, increasing the contact area.
- **Solution composition:** Divalent cations (Ca²⁺, Mg²⁺) in the bath and pipette solutions promote seal formation.

The resulting junction has a resistance of 1–100 GΩ, far higher than any ion channel or membrane resistance, which is why it is called a **gigaseal**.

### 3.2 Why does R_seal dominate the circuit?

Once R_seal ≫ R_pip, the total resistance seen by the amplifier is:

$$R_{\text{total}} = R_{\text{pip}} + (R_{\text{seal}} \| R_{\text{patch}}) \approx R_{\text{pip}} + R_{\text{seal}} \quad \text{when } R_{\text{seal}} \ll R_{\text{patch}}$$

With the default values:

$$R_{\text{seal}} \| R_{\text{patch}} = \frac{1\text{ G} \times 50\text{ G}}{1\text{ G} + 50\text{ G}} = 0.98\text{ GΩ}$$

$$R_{\text{total}} = 4\text{ MΩ} + 0.98\text{ GΩ} \approx 0.984\text{ GΩ}$$

Since R_seal (1 GΩ) ≫ R_pip (4 MΩ), the pipette resistance contributes less than 0.4% of the total. The seal is now the bottleneck.

### 3.3 The expected steady-state current

$$I_{\text{steady}} = \frac{V_{\text{pulse}}}{R_{\text{total}}} = \frac{-5 \text{ mV}}{0.984 \text{ GΩ}} \approx -5.1 \text{ pA}$$

This is the **gigaseal criterion** in action: a ~250-fold reduction from the 1.25 nA seen in Step01.

---

## 4. The Patch Capacitance and Its Transient

### 4.1 What is C_patch?

C_patch is the electrical capacitance of the small disc of membrane enclosed within the pipette tip. For a typical pipette tip diameter of ~1–2 µm:

$$C_{\text{patch}} \approx \varepsilon_0 \varepsilon_r \frac{A}{d}$$

where A is the membrane area (~1–3 µm²), d is the membrane thickness (~4 nm), and ε_r ≈ 2 for the lipid bilayer. This gives C_patch ≈ 0.05–0.5 pF — much smaller than C_pip (3 pF) and C_m of the whole cell (tens of pF).

### 4.2 The capacitive transient at the patch

At the onset and offset of each seal-test pulse, C_patch produces a capacitive transient that now **adds to** the one from C_pip:

$$\tau_{\text{patch}} = (R_{\text{pip}} \| R_{\text{seal}}) \times C_{\text{patch}}$$

Because R_seal ≫ R_pip:

$$\tau_{\text{patch}} \approx R_{\text{pip}} \times C_{\text{patch}} = 4 \times 10^6 \times 0.1 \times 10^{-12} = 0.4 \text{ µs}$$

This is even faster than τ_pip (12 µs from Step01) and appears as an additional spike overlapping the C_pip transient. In practice, these two transients are partially cancelled using analog **capacitance compensation** circuits in the amplifier — a procedure performed before attempting membrane breakthrough.

---

## 5. Current Pathways in the Cell-Attached Configuration

The total current measured by the amplifier has three components:

| Current | Symbol | Path | Typical magnitude |
|---|---|---|---|
| Seal leakage | I_seal | Through R_seal junction | ~5 pA steady-state |
| Patch ionic | I_R_patch | Through ion channels in patch | ~0 pA (all channels closed here) |
| Patch capacitive | I_C_patch | Charging/discharging C_patch | Brief transient at pulse edges |

In the default model (`R_patch = 50 GΩ`), all channels in the patch are assumed to be closed, so I_R_patch ≈ 0. The dominant steady-state current is I_seal. In a real cell-attached experiment with active channels, individual channel openings would appear as brief rectangular steps of a few pA superimposed on the seal leakage background — the basis of **single-channel recording**.

---

## 6. Variables to Plot

| Variable | Units | What to look for |
|---|---|---|
| `seal_test.V_command` | V | Square pulse protocol (−5 mV) |
| `seal_test.I_measured` | A | Steady-state ~−5 pA; tiny capacitive spikes |
| `seal_test.R_seal_est` | Ω | Converges to ~1 GΩ |
| `patch.I_seal` | A | Leakage through R_seal (dominant pathway) |
| `patch.I_R_patch` | A | Near zero (no open channels) |
| `patch.I_C_patch` | A | Capacitive transient from membrane patch |
| `patch.V_patch` | V | Voltage drop across the patch membrane |

---

<!-- build:start -->
## Build it yourself

Instead of opening the finished example you can build the model from an empty diagram, which is the best way to see how its blocks fit together. Read [Building a Model in OMEdit](00_BuildingModelsInOMEdit.md) first.

1. Create a new model named `MyStep02` and open its **Diagram View**.
2. Add the blocks, set their parameters and draw the connections exactly as in the tables below.

| # | Instance name | Library block (drag from the Libraries panel) |
|---|---|---|
| 1 | `seal_test` | `PatchClamp → Amplifiers → SealTest` (seal-test amplifier) |
| 2 | `pipette` | `PatchClamp → Electrodes → PatchPipette` (glass pipette) |
| 3 | `patch` | `PatchClamp → Membranes → CellAttachedPatch` |
| 4 | `bath` | `PatchClamp → Electrodes → BathElectrode` (bath electrode) |

**Parameters** (double-click each block; anything not listed stays at its default):

- `seal_test`: keep all defaults.

- `pipette`:

  | Parameter | Value |
  |---|---|
  | `V_junction` | `0.0` |

- `patch`: keep all defaults.

- `bath`: keep all defaults.

**Connections** (click one pin, then the other):

| From | To |
|---|---|
| `seal_test.p` | `pipette.p_amp` |
| `pipette.p_cell` | `patch.p_pip` |
| `patch.p_ext` | `bath.p` |
| `seal_test.n` | `bath.n` |
| `pipette.n` | `bath.n` |

**Simulation setup** (Simulation → Simulation Setup): StopTime = 0.060, Interval = 6e-6, Tolerance = 1e-6.

3. **Check Model**, then **Simulate**.

Compare your model with `PatchClamp → Examples → Step02_GigasealFormation`: the traces should overlay. From here on, the *Simulation Guide* below works with your `MyStep02` exactly as with the library example.
<!-- build:end -->

## 7. Step-by-Step Simulation Guide

1. Open `PatchClamp.Examples.Step02_GigasealFormation` in your Modelica environment.
2. Run with **Stop time:** 0.060 s, **Interval:** 6×10⁻⁶ s, **Tolerance:** 1×10⁻⁶.
3. Plot `seal_test.I_measured`. Compare the y-axis scale with Step01 — you will need to zoom in to the pA range.
4. Plot `seal_test.R_seal_est` and confirm it converges to ~1 GΩ.
5. Plot `patch.I_seal`, `patch.I_R_patch`, and `patch.I_C_patch` together. Note the relative magnitudes.
6. Zoom into the first pulse edge (t ≈ 2.000–2.050 ms) to observe the combined C_pip + C_patch transient.

---

## 8. Comparison Across the Three Steps

| Parameter | Step01 (Bath) | Step02 (Gigaseal) | Step03 (Whole-cell) |
|---|---|---|---|
| I_steady | ~1.25 nA | ~5 pA | RC transient |
| Dominant R | R_pip = 4 MΩ | R_seal = 1 GΩ | R_m ‖ R_pip |
| Dominant C | C_pip = 3 pF | C_pip + C_patch | C_pip + C_m (~30 pF) |
| Physical state | Free pipette | Tight membrane seal | Full cell access |
| Current reduction vs. Step01 | × 1 | × 250 | depends on R_m |

The jump from Step01 to Step02 — a 250-fold drop in current — is the most visually dramatic event in the patch clamp workflow. Experimenters watch `R_seal_est` on their amplifier display and wait for it to climb past the 1 GΩ threshold before proceeding.

---

## 9. Exercises

The following exercises use **only the Step02 model**. For each one, change the indicated parameter, re-run the simulation, and answer the questions.

---

### Exercise 1 — Simulating the Gigaseal Formation Process

In a real experiment, the seal does not form instantaneously — R_seal grows from R_pip (~4 MΩ) toward >1 GΩ over several seconds as suction is applied. Simulate this progression by running the model at different R_seal values.

**Modify:** Change `patch.R_seal` to each value below. Keep all other parameters at default.

| Trial | R_seal | Expected I_steady |
|---|---|---|
| A | 10 MΩ | ? |
| B | 100 MΩ | ? |
| C | 500 MΩ | ? |
| D | 1 GΩ | ? (default) |
| E | 5 GΩ | ? |

**Tasks:**
1. For each trial, calculate the expected R_total and I_steady before simulating. Remember: R_total = R_pip + (R_seal ‖ R_patch).
2. Run the simulation for each trial and record I_steady from the plot.
3. At which R_seal does the current drop below **10 pA**? This is a common practical threshold — why?
4. Plot R_seal (x-axis, log scale) vs. I_steady (y-axis). Describe the shape of this curve. Is the relationship linear or nonlinear?
5. In real life, the experimenter watches the amplifier in real time and sees the current drop as suction is applied. At which stage of this progression would you decide to proceed to membrane breakthrough? Justify your answer.

---

### Exercise 2 — Seal Resistance vs. Signal-to-Noise Ratio

The thermal (Johnson) noise of a resistor at room temperature is given by:

$$I_{\text{noise}} = \sqrt{\frac{4 k_B T \Delta f}{R}}$$

where k_B = 1.38×10⁻²³ J/K, T = 295 K, and Δf is the recording bandwidth.

**Tasks:**
1. For a recording bandwidth of Δf = 5 kHz (typical for single-channel recording), calculate the Johnson noise current of:
   - R_seal = 100 MΩ
   - R_seal = 1 GΩ
   - R_seal = 10 GΩ
2. Compare each noise value with the expected I_steady from Exercise 1. At which R_seal does the seal noise fall below 1 pA_rms?
3. Using the Step02 model with `R_seal = 100 MΩ`, run the simulation and compare the steady-state I_measured with the noise floor you calculated. Explain why a weak seal makes single-channel currents (typically 1–5 pA) impossible to resolve.
4. Based on this analysis, explain in your own words why the gigaseal — and not just any high-resistance seal — is the gold standard for patch clamp recordings.

---

### Exercise 3 — Effect of Patch Capacitance

**Modify:** Keep `R_seal = 1 GΩ` (default gigaseal). Change `patch.C_patch` to:

| Trial | C_patch | Notes |
|---|---|---|
| A | 0.05 pF | Small membrane patch (tight tip) |
| B | 0.1 pF | Default |
| C | 0.5 pF | Large membrane patch (wide tip) |

**Tasks:**
1. For each trial, calculate the expected time constant τ_patch = R_pip × C_patch. Compare with τ_pip = R_pip × C_pip = 12 µs.
2. Run the simulation and zoom into the first pulse edge (t ≈ 2.000–2.100 ms). Describe how the shape of the `I_measured` transient changes as C_patch increases.
3. Does changing C_patch affect the steady-state current I_steady? Explain why or why not.
4. In practice, larger C_patch means more capacitive noise during recordings. Given this, would you prefer a pipette with a very narrow or very wide tip for single-channel recording? What tradeoff does this introduce with respect to R_pip (recall Exercise 1 from the Step01 tutorial)?

---

### Exercise 4 — Dissecting the Three Current Pathways

**Use the default parameters** (R_seal = 1 GΩ, R_patch = 50 GΩ, C_patch = 0.1 pF).

**Tasks:**
1. Plot `patch.I_seal`, `patch.I_R_patch`, and `patch.I_C_patch` simultaneously. At steady state (e.g., t = 5–9 ms), which pathway carries the most current?
2. Calculate the expected fraction of total current flowing through R_seal vs. R_patch at steady state:

$$\frac{I_{\text{seal}}}{I_{\text{total}}} = \frac{R_{\text{patch}}}{R_{\text{seal}} + R_{\text{patch}}}$$

Verify this against your simulation output.

3. Now change `R_patch` to **500 MΩ** (simulating a membrane patch with several open channels). Re-run and plot the same three currents. What happens to the distribution of current between the three pathways?
4. In a real single-channel experiment, individual ion channel openings appear as brief reductions in R_patch (from ~50 GΩ closed to ~20 pA / V_patch when open). Given the values in this model, would a single 20 pA channel event be detectable above the seal leakage background? Justify your answer quantitatively.

---

### Exercise 5 — Connecting Step02 to Step01 and Step03 (Discussion)

No parameter changes required — this is a conceptual exercise to consolidate the three-step workflow.

1. The seal-test uses exactly the same V_pulse (−5 mV) in Step01 and Step02. Yet the current changes from ~1.25 nA to ~5 pA. A student claims: *"The amplifier must have changed its gain setting automatically."* Is this correct? Explain what actually changed in the circuit.

2. After confirming a gigaseal, the experimenter applies additional suction or a brief high-voltage zap to **rupture the membrane patch**. At this point the circuit transitions from Step02 to Step03 (whole-cell). Describe qualitatively what you would expect to happen to:
   - The steady-state current I_steady
   - The capacitive transient amplitude and time constant
   - The `R_seal_est` reading on the amplifier

3. In Step02, `R_pip = 4 MΩ` and `R_seal = 1 GΩ`. The pipette resistance contributes only 0.4% of the total resistance. Does this mean R_pip is irrelevant in the cell-attached configuration? Think about what happens during membrane breakthrough (Step03) and explain why R_pip still matters.

4. A colleague tells you they obtained a seal of "only" 500 MΩ and decided to proceed to whole-cell anyway. What risks does this introduce for the quality of the whole-cell recording? Use the concepts of seal noise and leakage current in your answer.

---

## 10. Summary

| Concept | Key equation | Typical value |
|---|---|---|
| Gigaseal criterion | R_seal > 1 GΩ | I_steady < ~5 pA |
| Total resistance (gigaseal) | R_total ≈ R_pip + R_seal | ~1 GΩ |
| Steady-state current (gigaseal) | I = V_pulse / R_total | ~5 pA |
| Patch capacitive time constant | τ_patch = R_pip × C_patch | ~0.4 µs |
| Current reduction vs. Step01 | — | ~250-fold |

The gigaseal transforms the patch clamp circuit from a low-resistance path (R_pip ≈ 4 MΩ) into an extremely high-resistance junction (R_seal > 1 GΩ). This is not merely a milestone to check off — it is the physical prerequisite for all subsequent measurements. Without a tight seal, seal leakage noise overwhelms the single-channel currents and whole-cell recordings are contaminated by uncontrolled leak conductances. Mastering the recognition of a good gigaseal — and understanding what the seal-test current tells you about the circuit — is the essential skill this model is designed to build.

---

*Tutorial based on model `PatchClamp.Examples.Step02_GigasealFormation` (Modelica). Part of a three-step patch clamp series: Step01 (pipette in bath) → **Step02 (gigaseal)** → Step03 (whole-cell).*
