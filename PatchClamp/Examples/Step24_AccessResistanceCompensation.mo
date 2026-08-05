within PatchClamp.Examples;
model Step24_AccessResistanceCompensation
  "R_s (series/access resistance) compensation in isolation -- whole-cell, both capacitive transients pre-compensated"

  // Continuing from Step22 (C-fast) and Step23 (C-slow), both capacitive
  // transients are pre-compensated here (frac_fast=1, frac_slow=1), so the
  // only remaining artifact is a DC voltage-clamp error: current flowing
  // through the series resistance drops some of the command voltage before
  // it ever reaches the membrane, so the cell never actually sees V_step.
  //
  // R_m is lowered relative to Step23 (20 MOhm instead of 200 MOhm) purely
  // to make that steady-state error large enough to see clearly on a
  // passive cell without needing an active channel model -- a real cell's
  // fast Na+/Ca2+ currents reach the same current regime (nA-scale) even
  // with high R_m; see Step12 or Step16 for R_s error's effect on real
  // channel kinetics.
  //
  // tau_comp is raised to 50 us here (vs. the library default of 15 us):
  // CompensatedVClampAmp's own documentation notes 15 us as the minimum
  // verified stable value, but that was verified against Step13's passive
  // cell (R_m=1 GOhm, C_m=10 pF) -- this cell's much lower R_m (20 MOhm,
  // closer to R_s itself) makes the R_s positive-feedback loop harder to
  // stabilize, and 15 us goes unstable (singular iteration matrix) well
  // before alpha reaches 0.9 here. On a real amplifier, too, the safe
  // R_s-compensation bandwidth depends on the cell being recorded, not
  // just the amplifier.
  //
  // Try: alpha = 0.0 (default) shows the full DC voltage error -- the cell
  // only reaches -29.4 mV of the commanded -50 mV step. alpha = 0.7 cuts
  // the error roughly in half (cell.V_m -> -41.3 mV); alpha = 0.9 (the
  // stability limit for this model) gets close to the true command
  // (cell.V_m -> -46.7 mV).

  PatchClamp.Amplifiers.Compensation.CompensatedVClampAmp amp(
    V_hold        = -0.070,
    V_step        = -0.050,
    t_step_start  = 0.050,
    t_step_end    = 0.150,
    V_ljp_correction = 0.0,
    C_fast    = 3.0e-12,
    frac_fast = 1.0,
    C_slow    = 50.0e-12,
    R_s_est   = 14.0e6,
    frac_slow = 1.0,
    R_s       = 14.0e6,
    alpha     = 0.9,
    tau_comp  = 50.0e-6)
    "Both capacitive transients pre-compensated; R_s compensation off by default -- toggle alpha up to 0.9"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Same parameters as Step04/Step23"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.WholeCell cell(
    R_access = 10.0e6,
    C_m      = 50.0e-12,
    R_m      = 20.0e6,
    V_m_init = -0.070)
    "Same access/capacitance as Step23; R_m lowered to make the R_s voltage
     error clearly visible. V_m_init matches V_hold (see Step23 for why
     this is needed instead of the model's default 0 V baseline)."
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pip.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pip.p_cell, cell.p_pip)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(cell.p_ext, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pip.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step24 -- R_s (series resistance) compensation, isolated</h2>

      <h3>Learning objective</h3>
      <p>
        See R_s compensation acting on its own, with both capacitive
        transients already handled (as if Step22 and Step23 had already been
        run on this same cell). What's left is a pure DC voltage-clamp
        error: current flowing through the series resistance drops some of
        the command voltage before it ever reaches the membrane, so the cell
        never actually sees V_step.
      </p>

      <h3>Circuit and series resistance</h3>
      <pre>
  [CompensatedVClampAmp] --[PatchPipette]-- [WholeCell] --[BathElectrode]
        amp.p                 pip.p_cell     cell.p_pip
        C-fast comp (on)      R_pipette=4M   R_access=10M -+- C_m=50pF (on)
        C-slow comp (on)                                    +- R_m=20M
        R_s comp (off)

  R_s (total series resistance) = R_pipette + R_access = 4 MOhm + 10 MOhm = 14 MOhm
      </pre>

      <h3>Expected voltage error (simulated)</h3>
      <p>
        This circuit has no other voltage source downstream (no reversal
        potential, just resistors to ground), so the membrane potential is
        pulled toward the amplifier's command by a simple voltage divider
        across R_pipette + R_access + R_m -- current through R_s (the first
        two of those) drops most of the intended step before it reaches the
        membrane:
      </p>
      <pre>
  Command (amp.V_command during the step): -50 mV

  alpha = 0.0:  cell.V_m -&gt; -29.4 mV   (only 59% of the command reaches the cell!)
  alpha = 0.7:  cell.V_m -&gt; -41.3 mV   (error roughly halved)
  alpha = 0.9:  cell.V_m -&gt; -46.7 mV   (close to the true command)
      </pre>
      <p>
        A voltage-clamp error this large (over 20 mV at alpha=0) is
        dramatic, but not unrealistic for a small, leaky cell recorded with
        a modest-resistance pipette -- exactly the situation where R_s
        compensation matters most. In a healthier, high-R_m cell the same
        absolute error would be a much smaller fraction of the step; but
        fast, large ionic currents (Na+, Ca2+ during an action potential)
        reach comparable current magnitudes even then, which is why R_s
        compensation is standard practice for any experiment measuring fast
        channel kinetics.
      </p>

      <h3>Suggested exploration</h3>
      <ol>
        <li>Simulate at defaults (alpha = 0.0): plot amp.V_error and amp.V_m_estimated -- see how far V_m_estimated sits from the commanded -50 mV.</li>
        <li>Set alpha = 0.7, then 0.9: watch the residual error shrink and V_m_estimated approach -50 mV.</li>
        <li>Compare cell.V_m (the true membrane voltage) against amp.V_m_estimated at each alpha to check how good the estimate really is.</li>
      </ol>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>amp.V_error</code> -- raw diagnostic quantity = R_s * I_raw (NOT the residual error after compensation -- compare cell.V_m to the command instead for that)</li>
        <li><code>amp.V_m_estimated</code> -- best estimate of the real membrane potential</li>
        <li><code>cell.V_m</code> -- the cell's actual membrane voltage (ground truth, for comparison)</li>
      </ul>

      <h3>Previous steps</h3>
      <p>
        <code>Step22_PipetteCapacitanceCompensation</code> (C-fast,
        cell-attached) and <code>Step23_WholeCellCapacitanceCompensation</code>
        (C-slow, just after break-in) cover the other two compensations this
        one assumes are already active. See also
        <code>Step13_SeriesResistanceCompensation</code>, which demonstrates
        all three compensations together on a single passive cell, and
        <code>docs/compensation-guide.md</code> for the full conceptual
        writeup.
      </p>
    </html>"),
    experiment(
      StopTime   = 0.200,
      Interval   = 1e-6,
      Tolerance  = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {180, 100, 0},
        lineThickness = 2.0,
        fillColor = {255, 240, 220},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step24",
        fontSize = 20,
        textColor = {150, 80, 0}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "R_s only",
        fontSize = 13,
        textColor = {150, 80, 0}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Whole-cell",
        fontSize = 11,
        textColor = {190, 130, 60})
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step24: R_s compensation, isolated (whole-cell, both C comps already active)",
        textColor = {80, 80, 80},
        fontSize = 12),
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
end Step24_AccessResistanceCompensation;