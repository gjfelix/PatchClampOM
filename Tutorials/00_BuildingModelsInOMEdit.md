# Building a Model in OMEdit — the Basics

Every tutorial in this folder asks you to **build an experiment from scratch** by dragging blocks
from the PatchClampOM library, setting their parameters, and connecting them. This page explains the
handful of OMEdit actions you need once; the tutorials then only say *which* blocks, parameters and
connections to use. Read it before your first tutorial and come back whenever you forget a step.

Everything here is done with the mouse in OMEdit. You never need a terminal.

---

## 1. Load the library (once per session)

1. Start OMEdit.
2. **File → Open Model/Library File(s)…**, choose `PatchClamp/package.mo` from the repository folder, and click **Open**.
3. In the **Libraries Browser** (left panel), expand **PatchClamp**. You should see the sub-packages
   *Interfaces, Media, Electrodes, Cells, Amplifiers, Membranes, Examples*.

If the library does not appear, check that OMEdit shows no red error message in the **Messages Browser** (bottom panel).

---

## 2. Create a new, empty model

1. **File → New Modelica Class…**
2. **Name:** type the model name given in the tutorial (for example `MyStep07`). Do not use spaces.
3. **Specialization:** *Model*.
4. Leave **Insert in class** empty, tick **Save contents in one file** and choose a folder for the file (for example next to your own notes, not inside `PatchClamp/`). Click **OK**.
5. OMEdit opens the new model. Switch to the **Diagram View** with the *Diagram View* button in the toolbar above the canvas (the one that shows an empty drawing area with a grid).

> Tip: the tutorials suggest a name that differs from the library example (`MyStepNN`, not `StepNN_…`), so you can keep your model open next to the original and compare them.

---

## 3. Add a block

1. In the **Libraries Browser**, expand the package given in the tutorial (for example *PatchClamp → Amplifiers*).
2. **Drag** the block (for example `CurrentClampAmplifier`) onto the diagram canvas and release. Arrange the blocks left to right: amplifier, pipette, cell or channel, bath electrode.
3. OMEdit gives the block a default name (`currentClampAmplifier`). The tutorials ask for specific instance names so the plots and exercises match.
   **Double-click** the block → **General** tab → **Name** → type the name given in the tutorial → **OK**.

---

## 4. Set the parameters of a block

1. **Double-click** the block. The *Component Properties* window opens; parameters are listed in groups on the **Parameters** area (some blocks have several groups, for example *Pulse 1* and *Pulse 2*).
2. Edit only the parameters the tutorial lists in its parameter table. **Everything else stays at its default value.**
3. Type values the way the tutorial writes them. Scientific notation such as `30.0e-12` is correct (that is 30 pA, because all quantities are in SI units: volts, amperes, seconds, siemens, farads, ohms, mol/m³).
4. Some values are expressions that refer to another block, for example `int_sol.c_K`. Type them exactly as written.
5. Click **OK**.

> **Units warning.** PatchClampOM uses SI units everywhere. A current of 30 pA is `30.0e-12`, not `30`. If a trace looks a thousand or a billion times too large or small, check the exponent first.

---

## 5. Connect two blocks

1. Move the mouse over a **connector** (a small square or circle on the edge of a block). The cursor turns into a cross.
2. **Click and drag** from that connector to the connector of the other block, then release. A line appears.
3. Repeat for every row of the tutorial's connection table. The table names each connector as `block.pin`, for example `pipette.p_cell` to `neuron.membrane_p`.
4. If you connect the wrong pins, click the line and press **Delete**, then redo it.

Two connectors with the same colour and shape fit together; you cannot join an electrical pin to an ion port.

---

## 6. Check the model

Before simulating, use **Check Model** (toolbar, or **Simulation → Check Model**).

- The message *"Check of … completed successfully"* means the model is well formed.
- If an error appears, read the **Messages Browser**. The most common causes are a missing connection, a connection to the wrong pin, or a parameter typed with the wrong name.

---

## 7. Simulate

1. **Simulation → Simulation Setup** (or the clock icon in the toolbar).
2. Set **Start Time** `0`, **Stop Time**, and **Interval** (or *Number of Intervals*) to the values in the tutorial. The default solver (`dassl`) and **Tolerance** `1e-8` are fine.
3. Click **OK**, then **Simulate** (the green *play* button, **Simulation → Simulate**).
4. When the simulation finishes OMEdit switches to the **Plotting** perspective.

---

## 8. Plot and inspect results

1. In the **Variables Browser** (right panel) expand your model, then the component (for example `neuron`) and tick the variable to plot (for example `V_m`). Each tick adds a trace to the plot window.
2. To plot variables of different magnitudes, right-click a variable and choose **Add to New Plot** (or use the *New Plot Window* button).
3. **Zoom:** use the *Zoom In* tool (magnifier) and drag a rectangle on the plot, or scroll. **Fit in View** returns to the full trace.
4. **Read a value:** hover the mouse over a trace; OMEdit shows the time and the value.
5. **Current versus voltage plots** (for I–V curves): use **New Parametric Plot Window**, choose the *x* variable first and then the *y* variable.
6. To change a parameter and run again: return to **Modeling**, double-click the block, change the value, and simulate again (**Simulation → Simulate**). Previous results stay in the Variables Browser; untick them to avoid confusion.

---

## 9. Compare with the library example

Each tutorial ends by asking you to compare your model with the corresponding example in
**PatchClamp → Examples** (for instance `Step07_RefractoryPeriod`). Open the example, simulate it with its own
settings, and check that your traces overlay the example's. If they do not, compare the parameter tables,
connections and simulation setup one by one.

---

## 10. Typing code instead of dragging (only a few tutorials)

Two tutorials (*Step08* and *Step09*) have no circuit: they are small equation models. For these, the tutorial gives a short block
of Modelica text. To use it:

1. Create the model as in Section 2.
2. Switch to the **Text View** (button above the canvas).
3. Select all the text, delete it, and **paste** the code from the tutorial.
4. Save (**Ctrl+S**) and continue with Section 6 (Check Model).

---

## Quick reference

| I want to… | Do this |
|---|---|
| Open the library | File → Open Model/Library File(s) → `PatchClamp/package.mo` |
| New model | File → New Modelica Class… → Specialization *Model* |
| Add a block | Drag it from the Libraries Browser into the Diagram View |
| Rename a block | Double-click → General → Name |
| Set a parameter | Double-click → Parameters |
| Connect | Drag from one connector to the other |
| Check | Simulation → Check Model |
| Simulate | Simulation → Simulation Setup, then Simulate |
| Plot | Tick variables in the Variables Browser |
| Zoom | Zoom In tool, or scroll; Fit in View to reset |
