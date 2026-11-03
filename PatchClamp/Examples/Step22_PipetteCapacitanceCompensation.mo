within PatchClamp.Examples;
model Step22_PipetteCapacitanceCompensation
  "C-fast compensation in isolation -- cell-attached configuration, before break-in (companion to Step02)"

  // Cell-attached configuration: the patch is still intact (R_seal ~ 1 GOhm,
  // R_patch ~ 50 GOhm), so essentially no current reaches "inside" the cell
  // -- there is no whole-cell membrane capacitance (C_m) in this circuit at
  // all, unlike Step23/Step24's break-in circuit. See the model's own
  // documentation below for an important subtlety: the visible transient
  // here is mostly the tiny patch capacitance (C_patch) charging through
  // R_pipette, not C_pipette's own current, which this idealized amplifier
  // model represents as a zero-width impulse.
  //
  // This mirrors real practice: on a real rig, C-fast is dialed in with the
  // pipette sealed onto the cell but BEFORE break-in, for exactly this
  // reason -- once break-in happens (Step23), a second, slower whole-cell
  // transient appears too, making C-fast harder to trim cleanly.
  //
  // Try: frac_fast = 0.0 (default) shows the raw transient in amp.I_raw;
  // frac_fast = 1.0 removes the (modest) part of it that C-fast actually
  // reaches in amp.I_measured. See the model's own documentation for why
  // this is a partial, not total, cancellation in this particular circuit.
  //
  // A technical note on alpha: this amplifier's command voltage is a
  // mathematically instantaneous step (zero rise time), so der(p.v-n.v) --
  // the signal C-fast compensation actually acts on -- is exactly zero
  // everywhere except at that single zero-width instant, UNLESS R_s
  // compensation (alpha > 0) is active: alpha's feedback runs the command
  // through the tau_comp low-pass filter, which is the only thing in this
  // model that gives the command edge any finite width for C-fast to
  // visibly cancel. alpha is set to a moderate value (0.3) here purely as
  // that numerical device -- it is NOT meant as an R_s-compensation demo
  // (see Step24_AccessResistanceCompensation for that); the cell-attached
  // configuration used here has no realistic use for R_s compensation at
  // all. On a real amplifier this isn't an issue, since the command output
  // always has *some* finite (if very fast) slew rate regardless of R_s
  // compensation status.

  PatchClamp.Amplifiers.Compensation.CompensatedVClampAmp amp(
    V_hold        = -0.070,
    V_step        = -0.050,
    t_step_start  = 0.050,
    t_step_end    = 0.150,
    V_ljp_correction = 0.0,
    C_fast    = 3.0e-12,
    frac_fast = 0.0,
    C_slow    = 10.0e-12,
    R_s_est   = 4.0e6,
    frac_slow = 0.0,
    R_s       = 4.0e6,
    alpha     = 0.3)
    "C-fast compensation off by default -- toggle frac_fast to 1.0.
     alpha=0.3 is a numerical device (see the comment above), not a
     realistic R_s-compensation setting for this configuration."
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = 0.0)
    "Same parameters as Step02"
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.CellAttachedPatch patch(
    R_seal  = 1.0e9,
    R_patch = 50.0e9,
    C_patch = 0.1e-12)
    "Gigaseal, patch intact -- same parameters as Step02"
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pip.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pip.p_cell, patch.p_pip)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(patch.p_ext, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));

  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pip.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step22 -- C-fast compensation, isolated (cell-attached)</h2>

      <h3>Learning objective</h3>
      <p>
        See C-fast (pipette capacitance) compensation acting in a
        configuration with no whole-cell capacitance to confuse it with.
        This is the cell-attached configuration <em>before</em> break-in
        (see <code>Step02_GigasealFormation</code>): the patch is intact, so
        no whole-cell membrane capacitance is in the circuit yet.
      </p>

      <p>
        Circuit: <code>CompensatedVClampAmp</code> (C-fast comp) -&gt;
        <code>PatchPipette</code> -&gt; <code>CellAttachedPatch</code>
        (R_seal=1G, R_patch=50G, C_patch=0.1pF) -&gt;
        <code>BathElectrode</code>.
      </p>

      <h3>A technical subtlety: what the visible transient actually is</h3>
      <p>
        R_seal (1 GOhm) and R_patch (50 GOhm) are both far larger than
        R_pipette (4 MOhm), so almost no current flows past the pipette tip
        at steady state -- but on the step itself, amp.I_raw shows a real,
        simulated (not idealized) transient several nA tall, decaying over
        roughly a microsecond. It is tempting to call this 'the C_pipette
        spike', but it is not: C_pipette's own charge-injection current,
        I = C_pipette * dV_cmd/dt, is a mathematically <em>instantaneous</em>
        impulse here, because this amplifier's command voltage is a true
        zero-rise-time step (see <code>Step01_PipetteSealTest</code>'s own
        documentation for the same point). An idealized impulse has no
        width to sample or plot, and is confirmed (numerically, in this
        model) to contribute nothing to <code>amp.I_comp_fast</code> at any
        simulated time once alpha = 0.
      </p>
      <p>
        What amp.I_raw actually shows is C_patch (0.1 pF) charging through
        R_pipette (4 MOhm) with tau ~ 0.4 us -- the same
        R_upstream * C_downstream mechanism as Step23's C-slow transient,
        just far smaller and faster because C_patch is 100x smaller than a
        typical whole-cell C_m. This is <em>not</em> what C-fast
        compensation targets, and frac_fast alone will not remove it.
      </p>
      <p>
        To give C-fast something real to cancel, this example runs with
        <code>alpha = 0.3</code>: R_s-compensation feedback pushes the
        command voltage through the tau_comp low-pass filter, giving it a
        small but genuinely finite (non-instantaneous) edge that
        amp.I_comp_fast can act on. This is a numerical device to make the
        mechanism observable, not a realistic R_s-compensation setting for
        cell-attached recording -- see
        <code>Step24_AccessResistanceCompensation</code> for R_s
        compensation on its own terms.
      </p>

      <h3>Expected currents (on the V_hold -&gt; V_step step, simulated)</h3>
      <p>
        This circuit has no other voltage source anywhere downstream (no
        membrane potential, no reversal potential -- just resistors to
        ground), so its steady current is proportional to the
        <em>absolute</em> command voltage, not the size of the step.
      </p>
      <pre>
  amp.I_raw       ~ 6.4 nA at t+20 ns after the step, decaying with
                    tau ~ R_pipette*C_patch ~ 0.4 us
  amp.I_comp_fast ~ 1.5 nA at the same instant (~24% of I_raw) -- the
                    alpha-loop-smoothed edge that C-fast can actually see
  amp.I_measured  ~ 4.8 nA at the same instant -- most of the transient
                    survives, because most of it is C_patch's RC charging,
                    not C_pipette's own current

  I_steady = V_step / (R_pipette + R_seal||R_patch)
           = -50e-3 / (4e6 + 0.98e9)
           ~ -51 pA   (near the amplifier's practical noise floor;
                       ~-71 pA during the V_hold baseline, for comparison)
      </pre>

      <h3>Suggested exploration</h3>
      <ol>
        <li>Simulate at defaults (frac_fast = 0.0): plot amp.I_raw, see the transient at t=50 ms and t=150 ms.</li>
        <li>Set frac_fast = 1.0: re-simulate and overlay amp.I_measured -- a modest but real reduction near the step edge (the alpha-loop component), while the C_patch RC relaxation underneath is untouched.</li>
        <li>Plot amp.I_comp_fast by itself and compare its (small) size to amp.I_raw's (much larger) peak -- a direct, quantitative illustration of which part of the transient C-fast actually reaches.</li>
        <li>Try C_fast values that deliberately mismatch pip.C_pipette (e.g. 2 pF vs 3 pF) to see what under/over-compensation looks like on amp.I_comp_fast.</li>
      </ol>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>amp.I_raw</code> -- raw current (C_patch RC transient + tiny seal leak)</li>
        <li><code>amp.I_measured</code> -- compensated current</li>
        <li><code>amp.I_comp_fast</code> -- the (small) canceled C-fast artifact by itself</li>
      </ul>

      <h3>Next step</h3>
      <p>
        Once C-fast is compensated here (as it would be on a real rig,
        before break-in), proceed to break-in and C-slow compensation in
        <code>Step23_WholeCellCapacitanceCompensation</code>.
      </p>
    </html>"),
    experiment(
      StopTime   = 0.200,
      Interval   = 1e-6,
      Tolerance  = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 180},
        lineThickness = 2.0,
        fillColor = {230, 245, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 40}, {90, 0}},
        textString = "Step22",
        fontSize = 20,
        textColor = {0, 80, 160}),
      Text(
        extent = {{-90, -5}, {90, -40}},
        textString = "C-fast only",
        fontSize = 13,
        textColor = {0, 80, 160}),
      Text(
        extent = {{-90, -45}, {90, -80}},
        textString = "Cell-attached",
        fontSize = 11,
        textColor = {60, 130, 190})
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step22: C-fast compensation, isolated (cell-attached, no whole-cell access yet)",
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
end Step22_PipetteCapacitanceCompensation;