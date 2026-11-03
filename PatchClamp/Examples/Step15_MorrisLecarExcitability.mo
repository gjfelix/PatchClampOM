within PatchClamp.Examples;
model Step15_MorrisLecarExcitability
  "Morris-Lecar model under current clamp: Type I and Type II excitability"

  // Compare against FitzHugh-Nagumo (Step14) and HH (Step06). With the
  // default (Type II) parameters and a sustained I_pulse = 2e-12 (2 pA,
  // t_end = 0.200), oscillations start ABRUPTLY (a Hopf bifurcation) --
  // firing rate can't be arbitrarily low. Sweeping I_pulse from 1.0e-12 to
  // 2.0e-12 in 0.1e-12 steps shows zero spikes below threshold and
  // continuous firing above it, the signature of a Hopf (Type II / Class 2)
  // bifurcation.
  //
  // Switching to Type I (SNIC): set neuron.V3 = 12e-3, neuron.V4 = 17.4e-3,
  // neuron.phi = 23.3; sweeping I_pulse from 0.5e-12 to 3e-12 now shows the
  // firing rate rising continuously from zero (Class 1) -- a direct
  // demonstration of how the bifurcation type sets the f-I relationship.
  //
  // For a voltage-clamp I-V curve instead, swap in a VoltageClampAmplifier
  // and read neuron.I_Ca / neuron.I_K separately.

  PatchClamp.Amplifiers.CurrentClampAmplifier amp(
    I_hold        = 0.0,
    I_pulse       = 1000.0e-12,
    t_pulse_start = 0.010,
    t_pulse_end   = 0.200,
    R_bridge      = 0.0)
    // I_pulse = 1000 pA (1 nA): safely above the Type II Hopf bifurcation
    // threshold (93.85 uA/cm2 * 1000 um2 = 1e-5 cm2 -> 938 pA). C_m = 200 pF
    // gives sustained firing at about 11-12 Hz (measured: 11.7 Hz at 1000 pA).
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.MorrisLecarNeuron neuron(
    C_m   = 200.0e-12,
    g_Ca  = 44.0,
    g_K   = 80.0,
    g_L   = 20.0,
    E_Ca  = 0.120,
    E_K   = -0.084,
    E_L   = -0.060,
    V1    = -0.0012,
    V2    = 0.018,
    V3    = 0.002,
    V4    = 0.030,
    phi   = 40.0)
    "Type II by default"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pip.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pip.p_cell, neuron.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(neuron.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));
  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pip.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step15 -- Morris-Lecar under current clamp</h2>
      <p>
        A current-clamp experiment with the Morris-Lecar neuron, which can
        show either of the two classes of neuronal excitability by changing
        just three parameters.
      </p>

      <p>
        Circuit: <code>CurrentClampAmp</code> -&gt; <code>PatchPipette</code>
        -&gt; <code>MorrisLecarNeuron</code> -&gt; <code>BathElectrode</code>.
      </p>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>neuron.V_m</code> -- membrane potential [V]</li>
        <li><code>neuron.w</code> -- K+ gate (slow variable)</li>
        <li><code>neuron.m_inf</code> -- Ca2+ activation (instantaneous)</li>
        <li><code>neuron.I_Ca</code> -- Ca2+ current [A]</li>
        <li><code>neuron.I_K</code> -- K+ current [A]</li>
        <li><code>amp.I_command</code> -- injected current [A]</li>
      </ul>

      <h3>Excitability classes compared</h3>
      <table border='1'>
        <tr><th></th><th>Type II (Hopf)</th><th>Type I (SNIC)</th></tr>
        <tr><td>Bifurcation</td><td>Hopf (sub/supercritical)</td><td>SNIC (saddle-node)</td></tr>
        <tr><td>Rate at threshold</td><td>finite (~10 Hz near threshold, 11.7 Hz at 1000 pA)</td><td>zero (rises continuously from 0)</td></tr>
        <tr><td>Sub-threshold response</td><td>graded</td><td>all-or-none</td></tr>
        <tr><td>f-I relationship</td><td>starts high</td><td>starts at 0 Hz</td></tr>
      </table>

      <h3>Type I parameters</h3>
      <pre>
  V3 = 12 mV = 0.012 V
  V4 = 17.4 mV = 0.0174 V
  phi = 23.3 [1/s]
      </pre>
    </html>"),
    experiment(
      StopTime  = 0.200,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 0},
        lineThickness = 2.0,
        fillColor = {230, 255, 240},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {0, 80, 0},
        fillColor = {0, 25, 10},
        fillPattern = FillPattern.Solid),
      Line(points = {{-85, 18}, {85, 18}}, color = {0, 60, 20}),
      Line(points = {{0, 65}, {0, -30}},   color = {0, 60, 20}),
      Line(
        points = {{-82, -12}, {-45, -12}, {-33, 48}, {-18, -28}, {-2, -16}, {14, 42}, {29, -28}, {44, -16}},
        color = {0, 220, 120},
        thickness = 2.0),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step15 Morris-Lecar",
        textColor = {0, 100, 0},
        fontSize = 11)
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step15: Morris-Lecar -- Type I / Type II regimes (current clamp)",
        textColor = {80, 80, 80},
        fontSize = 12),
      Text(extent = {{-190, 48}, {-110, 40}}, textString = "I-clamp",      textColor = {100, 0, 150},  fontSize = 9),
      Text(extent = {{-90, 48},  {-10, 40}},  textString = "Pipette",      textColor = {100, 80, 0},   fontSize = 9),
      Text(extent = {{10, 48},   {90, 40}},   textString = "Morris-Lecar", textColor = {0, 110, 85},   fontSize = 9),
      Text(extent = {{110, 48},  {190, 40}},  textString = "Bath",         textColor = {0, 100, 0},    fontSize = 9),
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 0}, thickness = 2.0),
      Text(extent = {{-50, -72}, {50, -84}},   textString = "GND bus", textColor = {80, 80, 80}, fontSize = 9)
    })
  );
end Step15_MorrisLecarExcitability;
