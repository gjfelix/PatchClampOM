within PatchClamp.Examples;
model Step25_LigandGatedSingleChannel
  "Stochastic ligand-gated single-channel recording -- agonist pulse on an outside-out patch"

  // Same stochastic-patch circuit as Step21, but the channel is opened by an
  // AGONIST instead of by voltage. The membrane is held at a constant
  // -70 mV; a 30 uM agonist pulse is applied from t = 0.05 to 0.20 s
  // (fast perfusion of an outside-out patch).
  //
  // Variables worth plotting: chan.I_patch [A] (discrete inward steps while
  // agonist is present), chan.I_mean (smooth ensemble average),
  // chan.c_L (agonist concentration), chan.nOpenChannels.
  //
  // Experiments:
  //  * Dose-response: repeat with chan.c_agonist = 0.003, 0.010, 0.030, 0.100 mM
  //    and compare the fraction of time open to chan.P_open_inf (Hill curve).
  //  * Law of large numbers: n_channels = 1, 5, 20 -- I_patch converges to I_mean.
  //  * Deactivation: after t_agonist_off the channel closes with time constant
  //    1/k_close; with many channels this is a smooth exponential decay.
  //  * Histogram: export I_patch for t = 0.08-0.20 s; two peaks at 0 and
  //    ~ -2.1 pA (30 pS x -70 mV).

  PatchClamp.Amplifiers.VoltageClampAmplifier amp(
    V_hold       = -0.070,
    V_step       = -0.070,
    t_step_start = 0.020,
    t_step_end   = 0.120,
    V_ljp_correction = 0.0)
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.LigandGatedChannel chan(
    n_channels       = 1,
    gamma            = 30.0e-12,
    E_rev            = 0.0,
    EC50             = 0.010,
    n_hill           = 2.0,
    k_close          = 200.0,
    c_agonist        = 0.030,
    t_agonist_on     = 0.050,
    t_agonist_off    = 0.200,
    dt               = 5.0e-5,
    useAutomaticSeed = false,
    fixedSeed        = 42)
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pipette.p_cell, chan.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(chan.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));
  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step25_LigandGatedSingleChannel — Ligand-Gated Single-Channel Recording</h2>
      <p>
        A single ligand-gated channel (30 pS, nonselective cation, E_rev = 0 mV) in an
        outside-out patch held at -70 mV. A 30 uM agonist pulse (EC50 = 10 uM, Hill
        coefficient 2) is applied from 0.05 to 0.20 s.
      </p>

      <h3>Expected results (default parameters, fixedSeed = 42)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Value</th><th>Notes</th></tr>
        <tr><td>i_unitary</td><td>-2.1 pA</td><td>30 pS x (-70 - 0) mV (inward)</td></tr>
        <tr><td>P_open_inf with agonist</td><td>0.90</td><td>Hill: 30^2/(30^2+10^2)</td></tr>
        <tr><td>P_open_inf without agonist</td><td>0</td><td>channel silent before and after the pulse</td></tr>
        <tr><td>Mean open time</td><td>~5 ms</td><td>1/k_close</td></tr>
        <tr><td>Deactivation tau (many channels)</td><td>5 ms</td><td>after agonist removal</td></tr>
      </table>

      <h3>Why this differs from Step21</h3>
      <p>
        In Step21 the channel is voltage-gated: the voltage step itself opens it.
        Here the voltage is constant and gating is controlled entirely by the ligand
        concentration. No current flows without agonist, regardless of voltage.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.300,
      Interval  = 5e-5,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 255}, thickness = 0.5),
      Text(extent = {{-190, -82}, {-120, -96}}, textString = "GND bus", textColor = {0, 0, 200}, fontSize = 9),
      Text(extent = {{-190, 60}, {-110, 44}}, textString = "V-Clamp", textColor = {0, 80, 160}, fontSize = 9),
      Text(extent = {{-90, 60}, {-10, 44}}, textString = "Pipette", textColor = {100, 0, 150}, fontSize = 9),
      Text(extent = {{10, 60}, {90, 44}}, textString = "Ligand-gated Channel", textColor = {20, 110, 60}, fontSize = 9),
      Text(extent = {{110, 60}, {190, 44}}, textString = "Bath", textColor = {150, 80, 0}, fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {20, 110, 60},
        lineThickness = 2.0,
        fillColor = {220, 245, 228},
        fillPattern = FillPattern.Solid),
      Ellipse(extent = {{-80, 70}, {-60, 50}}, lineColor = {200, 60, 20}, fillColor = {255, 170, 120}, fillPattern = FillPattern.Solid),
      Line(points = {{-60, 0}, {-30, 0}, {-30, -25}, {-10, -25}, {-10, 0}, {20, 0}, {20, -25}, {50, -25}, {50, 0}, {80, 0}}, color = {20, 110, 60}, thickness = 1.2),
      Text(extent = {{-90, 88}, {90, 73}}, textString = "Ligand-gated", textColor = {20, 110, 60}, fontSize = 11),
      Text(extent = {{-90, -70}, {90, -95}}, textString = "Step25 Single Channel", textColor = {20, 110, 60}, fontSize = 9)
    })
  );
end Step25_LigandGatedSingleChannel;
