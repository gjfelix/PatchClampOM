within PatchClamp.Examples;
model Step12_SodiumChannelIVCurve
  "Ion channel I-V curve -- voltage-step ladder protocol under voltage clamp"

  parameter Modelica.Units.SI.Voltage V_hold = -0.100
    "Holding voltage between steps [V] (-100 mV, fully removes Na+ inactivation)";
  parameter Modelica.Units.SI.Voltage V_step_min = -0.080
    "First test step [V] (-80 mV)";
  parameter Modelica.Units.SI.Voltage V_step_max = 0.040
    "Last test step [V] (+40 mV)";
  parameter Modelica.Units.SI.Voltage V_step_increment = 0.010
    "Increment between steps [V] (10 mV)";

  parameter Modelica.Units.SI.Time t_hold_dur  = 0.150
    "Holding period duration per step [s] (150 ms)";
  parameter Modelica.Units.SI.Time t_test_dur  = 0.030
    "Test step duration [s] (30 ms)";

  parameter Integer step_index(min = 0, max = 12) = 6
    "Index of the step simulated by this instance: 0 -> -80 mV, 1 -> -70 mV, ..., 12 -> +40 mV";

  parameter Modelica.Units.SI.Voltage V_test =
    V_step_min + step_index * V_step_increment
    "Selected test step voltage [V]";

  Boolean in_test_phase
    "True during the test step (t >= t_hold_dur), false during holding";

  PatchClamp.Amplifiers.VoltageClampAmplifier amplifier(
    V_hold       = V_hold,
    V_step       = V_test,
    t_step_start = t_hold_dur,
    t_step_end   = t_hold_dur + t_test_dur,
    V_ljp_correction = -11.0e-3)
    "Voltage clamp: hold at V_hold, step to V_test"
    annotation(Placement(transformation(extent={{-190,-40},{-110,40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    "Patch pipette: 4 MOhm"
    annotation(Placement(transformation(extent={{-90,-40},{-10,40}})));

  PatchClamp.Cells.HodgkinHuxleyNeuron neuron(
    C_m      = 10.0e-12,
    A        = 1000.0e-12,
    g_Na_max = 1200.0,
    g_K_max  = 360.0,
    g_L      = 3.0,
    E_Na     = 0.050,
    E_K      = -0.077,
    E_L      = -0.0544,
    V_m(fixed = false))
    // V_m.fixed=false: PartialExcitableCell hardwires V_m(start=-0.065,
    // fixed=true) for current-clamp use, but this experiment holds the
    // cell under voltage clamp at V_hold=-100 mV from t=0, so a fixed
    // -65 mV start would conflict with the amplifier's own algebraic
    // constraint on V_m ("Initialization problem is inconsistent...").
    // Freeing V_m lets the voltage clamp determine its own consistent
    // initial value.
    "HH neuron: source of the Na+ and K+ currents"
    annotation(Placement(transformation(extent={{10,-40},{90,40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode"
    annotation(Placement(transformation(extent={{110,-40},{190,40}})));

equation
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points={{-110,0},{-90,0}}, color={0,0,255}));
  connect(pipette.p_cell, neuron.membrane_p)
    annotation(Line(points={{-10,0},{10,0}}, color={0,0,255}));
  connect(neuron.membrane_n, bath.p)
    annotation(Line(points={{90,0},{110,0}}, color={0,0,255}));
  connect(amplifier.n, bath.n)
    annotation(Line(points={{-190,0},{-190,-80},{190,-80},{190,0}}, color={0,0,255}));
  connect(pipette.n, bath.n)
    annotation(Line(points={{-50,-40},{-50,-80},{190,-80},{190,0}}, color={0,0,255}));

  // A single hold-then-test cycle: 150 ms hold, then 30 ms test
  in_test_phase = (time >= t_hold_dur);

  annotation(
    Documentation(info = "<html>
      <h2>Step12 -- Ion channel I-V (current-voltage) curve</h2>

      <h3>Learning objective</h3>
      <p>
        Build the I-V curve of voltage-dependent ionic currents with a
        voltage-step ladder protocol under voltage clamp -- the standard
        method in electrophysiology for characterizing a channel's voltage
        dependence and computing its conductance.
      </p>

      <h3>Step protocol</h3>
      <pre>
  Cycle for each V_test (step_index = 0, 1, ..., 12):

  |   t_hold_dur = 150 ms   | t_test_dur = 30 ms |
  |                          |                    |
  V: V_hold (-100 mV) ------ -> V_test ---------- -> V_hold
  I:    ~ 0                      peak + recovery
      </pre>
      <p>
        V_hold = -100 mV fully removes Na+ channel inactivation (h -&gt; 1)
        before each test step.
      </p>

      <h3>Building the full I-V curve</h3>
      <p>
        Simulate this model 13 times with step_index = 0, 1, ..., 12
        (V_test = -80, -70, ..., +40 mV), reading the minimum of
        neuron.I_Na or amplifier.I_measured during the test phase
        (t = 150-180 ms) from each run's CSV output. From OMShell:
      </p>
      <pre>
  loadFile('PatchClamp/package.mo');
  for idx in 0:12 loop
    simulate(PatchClamp.Examples.Step12_SodiumChannelIVCurve(step_index=idx),
             stopTime=0.18, numberOfIntervals=18000,
             outputFormat='csv',
             fileNamePrefix='step12_step'+String(idx));
  end for;
      </pre>

      <h3>Reference values</h3>
      <pre>
  V_test (mV) | I_Na peak (approx.) | I_K late (approx.)
  ------------+---------------------+--------------------
    -80       |    -0.01 nA         |    0 pA
    -70       |    -0.05 nA         |    0 pA
    -60       |    -0.15 nA         |   ~5 pA
    -50       |    -0.40 nA         |  ~20 pA
    -40       |    -0.80 nA         |  ~60 pA
    -20       |    -1.20 nA         |  ~200 pA
      0       |    -0.90 nA         |  ~400 pA
    +20       |    -0.40 nA         |  ~600 pA
    +40       |    ~0 nA            |  ~700 pA
      </pre>
      <p>
        I_Na reverses (turns positive) near E_Na = +50 mV, and peak Na+
        conductance occurs around -20 to 0 mV.
      </p>

      <h3>Analyzing the I-V curve</h3>
      <p>Na+ conductance at each voltage:</p>
      <pre>  g_Na(V) = I_Na_peak / (V_test - E_Na)</pre>
      <p>Plotting g_Na vs. V_test gives the activation curve, a Boltzmann sigmoid:</p>
      <pre>  g_Na(V) / g_Na_max = 1 / (1 + exp(-(V - V_half) / k))</pre>

      <h3>What to look for</h3>
      <ul>
        <li>Below -60 mV, current is minimal -- Na+ channels haven't activated yet (m stays low).</li>
        <li>Between -60 and -20 mV, a large fast Na+ current appears, followed by a slower-growing outward K+ current.</li>
        <li>Above +30 mV, I_Na shrinks as V approaches E_Na, reducing the driving force.</li>
        <li>The time separation between I_Na's fast peak and I_K's slow plateau reflects their different channel kinetics.</li>
      </ul>

      <h3>Questions worth exploring</h3>
      <ol>
        <li>At what V_test does I_Na change sign? Does it match E_Na = +50 mV, and if not, why the small discrepancy?</li>
        <li>Block K+ channels (g_K_max = 0) -- how does the shape of I_measured change?</li>
        <li>Block Na+ channels (g_Na_max = 0) -- what current remains, and can its I-V curve be computed?</li>
        <li>Why does V_hold = -100 mV matter, versus -65 mV? What would go wrong at -65 mV?</li>
        <li>Compute g_Na for each V_test via g_Na = I_Na / (V_test - E_Na), and fit a Boltzmann curve.</li>
      </ol>

      <p>
        This protocol matches the one Hodgkin and Huxley (1952) used to
        characterize the squid giant axon's ionic currents, with TTX
        (blocking Na+) and TEA (blocking K+) to isolate each current
        individually -- the same approach used today in whole-cell
        recordings of cortical neurons to characterize voltage-gated
        channel subtypes.
      </p>

      <blockquote>
        Hodgkin AL, Huxley AF (1952). Currents carried by sodium and
        potassium ions through the membrane of the giant axon of Loligo.
        <em>J Physiol</em> <b>116</b>: 449-472.
      </blockquote>
    </html>"),
    experiment(
      StopTime  = 0.180,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(
        points = {{-190,-80},{190,-80}},
        color = {0,0,255},
        thickness = 0.5),
      Text(
        extent = {{-190,-82},{-120,-96}},
        textString = "GND bus",
        textColor = {0,0,200},
        fontSize = 9),
      Text(
        extent = {{-240,60},{-110,44}},
        textString = "V-clamp",
        textColor = {180,60,0},
        fontSize = 9),
      Text(
        extent = {{-100,60},{30,44}},
        textString = "Pipette",
        textColor = {0,100,0},
        fontSize = 9),
      Text(
        extent = {{10,60},{100,44}},
        textString = "HH Neuron",
        textColor = {0,0,180},
        fontSize = 9),
      Text(
        extent = {{110,60},{200,44}},
        textString = "Bath",
        textColor = {150,80,0},
        fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {180, 60, 0},
        fillColor = {255, 240, 225},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step12",
        textColor = {150, 50, 0},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "I-V Curve",
        textColor = {180, 60, 0},
        fontSize = 13)
    })
  );
end Step12_SodiumChannelIVCurve;
