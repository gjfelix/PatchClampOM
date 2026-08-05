# Contributing to PatchClamp

Thank you for your interest in contributing to the PatchClamp OpenModelica package.
This guide covers the conventions you need to follow so that new models integrate
cleanly with the existing package and with OMEdit's graphical interface.

---

## Table of Contents

1. [Getting Set Up](#1-getting-set-up)
2. [Package Conventions](#2-package-conventions)
3. [Adding a New Cell Model](#3-adding-a-new-cell-model)
4. [Adding a New Example](#4-adding-a-new-example)
5. [Adding a Media Component](#5-adding-a-media-component)
6. [Checklist Before Submitting](#6-checklist-before-submitting)

---

## 1. Getting Set Up

```bash
git clone https://github.com/gjfelix/PatchClampOM.git
cd PatchClampOM
```

Open `PatchClamp/package.mo` in OMEdit to verify the package loads without errors
before making changes.

To check a file from the command line:

```bash
omc +check PatchClamp/package.mo
```

---

## 2. Package Conventions

### 2.1 Naming

| Element | Style | Example |
|---|---|---|
| Packages | `PascalCase` | `PatchClamp.Cells` |
| Models / blocks | `PascalCase` | `HodgkinHuxleyNeuron` |
| Parameters | `camelCase` | `pipetteResistance` |
| Connectors | `camelCase` + domain suffix | `membrane_p`, `ion_port` |
| Internal variables | `camelCase`, no prefix | `gatingVariable` |

### 2.2 Units

Always use `Modelica.Units.SI` types — never bare `Real` where a physical
unit applies. Add `displayUnit` for quantities students will see in OMEdit:

```modelica
parameter Modelica.Units.SI.Current I_hold = 0
  "Holding current [A]"
  annotation(Dialog(group="Stimulus"))
  // displayUnit handled by the SI type; use pA in annotations if needed
```

| Quantity | SI type | Typical display |
|---|---|---|
| Voltage | `Voltage` (V) | `displayUnit="mV"` |
| Current | `Current` (A) | `displayUnit="pA"` |
| Resistance | `Resistance` (Ω) | `displayUnit="MOhm"` |
| Concentration | `MolarConcentration` (mol/m³) | `displayUnit="mmol/l"` |
| Temperature | `Temperature` (K) | default (K) |
| Time | `Time` (s) | `displayUnit="ms"` |

### 2.3 No magic numbers

Every constant must be either:
- A `parameter` (student-configurable in OMEdit), or
- A reference to `PatchClamp.Constants` (R, F, T_body).

```modelica
// WRONG
E_Na = (8.314 * 310.15 / 96485) * log(145.0 / 10.0);

// CORRECT
E_Na = PatchClamp.Media.Functions.nernstPotential(
         PatchClamp.Constants.T_body, 1, c_Na_out, c_Na_in);
```

### 2.4 One model per file

Do not place multiple model definitions in a single `.mo` file unless they are
`protected` inner classes. One public model = one file.

### 2.5 Numerical protection

Any division that could produce 0/0 requires a guard. The canonical pattern:

```modelica
// Protect against singularity (e.g. GHK at V=0)
if abs(x) < 1e-6 then
  result := limit_value;
else
  result := full_expression;
end if;
```

### 2.6 Kirchhoff compliance

Every electrical node must satisfy current balance. Add a comment where the
balance equation is written:

```modelica
membrane_p.i + membrane_n.i = 0;  // Kirchhoff: no current accumulation at node
```

### 2.7 Required annotations

Every model must have **both**:

1. **`Icon`** — at minimum a filled rectangle and a `Text` with the model name:

```modelica
annotation(
  Icon(graphics = {
    Rectangle(
      extent = {{-100,-100},{100,100}},
      lineColor = {0,0,200},
      fillColor = {220,230,255},
      fillPattern = FillPattern.Solid),
    Text(
      extent = {{-90,-80},{90,-95}},
      textString = "MyModel",
      textColor = {0,0,150})
  }),
  ...
);
```

2. **`Documentation`** — at minimum one paragraph explaining the physics in
   plain language for a physiology student (not a programmer):

```modelica
Documentation(info = "<html>
  <h2>MyModel</h2>
  <p>Explain what this model represents biologically,
     what the student should observe, and which parameters
     to change for the main teaching experiments.</p>
</html>")
```

---

## 3. Adding a New Cell Model

### Step 1 — Create the file

Place it in `PatchClamp/Cells/MyNewCell.mo`. Always extend `PartialExcitableCell`:

```modelica
within PatchClamp.Cells;
model MyNewCell "One-line description for OMEdit"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 20e-12,     // membrane capacitance [F]
    A   = 1000e-12,   // membrane area [m²]
    V_m(start = -0.065, fixed = true));

  // --- Parameters ---
  parameter Modelica.Units.SI.Conductance g_X = 1.0
    "Channel conductance [S/m²]"
    annotation(Dialog(group = "Conductances"));

  // ... more parameters

equation
  // --- Ionic currents ---
  I_X = g_X * gating * (V_m - E_X) * A;

  // --- Membrane equation (mandatory) ---
  I_total = I_X; // + other currents

  annotation(Icon(...), Documentation(...));
end MyNewCell;
```

**Mandatory equations from `PartialExcitableCell`:**

```modelica
C_m * der(V_m) = membrane_p.i - I_total;
membrane_p.i + membrane_n.i = 0;  // Kirchhoff
```

These are already defined in the base class — do **not** rewrite them.
Only define `I_total` as the sum of your ionic currents.

### Step 2 — Register in package.order

Add the model name to `PatchClamp/Cells/package.order` in a logical position
(roughly ordered from simple to complex):

```
Interfaces
PassiveCell
SimplifiedNeuron
HodgkinHuxleyNeuron
FitzHughNagumoNeuron
MorrisLecarNeuron
CardiacVentricularCell
PacemakerCell
MyNewCell          ← add here
```

### Step 3 — Create a companion example

Every new cell model must have at least one runnable example in
`PatchClamp/Examples/` (see Section 4).

---

## 4. Adding a New Example

### File placement and naming

```
PatchClamp/Examples/Step25_MyExperiment.mo
```

Number examples sequentially. Use descriptive names after the number.

### Minimum structure for a dynamic example

```modelica
within PatchClamp.Examples;
model Step25_MyExperiment "Brief description"
  PatchClamp.Cells.MyNewCell cell(
    g_X = 2.0)
    annotation(Placement(...));

  PatchClamp.Amplifiers.CurrentClampAmplifier amp(
    I_hold = 0,
    I_pulse = 1e-12,
    t_start = 0.010,
    t_end   = 0.011)
    annotation(Placement(...));

equation
  connect(amp.p, cell.membrane_p);
  connect(amp.n, cell.membrane_n);

  annotation(
    experiment(StopTime = 0.2, Interval = 1e-5, Tolerance = 1e-8),
    Documentation(info = "<html>...</html>"),
    Icon(...));
end Step25_MyExperiment;
```

### Purely algebraic examples (no connectors)

If the experiment has no electrical connectors (like Step08–Step10):
- Use `StopTime = 1.0, Interval = 1.0`
- Call `PatchClamp.Media.Functions.*` directly
- Do **not** instantiate amplifier blocks

### Register in package.order

Add to `PatchClamp/Examples/package.order` in numerical order.

---

## 5. Adding a Media Component

New ionic solutions or functions go in `PatchClamp/Media/`.

### New solution

Extend one of the existing solution models:

```modelica
within PatchClamp.Media;
model MyCustomSolution "Description"
  extends PatchClamp.Media.InternalSolution(
    c_K  = 120.0,
    c_Na = 10.0,
    c_Cl = 20.0,
    c_Ca = 1e-4);
  // override only what differs
end MyCustomSolution;
```

### New function

Place pure functions in `PatchClamp/Media/Functions/`:

```modelica
within PatchClamp.Media.Functions;
function myNewFunction
  input  Real x;
  output Real y;
algorithm
  y := ...; // pure calculation, no side effects
  annotation(Inline = true);
end myNewFunction;
```

Register in `PatchClamp/Media/Functions/package.order`.

---

## 6. Checklist Before Submitting

Before opening a pull request, verify all of the following:

### Code quality
- [ ] `omc +check PatchClamp/package.mo` runs without errors
- [ ] No bare `Real` variables where a physical unit applies
- [ ] No numeric literals for R, F, T — use `PatchClamp.Constants.*`
- [ ] All divisions with potential 0/0 have numerical guards
- [ ] `sum(i) = 0` satisfied at every electrical node (Kirchhoff comment present)

### Model completeness
- [ ] `Icon` annotation present with at least a rectangle and text
- [ ] `Documentation` annotation present with at least one paragraph in English
- [ ] `experiment(...)` annotation present in example models
- [ ] `parameter` annotations include `Dialog(group=...)` for OMEdit grouping

### File structure
- [ ] One public model per `.mo` file
- [ ] New model registered in the correct `package.order`
- [ ] Companion example created (for new cell models)
- [ ] Example registered in `Examples/package.order`

### Physics
- [ ] Units verified against SI definitions
- [ ] Default parameter values match a published biological reference
- [ ] Reference cited in `Documentation`

---

## Questions?

Open an issue on GitHub:
[https://github.com/gjfelix/PatchClampOM/issues](https://github.com/gjfelix/PatchClampOM/issues)
