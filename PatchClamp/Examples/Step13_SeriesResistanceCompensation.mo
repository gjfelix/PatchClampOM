within PatchClamp.Examples;
model Step13_SeriesResistanceCompensation
  "Compensation demo: effect of C-fast, C-slow, and R_s on the measured current"

  // Compare the measured current with and without each compensation
  // active. Starting from the defaults (all compensations = 0), I_raw
  // shows the double capacitive transient (pipette + membrane) and
  // V_error shows how far V_m drifts from the command due to R_s. Then
  // try: frac_fast = 1.0 (the fast initial peak, C_pipette, disappears
  // from I_measured); frac_slow = 1.0 (the slow exponential, C_m, also
  // disappears, leaving only the membrane's resistive current); and
  // alpha = 0.7 (70% R_s compensation: V_error_residual drops to
  // 0.3 * R_s * I_measured, and V_m_estimated approaches the true command).

  PatchClamp.Amplifiers.Compensation.CompensatedVClampAmp amp(
    V_hold        = -0.070,
    V_step        = -0.050,
    t_step_start  = 0.050,
    t_step_end    = 0.150,
    V_ljp_correction = -11.0e-3,
    C_fast    = 3.0e-12,
    frac_fast = 0,
    C_slow    = 10.0e-12,
    R_s_est   = 4.0e6,
    frac_slow = 0,
    R_s       = 4.0e6, alpha = 0, tau_comp = 10e-6)
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    "Same parameters as Step03"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.PassiveCell cell(
    C_m = 10.0e-12,
    R_m = 1.0e9)
    "Simple RC cell, to see clean capacitive transients"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pip.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pip.p_cell, cell.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(cell.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pip.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step13 -- Electronic compensation demo</h2>
      <p>
        Uses the simple RC passive cell (no active channels) so the
        response is analytically predictable, making the effect of each
        compensation easy to see.
      </p>

      <h3>Circuit</h3>
      <p>
        <code>CompensatedVClampAmp</code> (with C-fast, C-slow, and R_s
        compensation) drives a <code>PatchPipette</code> into a
        <code>PassiveCell</code>, grounded through a
        <code>BathElectrode</code>.
      </p>

      <h3>Expected raw signal (no compensation)</h3>
      <p>On the V_hold -&gt; V_step step (-70 mV -&gt; -50 mV):</p>
      <pre>
  1) Fast spike (C_pipette):  I_fast = C_pip * dV/dt  (very brief, ns scale)
  2) Slow exponential (C_m):  tau = R_pipette * C_m = 4e6 * 10e-12 = 40 us
                               (matches simulation: ~39.8 us, measured from
                               the decay between t+2us and t+20us)
  3) Steady state:            I_ss ~ 14.9 pA (simulated; not simply
                               V_step/R_m -- PassiveCell's leak reversal
                               E_L = -65 mV and R_pipette's own share of the
                               voltage divider both matter here)
      </pre>

      <h3>Effect of each compensation on I_measured</h3>
      <ul>
        <li><b>frac_fast = 1.0</b>: removes spike 1 (the C_pipette artifact)</li>
        <li><b>frac_slow = 1.0</b>: removes exponential 2 (the C_m artifact)</li>
        <li><b>alpha = 0.7</b>: reduces V_error from R_s * I_ss to 0.3 * R_s * I_ss</li>
      </ul>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>amp.I_raw</code> -- total uncompensated current</li>
        <li><code>amp.I_measured</code> -- compensated current</li>
        <li><code>amp.I_comp_fast</code> -- canceled C-fast artifact</li>
        <li><code>amp.I_comp_slow</code> -- canceled C-slow artifact</li>
        <li><code>amp.V_error</code> -- voltage error from R_s</li>
        <li><code>amp.V_m_estimated</code> -- estimate of the real V_m</li>
        <li><code>cell.V_m</code> -- the cell's membrane potential</li>
      </ul>
    </html>"),
    experiment(
      StopTime   = 0.200,
      Interval   = 1e-6,
      Tolerance  = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 0},
        lineThickness = 2.0,
        fillColor = {240, 255, 240},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {0, 80, 0},
        fillColor = {0, 25, 0},
        fillPattern = FillPattern.Solid),
      Line(
        points = {{-82, -15}, {-50, -15}, {-40, 52}, {-30, -28}, {-15, -20}, {20, -20}},
        color = {255, 220, 0},
        thickness = 1.5),
      Line(
        points = {{-82, -15}, {-50, -15}, {-50, -20}, {20, -20}},
        color = {0, 255, 100},
        thickness = 2.0),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step13 Compensation",
        textColor = {0, 100, 0},
        fontSize = 11)
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step13: Amplifier compensation (C-fast, C-slow, R_s)",
        textColor = {80, 80, 80},
        fontSize = 12),
      Text(
        extent = {{-190, 48}, {-110, 40}},
        textString = "CompensatedVClamp",
        textColor = {100, 0, 150},
        fontSize = 9),
      Text(
        extent = {{-90, 48}, {-10, 40}},
        textString = "Pipette",
        textColor = {100, 80, 0},
        fontSize = 9),
      Text(
        extent = {{10, 48}, {90, 40}},
        textString = "PassiveCell",
        textColor = {180, 0, 0},
        fontSize = 9),
      Text(
        extent = {{110, 48}, {190, 40}},
        textString = "Bath",
        textColor = {0, 100, 0},
        fontSize = 9),
      Line(
        points = {{-190, -80}, {190, -80}},
        color = {0, 0, 0},
        thickness = 2.0),
      Text(
        extent = {{-50, -72}, {50, -84}},
        textString = "GND bus",
        textColor = {80, 80, 80},
        fontSize = 9)
    })
  );
end Step13_SeriesResistanceCompensation;