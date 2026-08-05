within PatchClamp.Examples;
model Step19_InsideOutSingleChannel
  "Inside-out patch clamp -- BK channel modulated by intracellular Ca2+"

  // Inside-out: the pipette is pulled away from the cell, taking a small
  // patch with it, and the patch's INTRACELLULAR face ends up exposed to
  // the bath -- letting the experimenter control [Ca2+], [ATP], pH, or
  // other ligands directly.
  //
  // Channel: BK (big-conductance Ca2+-activated K+ channel, KCa1.1/Slo1).
  // gamma = 200 pS (the largest known unitary conductance), K+-selective
  // (z=1), and gated by BOTH voltage and Ca2+ (a coincidence detector):
  // V_half shifts about -18 mV per 10-fold increase in Ca2+ (Cui et al.
  // 1997). With no Ca2+, V_half ~ +80 mV (nearly silent at rest); at
  // 10 uM Ca2+, V_half ~ +20 mV; at 100 uM, V_half ~ 0 mV (active at rest).
  //
  // Main point: intracellular Ca2+ shifts the activation curve toward more
  // negative potentials -- sweep delta_V_half and repeat the voltage
  // sweep to build a family of I-V curves at different [Ca2+].
  //
  // Variables worth plotting: patch.I_patch [pA], patch.P_open [0-1],
  // patch.P_open_inf (Boltzmann steady state), patch.E_rev (Nernst
  // reversal, mV), amp.I_measured [pA].
  //
  // With no Ca2+ (default, delta_V_half = 0) and a -70 -> +80 mV step,
  // there's little activation even at +80 mV, since V_half = +80 mV
  // means P_open_inf(+80 mV) = 0.50 exactly, by definition.
  //
  // At 10 uM Ca2+ (delta_V_half = -0.060): V_half_eff = 80-60 = +20 mV,
  // so activation shifts to lower voltages -- P_open_inf(+20mV) = 0.50,
  // P_open_inf(+80mV) = 0.98.
  //
  // At 100 uM Ca2+ (delta_V_half = -0.080): V_half_eff = 80-80 = 0 mV,
  // so the channel activates near resting potential --
  // P_open_inf(0mV) = 0.50, P_open_inf(+80mV) ~ 1.00.
  //
  // To trace the static activation curve, sweep amp.V_step (-70, -40,
  // -20, 0, +20, +40, +60, +80 mV), read patch.P_open_inf at the end of
  // each step, and plot vs. V_step for each Ca2+ level -- it should trace
  // a Boltzmann sigmoid.
  //
  // Unitary current and E_rev: with c_bath=140 mM K+ (intracellular face,
  // fixed here) and c_pipette=5 mM K+ (extracellular face),
  // E_rev = E_K = (RT/F)*ln(5/140) ~ -89 mV, giving i_unitary =
  // 200pS*(0-(-89)) = +17.8 pA at V_step=0 mV, or 200pS*(80-(-89)) =
  // +33.8 pA at V_step=+80 mV.
  //
  // Why inside-out is unique: on-cell can't change intracellular Ca2+,
  // while inside-out exposes the cytoplasmic face directly -- Hamill et
  // al. (1981) showed all four patch configurations arise from mechanical
  // excision of the patch at different stages.

  PatchClamp.Amplifiers.VoltageClampAmplifier amp(
    V_hold           = -0.070,
    V_step           = +0.080,
    t_step_start     = 0.050,
    t_step_end       = 0.250,
    V_ljp_correction = 0.0)
    "Long step, to see BK activation fully develop"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  // Inside-out patch, BK channel: config=2 (inside-out) means the
  // intracellular face = c_bath (student-controlled) and the
  // extracellular face = c_pipette (fixed). z=1 (K+), c_pipette=5 mM
  // (standard extracellular HEPES solution), c_bath=140 mM (symmetric
  // intracellular K+), gamma=200 pS (the largest known channel
  // conductance), V_half=+80 mV (with no Ca2+, essentially silent at
  // rest), k_v=15 mV (a shallower activation curve than Kv), tau_max=3 ms
  // (BK activates faster than Kv), delta_V_half=0 (no Ca2+ by default --
  // change this to model different [Ca2+]).
  PatchClamp.Electrodes.PatchPipette pipette(
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.SingleChannelPatch patch(
    config          = 2,
    c_pipette       = 5.0,
    c_bath          = 140.0,
    c_cell_native   = 140.0,
    z               = 1,
    T               = PatchClamp.Constants.T_body,
    gamma           = 200.0e-12,
    n_channels      = 5,
    V_half          = +0.080,
    k_v             = 0.015,
    tau_max         = 3.0e-3,
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
      <h2>Step19 -- Inside-out patch clamp: BK channel and intracellular Ca2+</h2>

      <p>
        An inside-out patch experiment on a BK channel (big-conductance
        Ca2+-activated K+, KCa1.1), showing how intracellular Ca2+ shifts
        the channel's voltage-activation curve, making BK a coincidence
        detector for voltage and Ca2+ together.
      </p>

      <h3>Inside-out configuration</h3>
      <p>
        The pipette pulls the patch away from the cell, exposing its
        intracellular face to the bath -- so Ca2+, ATP, pH, or other
        ligands can be changed freely during the experiment.
      </p>
      <pre>
  Pipette (ext. face)      Bath (int. face)
  c_pipette = 5 mM K+      c_bath = 140 mM K+   &lt;-- controlled by the experimenter
  (fixed)                  + variable [Ca2+]
      </pre>

      <h3>BK as a coincidence detector</h3>
      <p>
        BK has two sensors: a voltage sensor (the S4 domain) and four Ca2+
        binding sites in the C-terminal RCK domain. With no Ca2+,
        V&#189; &#8776; +80 mV (silent at rest); each decade of [Ca2+]
        shifts V&#189; by roughly -18 mV.
      </p>
      <table border='1'>
        <tr><th>[Ca2+]</th><th>delta_V_half</th><th>V_half_eff</th><th>Activation at -70 mV</th></tr>
        <tr><td>~0 nM (basal)</td><td>0 mV</td><td>+80 mV</td><td>~0%</td></tr>
        <tr><td>~1 &#956;M</td><td>-40 mV</td><td>+40 mV</td><td>&lt;1%</td></tr>
        <tr><td>~10 &#956;M</td><td>-60 mV</td><td>+20 mV</td><td>~1%</td></tr>
        <tr><td>~100 &#956;M</td><td>-80 mV</td><td>0 mV</td><td>~7%</td></tr>
      </table>
      <p>(Approximate values, after Cui et al. 1997, <em>J Gen Physiol</em>.)</p>

      <h3>Expected results (default: no Ca2+, V_step = +80 mV)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Expected value</th><th>Note</th></tr>
        <tr><td>E_rev (E_K)</td><td>-89 mV</td><td>Nernst K+: 140/5 mM</td></tr>
        <tr><td>i_unitary at +80 mV</td><td>~+33.8 pA</td><td>200 pS * (80-(-89)) mV</td></tr>
        <tr><td>P_open_inf at +80 mV</td><td>0.50</td><td>V_step = V_half, by definition</td></tr>
        <tr><td>I_patch (5 channels)</td><td>~+85 pA</td><td>0.50 * 5 * 33.8 pA</td></tr>
        <tr><td>Activation tau</td><td>~3 ms</td><td>tau_max / cosh(0) = tau_max</td></tr>
      </table>

      <h3>With delta_V_half = -0.080 V (high Ca2+, ~100 &#956;M)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Expected value</th></tr>
        <tr><td>V_half_eff</td><td>0 mV</td></tr>
        <tr><td>P_open_inf at +80 mV</td><td>~1.00</td></tr>
        <tr><td>I_patch (5 channels)</td><td>~+169 pA</td></tr>
        <tr><td>P_open_inf at -70 mV</td><td>~7%</td></tr>
      </table>

      <blockquote>
        Hamill OP et al. (1981). Improved patch-clamp techniques (original
        description of the patch clamp configurations). <em>Pfl&#252;gers Arch</em>
        <b>391</b>: 85-100.<br/>
        Cui J, Cox DH, Aldrich RW (1997). Voltage and Ca2+ as BK channel
        sensors. <em>J Gen Physiol</em> <b>109</b>: 647-673.<br/>
        Marty A (1981). Original discovery of the BK channel in chromaffin
        cells. <em>Nature</em> <b>291</b>: 497-500.
      </blockquote>
    </html>"),
    experiment(
      StopTime         = 0.300,
      Interval         = 1.0e-5,
      Tolerance        = 1.0e-8),
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
        textString = "Inside-Out Patch",
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
        extent          = {{-100, 100}, {100, -100}},
        lineColor       = {0, 0, 0},
        fillColor       = {200, 230, 255},
        fillPattern     = FillPattern.Solid),
      Text(
        extent          = {{-90, 40}, {90, -40}},
        textString      = "Step19",
        fontSize        = 28,
        fontName        = "Arial",
        textColor       = {0, 0, 200}),
      Text(
        extent          = {{-90, -40}, {90, -80}},
        textString      = "Inside-Out BK",
        fontSize        = 12,
        fontName        = "Arial",
        textColor       = {0, 0, 0})})
  );
end Step19_InsideOutSingleChannel;
