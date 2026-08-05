within PatchClamp.Examples;
model Step16_CardiacActionPotential
  "Cardiac ventricular action potential -- Ca2+ plateau (~200 ms)"

  // Compare the long cardiac action potential with its Ca2+ plateau
  // against the neuronal AP in Step06. The default 1 ms current pulse
  // fires a single AP: watch the fast upstroke (~1 ms), the ~150 ms
  // plateau, then repolarization, via neuron.V_m, neuron.I_Na, neuron.I_Ca,
  // neuron.I_K.
  //
  // Refractory period: add a second pulse during the plateau
  // (amp.I_pulse2 = 0.5e-12, amp.t_pulse2_start = 0.050) -- it should NOT
  // fire a second AP, since Na+ channels are fully inactivated (h_Na ~ 0)
  // throughout the plateau.
  //
  // Compared to the HH neuron (Step06): duration ~2 ms (HH) vs. ~200 ms
  // (cardiac); no Ca2+ plateau (HH) vs. a pronounced one (cardiac); max
  // firing rate ~100 Hz (HH) vs. ~5 Hz (cardiac).
  //
  // Pharmacology: reducing neuron.g_Ca from 0.5 to 0.0 removes the
  // plateau entirely (immediate repolarization), modeling a Ca2+ channel
  // blocker like verapamil; reducing neuron.g_K from 2.0 to 0.0 instead
  // prolongs the plateau and slows repolarization dramatically, modeling
  // an IKr blocker (as with some antiarrhythmics).

  PatchClamp.Amplifiers.CurrentClampAmplifier amp(
    I_hold        = 0.0,
    I_pulse       = 2000.0e-12,
    t_pulse_start = 0.005,
    t_pulse_end   = 0.007,
    R_bridge      = 0.0)
    // 2 nA x 2 ms: DeltaV = 2000e-12 * 2e-3 / 100e-12 = 40 mV (-80 to -40 mV).
    // The Na+ threshold (~-45 mV) is crossed at ~1.75 ms. A short pulse is
    // needed to cross threshold before h_Na inactivates (tau_h = 8 ms, so
    // pulses beyond ~5 ms start to see accommodation); a longer, slower
    // pulse (e.g. 500 pA x 10 ms) would let h_Na decay to ~0 before threshold.
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 3.0e6,
    C_pipette  = 2.0e-12,
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.CardiacVentricularCell neuron(
    C_m   = 100.0e-12,
    g_Na  = 230.0,
    g_Ca  = 3.0,
    g_K   = 1.0,
    g_K1  = 10.0,
    g_L   = 2.0,
    E_Na  = 0.050,
    E_Ca  = 0.120,
    E_K   = -0.084,
    E_L   = -0.084,
    tau_m = 0.5e-3,
    tau_h = 8.0e-3,
    tau_n = 200.0e-3,
    tau_f = 300.0e-3)
    "Simplified Beeler-Reuter parameters"
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
      <h2>Step16 -- Cardiac ventricular action potential</h2>
      <p>
        A current-clamp experiment with the cardiac ventricular cell: a
        brief (1 ms) current pulse fires a long (~200 ms) action potential
        with the Ca2+ plateau characteristic of cardiac muscle.
      </p>

      <h3>Circuit</h3>
      <pre>  [CurrentClampAmp] -- [PatchPipette] -- [CardiacVentricularCell] -- [BathElectrode]</pre>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>neuron.V_m</code> -- membrane potential [V]</li>
        <li><code>neuron.m_Na</code> -- Na+ activation (transient)</li>
        <li><code>neuron.h_Na</code> -- Na+ inactivation (slow)</li>
        <li><code>neuron.n_K</code> -- IKr activation (very slow)</li>
        <li><code>neuron.d_inf</code> -- L-type Ca2+ activation (instantaneous)</li>
        <li><code>neuron.I_Na</code> -- Na+ current [A]</li>
        <li><code>neuron.I_Ca</code> -- Ca2+ current [A]</li>
        <li><code>neuron.I_K</code>  -- K+ current [A]</li>
      </ul>

      <h3>The plateau mechanism</h3>
      <p>
        Upstroke: m_Na activates rapidly (tau_m = 0.5 ms), and inward
        I_Na depolarizes the cell to ~+30 mV within ~1 ms. Inactivation:
        h_Na decays (tau_h = 8 ms), turning I_Na off. Plateau: d_inf ~ 0.78
        keeps I_Ca active (inward) while n_K grows slowly (tau_n = 200 ms).
        Repolarization: once n_K^2 * g_K overtakes I_Ca, I_K dominates and
        V_m returns to -80 mV over ~50 ms. Rest: I_L holds the cell at
        -80 mV (E_L).
      </p>

      <h3>HH vs. cardiac</h3>
      <table border='1'>
        <tr><th></th><th>Step06 HH</th><th>Step16 cardiac</th></tr>
        <tr><td>AP duration</td><td>~2 ms</td><td>~200 ms</td></tr>
        <tr><td>I_Ca present</td><td>no</td><td>yes (plateau)</td></tr>
        <tr><td>Max firing rate</td><td>~100 Hz</td><td>~5 Hz</td></tr>
        <tr><td>C_m</td><td>10 pF</td><td>100 pF</td></tr>
        <tr><td>Refractory period</td><td>~5 ms</td><td>~250 ms</td></tr>
      </table>
    </html>"),
    experiment(
      StopTime  = 0.400,
      Interval  = 1e-5,
      Tolerance = 1e-9),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {180, 0, 0},
        lineThickness = 2.0,
        fillColor = {255, 235, 235},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {120, 0, 0},
        fillColor = {30, 0, 0},
        fillPattern = FillPattern.Solid),
      Line(points = {{-85, 18}, {85, 18}}, color = {80, 0, 0}),
      Line(points = {{0, 65}, {0, -30}},   color = {80, 0, 0}),
      Line(
        points = {{-82, -10}, {-60, -10}, {-50, 52}, {-38, 45}, {-20, 42},
                  {10, 40}, {35, 38}, {55, 20}, {70, -8}, {82, -10}},
        color = {255, 80, 80},
        thickness = 2.5),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step16 Cardiac AP",
        textColor = {140, 0, 0},
        fontSize = 11)
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step16: Ventricular action potential -- Ca2+ plateau (~200 ms)",
        textColor = {80, 80, 80},
        fontSize = 12),
      Text(extent = {{-190, 48}, {-110, 40}}, textString = "I-clamp",   textColor = {100, 0, 150}, fontSize = 9),
      Text(extent = {{-90,  48}, {-10, 40}},  textString = "Pipette",   textColor = {100, 80, 0},  fontSize = 9),
      Text(extent = {{10,   48}, {90,  40}},  textString = "Cardiac",   textColor = {180, 0, 0},   fontSize = 9),
      Text(extent = {{110,  48}, {190, 40}},  textString = "Bath",      textColor = {0, 100, 0},   fontSize = 9),
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 0}, thickness = 2.0),
      Text(extent = {{-50, -72}, {50, -84}},   textString = "GND bus", textColor = {80, 80, 80}, fontSize = 9)
    })
  );
end Step16_CardiacActionPotential;
