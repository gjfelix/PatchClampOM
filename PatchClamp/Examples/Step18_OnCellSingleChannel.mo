within PatchClamp.Examples;
model Step18_OnCellSingleChannel
  "On-cell patch clamp -- activation curve P_open(V) of a Kv channel"

  // On-cell (cell-attached): the pipette seals onto the intact cell
  // membrane, so the amplifier controls the patch voltage (pipette - bath)
  // but not the whole-cell voltage -- the intracellular face stays at its
  // native, uncontrolled composition.
  //
  // With the default Kv channel, a -70 -> +20 mV step activates the
  // channels over ~5 ms (tau_max), I_patch ~ P_open*n_channels*gamma*(V_m-E_K),
  // and the current falls again (deactivation) once the step ends.
  //
  // To trace the activation curve: sweep amp.V_step (-60, -50, ..., +20
  // mV), read I_patch at the end of each step (steady state), and check
  // that P_open_inf = 1/(1+exp(-(V-V_half)/k_v)).
  //
  // With patch.n_channels = 1 (a true single channel, i_unitary ~ 1-2 pA
  // at 100 pS * 10-20 mV), P_open still shows a smooth probability, not
  // discrete jumps -- this model is deterministic mean-field, not
  // stochastic (see StochasticChannel for genuine single-channel noise).
  //
  // patch.T = 293.15 vs 310.15 K shows E_rev shift slightly (Nernst); in
  // reality tau_max would also change substantially with temperature
  // (Q10 ~ 3), which this model doesn't include.
  //
  // Compare with Step12_SodiumChannelIVCurve, which uses a nonlinear GHK
  // conductance instead of this model's ohmic one (gamma = constant).

  PatchClamp.Amplifiers.VoltageClampAmplifier amp(
    V_hold       = -0.070,
    V_step       = +0.020,
    t_step_start = 0.020,
    t_step_end   = 0.120,
    V_ljp_correction = 0.0)
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  // On-cell patch, Kv (voltage-gated K+) channel: config=1 (on-cell), z=1
  // (K+), c_pipette=[K+]_extracellular=5 mM, c_cell_native=[K+]_intracellular
  // =140 mM, gamma=100 pS (real Kv is 8-20 pS; 100 pS is used here for a
  // clearer trace), V_half=-20 mV, k_v=10 mV (typical Kv values).
  // V_junction=0.0 on the pipette: no LJP correction, so the nominal
  // command voltage is preserved; R_pipette/C_pipette are physically
  // realistic and drop under 1 mV at these pA-scale currents.
  PatchClamp.Electrodes.PatchPipette pipette(
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.SingleChannelPatch patch(
    config          = 1,
    c_pipette       = 5.0,
    c_bath          = 5.0,
    c_cell_native   = 140.0,
    z               = 1,
    T               = PatchClamp.Constants.T_body,
    gamma           = 100.0e-12,
    n_channels      = 10,
    V_half          = -0.020,
    k_v             = 0.010,
    tau_max         = 5.0e-3,
    delta_V_half    = 0.0)
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));

  connect(pipette.p_cell, patch.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));

  connect(patch.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step18_OnCellSingleChannel -- On-Cell Patch Clamp</h2>
      <p>
        Simulates a <strong>cell-attached (on-cell)</strong> patch clamp experiment
        on a membrane patch containing voltage-gated K⁺ channels (Kv).
      </p>

      <h3>Configuration</h3>
      <p>
        The pipette seals onto the intact cell membrane. The amplifier controls
        the <em>patch voltage</em> (pipette − bath), not the whole-cell voltage.
        The intracellular face is not dialyzed -- the cytoplasmic [K⁺] is the
        native value (140 mM) and cannot be changed during the experiment.
      </p>

      <h3>Expected results (default parameters)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Value</th><th>Notes</th></tr>
        <tr><td>E_rev (E_K)</td><td>−89 mV</td><td>Nernst K⁺, 140/5 mM</td></tr>
        <tr><td>i_unitary at +20 mV</td><td>~+11 pA</td><td>100 pS × (20−(−89)) mV</td></tr>
        <tr><td>I_patch (peak, 10 ch)</td><td>~+4 pA</td><td>P_open_inf(+20mV) × 10 × i_unitary</td></tr>
        <tr><td>Activation τ at +20 mV</td><td>~5 ms</td><td>tau_max / cosh(2) ≈ 1.4 ms</td></tr>
        <tr><td>P_open_inf at +20 mV</td><td>~0.98</td><td>Boltzmann: V >> V_half</td></tr>
        <tr><td>P_open_inf at −70 mV</td><td>~0.00</td><td>Well below threshold</td></tr>
      </table>

      <h3>On-cell vs whole-cell comparison</h3>
      <p>
        In a whole-cell recording, the measured current would be:
      </p>
      <pre>  I_WC = g_K_max * P_open * (V_m − E_K) * A</pre>
      <p>where g_K_max = n_channels/A × gamma. This experiment measures the
      same physics at the single-patch level: I_patch = P_open × n_channels × i_unitary.</p>

      <h3>Why P_open does not show discrete jumps</h3>
      <p>
        This model is <em>deterministic</em> (mean-field Markov). P_open represents
        the ensemble-average open probability, not a stochastic sequence of openings
        and closings. A real single-channel recording shows rectangular current pulses
        of amplitude i_unitary with random dwell times. The mean of those traces
        converges to this model's P_open × i_unitary.
      </p>

      <h3>Key teaching points</h3>
      <ul>
        <li>The activation curve P_open_inf(V) is directly measurable from I_patch
            at the end of each voltage step (steady-state).</li>
        <li>V_half and k_v are the two parameters a student extracts from fitting
            a Boltzmann to the I/I_max vs V relationship.</li>
        <li>The on-cell configuration preserves the native intracellular environment
            -- it is the least invasive patch-clamp mode.</li>
        <li>The amplifier measures pipette current; with n_channels = 1 this is
            truly a single-channel amplitude measurement.</li>
      </ul>
    </html>"),
    experiment(
      StopTime  = 0.200,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(
        points = {{-190, -80}, {190, -80}},
        color = {0, 0, 255},
        thickness = 0.5),
      Text(
        extent = {{-190, -82}, {-120, -96}},
        textString = "GND bus",
        textColor = {0, 0, 200},
        fontSize = 9),
      Text(
        extent = {{-190, 60}, {-110, 44}},
        textString = "V-Clamp",
        textColor = {0, 80, 160},
        fontSize = 9),
      Text(
        extent = {{-90, 60}, {-10, 44}},
        textString = "Pipette",
        textColor = {100, 0, 150},
        fontSize = 9),
      Text(
        extent = {{10, 60}, {90, 44}},
        textString = "On-Cell Patch",
        textColor = {0, 100, 0},
        fontSize = 9),
      Text(
        extent = {{110, 60}, {190, 44}},
        textString = "Bath",
        textColor = {150, 80, 0},
        fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 180},
        lineThickness = 2.0,
        fillColor = {225, 240, 255},
        fillPattern = FillPattern.Solid),
      // Pipette (triangle pointing right)
      Polygon(
        points = {{-90, 30}, {-90, -30}, {-30, 0}},
        lineColor = {0, 80, 160},
        lineThickness = 1.5,
        fillColor = {180, 210, 255},
        fillPattern = FillPattern.Solid),
      // Cell membrane (curved arc suggesting intact cell)
      Ellipse(
        extent = {{-15, 60}, {85, -60}},
        lineColor = {120, 90, 20},
        lineThickness = 2.5,
        fillColor = {255, 220, 180},
        fillPattern = FillPattern.None),
      // Channel pore
      Rectangle(
        extent = {{-8, 18}, {8, -18}},
        lineColor = {0, 100, 180},
        lineThickness = 1.5,
        fillColor = {200, 230, 255},
        fillPattern = FillPattern.Solid),
      // Label
      Text(
        extent = {{-90, 88}, {90, 73}},
        textString = "On-Cell",
        textColor = {0, 80, 160},
        fontSize = 11),
      Text(
        extent = {{-90, -70}, {90, -95}},
        textString = "Step18 On-Cell Patch",
        textColor = {0, 80, 160},
        fontSize = 9)
    })
  );
end Step18_OnCellSingleChannel;
