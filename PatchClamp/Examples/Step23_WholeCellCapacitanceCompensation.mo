within PatchClamp.Examples;
model Step23_WholeCellCapacitanceCompensation
  "C-slow compensation in isolation -- whole-cell configuration just after break-in (companion to Step04)"

  // The patch has just ruptured (see Step04_WholeCellBreakIn): the pipette
  // interior is now in continuity with the cytoplasm through R_access, and
  // a new capacitive transient appears as C_m charges through the total
  // series resistance (R_pipette + R_access) -- this is what C-slow
  // compensation targets.
  //
  // frac_fast = 1.0 is set here (continuing from Step22) to match the real
  // order of operations on a rig, but -- as explained in
  // Step22_PipetteCapacitanceCompensation's own documentation -- it has NO
  // visible numerical effect in this circuit while alpha = 0: this model's
  // C_pipette current is a mathematically instantaneous impulse, invisible
  // to any sampled trace, so there was never a separate fast transient here
  // for frac_fast to remove. The single transient this whole circuit
  // actually produces is C_m charging through (R_pipette + R_access),
  // tau ~ 650 us -- and THAT is what C-slow compensation targets and
  // removes below.
  //
  // Try: frac_slow = 0.0 (default) shows the raw exponential in amp.I_raw;
  // frac_slow = 1.0 cancels most of it, leaving mostly the resistive (DC)
  // current -- what a real amplifier displays once C-slow is correctly
  // dialed in. R_s_est is set to R_pipette + R_access (14 MOhm, the true
  // total series resistance C_m charges through), not R_access alone --
  // using R_access alone leaves a larger, more sluggish residual, a good
  // illustration of how compensation quality depends on how well R_s_est
  // matches the real circuit.

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
    frac_slow = 1,
    R_s       = 4.0e6,
    alpha     = 0.0)
    "C-fast already compensated (frac_fast=1); C-slow off by default -- toggle frac_slow to 1.0"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Same parameters as Step04"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.WholeCell cell(
    R_access = 10.0e6,
    C_m      = 50.0e-12,
    R_m      = 200.0e6,
    V_m_init = -0.070)
    "Same parameters as Step04. V_m_init matches V_hold, so the membrane
     starts already sitting at the holding potential instead of fighting
     WholeCell's V_m_init=0 default, which assumes a 0 V (SealTest-style)
     baseline rather than V_hold."
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
      <h2>Step23 -- C-slow compensation, isolated (whole-cell, just after break-in)</h2>

      <h3>Learning objective</h3>
      <p>
        See C-slow (whole-cell membrane capacitance) compensation acting on
        the single visible capacitive transient in the break-in circuit
        from <code>Step04_WholeCellBreakIn</code> -- R_access in series with
        (C_m || R_m). <code>frac_fast = 1.0</code> is set to continue from
        <code>Step22_PipetteCapacitanceCompensation</code>'s workflow order,
        but (see that model's own documentation) has no visible effect on
        its own here -- there is only one real transient in this circuit to
        deal with, and C-slow is what removes it.
      </p>

      <h3>Circuit</h3>
      <pre>
  [CompensatedVClampAmp] --[PatchPipette]-- [WholeCell] --[BathElectrode]
        amp.p                 pip.p_cell     cell.p_pip
        C-fast comp (on)      R_pipette=4M   R_access=10M -+- C_m=50pF
        C-slow comp (off)                                   +- R_m=200M
      </pre>

      <h3>Time constant (simulated)</h3>
      <pre>
  tau ~ 650 us, close to the (R_pipette + R_access) * C_m = 14e6 * 50e-12
      = 700 us prediction (the small gap comes from second-order effects
      of C_pipette that the simple R*C estimate ignores).
      </pre>
      <p>
        R_s_est is set to R_pipette + R_access = 14 MOhm (the true total
        series resistance C_m charges through) rather than R_access alone,
        so C-slow's internal RC estimator's own time constant
        (R_s_est * C_slow) matches the real circuit closely.
      </p>

      <h3>Suggested exploration</h3>
      <ol>
        <li>Simulate at defaults (frac_slow = 0.0): plot amp.I_raw -- a single ~650 us exponential decaying to the resistive steady state.</li>
        <li>Set frac_slow = 1.0: re-simulate and overlay amp.I_measured -- most of the transient is gone, leaving mostly the flat resistive step (a small residual remains, from the ~50 us gap between R_s_est's implied tau and the true one).</li>
        <li>Set R_s_est back to R_access alone (10 MOhm, the value WholeCellCapacitanceComp's own docs use as a rule of thumb) and compare -- the residual after frac_slow=1.0 gets visibly larger and more sluggish, a direct illustration of why R_s_est needs to match the real circuit.</li>
        <li>Increase cell.C_m (e.g. to 150 pF, a larger cell) and watch the transient -- and the C_slow needed to compensate it -- scale with it.</li>
      </ol>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>amp.I_raw</code> -- raw current (exponential transient + DC)</li>
        <li><code>amp.I_measured</code> -- compensated current</li>
        <li><code>amp.I_comp_slow</code> -- the canceled C-slow artifact by itself</li>
        <li><code>cell.V_m</code> -- membrane voltage (how well the clamp tracks the command)</li>
      </ul>

      <h3>Next step</h3>
      <p>
        With both capacitive transients handled, the remaining artifact is
        the DC voltage error from series resistance -- see
        <code>Step24_AccessResistanceCompensation</code>.
      </p>
    </html>"),
    experiment(
      StopTime   = 0.200,
      Interval   = 1e-6,
      Tolerance  = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {120, 0, 50},
        lineThickness = 2.0,
        fillColor = {255, 220, 230},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step23",
        fontSize = 20,
        textColor = {100, 0, 40}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "C-slow only",
        fontSize = 13,
        textColor = {100, 0, 40}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Whole-cell",
        fontSize = 11,
        textColor = {150, 60, 80})
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step23: C-slow compensation, isolated (whole-cell, single transient)",
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
end Step23_WholeCellCapacitanceCompensation;