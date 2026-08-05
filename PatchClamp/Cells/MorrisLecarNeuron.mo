within PatchClamp.Cells;
model MorrisLecarNeuron
  "Morris-Lecar neuron (ML 1981): voltage-gated Ca2+/K+ channels, biophysical 2D model"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 200e-12,
    A   = 1000e-12,
    V_m(start = -0.060, fixed = true));
  // C_m = 200 pF, consistent with the original ML specific capacitance of
  // 20 uF/cm2 and membrane area A = 1000 um2 = 1e-5 cm2: C = 20e-6*1e-5 = 200 pF.
  // I_bifurcation (Type II) = 93.85 uA/cm2 * 1e-5 cm2 = 940 pA. At 20 pF
  // (10x too small) spikes would run 10x too fast (~400 Hz instead of ~40 Hz).

  // Default parameters are the Type II (Hopf bifurcation) set: oscillations
  // start abruptly once the current threshold is crossed.
  // Reference: Morris C, Lecar H (1981) Biophys J 35:193-213;
  //            Rinzel J, Ermentrout B (1989), Methods in Neuronal Modeling.

  parameter Real g_Ca(unit = "S/m2") = 44.0
    "Max Ca2+ conductance [S/m2] (4.4 mS/cm2, Type II)"
    annotation(Dialog(group = "Conductances"));

  parameter Real g_K(unit = "S/m2") = 80.0
    "Max K+ conductance [S/m2] (8.0 mS/cm2)"
    annotation(Dialog(group = "Conductances"));

  parameter Real g_L(unit = "S/m2") = 20.0
    "Leak conductance [S/m2] (2 mS/cm2, standard ML barnacle muscle value)"
    annotation(Dialog(group = "Conductances"));

  parameter Modelica.Units.SI.Voltage E_Ca = 0.120
    "Ca2+ reversal potential [V] (+120 mV)"
    annotation(Dialog(group = "Reversal potentials"));

  parameter Modelica.Units.SI.Voltage E_K = -0.084
    "K+ reversal potential [V] (-84 mV)"
    annotation(Dialog(group = "Reversal potentials"));

  parameter Modelica.Units.SI.Voltage E_L = -0.060
    "Leak reversal potential [V] (-60 mV)"
    annotation(Dialog(group = "Reversal potentials"));

  // m_inf(V) = 0.5*(1+tanh((V-V1)/V2))  -- instantaneous Ca2+ activation
  // w_inf(V) = 0.5*(1+tanh((V-V3)/V4))  -- slow K+ activation (variable w)

  parameter Modelica.Units.SI.Voltage V1 = -0.0012
    "Ca2+ half-activation potential [V] (-1.2 mV, Type II)"
    annotation(Dialog(group = "Activation curves"));

  parameter Modelica.Units.SI.Voltage V2 = 0.018
    "Ca2+ activation slope [V] (18 mV, Type II)"
    annotation(Dialog(group = "Activation curves"));

  parameter Modelica.Units.SI.Voltage V3 = 0.002
    "K+ half-activation potential [V] (2 mV, Type II)"
    annotation(Dialog(group = "Activation curves"));

  parameter Modelica.Units.SI.Voltage V4 = 0.030
    "K+ activation slope [V] (30 mV, Type II)"
    annotation(Dialog(group = "Activation curves"));

  parameter Real phi(unit = "1/s") = 40.0
    "Relaxation rate of w [1/s] (phi = 0.04 in [1/ms] convention = 40 [1/s]);
     sets the speed of the slow K+ variable";

  Real w(start = 0.015, fixed = true)
    "K+ activation [-] (slow recovery variable, 0..1); loosely analogous to
     Hodgkin-Huxley's n gate, but slower";

  Real m_inf "Steady-state Ca2+ activation [-] (instantaneous, no ODE)";

  Real w_inf "Steady-state K+ activation [-] (the target that w relaxes toward)";

  Real tau_w(unit = "s")
    "Time constant of w [s] = 1 / (phi * cosh((V_m - V3) / (2*V4)))";

  Modelica.Units.SI.Current I_Ca "Ca2+ current [A] (typically inward/negative)";
  Modelica.Units.SI.Current I_K  "K+ current [A] (typically outward/positive)";
  Modelica.Units.SI.Current I_L  "Ohmic leak current [A]";

equation
  // tanh is never singular, so m_inf needs no numerical guard
  m_inf = 0.5 * (1.0 + tanh((V_m - V1) / V2));

  w_inf = 0.5 * (1.0 + tanh((V_m - V3) / V4));

  // cosh >= 1 always, so tau_w > 0 always -- no singularity
  tau_w = 1.0 / (phi * cosh((V_m - V3) / (2.0 * V4)));

  der(w) = (w_inf - w) / tau_w;

  I_Ca = g_Ca * m_inf * (V_m - E_Ca) * A;
  I_K  = g_K  * w     * (V_m - E_K)  * A;
  I_L  = g_L          * (V_m - E_L)  * A;

  I_total = I_Ca + I_K + I_L;

  annotation(
    Documentation(info = "<html>
      <h2>MorrisLecarNeuron</h2>
      <p>
        The Morris-Lecar model for the barnacle giant muscle fiber
        (<em>Balanus nubilus</em>):
      </p>
      <blockquote>
        Morris C, Lecar H (1981). Voltage oscillations in the barnacle giant
        muscle fiber. <em>Biophys J</em> <b>35</b>: 193-213.
      </blockquote>
      <p>
        It's the simplest biophysical model that keeps two state variables
        with a direct physical interpretation (voltage and an ionic gate),
        unlike FitzHugh-Nagumo's dimensionless variables, and it can show
        either Type I or Type II excitability depending on its parameters.
      </p>
      <pre>
  C_m * dV/dt = I_ext - I_Ca - I_K - I_L

  I_Ca = g_Ca * m_inf(V) * (V - E_Ca)   [instantaneous activation]
  I_K  = g_K  * w        * (V - E_K)    [slow activation]
  I_L  = g_L             * (V - E_L)    [ohmic leak]

  m_inf(V) = 0.5 * (1 + tanh((V - V1) / V2))
  w_inf(V) = 0.5 * (1 + tanh((V - V3) / V4))
  tau_w(V) = 1 / (phi * cosh((V - V3) / (2*V4)))

  dw/dt = (w_inf(V) - w) / tau_w(V)
      </pre>
      <p>
        The defaults are the Type II set, where oscillations start abruptly
        via a subcritical Hopf bifurcation once the current threshold is
        crossed:
      </p>
      <pre>
  V1 = -1.2 mV, V2 = 18 mV   (Ca2+ activates near rest)
  V3 =  2.0 mV, V4 = 30 mV   (K+ activates at more positive voltages)
  phi = 40 [1/s]  (tau_w ~ 25 ms near threshold)
  Firing/oscillation threshold: I_ext ~ 1.5 pA for this cell size, with an
  abrupt onset and no graded sub-threshold zone.
      </pre>
      <p>To switch to Type I (SNIC bifurcation, continuous f-I relationship):</p>
      <pre>
  V3 = 12 mV, V4 = 17.4 mV
  phi = 23.3 [1/s]
      </pre>
      <p>
        Compared to Hodgkin-Huxley: only 2 ODEs instead of 4 (faster to
        simulate); a Ca2+ channel instead of Na+, with instantaneous
        activation (no m^3*h); a single K+ gate rather than separate
        activation/inactivation; no mV/V conversion needed since the
        equations use V directly; and both excitability classes are
        reachable just by adjusting V3, V4, and phi.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/MorrisLecarNeuron.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-90, 100}, {90, 90}},
        textString = "Morris-Lecar model: Ca2+ (instantaneous) + K+ (slow) + leak",
        textColor = {120, 120, 120},
        fontSize = 11),
      Line(points = {{-80, 75}, {-80, -75}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{80, 75}, {80, -75}},   color = {0, 150, 0}, thickness = 1.5),
      Text(extent = {{-110, 88}, {-55, 78}}, textString = "membrane_p", textColor = {0, 0, 200},   fontSize = 9),
      Text(extent = {{55, 88},  {110, 78}},  textString = "membrane_n", textColor = {0, 150, 0},   fontSize = 9),
      // Branch 1: C_m
      Line(points = {{-80, 60}, {-12, 60}}, color = {0, 0, 200}),
      Line(points = {{-12, 48}, {-12, 72}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{12, 48},  {12, 72}},  color = {80, 80, 80}, thickness = 3),
      Line(points = {{12, 60},  {80, 60}},  color = {0, 150, 0}),
      Text(extent = {{-50, 78}, {50, 70}}, textString = "C_m = 200 pF", textColor = {80, 80, 80}, fontSize = 9),
      // Branch 2: Ca2+ channel (instantaneous, g_Ca * m_inf)
      Line(points = {{-80, 20}, {-62, 20}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, 28}, {-22, 12}},
        lineColor = {200, 80, 0},
        fillColor = {255, 230, 200},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-60, 27}, {-24, 13}}, textString = "g_Ca*m_inf", textColor = {200, 80, 0}, fontSize = 8),
      Line(points = {{-22, 20}, {0, 20}},   color = {200, 80, 0}),
      Line(points = {{0, 28},  {0, 12}},    color = {200, 80, 0}, thickness = 2.5),
      Line(points = {{10, 24}, {10, 16}},   color = {200, 80, 0}, thickness = 1),
      Line(points = {{10, 20}, {80, 20}},   color = {0, 150, 0}),
      Text(extent = {{-20, 38}, {80, 30}},  textString = "E_Ca = +120 mV", textColor = {200, 80, 0}, fontSize = 8),
      // Branch 3: K+ channel (slow, g_K * w)
      Line(points = {{-80, -20}, {-62, -20}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, -12}, {-22, -28}},
        lineColor = {0, 0, 180},
        fillColor = {220, 220, 255},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-60, -13}, {-24, -27}}, textString = "g_K * w", textColor = {0, 0, 180}, fontSize = 8),
      Line(points = {{-22, -20}, {0, -20}},   color = {0, 0, 180}),
      Line(points = {{0, -12},  {0, -28}},    color = {0, 0, 180}, thickness = 2.5),
      Line(points = {{10, -16}, {10, -24}},   color = {0, 0, 180}, thickness = 1),
      Line(points = {{10, -20}, {80, -20}},   color = {0, 150, 0}),
      Text(extent = {{-20, -2}, {80, -10}},   textString = "E_K = -84 mV", textColor = {0, 0, 180}, fontSize = 8),
      // Branch 4: leak
      Line(points = {{-80, -60}, {-62, -60}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, -52}, {-22, -68}},
        lineColor = {100, 100, 0},
        fillColor = {255, 255, 200},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-60, -53}, {-24, -67}}, textString = "g_L (leak)", textColor = {100, 100, 0}, fontSize = 8),
      Line(points = {{-22, -60}, {0, -60}},   color = {100, 100, 0}),
      Line(points = {{0, -52},  {0, -68}},    color = {100, 100, 0}, thickness = 2.5),
      Line(points = {{10, -56}, {10, -64}},   color = {100, 100, 0}, thickness = 1),
      Line(points = {{10, -60}, {80, -60}},   color = {0, 150, 0}),
      Text(extent = {{-20, -42}, {80, -50}},  textString = "E_L = -60 mV", textColor = {100, 100, 0}, fontSize = 8)
    })
  );
end MorrisLecarNeuron;
