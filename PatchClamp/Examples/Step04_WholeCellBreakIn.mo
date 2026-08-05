within PatchClamp.Examples;
model Step04_WholeCellBreakIn
  "Whole-cell break-in -- patch rupture and the slow capacitive transient (step 3)"

  // The membrane patch has just been ruptured (by further suction or a
  // voltage pulse), putting the pipette interior in electrical continuity
  // with the cytoplasm. The equivalent circuit changes from cell-attached's
  // (R_seal || R_patch || C_patch) (Step02) to whole-cell's R_access in
  // series with (C_m || R_m) (this model):
  //
  //   SealTest         PatchPipette        WholeCell            Bath
  //   [V_pulse] --- [R_pip + C_pip] --- [R_access] -+- C_m --- GND
  //                                                   +- R_m --- GND
  //
  // On each -5 mV pulse there are three regimes: a fast transient
  // (tau_fast ~ R_pip*C_pip ~ 4M*3pF = 12 us, ~1 nA, charging C_pip, nearly
  // invisible at whole-cell scale), the slow transient we're here to see
  // (tau_slow ~ R_access*C_m ~ 10M*50pF = 500 us, ~0.5 nA, C_m charging
  // through R_access), and the DC steady state
  // (I_ss = V_pulse/(R_pip+R_access+R_m) = 5e-3/(4M+10M+200M) ~ 23 pA).
  //
  // Try: a small cell (R_access=10M, C_m=20pF, R_m=200M -> tau_slow=200us,
  // I_peak~500pA); a large neuron (C_m=100pF, R_m=500M -> tau_slow=1ms,
  // a much wider transient); degraded access (R_access=30M ->
  // tau_slow=1.5ms, and V_m no longer tracks V_cmd well); or C_m
  // compensation (set C_m=0 to see what a perfectly-compensated trace
  // would look like -- real amplifiers cancel this transient with analog
  // circuitry). A successful whole-cell break-in is confirmed
  // experimentally by: the slow transient appearing (absent in
  // cell-attached), I_steady dropping relative to cell-attached (since
  // R_m >> R_seal), an estimated R_access in the 5-30 MOhm range, and
  // C_m estimated from the transient's charge integral, Q/V_pulse.
  //
  // Next: switch to current clamp and inject current to see action
  // potentials -- see Step06_HodgkinHuxleyActionPotential for the same
  // protocol applied to a full excitable cell.

  PatchClamp.Amplifiers.SealTest seal_test(
    V_pulse       = -5.0e-3,
    t_period      = 0.020,
    t_pulse_width = 0.010,
    t_start       = 0.002,
    R_pipette_nom = 4.0e6)
    "Seal-test: -5 mV pulse, 50 Hz"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Pipette: R=4 MOhm, C=3 pF (same as Step02)"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  // Replaces CellAttachedPatch now that the patch has ruptured
  PatchClamp.Membranes.WholeCell cell(
    R_access = 10.0e6,
    C_m      = 50.0e-12,
    R_m      = 200.0e6)
    "Cell: R_access=10 MOhm, C_m=50 pF, R_m=200 MOhm"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: 0 V reference"
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(seal_test.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));

  connect(pipette.p_cell, cell.p_pip)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));

  connect(cell.p_ext, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(seal_test.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step04 -- Whole-cell break-in (patch clamp step 3)</h2>

      <h3>Learning objective</h3>
      <p>
        Simulate the membrane patch rupturing and observe the slow
        capacitive transient characteristic of the whole-cell
        configuration. Its time constant, tau = R_access * C_m, sets the
        speed of the voltage clamp.
      </p>

      <h3>Equivalent circuit</h3>
      <pre>
  SealTest    PatchPipette         WholeCell          Bath
  [V_pls] - [R_pip=4M + C_pip=3pF] - [R_acc=10M] -+- C_m=50pF - GND
                                                     +- R_m=200M - GND
      </pre>

      <h3>Time constants</h3>
      <pre>
  tau_fast    = R_pip * C_pip  = 4M * 3pF   =  12 us  (pipette transient)
  tau_slow    = R_acc * C_m    = 10M * 50pF = 500 us  (membrane transient -- watch this one)
  tau_membrane = R_m * C_m     = 200M * 50pF = 10 ms  (slow discharge at the end)
      </pre>

      <h3>Expected currents</h3>
      <pre>
  I_peak_slow ~ V_pulse / R_access = 5e-3 / 10e6  = 500 pA  (slow transient peak)
  I_steady    = V_pulse / (R_pip + R_access + R_m) ~ 23 pA   (DC)
  Q_Cm        = C_m * V_pulse      = 50pF * 5mV   = 0.25 pC (transient charge integral)
      </pre>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><b>seal_test.I_measured</b> -- total current measured by the amplifier [A]</li>
        <li><b>cell.I_Cm</b>           -- slow membrane capacitive current [A]</li>
        <li><b>cell.I_Rm</b>           -- DC ionic current [A]</li>
        <li><b>cell.V_m</b>            -- membrane voltage (clamp quality) [V]</li>
      </ul>

      <h3>Suggested simulation</h3>
      <p>stopTime = 0.060 s, numberOfIntervals = 20000 (3 us resolution, to resolve the fast transient)</p>
    </html>"),
    experiment(
      StopTime    = 0.060,
      Interval    = 3e-6,
      Tolerance   = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, 100}, {100, -100}},
        lineColor = {120, 0, 50},
        fillColor = {255, 220, 230},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step04",
        fontSize = 22,
        textColor = {100, 0, 40}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "Whole-Cell",
        fontSize = 14,
        textColor = {100, 0, 40}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Step 4",
        fontSize = 12,
        textColor = {150, 60, 80})
    })
  );
end Step04_WholeCellBreakIn;
