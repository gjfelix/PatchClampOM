within PatchClamp.Examples;
model Step21_StochasticSingleChannel
  "Stochastic single-channel recording -- the same Kv channel as Step18, but with discrete events"

  // Uses EXACTLY the same Kv channel as Step18_OnCellSingleChannel (same
  // V_half, k_v, tau_max, gamma, concentrations), but with
  // StochasticChannel instead of SingleChannelPatch, to see a genuine
  // single-channel recording -- discrete jumps between 0 and i_unitary
  // with random dwell times -- directly against Step18's smooth,
  // deterministic trace.
  //
  // Variables worth plotting: chan.I_patch [pA] (discrete steps),
  // chan.isOpen[1] (the channel's 0/1 state -- its "raster"),
  // chan.nOpenChannels (channels open at each instant; here, 0 or 1).
  //
  // Overlay chan.I_patch (this model) with patch.I_patch (Step18): the
  // latter is the average this trace fluctuates around.
  //
  // Law of large numbers: sweep n_channels = 1, 5, 20 and watch I_patch
  // converge toward Step18's smooth curve (which uses n_channels=10);
  // very large n_channels (>~50) may need more compute time or solver
  // tuning -- see StochasticChannel's documentation.
  //
  // Amplitude histogram: export chan.I_patch during the pulse's steady
  // state (t = 0.08-0.12 s) and histogram it. With n_channels=1 there
  // should be two peaks -- one at 0 pA (closed), one at ~i_unitary pA
  // (open) -- the classic signature of a real single-channel recording.
  //
  // Reproducibility: change chan.fixedSeed (e.g. 42 to 7) and re-simulate.
  // The opening pattern changes, but the statistics (mean P_open, mean
  // open duration) should stay consistent with Step18 in the long-time limit.

  PatchClamp.Amplifiers.VoltageClampAmplifier amp(
    V_hold       = -0.070,
    V_step       = +0.020,
    t_step_start = 0.020,
    t_step_end   = 0.120,
    V_ljp_correction = 0.0)
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  // Stochastic on-cell patch: same Kv channel as Step18, n_channels=1
  PatchClamp.Membranes.StochasticChannel chan(
    config          = 1,
    c_pipette       = 5.0,
    c_bath          = 5.0,
    c_cell_native   = 140.0,
    z               = 1,
    T               = PatchClamp.Constants.T_body,
    gamma           = 100.0e-12,
    n_channels      = 1,
    V_half          = -0.020,
    k_v             = 0.010,
    tau_max         = 5.0e-3,
    delta_V_half    = 0.0,
    dt              = 5.0e-5,
    useAutomaticSeed = false,
    fixedSeed       = 42)
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
      <h2>Step21_StochasticSingleChannel -- Stochastic Single-Channel Recording</h2>
      <p>
        Same Kv channel as <code>Step18_OnCellSingleChannel</code> (identical V_half, k_v, tau_max,
        gamma, and ionic concentrations), but simulated with
        <code>StochasticChannel</code> instead of <code>SingleChannelPatch</code>,
        with <em>n_channels = 1</em> -- a genuine single-channel recording.
      </p>

      <h3>Expected results (default parameters, fixedSeed = 42)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Value</th><th>Notes</th></tr>
        <tr><td>E_rev (E_K)</td><td>-89.1 mV</td><td>identical to Step18 (same Nernst calc)</td></tr>
        <tr><td>i_unitary at +20 mV</td><td>~10.9 pA</td><td>100 pS x (20-(-89.1)) mV</td></tr>
        <tr><td>P_open_inf at +20 mV</td><td>0.982</td><td>identical Boltzmann curve as Step18</td></tr>
        <tr><td>I_patch during step</td><td>0 pA or ~10.9 pA</td><td>two discrete levels, not a smooth curve</td></tr>
        <tr><td>Fraction of time open (t=0.08-0.12s)</td><td>~0.98</td><td>matches P_open_inf statistically</td></tr>
      </table>

      <h3>Why this differs from Step18</h3>
      <p>
        Step18's <code>SingleChannelPatch</code> is deterministic: it solves an ODE for
        the ensemble-average P_open(t) and reports a smooth current. This example's
        <code>StochasticChannel</code> instead flips a single channel randomly between
        closed and open at voltage-dependent rates, producing the rectangular,
        randomly-timed current steps seen in a real excised- or cell-attached-patch
        recording. Averaging many repeats of this experiment (or increasing
        n_channels) recovers Step18's smooth curve -- a direct illustration of the
        relationship between single-channel and mean-field (macroscopic) descriptions.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.150,
      Interval  = 5e-5,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 255}, thickness = 0.5),
      Text(extent = {{-190, -82}, {-120, -96}}, textString = "GND bus", textColor = {0, 0, 200}, fontSize = 9),
      Text(extent = {{-190, 60}, {-110, 44}}, textString = "V-Clamp", textColor = {0, 80, 160}, fontSize = 9),
      Text(extent = {{-90, 60}, {-10, 44}}, textString = "Pipette", textColor = {100, 0, 150}, fontSize = 9),
      Text(extent = {{10, 60}, {90, 44}}, textString = "Stochastic Channel", textColor = {160, 60, 0}, fontSize = 9),
      Text(extent = {{110, 60}, {190, 44}}, textString = "Bath", textColor = {150, 80, 0}, fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {160, 60, 0},
        lineThickness = 2.0,
        fillColor = {255, 235, 220},
        fillPattern = FillPattern.Solid),
      Polygon(
        points = {{-90, 30}, {-90, -30}, {-30, 0}},
        lineColor = {160, 60, 0},
        lineThickness = 1.5,
        fillColor = {255, 210, 180},
        fillPattern = FillPattern.Solid),
      Line(points = {{-15, 40}, {-15, 20}, {5, 20}, {5, 45}, {25, 45}, {25, 15}, {45, 15}, {45, 30}, {80, 30}}, color = {160, 60, 0}, thickness = 1.2),
      Text(extent = {{-90, 88}, {90, 73}}, textString = "Stochastic", textColor = {140, 50, 0}, fontSize = 11),
      Text(extent = {{-90, -70}, {90, -95}}, textString = "Step21 Single Channel", textColor = {140, 50, 0}, fontSize = 9)
    })
  );
end Step21_StochasticSingleChannel;
