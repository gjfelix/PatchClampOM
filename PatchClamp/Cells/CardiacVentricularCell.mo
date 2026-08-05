within PatchClamp.Cells;
model CardiacVentricularCell
  "Simplified cardiac ventricular cell -- long action potential with a Ca2+ plateau"

  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 100.0e-12,
    A   = 1500.0e-12,
    V_m(start = -0.084, fixed = true));  // V_rest = E_K = E_L = -84 mV

  // Conductances in S/m2 (1 mS/cm2 = 10 S/m2); numeric values are the
  // Beeler-Reuter (1977) mS/cm2 figures scaled by 10.
  parameter Real g_Na(unit = "S/m2") = 230.0
    "Max fast Na+ conductance [S/m2] (23 mS/cm2, Beeler-Reuter 1977)"
    annotation(Dialog(group = "Maximum conductances"));
  parameter Real g_Ca(unit = "S/m2") = 3.0
    "Max L-type Ca2+ conductance [S/m2] (0.3 mS/cm2).
     With f_Ca_ss = 0.62 on the plateau, equilibrium
     V_p = (3*0.62*0.12 + 2*(-0.084)) / (3*0.62+2) ~ +9 mV."
    annotation(Dialog(group = "Maximum conductances"));
  parameter Real g_K(unit = "S/m2") = 1.0
    "Max delayed-rectifier K+ (IKr) conductance [S/m2] (0.1 mS/cm2).
     Kept low to delay Phase 3 to ~200 ms post-upstroke, giving APD90 ~ 250-300 ms."
    annotation(Dialog(group = "Maximum conductances"));
  parameter Real g_L(unit = "S/m2") = 2.0
    "Leak conductance [S/m2] (0.2 mS/cm2)"
    annotation(Dialog(group = "Maximum conductances"));

  parameter Modelica.Units.SI.Voltage E_Na = 0.050
    "Na+ reversal potential [V]"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage E_Ca = 0.120
    "Ca2+ reversal potential [V]"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage E_K  = -0.084
    "K+ reversal potential [V]"
    annotation(Dialog(group = "Reversal potentials"));
  parameter Modelica.Units.SI.Voltage E_L  = -0.084
    "Leak (resting) reversal potential [V].
     Must match V_m(start) = E_K = -0.084 V for a stable rest; if E_L differs
     from V_rest the cell slowly drifts and inactivates h_Na."
    annotation(Dialog(group = "Reversal potentials"));

  parameter Modelica.Units.SI.Time tau_m = 0.5e-3
    "Na+ activation time constant [s] (0.5 ms -- fast)"
    annotation(Dialog(group = "Kinetics"));
  parameter Modelica.Units.SI.Time tau_h = 8.0e-3
    "Na+ inactivation time constant [s] (8 ms -- intermediate)"
    annotation(Dialog(group = "Kinetics"));
  parameter Modelica.Units.SI.Time tau_n = 200.0e-3
    "IKr time constant [s] (200 ms -- slow; sets the plateau length)"
    annotation(Dialog(group = "Kinetics"));
  parameter Modelica.Units.SI.Time tau_f = 300.0e-3
    "L-type Ca2+ inactivation time constant [s] (300 ms).
     f_Ca decays from 1.0 toward f_inf = 0.62 with this time constant, so
     I_Ca persists for over 200 ms, balancing I_L and keeping the plateau flat."
    annotation(Dialog(group = "Kinetics"));
  parameter Real g_K1(unit = "S/m2") = 10.0
    "Inward-rectifier (IK1) conductance [S/m2] (1 mS/cm2).
     V_half = -40 mV: IK1 is near 0 during the plateau (0 to +50 mV), but
     opens strongly below -40 mV to accelerate Phase 3 and clamp rest."
    annotation(Dialog(group = "Maximum conductances"));

  Real m_Na(start = 0.004, fixed = true)
    "Na+ activation gate (0-1) -- m_inf at V_rest = -84 mV";
  Real h_Na(start = 0.784, fixed = true)
    "Na+ inactivation gate (0-1) -- h_inf at V_rest = -84 mV";
  Real n_K(start  = 0.005, fixed = true)
    "IKr activation gate (0-1) -- n_inf at V_rest = -84 mV";

  Real f_Ca(start = 1.0, fixed = true)
    "L-type Ca2+ inactivation (0-1); 1 = open at rest, decays through the
     plateau (tau_f) to limit I_Ca's duration and drive Phase 3 repolarization";

  Real d_inf "Instantaneous L-type Ca2+ activation (0-1)";

  Real m_inf "Na+ steady-state activation (0-1)";
  Real h_inf "Na+ steady-state inactivation (0-1)";
  Real n_inf "IKr steady-state activation (0-1)";
  Real f_inf "Ca2+ steady-state inactivation (0-1) -- decreases with depolarization";
  Real K1_inf "IK1 instantaneous rectification (0-1)";

  Modelica.Units.SI.Current I_Na "Fast Na+ current [A] (negative = inward = depolarizing)";
  Modelica.Units.SI.Current I_Ca "L-type Ca2+ current [A] (negative = sustains the plateau)";
  Modelica.Units.SI.Current I_K  "IKr current [A] (positive = outward = repolarizing)";
  Modelica.Units.SI.Current I_K1 "Inward-rectifier current [A] (large at rest, ~0 on the plateau)";
  Modelica.Units.SI.Current I_L  "Leak current [A]";

equation
  // Boltzmann gating functions (no singularities)
  m_inf = 1.0 / (1.0 + exp(-(V_m + 0.045) / 0.007));  // Na+ activation: V_half=-45mV, slope=7mV
  h_inf = 1.0 / (1.0 + exp( (V_m + 0.075) / 0.007));  // Na+ inactivation: V_half=-75mV, slope=7mV
  n_inf = 1.0 / (1.0 + exp(-(V_m + 0.020) / 0.012));  // IKr activation: V_half=-20mV, slope=12mV
  d_inf = 1.0 / (1.0 + exp(-(V_m + 0.010) / 0.008));  // Ca2+ L-type: V_half=-10mV, slope=8mV

  // Ca2+ inactivation: V_half=+20mV, slope=20mV. f_inf(+10mV)=0.62,
  // f_inf(+40mV)=0.27, so f_Ca settles near 0.62 through the plateau,
  // keeping a window current alive; an earlier V_half of -35mV drove
  // f_inf to 0 on the plateau, producing a dome instead of a flat plateau.
  f_inf = 1.0 / (1.0 + exp( (V_m - 0.020) / 0.020));

  // IK1 inward rectifier: V_half=-40mV, slope=6mV -- closed above -20mV
  // (plateau, no notch), open below -50mV (Phase 3, rest);
  // K1_inf(-80mV)=1, K1_inf(0mV)~0.
  K1_inf = 1.0 / (1.0 + exp( (V_m + 0.040) / 0.006));

  der(m_Na) = (m_inf - m_Na) / tau_m;
  der(h_Na) = (h_inf - h_Na) / tau_h;
  der(n_K)  = (n_inf - n_K)  / tau_n;
  der(f_Ca) = (f_inf - f_Ca) / tau_f;

  I_Na = g_Na * m_Na^3 * h_Na  * (V_m - E_Na) * A;
  I_Ca = g_Ca * d_inf  * f_Ca  * (V_m - E_Ca) * A;
  I_K  = g_K  * n_K^2          * (V_m - E_K)  * A;
  I_K1 = g_K1 * K1_inf         * (V_m - E_K)  * A;
  I_L  = g_L                   * (V_m - E_L)  * A;

  I_total = I_Na + I_Ca + I_K + I_K1 + I_L;

  annotation(
    Documentation(info = "<html>
      <h2>CardiacVentricularCell</h2>
      <p>
        A 4-state-variable model (V_m, m_Na, h_Na, n_K) inspired by Beeler
        and Reuter (1977), reproducing the three phases of the ventricular
        action potential with singularity-free Boltzmann gating functions.
      </p>

      <table border='1'>
        <tr><th>Phase</th><th>Duration</th><th>Dominant current</th></tr>
        <tr><td>0 -- upstroke</td>   <td>~1 ms</td>   <td>I_Na (fast inward)</td></tr>
        <tr><td>1 -- fast repolarization</td><td>~10 ms</td><td>h_Na decays, I_Na shuts off</td></tr>
        <tr><td>2 -- plateau</td><td>~150 ms</td><td>I_Ca balanced against I_K + I_L</td></tr>
        <tr><td>3 -- repolarization</td><td>~50 ms</td><td>n_K grows, I_K dominates</td></tr>
        <tr><td>4 -- rest</td>     <td>stable</td>  <td>I_L holds -84 mV</td></tr>
      </table>

      <table border='1'>
        <tr><th></th><th>HH (squid)</th><th>Cardiac (ventricular)</th></tr>
        <tr><td>AP duration</td><td>~2 ms</td><td>~200 ms</td></tr>
        <tr><td>Ca2+ channel</td><td>absent</td><td>present (L-type I_Ca)</td></tr>
        <tr><td>Max firing rate</td><td>~100 Hz</td><td>~5 Hz</td></tr>
        <tr><td>C_m</td><td>10 pF</td><td>100 pF</td></tr>
        <tr><td>tau_K</td><td>~10 ms</td><td>~200 ms</td></tr>
        <tr><td>Refractory period</td><td>~5 ms</td><td>~250 ms</td></tr>
      </table>

      <h3>The plateau mechanism</h3>
      <p>
        On the plateau (~0 mV), h_Na has decayed to zero (I_Na is off) but
        d_inf is ~0.78, keeping I_Ca active. Repolarization begins once n_K
        has grown enough for I_K to overtake I_Ca + I_L; with tau_n = 200 ms
        that takes roughly 150 ms.
      </p>

      <p>
        I_Ca uses instantaneous activation (algebraic d_inf), as in the
        Morris-Lecar Ca2+ current; a more detailed model would add a slow
        inactivation variable, but this already reproduces the plateau
        correctly. See <code>PacemakerCell</code> (used in
        <code>Step17_PacemakerAutorhythmicity</code>) for a model dedicated
        to nodal automaticity via the funny current I_f.
      </p>

      <blockquote>
        Beeler GW, Reuter H (1977). Reconstruction of the action potential
        of ventricular myocardial fibres. <em>J Physiol</em> <b>268</b>: 177-210.
      </blockquote>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/CardiacVentricularCell.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-110, 88}, {110, 78}},
        textString = "CardiacVentricularCell: I_Na + I_Ca(L) + I_K(IKr) + I_L",
        textColor = {80, 80, 80},
        fontSize = 10),
      Line(points = {{-90, -10}, {90, -10}}, color = {0, 0, 0}, thickness = 2.0),
      Line(points = {{-90,  60}, {90,  60}}, color = {0, 0, 0}, thickness = 2.0),
      // C_m (gray, far left)
      Line(points = {{-88, -10}, {-88, 60}}, color = {80, 80, 80}, thickness = 1.5),
      Line(points = {{-84, 30}, {-92, 30}}, color = {80, 80, 80}, thickness = 3.0),
      Line(points = {{-84, 25}, {-92, 25}}, color = {80, 80, 80}, thickness = 3.0),
      Text(extent = {{-95, 45}, {-75, 37}}, textString = "Cm", textColor = {80, 80, 80}, fontSize = 8),
      // I_Na (red)
      Line(points = {{-55, -10}, {-55, 60}}, color = {200, 0, 0}, thickness = 1.5),
      Line(points = {{-40, -10}, {-40, 60}}, color = {200, 0, 0}, thickness = 1.5),
      Rectangle(extent = {{-54, 45}, {-41, 35}}, lineColor = {200, 0, 0}, fillColor = {255, 200, 200}, fillPattern = FillPattern.Solid),
      Text(extent = {{-54, 44}, {-41, 36}}, textString = "m3h", textColor = {200, 0, 0}, fontSize = 7),
      Line(points = {{-47, 22}, {-47, 16}}, color = {200, 0, 0}, thickness = 1.5),
      Line(points = {{-54, 16}, {-40, 16}}, color = {200, 0, 0}, thickness = 2.5),
      Line(points = {{-54, 12}, {-40, 12}}, color = {200, 0, 0}, thickness = 2.5),
      Text(extent = {{-55, 10}, {-39, 3}},  textString = "E_Na",  textColor = {200, 0, 0}, fontSize = 7),
      Text(extent = {{-55, 70}, {-39, 62}}, textString = "I_Na",  textColor = {200, 0, 0}, fontSize = 9),
      // I_Ca (orange)
      Line(points = {{-15, -10}, {-15, 60}}, color = {220, 100, 0}, thickness = 1.5),
      Line(points = {{5,   -10}, {5,   60}}, color = {220, 100, 0}, thickness = 1.5),
      Rectangle(extent = {{-14, 45}, {4, 35}}, lineColor = {220, 100, 0}, fillColor = {255, 225, 185}, fillPattern = FillPattern.Solid),
      Text(extent = {{-13, 44}, {3, 36}}, textString = "d_inf", textColor = {220, 100, 0}, fontSize = 7),
      Line(points = {{-5, 22}, {-5, 16}}, color = {220, 100, 0}, thickness = 1.5),
      Line(points = {{-12, 16}, {2, 16}}, color = {220, 100, 0}, thickness = 2.5),
      Line(points = {{-12, 12}, {2, 12}}, color = {220, 100, 0}, thickness = 2.5),
      Text(extent = {{-13, 10}, {3, 3}},  textString = "E_Ca",  textColor = {220, 100, 0}, fontSize = 7),
      Text(extent = {{-15, 70}, {5, 62}}, textString = "I_Ca",  textColor = {220, 100, 0}, fontSize = 9),
      // I_K (blue)
      Line(points = {{25, -10}, {25, 60}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{45, -10}, {45, 60}}, color = {0, 0, 200}, thickness = 1.5),
      Rectangle(extent = {{26, 45}, {44, 35}}, lineColor = {0, 0, 200}, fillColor = {200, 210, 255}, fillPattern = FillPattern.Solid),
      Text(extent = {{27, 44}, {43, 36}}, textString = "n2", textColor = {0, 0, 200}, fontSize = 7),
      Line(points = {{35, 22}, {35, 16}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{28, 16}, {42, 16}}, color = {0, 0, 200}, thickness = 2.5),
      Line(points = {{28, 12}, {42, 12}}, color = {0, 0, 200}, thickness = 2.5),
      Text(extent = {{27, 10}, {43, 3}},  textString = "E_K",   textColor = {0, 0, 200}, fontSize = 7),
      Text(extent = {{25, 70}, {45, 62}}, textString = "I_K",   textColor = {0, 0, 200}, fontSize = 9),
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
end CardiacVentricularCell;
