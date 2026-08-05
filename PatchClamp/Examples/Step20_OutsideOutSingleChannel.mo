within PatchClamp.Examples;
model Step20_OutsideOutSingleChannel
  "Outside-out patch clamp -- AMPA receptor reversal potential"

  // Outside-out: the pipette is pulled away so the patch's EXTRACELLULAR
  // face ends up exposed to the bath, letting the experimenter apply
  // neurotransmitters, toxins, or antagonists to that side -- the standard
  // configuration for ligand-gated channels.
  //
  // Channel: AMPA receptor (ionotropic glutamate receptor, GluA1-4).
  // gamma = 10 pS, a non-selective cation channel permeable to both Na+
  // and K+ (z=1, so E_rev ~ 0 mV from the approximate Na+/K+ symmetry).
  // VOLTAGE-INSENSITIVE: gated by ligand, not voltage (modeled with
  // k_v = 100 mV, an almost-flat Boltzmann curve). With no glutamate,
  // delta_V_half = 0 -> V_half_eff = +500 mV -> closed; with glutamate,
  // delta_V_half = -0.500 V -> V_half_eff = 0 mV -> open.
  //
  // Main point: find the AMPA channel's reversal potential (E_rev ~ 0 mV,
  // contrasting with Kv's E_K ~ -89 mV in Step18) -- below E_rev the
  // current is inward (depolarizing, excitatory), above it outward.
  //
  // Variables worth plotting: patch.I_patch [pA], patch.P_open [0-1],
  // patch.P_open_inf (Boltzmann steady state), patch.E_rev [mV],
  // amp.I_measured [pA].
  //
  // With glutamate present (default, delta_V_half = -0.500 V), sweep
  // V_step (-80, -60, ..., +60 mV), read I_patch at the end of each
  // step, and find where I_patch = 0 -- should land near E_rev ~ 0 mV,
  // unlike Step18_OnCellSingleChannel's K+-selective E_K ~ -89 mV.
  //
  // Comparing glutamate off vs. on: delta_V_half=0 gives P_open_inf ~ 0
  // (closed, I_patch ~ 0); delta_V_half=-0.500 opens the channel to a
  // measurable I_patch -- modeling a bath exchange with/without 1 mM
  // glutamate as two separate runs with different parameters.
  //
  // Voltage insensitivity: with delta_V_half=-0.500,
  // P_open_inf(-70mV)=1/(1+exp(0.70))~0.33, P_open_inf(0mV)=0.50,
  // P_open_inf(+60mV)=1/(1+exp(-0.60))~0.65 -- a swing of only 33% to 65%
  // over 130 mV, nearly flat, vs. Step18's Kv channel swinging 0% to 98%
  // over 80 mV.
  //
  // Unitary current and sign: with E_rev = 0 mV (c_pipette = c_bath =
  // 130 mM, a symmetric solution), i_unitary = 10pS*(-70-0) = -0.7 pA
  // (inward) at V_hold=-70 mV, or 10pS*(40-0) = +0.4 pA (outward) at
  // V_step=+40 mV -- inward current at -70 mV means an excitatory,
  // depolarizing channel.
  //
  // Compare with Step09_GHKReversalPotential, which computes E_rev for K+
  // algebraically via Nernst; here E_rev is instead measured dynamically
  // from the patch current. Both give E_rev ~ 0 mV for a symmetric
  // solution (c_in = c_out = 130 mM), but by different mechanisms: ionic
  // selectivity there, mixed permeability here.
  //
  // Why outside-out is unique: inside-out exposes the INTRAcellular face
  // to the bath, outside-out exposes the EXTRAcellular face -- and since
  // neurotransmitter receptors (AMPA, GABA_A, nACh) bind ligand on their
  // extracellular side, outside-out is the natural configuration for
  // applying and washing out neurotransmitters with high temporal
  // precision. Classic reference: Hamill et al. (1981), Pflugers Arch 391:85-100.

  PatchClamp.Amplifiers.VoltageClampAmplifier amp(
    V_hold           = -0.070,
    V_step           = +0.040,
    t_step_start     = 0.050,
    t_step_end       = 0.250,
    V_ljp_correction = 0.0)
    "Step from V_hold to V_step (default: -70 -> +40 mV, above E_rev = 0 mV);
     sweep V_step to build the I-V curve"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  // Outside-out patch, AMPA receptor: config=3 (outside-out) means the
  // extracellular face = c_bath (where glutamate is applied) and the
  // intracellular face = c_pipette (internal solution). z=1 (an
  // undifferentiated monovalent cation, Na+ or K+); c_pipette=130 mM
  // (intracellular K+), c_bath=130 mM (extracellular Na+) gives
  // E_rev=(RT/F)*ln(c_bath/c_pipette)=0 mV (symmetric concentrations);
  // gamma=10 pS (typical AMPA unitary conductance, 8-12 pS);
  // n_channels=20 (a typical patch holds 10-50 AMPA receptors);
  // V_half=+500 mV (essentially closed at physiological voltage with no
  // glutamate); k_v=100 mV (a very flat curve -- voltage insensitivity);
  // tau_max=2 ms (AMPA deactivates fast, ~1-2 ms at 37 degC);
  // delta_V_half=-500 mV (glutamate present -> V_half_eff=0 mV -> open;
  // set to 0.0 to simulate no glutamate).
  PatchClamp.Electrodes.PatchPipette pipette(
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Membranes.SingleChannelPatch patch(
    config          = 3,
    c_pipette       = 130.0,
    c_bath          = 130.0,
    c_cell_native   = 140.0,
    z               = 1,
    T               = PatchClamp.Constants.T_body,
    gamma           = 10.0e-12,
    n_channels      = 20,
    V_half          = +0.500,
    k_v             = 0.100,
    tau_max         = 2.0e-3,
    delta_V_half    = -0.500)
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
      <h2>Step20 -- Outside-out patch: AMPA receptor and E_rev</h2>

      <p>
        An outside-out patch experiment on AMPA receptors (ionotropic
        glutamate receptors). The goal is measuring the reversal potential
        of a non-selective cation channel (E_rev &#8776; 0 mV) and
        comparing it to the selective Kv channel in
        Step18_OnCellSingleChannel (E_rev &#8776; -89 mV).
      </p>

      <h3>Outside-out configuration</h3>
      <p>
        In outside-out, the pipette pulls the patch away such that its
        EXTRACELLULAR face ends up exposed to the bath, allowing
        neurotransmitters to be applied and washed out with sub-millisecond
        precision using fast perfusion systems.
      </p>
      <pre>
  Pipette (int. face)          Bath (ext. face)
  c_pipette = 130 mM K+        c_bath = 130 mM Na+   &lt;-- apply glutamate here
  (fixed, internal)            + variable glutamate
      </pre>

      <h3>Simplified E_rev model</h3>
      <p>
        AMPA is permeable to Na+ and K+ (and some Ca2+); its real E_rev
        would need a multi-ion GHK calculation. Here we use an equivalent
        single-ion approximation (z=1, c_pipette=c_bath=130 mM) giving
        E_rev = 0 mV, consistent with experimental AMPA data.
      </p>

      <h3>Voltage insensitivity</h3>
      <p>With k_v = 100 mV, the Boltzmann curve is nearly flat:</p>
      <table border='1'>
        <tr><th>V_m</th><th>P_open,inf (with glutamate)</th></tr>
        <tr><td>-70 mV</td><td>~0.33</td></tr>
        <tr><td>0 mV</td><td>0.50</td></tr>
        <tr><td>+60 mV</td><td>~0.65</td></tr>
      </table>
      <p>
        That 33%-to-65% swing over 130 mV contrasts sharply with Step18's
        Kv channel (0% to 98% over 80 mV) -- AMPA responds to its ligand,
        not to voltage.
      </p>

      <h3>Expected results (default: glutamate present, V_step = +40 mV)</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Expected value</th><th>Note</th></tr>
        <tr><td>E_rev</td><td>0 mV</td><td>symmetric Nernst: ln(130/130) = 0</td></tr>
        <tr><td>i_unitary at +40 mV</td><td>+0.4 pA</td><td>10 pS * (+40 - 0) mV</td></tr>
        <tr><td>P_open_inf at +40 mV</td><td>~0.60</td><td>Boltzmann with k_v=100 mV</td></tr>
        <tr><td>I_patch (20 ch)</td><td>~+4.8 pA</td><td>0.60 * 20 * 0.4 pA</td></tr>
        <tr><td>i_unitary at -70 mV</td><td>-0.7 pA</td><td>inward (excitatory) current</td></tr>
        <tr><td>Activation tau</td><td>~2 ms</td><td>tau_max / cosh(0) = tau_max</td></tr>
      </table>

      <h3>Expected I-V curve (glutamate present)</h3>
      <table border='1'>
        <tr><th>V_step</th><th>i_unitary</th><th>P_open_inf</th><th>I_patch (20 ch)</th></tr>
        <tr><td>-80 mV</td><td>-0.8 pA</td><td>0.31</td><td>-5.0 pA</td></tr>
        <tr><td>-40 mV</td><td>-0.4 pA</td><td>0.40</td><td>-3.2 pA</td></tr>
        <tr><td>0 mV</td><td>0 pA</td><td>0.50</td><td>0 pA (E_rev)</td></tr>
        <tr><td>+40 mV</td><td>+0.4 pA</td><td>0.60</td><td>+4.8 pA</td></tr>
        <tr><td>+60 mV</td><td>+0.6 pA</td><td>0.65</td><td>+7.8 pA</td></tr>
      </table>

      <h3>With no glutamate (delta_V_half = 0)</h3>
      <p>
        With V_half = +500 mV and k_v = 100 mV: P_open_inf(-70 mV)
        &#8776; 0.007 (&lt; 1%), so I_patch &#8776; 0 -- the channel stays
        closed with no ligand present.
      </p>

      <blockquote>
        Hamill OP et al. (1981). Patch clamp configurations; outside-out as
        a tool for neurotransmitter receptors. <em>Pfl&#252;gers Arch</em>
        <b>391</b>: 85-100.<br/>
        Hollmann M, Heinemann S (1994). Biophysical properties of AMPA/NMDA
        receptors. <em>Annu Rev Neurosci</em> <b>17</b>: 31-108.<br/>
        Traynelis SF et al. (2010). Glutamate receptor ion channels:
        structure, regulation, and function. <em>Pharmacol Rev</em>
        <b>62</b>: 405-496.
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
        textString = "Outside-Out Patch",
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
        fillColor       = {230, 255, 210},
        fillPattern     = FillPattern.Solid),
      Text(
        extent          = {{-90, 40}, {90, -40}},
        textString      = "Step20",
        fontSize        = 28,
        fontName        = "Arial",
        textColor       = {0, 150, 0}),
      Text(
        extent          = {{-90, -40}, {90, -80}},
        textString      = "Outside-Out AMPA",
        fontSize        = 12,
        fontName        = "Arial",
        textColor       = {0, 0, 0})})
  );
end Step20_OutsideOutSingleChannel;
