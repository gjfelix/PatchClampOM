# Understanding PatchClampOM from the Acausal Modelica Perspective

You already understand these blocks experimentally: a pipette, an amplifier, a
cell, a bath electrode, wired the way you'd wire a real rig. What's missing is
the *other* layer underneath every block — the system of equations Modelica
actually solves — and that's exactly what makes OMEdit's Variables Browser
feel like a wall of noise: it lists every variable of every component flat,
with no indication of which ones are "the answer" and which are internal
bookkeeping. This guide fills that gap using the package's own models as
worked examples, so you can look at any diagram and reason out what to plot
instead of guessing.

---

## 1. The core idea: connectors are potential+flow pairs, not wires

Every electrical connection in this package uses `ElectricalPin`
(`PatchClamp/Interfaces/ElectricalPin.mo`):

```modelica
connector ElectricalPin
  Modelica.Units.SI.Voltage v;        // potential
  flow Modelica.Units.SI.Current i;   // flow — sum = 0 at a node
end ElectricalPin;
```

Two variables, and they behave completely differently when you `connect()`
two pins:

- **`v` (potential):** connecting two pins forces their `v` to be **equal**.
- **`i` (flow):** connecting pins does *not* make their `i` equal — it forces
  the **sum of every flow variable at that node to be zero** (Kirchhoff's
  current law, generalized to any number of connected pins, not just two).

This is the whole trick of acausal modeling: a block like `PatchPipette`
never says "current flows from p_amp to p_cell." It just writes down the
physical relationships (Ohm's law, `C*dV/dt`) between its own pins' `v` and
`i`. Nobody in the model declares which variable is an input and which is an
output — when you hit Simulate, the compiler collects every equation from
every connected block, plus one `v`-equality and one `i`-sum-to-zero equation
per node from every `connect()` statement, and solves the whole system
simultaneously. This is also why you can swap `HodgkinHuxleyNeuron` for
`PassiveCell` without rewiring anything (README's headline claim): the
*equations* change, but the *interface* (`membrane_p`/`membrane_n`, both
`ElectricalPin`) doesn't.

Non-electrical connectors follow the same idea but conjugate different
physical quantities. `SolutionPort` (`Interfaces/SolutionPort.mo`) conjugates
temperature/pressure/osmolarity with no `flow` variable at all — it's a
bus of shared properties, not a circuit node, which is why `Media` blocks
don't participate in any current-balance equation.

---

## 2. Worked example — Step01: from diagram to equations, by hand

`Step01_PipetteSealTest` connects three blocks in series:
`SealTest.p → PatchPipette.p_amp`, `PatchPipette.p_cell → BathElectrode.p`,
and a shared ground bus. Here is *every* equation in the assembled system
(reading directly from the three `.mo` files):

```
-- SealTest --
V_command = (pulse protocol, a function of time)
seal_test.p.v - seal_test.n.v = V_command
I_measured   = -seal_test.p.i

-- connect(seal_test.p, pipette.p_amp) --
seal_test.p.v = pipette.p_amp.v
seal_test.p.i + pipette.p_amp.i = 0

-- PatchPipette --
V_node = pipette.p_amp.v + V_junction
i_R    = (V_node - pipette.p_cell.v) / R_pipette
i_C    = C_pipette * der(V_node - pipette.n.v)
pipette.p_amp.i  = i_R + i_C
pipette.p_cell.i = -i_R
pipette.n.i       = -i_C

-- connect(pipette.p_cell, bath.p) --
pipette.p_cell.v = bath.p.v
pipette.p_cell.i + bath.p.i = 0

-- BathElectrode --
bath.p.v - bath.n.v = bath.p.i * R_bath
bath.n.v = 0

-- ground bus: connect(seal_test.n, bath.n), connect(pipette.n, bath.n) --
seal_test.n.v = bath.n.v,  pipette.n.v = bath.n.v
seal_test.n.i + pipette.n.i + bath.n.i = 0
```

Count it up: this is a fully determined algebraic system (one differential
state, `V_node`, via `der()`), no free variables. The compiler picks a
solving order automatically — you never see that order, but it's why
changing `R_pipette` propagates to `I_measured` without you specifying how.

**Now, the plotting question this example answers:** in a pure series
circuit like this one, `seal_test.I_measured`, `pipette.i_R` (up to sign),
and `bath.p.i` are all *numerically* the same current — there's only one
path for it to take. That's specifically why the docstring tells you to plot
`seal_test.I_measured`: it's the block that represents what the real
amplifier's ADC would report, i.e. the "instrument-observable" variable, even
though several other variables would show the identical trace here. Don't
generalize that equivalence, though — see the next example.

---

## 3. Worked example — Step02: branching current invalidates that shortcut

`Step02_GigasealFormation` inserts `CellAttachedPatch` between the pipette
tip and the bath. Unlike Step01, this block has **three parallel paths**
between its two pins (`Membranes/CellAttachedPatch.mo`):

```modelica
V_patch = p_pip.v - p_ext.v;
I_seal    = V_patch / R_seal;
I_R_patch = V_patch / R_patch;
I_C_patch = C_patch * der(V_patch);
p_pip.i = I_seal + I_R_patch + I_C_patch;   // <- sum of three branches
```

Now `seal_test.I_measured` (still the total current the amplifier sees) is
**not** the same variable as `patch.I_seal` (only the seal-leak branch) or
`patch.I_R_patch` (only the channel-resistive branch) or `patch.I_C_patch`
(only the capacitive branch). They only *happen* to be numerically close in
this specific example because `R_patch` (50 GΩ, channels closed) is so much
larger than `R_seal` (1 GΩ) that `I_seal` dominates the sum — which is
exactly the pedagogical point check W-2 in `docs/validation-results.md` exists
to confirm (`patch.I_seal ≈ seal_test.I_measured` because `R_patch >> R_seal`).
If you were modeling an open channel instead, `I_R_patch` would stop being
negligible and the two variables would visibly diverge.

**The generalizable lesson:** whenever a block has more than one path between
its pins (a `+` on the right-hand side of a flow-balance equation), the
"total current in" variable and each branch's individual current are
different variables that are only equal in special-case parameter regimes.
Check the equation, don't assume.

---

## 4. Worked example — the cell itself: states vs. algebraic outputs

Every cell model extends `Cells.Interfaces.PartialExcitableCell`, which
defines the one equation that matters most for "what do I plot to see what
the cell did":

```modelica
V_m = membrane_p.v - membrane_n.v;
C_m * der(V_m) = membrane_p.i - I_total;   // <- the ONLY der() in this partial
```

`V_m` is a genuine **differential state**: it has memory, it's what gets
integrated forward in time, and every cell model's whole point is producing
its trace. `I_total` is left abstract here — each concrete cell model
(`HodgkinHuxleyNeuron`, `PassiveCell`, etc.) supplies its own algebraic
equation for it.

In `HodgkinHuxleyNeuron` (`Cells/HodgkinHuxleyNeuron.mo`), the full local
system is:

```
der(m) = alpha_m(V_m)*(1-m) - beta_m(V_m)*m     -- state
der(h) = alpha_h(V_m)*(1-h) - beta_h(V_m)*h     -- state
der(n) = alpha_n(V_m)*(1-n) - beta_n(V_m)*n     -- state
I_Na   = g_Na_max * m^3 * h * (V_m - E_Na) * A  -- algebraic, from states
I_K    = g_K_max  * n^4     * (V_m - E_K)  * A  -- algebraic, from states
I_leak = g_L                * (V_m - E_L)  * A  -- algebraic, from parameters only
I_total = I_Na + I_K + I_leak                    -- algebraic
```

So a Hodgkin-Huxley simulation actually has **four** differential states
(`V_m`, `m`, `h`, `n`) coupled together — not one. That reframes the plotting
question as a hierarchy, not a flat list:

| Question | Variable(s) |
|---|---|
| What did the membrane do? (the headline result) | `V_m` |
| Why did it do that — which conductance drove it? | `I_Na`, `I_K`, `I_leak` (signs: `I_Na<0` inward/depolarizing during upstroke, `I_K>0` outward/repolarizing) |
| What's the microscopic gating mechanism behind those currents? | `m`, `h`, `n` (dimensionless, 0–1, meaningless on their own except as multipliers on conductance) |
| What did the experimenter apply? | `amplifier.I_command` (current-clamp) or `amplifier.V_command`/`vClamp.V_out` (voltage-clamp) |
| What would the instrument actually report? | `amplifier.V_membrane` (current-clamp) or `amplifier.I_measured`-equivalent (voltage-clamp) — see §5, these are *not* the same number as the cell's own `V_m`/current |

`I_total` itself is rarely what you plot — it's the internal glue between the
cell's ionic currents and the capacitive charging equation, useful mainly as
a sanity check (it should equal `-C_m * der(V_m) + membrane_p.i`, i.e. it's
implied by the other traces, not new information).

---

## 5. Case study: why `neuron.V_m` and `amplifier.V_membrane` disagree by 11 mV

This is the single most common source of "which variable is the *real* one"
confusion, and it's fully traceable through the equations. In
`Step06_HodgkinHuxleyActionPotential`, `CurrentClampAmplifier` reports:

```modelica
V_membrane = (p.v - n.v) - I_command * R_bridge;   // "bridge-balanced" reading
```

Follow the chain from the amplifier's `p` pin through the pipette to the
neuron. `PatchPipette` adds the liquid-junction-potential offset internally:

```modelica
V_node = p_amp.v + V_junction;                       // p_amp.v is the amplifier's p.v
i_R    = (V_node - p_cell.v) / R_pipette;             // p_cell.v is the neuron's membrane_p.v = V_m
```

At the (quasi-)steady moments where the pipette's capacitive current is
negligible, `i_R ≈ I_command`, so solving for `p.v`:

```
p.v = V_node - V_junction = p_cell.v + I_command*R_pipette - V_junction
    = V_m + I_command*R_pipette - V_junction
```

Substitute into the amplifier's own equation, and — because the tutorial sets
`R_bridge = R_pipette` specifically to cancel the pipette's resistive drop —
the `I_command*R_pipette` terms cancel exactly, leaving:

```
V_membrane = V_m - V_junction = V_m - (-0.011 V) = V_m + 11 mV
```

That +11 mV is not a bug, and it's not noise — it's the model faithfully
reproducing a real, textbook patch-clamp artifact (the liquid junction
potential between a KCl-based pipette solution and ACSF bath). At rest,
`V_m = -65 mV` while `V_membrane ≈ -54 mV`; both are "correct," they're
answering different questions:

- **`neuron.V_m`** is the biophysical ground truth — use it whenever you're
  validating the biophysics itself (this is what `docs/validation-results.md`
  uses for every Hodgkin-Huxley check, explicitly for this reason).
- **`amplifier.V_membrane`** is what a real instrument would display *if you
  hadn't corrected for LJP* — use it when the pedagogical point is the
  instrumentation artifact itself (teaching why experimentalists correct for
  LJP before publishing a resting potential).

The same pattern — a "cell-truth" variable and a "what-the-instrument-shows"
variable that are equal only under a specific compensation condition — recurs
with `V_command` vs. the cell's actual clamped voltage under finite series
resistance (Step13), and with `seal_test.I_measured` vs. `patch.I_seal` in
§3 above. Whenever you see two similarly-named variables straddling an
amplifier/pipette boundary, assume they differ by exactly the artifact the
amplifier is modeling, and go find the equation that relates them rather than
guessing.

---

## 6. Why Step08–Step10 have no pins at all

If you've looked at `Step08_NernstEquilibriumPotential` or
`Step09_GHKReversalPotential`, you'll notice they declare no
`ElectricalPin`, no `connect()` statements — just `parameter`s feeding
straight into a function call. That's not a stripped-down or incomplete
model; it's because the Nernst/GHK equations aren't a circuit at all. There's
no current to conserve and no node to balance — `E_K = nernstPotential(...)`
is a pure algebraic function of concentrations and temperature, full stop.
Once you're looking for `flow` variables and `connect()` statements to
understand a model, the absence of both is itself informative: it tells you
you're looking at closed-form physics, not an equivalent circuit, and the
"what to plot" question collapses to "the one output variable the function
computes," no KCL bookkeeping involved.

---

## 7. A practical checklist for "what do I plot?"

When you open a new example and the Variables Browser looks overwhelming,
work through this in order:

1. **Is the question about biophysics or about instrumentation?**
   Biophysics → cell-internal variables (`V_m`, `I_Na`, `m`/`h`/`n`,
   `E_K`...). Instrumentation/measurement artifact → amplifier/pipette
   variables (`V_membrane`, `I_measured`, `V_command`).
2. **Find the `der()`.** Any variable that appears inside `der(...)` in a
   model's equation section is a genuine state — it's *always* worth
   plotting first, because it's the one thing with memory; everything else
   is recomputed from it and the parameters at every instant.
3. **Everything without `der()` is algebraic** — instantaneously determined
   by the states and parameters. These answer "why" once you already know
   "what" from step 2 (e.g., `I_Na`/`I_K` explain the shape of `V_m`).
4. **Count the branches.** If a block's flow-balance equation
   (`pin.i = A + B + C`) has more than one term on the right, the "total"
   variable and each branch's variable are genuinely different quantities —
   check which one your question is actually about (§3).
5. **Don't assume two similarly-named variables across a pipette/amplifier
   boundary are equal** — they're equal only under a stated compensation
   condition (`R_bridge = R_pipette`, `V_junction = 0`, etc.). If the
   condition doesn't hold in your parameter set, expect an offset, and go
   find it in the equations (§5) rather than treating it as an error.
6. **If the model has no pins**, you're looking at closed-form algebra, not
   a circuit — there's exactly one output to plot, and no KCL bookkeeping to
   reason through at all (§6).
7. Most `Examples/Step*.mo` docstrings already end with a "Variables clave a
   graficar" (key variables to plot) section written by hand for that
   specific experiment — read it first; this guide is for when you need to
   reason it out yourself, e.g. for a parameter regime the docstring didn't
   anticipate.

---

## 8. Connector and variable-naming cheat sheet

| Connector | Conjugate variables | Used by | Conserved quantity |
|---|---|---|---|
| `ElectricalPin` (`_p`/`_n` are just the same type, colored for clarity) | `v` (potential), `i` (flow) | Everything electrical: pipette, amplifiers, cells' `membrane_p`/`membrane_n`, patches | Current (KCL): Σi = 0 at a node |
| `SolutionPort` | `T`, `p`, `osmolarity` (no flow) | `Media` solution blocks | Nothing conserved — a shared-properties bus, not a circuit |
| `IonPort` | `c_in`, `c_out` (two potential-like variables), `q` (flow, molar rate) | Per-ion-species exchange between solution and membrane blocks | Molar flux (Σq = 0) — same conservation *pattern* as `ElectricalPin`, just for moles instead of charge (`I = z·F·q` converts one to the other) |

| Variable name pattern | Typical meaning |
|---|---|
| `*.V_m` | Cell's own transmembrane potential — biophysical ground truth |
| `*.V_membrane` | Amplifier's *measured/compensated* voltage — includes instrumentation artifacts (LJP, bridge balance) unless explicitly corrected |
| `*.V_command` / `*.vClamp.V_out` | What the experimenter told the amplifier to output — the setpoint, not a measurement |
| `*.I_total` | Sum of a cell's ionic currents — internal glue variable, rarely the headline plot |
| `*.I_Na`, `*.I_K`, `*.I_leak`, ... | Individual ionic currents — mechanism-level detail, explains *why* `V_m` moved |
| `*.I_measured` | What the amplifier's ADC would report — the instrument-observable total current |
| `*.I_command` | What the experimenter told a current-clamp amplifier to inject |
| `*.I_seal`, `*.I_R_patch`, `*.I_C_patch` | Individual branch currents inside a multi-path block — only sum to the total, not equal to it |
| `E_K`, `E_Na`, ... (alias variables) | Nernst potentials — pure algebra, no `der()`, recomputed instantly from concentrations |

For the full behavioral documentation of any single block, its own
`Documentation(info=...)` annotation (visible in OMEdit's Documentation
browser, or just open the `.mo` file) is always the authoritative source —
this guide is meant to give you the reading strategy, not replace it.
