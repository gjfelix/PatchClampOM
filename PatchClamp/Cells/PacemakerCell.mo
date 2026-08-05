within PatchClamp.Cells;
model PacemakerCell
  "Sinoatrial pacemaker cell -- spontaneous automaticity via the funny current I_f (HCN)"

  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 20.0e-12,
    A   = 1000.0e-12,
    V_m(start = -0.065, fixed = true));

  // I_f (funny current, HCN channel) -- unique among these models in that
  // it activates on HYPERPOLARIZATION (inverted sign vs. every other channel)
  parameter Real g_f(unit = "S/m2") = 0.014
    "Max I_f (HCN) conductance [S/m2].
     Sets the firing rate: higher g_f gives a faster diastolic depolarization
     and more beats/s. T_cycle = K/g_f + c, with K=0.0056 and c=0.44 s
     (upstroke+repolarization time). g_f=0.014 -> T~0.85 s (~70 bpm);
     g_f=0.005 -> T~1.6 s (bradycardia). To modulate rate via I_f directly,
     prefer changing V_f_half over g_f."
    annotation(Dialog(group = "Maximum conductances"));
  parameter Modelica.Units.SI.Voltage E_f = -0.010
    "I_f reversal potential [V] (mixed Na+/K+, ~-10 mV)"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage V_f_half = -0.058
    "I_f half-activation voltage [V].
     At -58 mV, I_f is 50% active; at -65 mV, 73% active. Useful range:
     -80 mV (fully open) to -35 mV (nearly closed). Shift toward -0.045 for
     a tachycardia-like effect, or -0.075 for bradycardia."
    annotation(Dialog(group = "I_f kinetics"));
  parameter Modelica.Units.SI.Voltage k_f = 0.007
    "I_f activation slope [V]"
    annotation(Dialog(group = "I_f kinetics"));
  parameter Modelica.Units.SI.Time tau_y = 600.0e-3
    "Time constant of the I_f gate y [s] (600 ms -> cycle ~0.8 Hz, ~75 bpm)"
    annotation(Dialog(group = "I_f kinetics"));

  parameter Real g_Ca(unit = "S/m2") = 0.5
    "Max L-type Ca2+ conductance [S/m2] (slow upstroke, Cav1.3 in the SAN)"
    annotation(Dialog(group = "Maximum conductances"));
  parameter Modelica.Units.SI.Voltage E_Ca = 0.060
    "Ca2+ reversal potential [V]"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage V_d_half = -0.030
    "I_Ca half-activation voltage [V] (Cav1.3 in the SAN: threshold ~-40 mV, mid ~-30 mV).
     Must be reachable by diastolic depolarization (i.e. below ~-35 mV); an
     earlier value of -0.010 kept I_Ca from ever activating, so the cell never fired."
    annotation(Dialog(group = "Ca kinetics"));
  parameter Modelica.Units.SI.Voltage k_d = 0.008
    "I_Ca activation slope [V]"
    annotation(Dialog(group = "Ca kinetics"));

  parameter Real g_K(unit = "S/m2") = 4.0
    "Max I_K conductance [S/m2]"
    annotation(Dialog(group = "Maximum conductances"));
  parameter Modelica.Units.SI.Voltage E_K = -0.080
    "K+ reversal potential [V]"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage V_n_half = -0.020
    "I_K half-activation voltage [V]"
    annotation(Dialog(group = "K kinetics"));
  parameter Modelica.Units.SI.Voltage k_n = 0.012
    "I_K activation slope [V]"
    annotation(Dialog(group = "K kinetics"));
  parameter Modelica.Units.SI.Time tau_n = 150.0e-3
    "Time constant of the I_K gate n [s]"
    annotation(Dialog(group = "K kinetics"));

  parameter Real g_L(unit = "S/m2") = 0.02
    "Leak conductance [S/m2].
     Must stay small: a larger g_L with E_L above V_rest creates a stable
     fixed point that blocks automaticity. g_L=0.02 with E_L=-80 mV keeps
     I_L near 0 at rest, rising only during the upstroke."
    annotation(Dialog(group = "Maximum conductances"));
  parameter Modelica.Units.SI.Voltage E_L = -0.080
    "Leak reversal potential [V].
     Matches E_K=-80 mV so leak contributes no current during the
     post-AP hyperpolarization where I_f recharges. An earlier value of
     -0.062 created a stable fixed point near -52 mV that blocked automaticity."
    annotation(Dialog(group = "Reversal potentials"));

  Real y(start = 0.50, fixed = true)
    "I_f (HCN) gate: 1 = open on hyperpolarization, 0 = closed on depolarization.
     start=0.50 is close to y_inf(-65 mV)=0.73, so it opens quickly from the start.";
  Real n(start = 0.035, fixed = true)
    "Delayed I_K gate: 0 = closed at rest";

  Real d_inf "Instantaneous L-type Ca2+ activation (0-1)";

  Real y_inf "Steady-state I_f activation (HIGH on hyperpolarization -- inverted)";
  Real n_inf "Steady-state I_K activation";

  Modelica.Units.SI.Current I_f  "Funny current [A] (negative = inward = depolarizing in diastole)";
  Modelica.Units.SI.Current I_Ca "L-type Ca2+ current [A] -- drives the sinus AP upstroke";
  Modelica.Units.SI.Current I_K  "Delayed K+ current [A] (positive = outward = repolarizing)";
  Modelica.Units.SI.Current I_L  "Leak current [A]";

equation
  // Boltzmann gating (no singularities). Compare the exponent signs:
  //   I_f (y_inf):   exp(+(V_m - V_half)/k)  -- inverted, activates on hyperpolarization
  //   I_Ca / I_K:    exp(-(V_m - V_half)/k)  -- normal,   activates on depolarization
  y_inf = 1.0 / (1.0 + exp( (V_m - V_f_half) / k_f));
  d_inf = 1.0 / (1.0 + exp(-(V_m - V_d_half) / k_d));
  n_inf = 1.0 / (1.0 + exp(-(V_m - V_n_half) / k_n));

  der(y) = (y_inf - y) / tau_y;
  der(n) = (n_inf - n) / tau_n;

  I_f  = g_f  * y     * (V_m - E_f)  * A;
  I_Ca = g_Ca * d_inf * (V_m - E_Ca) * A;
  I_K  = g_K  * n^2   * (V_m - E_K)  * A;
  I_L  = g_L          * (V_m - E_L)  * A;

  I_total = I_f + I_Ca + I_K + I_L;

  annotation(
    Documentation(info = "<html>
      <h2>PacemakerCell</h2>
      <p>
        A 3-state-variable model (V_m, y, n) reproducing sinoatrial
        automaticity: rhythmic action potentials with no external stimulus,
        driven by the funny current I_f through HCN
        (Hyperpolarization-activated Cyclic Nucleotide-gated) channels.
      </p>

      <h3>The automaticity cycle</h3>
      <ol>
        <li>Repolarization brings V_m down to about -70 mV.</li>
        <li>y_inf rises and y opens slowly (tau_y = 600 ms).</li>
        <li>I_f flows inward (V_m &lt; E_f = -10 mV), producing the slow diastolic depolarization (~66 mV/s).</li>
        <li>V_m reaches about -10 mV; d_inf rises and I_Ca fires the upstroke.</li>
        <li>n grows, I_K repolarizes the cell, and the cycle repeats from step 1.</li>
      </ol>

      <p>
        I_f's defining trait is activating on hyperpolarization -- the
        opposite of Na+, K+, and Ca2+ channels, and in that sense the
        functional mirror image of the Hodgkin-Huxley Na+ channel. As a
        result, this cell has no stable resting point at all: unlike the
        neuron models (HH, ML, FHN) or <code>CardiacVentricularCell</code>,
        every physiological V_m generates enough net current to fire
        again -- which is the essence of cardiac automaticity.
      </p>

      <h3>Autonomic modulation</h3>
      <table border='1'>
        <tr><th>Effect</th><th>Parameter change</th><th>Result</th></tr>
        <tr><td>Sympathetic (faster rate)</td><td>V_f_half: -65 &#8594; -50 mV</td><td>I_f activates earlier &#8594; higher rate</td></tr>
        <tr><td>Parasympathetic (slower rate)</td><td>V_f_half: -65 &#8594; -80 mV</td><td>I_f activates later &#8594; lower rate</td></tr>
        <tr><td>Ivabradine (I_f blocker)</td><td>g_f: 0.014 &#8594; 0.0</td><td>No I_f &#8594; no automaticity</td></tr>
      </table>

      <table border='1'>
        <tr><th></th><th>SAN (pacemaker)</th><th>Ventricular</th></tr>
        <tr><td>Automaticity</td><td>yes (spontaneous)</td><td>no</td></tr>
        <tr><td>I_f</td><td>present (the driver)</td><td>absent</td></tr>
        <tr><td>Fast I_Na</td><td>absent</td><td>present (upstroke)</td></tr>
        <tr><td>Upstroke</td><td>I_Ca (~5 V/s)</td><td>I_Na (~200 V/s)</td></tr>
        <tr><td>AP peak</td><td>~+10 mV</td><td>~+30 mV</td></tr>
        <tr><td>Rate</td><td>~1-3 Hz, spontaneous</td><td>stimulus-driven only</td></tr>
        <tr><td>Initial V_m</td><td>-60 mV (not stable)</td><td>-80 mV (stable)</td></tr>
      </table>

      <blockquote>
        Di Francesco D (1993). Pacemaker mechanisms in cardiac tissue.
        <em>Annu Rev Physiol</em> <b>55</b>: 455-472.
      </blockquote>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PacemakerCell.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-110, 88}, {110, 78}},
        textString = "PacemakerCell: I_f(HCN) + I_Ca(L-type) + I_K + I_L -- sinoatrial automaticity",
        textColor = {80, 80, 80},
        fontSize = 10),
      Line(points = {{-90, -10}, {90, -10}}, color = {0, 0, 0}, thickness = 2.0),
      Line(points = {{-90,  60}, {90,  60}}, color = {0, 0, 0}, thickness = 2.0),
      // C_m (gray)
      Line(points = {{-88, -10}, {-88, 60}}, color = {80, 80, 80}, thickness = 1.5),
      Line(points = {{-84, 30}, {-92, 30}}, color = {80, 80, 80}, thickness = 3.0),
      Line(points = {{-84, 25}, {-92, 25}}, color = {80, 80, 80}, thickness = 3.0),
      Text(extent = {{-95, 45}, {-75, 37}}, textString = "Cm", textColor = {80, 80, 80}, fontSize = 8),
      // I_f (purple) -- inverted
      Line(points = {{-55, -10}, {-55, 60}}, color = {130, 0, 180}, thickness = 1.5),
      Line(points = {{-40, -10}, {-40, 60}}, color = {130, 0, 180}, thickness = 1.5),
      Rectangle(extent = {{-54, 45}, {-41, 35}}, lineColor = {130, 0, 180}, fillColor = {230, 200, 255}, fillPattern = FillPattern.Solid),
      Text(extent = {{-54, 44}, {-41, 36}}, textString = "y", textColor = {130, 0, 180}, fontSize = 9),
      Line(points = {{-47, 22}, {-47, 16}}, color = {130, 0, 180}, thickness = 1.5),
      Line(points = {{-54, 16}, {-40, 16}}, color = {130, 0, 180}, thickness = 2.5),
      Line(points = {{-54, 12}, {-40, 12}}, color = {130, 0, 180}, thickness = 2.5),
      Text(extent = {{-55, 10}, {-39, 3}},  textString = "E_f",  textColor = {130, 0, 180}, fontSize = 7),
      Text(extent = {{-55, 70}, {-39, 62}}, textString = "I_f",  textColor = {130, 0, 180}, fontSize = 9),
      Text(extent = {{-56, -24}, {-39, -32}}, textString = "INVERTED", textColor = {130, 0, 180}, fontSize = 6),
      // I_Ca (orange)
      Line(points = {{-15, -10}, {-15, 60}}, color = {220, 100, 0}, thickness = 1.5),
      Line(points = {{5,   -10}, {5,   60}}, color = {220, 100, 0}, thickness = 1.5),
      Rectangle(extent = {{-14, 45}, {4, 35}}, lineColor = {220, 100, 0}, fillColor = {255, 225, 185}, fillPattern = FillPattern.Solid),
      Text(extent = {{-13, 44}, {3, 36}}, textString = "d_inf", textColor = {220, 100, 0}, fontSize = 7),
      Line(points = {{-5, 22}, {-5, 16}}, color = {220, 100, 0}, thickness = 1.5),
      Line(points = {{-12, 16}, {2, 16}}, color = {220, 100, 0}, thickness = 2.5),
      Line(points = {{-12, 12}, {2, 12}}, color = {220, 100, 0}, thickness = 2.5),
      Text(extent = {{-13, 10}, {3, 3}},  textString = "E_Ca", textColor = {220, 100, 0}, fontSize = 7),
      Text(extent = {{-15, 70}, {5, 62}}, textString = "I_Ca", textColor = {220, 100, 0}, fontSize = 9),
      // I_K (blue)
      Line(points = {{25, -10}, {25, 60}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{45, -10}, {45, 60}}, color = {0, 0, 200}, thickness = 1.5),
      Rectangle(extent = {{26, 45}, {44, 35}}, lineColor = {0, 0, 200}, fillColor = {200, 210, 255}, fillPattern = FillPattern.Solid),
      Text(extent = {{27, 44}, {43, 36}}, textString = "n2", textColor = {0, 0, 200}, fontSize = 7),
      Line(points = {{35, 22}, {35, 16}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{28, 16}, {42, 16}}, color = {0, 0, 200}, thickness = 2.5),
      Line(points = {{28, 12}, {42, 12}}, color = {0, 0, 200}, thickness = 2.5),
      Text(extent = {{27, 10}, {43, 3}},  textString = "E_K",  textColor = {0, 0, 200}, fontSize = 7),
      Text(extent = {{25, 70}, {45, 62}}, textString = "I_K",  textColor = {0, 0, 200}, fontSize = 9),
      // I_L (yellow)
      Line(points = {{65, -10}, {65, 60}}, color = {160, 120, 0}, thickness = 1.5),
      Line(points = {{80, -10}, {80, 60}}, color = {160, 120, 0}, thickness = 1.5),
      Rectangle(extent = {{66, 45}, {79, 32}}, lineColor = {160, 120, 0}, fillColor = {255, 248, 180}, fillPattern = FillPattern.Solid),
      Text(extent = {{67, 44}, {78, 33}}, textString = "gL", textColor = {160, 120, 0}, fontSize = 8),
      Text(extent = {{63, 70}, {82, 62}}, textString = "I_L",  textColor = {160, 120, 0}, fontSize = 9),
      // Pins
      Line(points = {{-110, 25}, {-88, 25}}, color = {0, 0, 255}, thickness = 2.0),
      Line(points = {{80,   25}, {110, 25}}, color = {0, 0, 200}, thickness = 2.0),
      Text(extent = {{-108, 35}, {-85, 27}}, textString = "p", textColor = {0, 0, 200}, fontSize = 10),
      Text(extent = {{80,   35}, {108, 27}}, textString = "n", textColor = {0, 0, 200}, fontSize = 10)
    })
  );
end PacemakerCell;
