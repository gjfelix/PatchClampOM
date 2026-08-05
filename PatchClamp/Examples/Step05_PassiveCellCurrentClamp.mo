within PatchClamp.Examples;
model Step05_PassiveCellCurrentClamp
  "Passive cell under current clamp -- measuring tau_m = R_m * C_m"

  PatchClamp.Amplifiers.CurrentClampAmplifier amplifier(
    I_hold        = 0.0,
    I_pulse       = 20.0e-12,
    t_pulse_start = 0.010,
    t_pulse_end   = 0.110,
    R_bridge      = 4.0e6)
    "Current-clamp amplifier: 20 pA pulse for 100 ms (>> tau_m = 10 ms)"
    annotation(Placement(transformation(extent={{-190,-40},{-110,40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Patch pipette: R=4 MOhm, C=3 pF, LJP=0 (omitted for clarity)"
    annotation(Placement(transformation(extent={{-90,-40},{-10,40}})));

  PatchClamp.Cells.PassiveCell cell(
    C_m = 10.0e-12,
    R_m = 1.0e9)
    "Passive cell: C_m=10 pF, R_m=1 GOhm, tau_m=10 ms"
    annotation(Placement(transformation(extent={{10,-40},{90,40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: 0 V reference"
    annotation(Placement(transformation(extent={{110,-40},{190,40}})));

equation
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points={{-110,0},{-90,0}}, color={0,0,255}));
  connect(pipette.p_cell, cell.membrane_p)
    annotation(Line(points={{-10,0},{10,0}}, color={0,0,255}));
  connect(cell.membrane_n, bath.p)
    annotation(Line(points={{90,0},{110,0}}, color={0,0,255}));
  connect(amplifier.n, bath.n)
    annotation(Line(points={{-190,0},{-190,-80},{190,-80},{190,0}}, color={0,0,255}));
  connect(pipette.n, bath.n)
    annotation(Line(points={{-50,-40},{-50,-80},{190,-80},{190,0}}, color={0,0,255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step05 -- Passive cell under current clamp: measuring tau_m</h2>

      <h3>Learning objective</h3>
      <p>
        Set in the whole-cell configuration under current clamp (see
        <code>Step01_PipetteSealTest</code> and
        <code>Step02_GigasealFormation</code> for the steps leading up to
        it). Measure the membrane time constant tau_m = R_m * C_m by
        watching V_m charge exponentially under a constant current pulse.
        This is the current-clamp companion to Step03: Step03 shows
        tau_pip (40 us) under voltage clamp, Step05 shows tau_m (10 ms)
        under current clamp.
      </p>

      <h3>Protocol</h3>
      <pre>
  t = 0    - 10 ms:   I_command = 0 pA   (rest, V_m = -65 mV)
  t = 10   - 110 ms:  I_command = 20 pA  (current pulse)
  t = 110  - 150 ms:  I_command = 0 pA   (back to rest)
      </pre>

      <h3>Expected values</h3>
      <pre>
  tau_m   = R_m * C_m = 1e9 * 10e-12        = 10 ms
  V_rest  = E_L                              = -65 mV  (equilibrium with no I_ext)
  V_ss    = E_L + I_pulse * R_m
          = -0.065 + 20e-12 * 1e9           = -0.045 V  (-45 mV)
  DeltaV  = V_ss - V_rest = 20 pA * 1 GOhm = 20 mV

  At t = t_pulse_start + tau_m (t = 20 ms):
    V_m = V_rest + DeltaV * (1 - exp(-1))
        = -0.065 + 0.020 * 0.6321          = -0.0524 V  (-52.4 mV)
      </pre>

      <h3>Measuring tau_m in OMEdit</h3>
      <ol>
        <li>Simulate with stopTime = 0.150, Interval = 1e-4.</li>
        <li>Plot <b>cell.V_m</b>.</li>
        <li>Find t_63, the time at which V_m = -52.4 mV (63% of the way from -65 to -45 mV).</li>
        <li>tau_m = t_63 - t_pulse_start = t_63 - 0.010.</li>
        <li>Expected result: tau_m = 10 ms.</li>
      </ol>

      <h3>Comparison with Step03 (voltage clamp)</h3>
      <table border='1' cellpadding='4'>
        <tr><th>Experiment</th><th>Mode</th><th>Variable to watch</th><th>Time constant</th></tr>
        <tr><td>Step03</td><td>Voltage clamp</td><td>amplifier.I_measured</td><td>tau_pip = 40 us</td></tr>
        <tr><td>Step05</td><td>Current clamp</td><td>cell.V_m</td><td>tau_m = 10 ms</td></tr>
      </table>

      <h3>Questions worth exploring</h3>
      <ol>
        <li>Double R_m to 2 GOhm. How do tau_m and V_ss change?</li>
        <li>Double C_m to 20 pF. How does tau_m change without affecting V_ss?</li>
        <li>Why is tau_pip so much shorter than tau_m in this circuit? (Hint: R_pip = 4 MOhm vs. R_m = 1000 MOhm.)</li>
        <li>In a real current-clamp recording, what artifact appears at the pulse onset that's absent from this passive model?</li>
      </ol>
    </html>"),
    experiment(
      StopTime  = 0.150,
      Interval  = 1e-4,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {100, 0, 150},
        fillColor = {248, 240, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step05",
        textColor = {80, 0, 130},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "tau_m CC",
        textColor = {100, 0, 150},
        fontSize = 13)
    })
  );
end Step05_PassiveCellCurrentClamp;
