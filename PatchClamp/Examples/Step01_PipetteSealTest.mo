within PatchClamp.Examples;
model Step01_PipetteSealTest
  "Pipette immersed in the bath -- seal-test with no cell (step 1)"

  // The first step of a patch clamp experiment: the pipette sits in the
  // bath solution but hasn't touched a cell yet. Try changing R_pipette
  // (e.g. 3e6, 5e6, 8e6) and check that I_steady = V_pulse / R_pipette
  // tracks it -- this is why 3-5 MOhm pipettes are preferred for
  // whole-cell recording. Compare against Step02 (gigaseal formed,
  // I_steady ~ 5 pA) and Step03 (whole-cell, a genuine RC transient).

  PatchClamp.Amplifiers.SealTest seal_test(
    V_pulse       = -5.0e-3,
    t_period      = 0.020,
    t_pulse_width = 0.010,
    t_start       = 0.002,
    R_pipette_nom = 4.0e6)
    "Seal-test: -5 mV pulse, 50 Hz, estimates R_seal in real time"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Pipette: R=4 MOhm, C=3 pF, LJP=0 (no relevant solution mismatch here)"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: 0 V reference, R_bath=100 Ohm (negligible vs. R_pip)"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

equation
  connect(seal_test.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));

  // Pipette tip -> bath directly (no cell in the way)
  connect(pipette.p_cell, bath.p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));

  connect(seal_test.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {90, -80}, {90, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {90, -80}, {90, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step01 -- Pipette immersed in the bath (patch clamp step 1)</h2>

      <h3>Learning objective</h3>
      <p>
        Understand the electrical circuit of the patch pipette while
        immersed in the bath, before contacting any cell -- the seal-test's
        reference state, where current flows freely through the pipette
        resistance.
      </p>

      <h3>Equivalent circuit</h3>
      <pre>
  SealTest         PatchPipette            BathElectrode
  [V_pulse] ---- [R_pip  = 4 MOhm] ---- [R_bath = 100 Ohm] ---- GND
                 [C_pip  = 3 pF  ]
      </pre>

      <h3>Expected current</h3>
      <pre>
  I_steady = V_pulse / R_pip
           = -5 mV / 4 MOhm
           = -1.25 nA   (background current in a free bath, an instant step)
      </pre>
      <p>
        <b>About C_pipette:</b> here it sits in parallel with the SealTest
        amplifier's ideal (zero-impedance) output, with no series resistance
        to charge it -- so its current is an instantaneous impulse on each
        edge of V_command, not a visible RC transient in
        <code>I_measured</code>. To see a real capacitive transient
        (tau = R_pip * C), see Step03, where the membrane capacitance C_m
        sits downstream of R_pip and charges through it.
      </p>

      <h3>Comparison with later steps</h3>
      <table border='1'>
        <tr><th>Experiment</th><th>I_steady</th><th>Physics</th></tr>
        <tr><td>Step01 (free bath)</td><td>~1.25 nA</td><td>R_pip = 4 MOhm</td></tr>
        <tr><td>Step02 (gigaseal)</td><td>~5 pA</td><td>R_seal = 1 GOhm &gt;&gt; R_pip</td></tr>
        <tr><td>Step03 (whole-cell)</td><td>RC transient</td><td>tau = R_m * C_m = 10 ms</td></tr>
      </table>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><b>seal_test.I_measured</b> -- measured current (watch I_steady and any transients)</li>
        <li><b>seal_test.V_command</b> -- the applied voltage protocol</li>
        <li><b>seal_test.R_seal_est</b> -- the real-time resistance estimate</li>
      </ul>

      <h3>Suggested simulation</h3>
      <p>stopTime = 0.060 s, numberOfIntervals = 10000</p>
    </html>"),
    experiment(
      StopTime    = 0.060,
      Interval    = 6e-6,
      Tolerance   = 1e-6),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, 100}, {100, -100}},
        lineColor = {0, 100, 200},
        fillColor = {230, 245, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step01",
        fontSize = 22,
        textColor = {0, 80, 180}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "Pipette in Bath",
        fontSize = 14,
        textColor = {0, 80, 180}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Step 1",
        fontSize = 12,
        textColor = {100, 140, 200})
    })
  ,
  Diagram(coordinateSystem(extent = {{-200, 40}, {100, -80}})));
end Step01_PipetteSealTest;
