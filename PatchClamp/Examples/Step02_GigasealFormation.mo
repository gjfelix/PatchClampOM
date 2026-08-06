within PatchClamp.Examples;
model Step02_GigasealFormation
  "Cell-attached gigaseal formed -- seal-test with a membrane patch (step 2)"

  // The pipette has touched the cell membrane and light suction has been
  // applied, bringing the glass-membrane seal above 1 GOhm; seal-test
  // current drops from ~1.25 nA (free bath, Step01) to ~5 pA, now limited
  // by R_seal rather than R_pip.
  //
  // Try sweeping patch.R_seal to see the progression toward a gigaseal:
  //   R_seal = 10 MOhm  -> I_steady ~ 350 pA  (weak seal)
  //   R_seal = 100 MOhm -> I_steady ~  35 pA  (partial seal)
  //   R_seal = 500 MOhm -> I_steady ~   9 pA  (good seal)
  //   R_seal = 1 GOhm   -> I_steady ~   5 pA  (gigaseal)
  //   R_seal = 5 GOhm   -> I_steady ~   1 pA  (excellent)
  // At what R_seal does the current drop below the pipette's Johnson
  // thermal noise floor (~0.5 pA at 5 kHz bandwidth)?
  //
  // Also try sweeping patch.C_patch (0.05-0.5 pF) to see how the pulse-edge
  // capacitive transient changes -- in practice, a smaller patch gives a
  // better seal-to-noise ratio.

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
    "Pipette: R=4 MOhm, C=3 pF"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.CellAttachedPatch patch(
    R_seal  = 1.0e9,
    R_patch = 50.0e9,
    C_patch = 0.1e-12)
    "Patch: gigaseal R_seal=1 GOhm, closed channels R_patch=50 GOhm, C_patch=0.1 pF"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: 0 V reference"
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(seal_test.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));

  connect(pipette.p_cell, patch.p_pip)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));

  connect(patch.p_ext, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(seal_test.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step02 -- Cell-attached gigaseal (patch clamp step 2)</h2>

      <h3>Learning objective</h3>
      <p>
        Simulate gigaseal formation and watch the seal-test current drop
        from ~1.25 nA (free pipette) to ~5 pA (a 1 GOhm gigaseal) -- the
        experimental criterion confirming the seal is good enough to
        continue.
      </p>

      <h3>Expected currents</h3>
      <pre>
  R_total = R_pip + R_seal || R_patch
          = 4 MOhm + (1G || 50G)
          = 4 MOhm + 0.98 GOhm
          ~ 0.984 GOhm

  I_steady = V_pulse / R_total
           = 5e-3 / 0.984e9
           ~ 5.1 pA   (vs. 1.25 nA in Step01: a 250-fold drop)
      </pre>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><b>seal_test.I_measured</b> -- total current (should settle near ~5 pA)</li>
        <li><b>patch.I_seal</b> -- seal leak current</li>
        <li><b>patch.I_C_patch</b> -- patch capacitive transient</li>
        <li><b>seal_test.R_seal_est</b> -- resistance estimate (converges to ~1 GOhm)</li>
      </ul>

      <h3>Suggested simulation</h3>
      <p>stopTime = 0.060 s, numberOfIntervals = 10000</p>

      <h3>Next step</h3>
      <p>
        Once the gigaseal is confirmed (I_steady &lt; 10 pA), the patch is
        ruptured with further suction to reach the whole-cell
        configuration -- see <code>Step04_WholeCellBreakIn</code>, followed
        by <code>Step03_PassiveCellVoltageClamp</code> (voltage clamp) and
        <code>Step05_PassiveCellCurrentClamp</code> (current clamp).
      </p>
    </html>"),
    experiment(
      StopTime    = 0.060,
      Interval    = 6e-6,
      Tolerance   = 1e-6),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, 100}, {100, -100}},
        lineColor = {0, 120, 50},
        fillColor = {220, 255, 230},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step02",
        fontSize = 22,
        textColor = {0, 100, 40}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "Gigaseal",
        fontSize = 14,
        textColor = {0, 100, 40}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Step 2",
        fontSize = 12,
        textColor = {60, 150, 80})
    })
  );
end Step02_GigasealFormation;
