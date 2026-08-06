within PatchClamp.Examples;
model Step14_FitzHughNagumoExcitability
  "FitzHugh-Nagumo model under current clamp: single and repetitive firing"

  // Worth trying: a single brief pulse (I_pulse=1.0e-12, t_start=10ms,
  // t_end=12ms) gives one spike back to rest, in a stylized version of
  // Step06's HH shape; a sustained pulse (t_end=0.200, I_pulse=5e-12,
  // above the oscillation threshold) gives repetitive firing -- measure
  // the inter-spike period; sweeping I_pulse from 1e-12 to 20e-12 (steps
  // of 2e-12) with t_end=0.200 traces the f-I curve, worth comparing
  // against SimplifiedNeuron's (LIF) very different f-I relationship; and
  // plotting neuron.u vs. neuron.w in XY (parametric) mode shows the
  // trajectory in the FHN phase plane.

  PatchClamp.Amplifiers.CurrentClampAmplifier amp(
    I_hold       = 0.0,
    I_pulse      = 50.0e-12,
    t_pulse_start = 0.010,
    t_pulse_end   = 0.012,
    R_bridge     = 0.0)
    // I_pulse = 50 pA: slightly above the FHN threshold (~40 pA) for a
    // 2 ms pulse. HH's rheobase is 29 pA; FHN needs more here because the
    // Sylgard-coated pipette still adds C_pip=0.5 pF to the effective
    // membrane capacitance.
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 0.5e-12,
    V_junction = 0.0)
    // C_pipette = 0.5 pF: a Sylgard-coated pipette with minimal stray
    // capacitance. The library default of 3 pF would shunt 75% of the
    // injected current into the glass wall capacitance (C_pip >> C_m=1 pF),
    // keeping the membrane from ever reaching the FHN spike threshold.
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.FitzHughNagumoNeuron neuron(
    C_m     = 1.0e-12,
    V_rest  = -0.005,
    V_scale = 0.050,
    a       = 0.7,
    b       = 0.8,
    epsilon = 0.08,
    tau_u   = 2.0e-3)
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
      <h2>Step14 -- FitzHugh-Nagumo under current clamp</h2>
      <p>
        A current-clamp experiment with the FitzHugh-Nagumo neuron. Its two
        state variables make excitability and bifurcations easier to
        explore visually than in the full Hodgkin-Huxley model.
      </p>

      <p>
        Circuit: <code>CurrentClampAmp</code> -&gt; <code>PatchPipette</code>
        -&gt; <code>FitzHughNagumoNeuron</code> -&gt; <code>BathElectrode</code>.
      </p>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>neuron.V_m</code> -- membrane potential [V]</li>
        <li><code>neuron.u</code> -- fast dimensionless variable</li>
        <li><code>neuron.w</code> -- recovery variable</li>
        <li><code>amp.I_command</code> -- injected current [A]</li>
      </ul>

      <h3>Comparison with other cell models</h3>
      <table border='1'>
        <tr><th>Model</th><th>ODEs</th><th>Sim. speed</th><th>Fidelity</th></tr>
        <tr><td>SimplifiedNeuron (LIF)</td><td>1</td><td>very fast</td><td>low</td></tr>
        <tr><td>FitzHughNagumoNeuron</td><td>2</td><td>fast</td><td>medium</td></tr>
        <tr><td>HodgkinHuxleyNeuron</td><td>4</td><td>slow</td><td>high</td></tr>
      </table>

      <h3>Firing parameters</h3>
      <pre>
  Approx. threshold (brief 2 ms pulse): I_pulse ~ 1.0 pA
  Continuous oscillation threshold:     I_pulse ~ 3.5 pA
  Repetitive-firing range:              3.5 pA to 15 pA
      </pre>
    </html>"),
    experiment(
      StopTime  = 0.100,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 0},
        lineThickness = 2.0,
        fillColor = {230, 255, 230},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {0, 80, 0},
        fillColor = {0, 25, 0},
        fillPattern = FillPattern.Solid),
      Line(points = {{-85, 18}, {85, 18}}, color = {0, 60, 0}),
      Line(points = {{0, 65}, {0, -30}}, color = {0, 60, 0}),
      Line(
        points = {{-82, -10}, {-50, -10}, {-38, 55}, {-22, -28}, {-5, -18}, {35, -18}},
        color = {0, 200, 100},
        thickness = 2.0),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step14 FHN",
        textColor = {0, 100, 0},
        fontSize = 12)
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step14: FitzHugh-Nagumo -- single and repetitive firing (current clamp)",
        textColor = {80, 80, 80},
        fontSize = 12),
      Text(extent = {{-190, 48}, {-110, 40}}, textString = "I-clamp",      textColor = {100, 0, 150}, fontSize = 9),
      Text(extent = {{-90,  48}, {-10,  40}}, textString = "Pipette",      textColor = {100, 80, 0},  fontSize = 9),
      Text(extent = {{10,   48}, {90,   40}}, textString = "FHN Neuron",   textColor = {0, 80, 160},  fontSize = 9),
      Text(extent = {{110,  48}, {190,  40}}, textString = "Bath",         textColor = {0, 100, 0},   fontSize = 9),
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 0}, thickness = 2.0),
      Text(extent = {{-50, -72}, {50, -84}}, textString = "GND bus", textColor = {80, 80, 80}, fontSize = 9)
    })
  );
end Step14_FitzHughNagumoExcitability;
