within PatchClamp.Cells;
model HodgkinHuxleyNeuron
  "Hodgkin-Huxley neuron with Na+, K+, and leak channels (HH 1952)"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 10e-12,
    A   = 1000e-12);

  // Maximum conductances [S/m2]. 1 mS/cm2 = 10 S/m2 (e.g. 120 mS/cm2 = 1200 S/m2)
  parameter Real g_Na_max(unit = "S/m2") = 1200.0
    "Max Na+ conductance [S/m2] (120 mS/cm2, HH 1952)";

  parameter Real g_K_max(unit = "S/m2") = 360.0
    "Max K+ conductance [S/m2] (36 mS/cm2, HH 1952)";

  parameter Real g_L(unit = "S/m2") = 3.0
    "Leak conductance [S/m2] (0.3 mS/cm2, HH 1952)";

  parameter Modelica.Units.SI.Voltage E_Na = 0.050
    "Na+ reversal potential [V] (+50 mV, squid axon)";

  parameter Modelica.Units.SI.Voltage E_K = -0.077
    "K+ reversal potential [V] (-77 mV, squid axon)";

  parameter Modelica.Units.SI.Voltage E_L = -0.0544
    "Leak reversal potential [V] (-54.4 mV, HH fit)";

  // Gating variables (dimensionless, 0..1); initial conditions are the
  // steady state at V_m = -65 mV
  Real m(start = 0.053, fixed = true) "Na+ activation gate (m)";
  Real h(start = 0.596, fixed = true) "Na+ inactivation gate (h)";
  Real n(start = 0.318, fixed = true) "K+ activation gate (n)";

  Real V_mV
    "Membrane potential in mV (the classic gate rate equations are expressed in mV)";

  Real alpha_m(unit = "1/s"), beta_m(unit = "1/s") "m gate rate constants [1/s]";
  Real alpha_h(unit = "1/s"), beta_h(unit = "1/s") "h gate rate constants [1/s]";
  Real alpha_n(unit = "1/s"), beta_n(unit = "1/s") "n gate rate constants [1/s]";

  Modelica.Units.SI.Current I_Na   "Sodium current [A]";
  Modelica.Units.SI.Current I_K    "Potassium current [A]";
  Modelica.Units.SI.Current I_leak "Leak current [A]";

equation
  V_mV = V_m * 1000.0;

  // alpha_m has a removable singularity at V = -40 mV; L'Hopital gives 1.0 [1/ms]
  alpha_m = noEvent(
    if abs(V_mV + 40.0) < 1e-7 then
      1000.0
    else
      0.1 * (V_mV + 40.0) / (1.0 - exp(-(V_mV + 40.0) / 10.0)) * 1000.0);

  beta_m = 4.0 * exp(-(V_mV + 65.0) / 18.0) * 1000.0;

  alpha_h = 0.07 * exp(-(V_mV + 65.0) / 20.0) * 1000.0;
  beta_h  = 1000.0 / (1.0 + exp(-(V_mV + 35.0) / 10.0));

  // alpha_n has a removable singularity at V = -55 mV; L'Hopital gives 0.1 [1/ms]
  alpha_n = noEvent(
    if abs(V_mV + 55.0) < 1e-7 then
      100.0
    else
      0.01 * (V_mV + 55.0) / (1.0 - exp(-(V_mV + 55.0) / 10.0)) * 1000.0);

  beta_n = 0.125 * exp(-(V_mV + 65.0) / 80.0) * 1000.0;

  der(m) = alpha_m * (1.0 - m) - beta_m * m;
  der(h) = alpha_h * (1.0 - h) - beta_h * h;
  der(n) = alpha_n * (1.0 - n) - beta_n * n;

  I_Na   = g_Na_max * (m ^ 3) * h * (V_m - E_Na) * A;
  I_K    = g_K_max  * (n ^ 4)     * (V_m - E_K)  * A;
  I_leak = g_L                    * (V_m - E_L)   * A;

  I_total = I_Na + I_K + I_leak;

  annotation(
    Documentation(info = "<html>
      <h2>HodgkinHuxleyNeuron</h2>
      <p>
        Implements the classic squid giant axon action potential model from:
      </p>
      <blockquote>
        Hodgkin AL, Huxley AF (1952). A quantitative description of membrane
        current and its application to conduction and excitation in nerve.
        <em>J Physiol</em> <b>117</b>: 500-544.
      </blockquote>
      <p>Membrane equation:</p>
      <pre>
  C_m * dV_m/dt = I_ext - I_Na - I_K - I_leak

  I_Na   = g_Na_max * m^3 * h * (V_m - E_Na) * A
  I_K    = g_K_max  * n^4     * (V_m - E_K)  * A
  I_leak = g_L                * (V_m - E_L)  * A
      </pre>
      <p>Gate kinetics (voltage in mV):</p>
      <pre>
  dm/dt = alpha_m*(1-m) - beta_m*m
  dh/dt = alpha_h*(1-h) - beta_h*h
  dn/dt = alpha_n*(1-n) - beta_n*n

  alpha_m(V) = 0.1*(V+40)/(1-exp(-(V+40)/10))    beta_m(V) = 4*exp(-(V+65)/18)
  alpha_h(V) = 0.07*exp(-(V+65)/20)               beta_h(V) = 1/(1+exp(-(V+35)/10))
  alpha_n(V) = 0.01*(V+55)/(1-exp(-(V+55)/10))    beta_n(V) = 0.125*exp(-(V+65)/80)
      </pre>
      <p>
        alpha_m and alpha_n each have a removable 0/0 singularity, at
        V = -40 mV and V = -55 mV respectively; both are handled via the
        L'Hopital limit (1.0 and 0.1 [1/ms]) within 1e-7 mV of that point.
      </p>
      <p>
        Default parameters are the original HH squid-axon fit
        (g_Na_max = 1200, g_K_max = 360, g_L = 3 S/m&#178;;
        E_Na = +50, E_K = -77, E_L = -54.4 mV). Gate initial conditions are
        the steady state at V_m = -65 mV (m0 = 0.053, h0 = 0.596, n0 = 0.318).
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/HodgkinHuxleyNeuron.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-90, 100}, {90, 90}},
        textString = "Hodgkin-Huxley model: four parallel branches",
        textColor = {120, 120, 120},
        fontSize = 11),
      Line(points = {{-80, 75}, {-80, -75}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{80, 75}, {80, -75}}, color = {0, 150, 0}, thickness = 1.5),
      Text(
        extent = {{-110, 88}, {-55, 78}},
        textString = "membrane_p",
        textColor = {0, 0, 200},
        fontSize = 9),
      Text(
        extent = {{55, 88}, {110, 78}},
        textString = "membrane_n",
        textColor = {0, 150, 0},
        fontSize = 9),
      // Branch 1: C_m (capacitor)
      Line(points = {{-80, 60}, {-12, 60}}, color = {0, 0, 200}),
      Line(points = {{-12, 48}, {-12, 72}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{12, 48}, {12, 72}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{12, 60}, {80, 60}}, color = {0, 150, 0}),
      Text(
        extent = {{-50, 78}, {50, 70}},
        textString = "C_m = 10 pF",
        textColor = {80, 80, 80},
        fontSize = 9),
      // Branch 2: Na+ channel
      Line(points = {{-80, 20}, {-62, 20}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, 28}, {-22, 12}},
        lineColor = {180, 0, 0},
        fillColor = {255, 220, 220},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-60, 27}, {-24, 13}},
        textString = "g_Na*m3*h",
        textColor = {180, 0, 0},
        fontSize = 8),
      Line(points = {{-22, 20}, {0, 20}}, color = {180, 0, 0}),
      Line(points = {{0, 28}, {0, 12}}, color = {180, 0, 0}, thickness = 2.5),
      Line(points = {{10, 24}, {10, 16}}, color = {180, 0, 0}, thickness = 1),
      Line(points = {{10, 20}, {80, 20}}, color = {0, 150, 0}),
      Text(
        extent = {{-20, 38}, {80, 30}},
        textString = "E_Na = +50 mV",
        textColor = {180, 0, 0},
        fontSize = 8),
      // Branch 3: K+ channel
      Line(points = {{-80, -20}, {-62, -20}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, -12}, {-22, -28}},
        lineColor = {0, 0, 180},
        fillColor = {220, 220, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-60, -13}, {-24, -27}},
        textString = "g_K*n4",
        textColor = {0, 0, 180},
        fontSize = 8),
      Line(points = {{-22, -20}, {0, -20}}, color = {0, 0, 180}),
      Line(points = {{0, -12}, {0, -28}}, color = {0, 0, 180}, thickness = 2.5),
      Line(points = {{10, -16}, {10, -24}}, color = {0, 0, 180}, thickness = 1),
      Line(points = {{10, -20}, {80, -20}}, color = {0, 150, 0}),
      Text(
        extent = {{-20, -2}, {80, -10}},
        textString = "E_K = -77 mV",
        textColor = {0, 0, 180},
        fontSize = 8),
      // Branch 4: leak
      Line(points = {{-80, -60}, {-62, -60}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-62, -52}, {-22, -68}},
        lineColor = {100, 100, 0},
        fillColor = {255, 255, 200},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-60, -53}, {-24, -67}},
        textString = "g_L (leak)",
        textColor = {100, 100, 0},
        fontSize = 8),
      Line(points = {{-22, -60}, {0, -60}}, color = {100, 100, 0}),
      Line(points = {{0, -52}, {0, -68}}, color = {100, 100, 0}, thickness = 2.5),
      Line(points = {{10, -56}, {10, -64}}, color = {100, 100, 0}, thickness = 1),
      Line(points = {{10, -60}, {80, -60}}, color = {0, 150, 0}),
      Text(
        extent = {{-20, -42}, {80, -50}},
        textString = "E_L = -54 mV",
        textColor = {100, 100, 0},
        fontSize = 8)
    })
  );
end HodgkinHuxleyNeuron;
