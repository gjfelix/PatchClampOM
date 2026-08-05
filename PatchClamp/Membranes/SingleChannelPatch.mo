within PatchClamp.Membranes;
model SingleChannelPatch
  "Membrane patch -- configuration: on-cell, inside-out, or outside-out"

  // The patch configuration determines which solution contacts each face
  // of the channel:
  //   config=1 OnCell:     pipette seals onto the intact cell membrane;
  //     extracellular face = pipette (controlled), intracellular face =
  //     native cytoplasm (not controllable).
  //   config=2 InsideOut:  the pipette is pulled away after sealing,
  //     excising the patch; intracellular face is now exposed to the bath
  //     (controlled -- e.g. to study Ca2+/nucleotide modulation),
  //     extracellular face stays fixed in the pipette.
  //   config=3 OutsideOut: the alternative excision; extracellular face is
  //     exposed to the bath (controlled -- e.g. to apply ligands/toxins),
  //     intracellular face stays fixed in the pipette.

  parameter Integer config(min = 1, max = 3) = 1
    "Patch configuration:  1 = OnCell   2 = InsideOut   3 = OutsideOut"
    annotation(Dialog(group = "Patch configuration"));

  parameter Real c_pipette(unit = "mol/m3", min = 1e-9) = 5.0
    "Ion concentration in PIPETTE solution [mM]
     On-cell / Inside-out: extracellular face contact
     Outside-out:          intracellular face contact"
    annotation(Dialog(group = "Solution concentrations"));

  parameter Real c_bath(unit = "mol/m3", min = 1e-9) = 5.0
    "Ion concentration in BATH solution [mM]
     Inside-out:  intracellular face contact (vary this to modulate BK, etc.)
     Outside-out: extracellular face contact  (vary this to apply ligands)
     On-cell:     not in contact with the channel (bath washes the intact cell)"
    annotation(Dialog(group = "Solution concentrations"));

  parameter Real c_cell_native(unit = "mol/m3", min = 1e-9) = 140.0
    "Native INTRACELLULAR concentration in the intact cell [mM].
     Used only in on-cell mode (config = 1); represents the cytoplasmic
     concentration the experimenter cannot control."
    annotation(Dialog(group = "Solution concentrations"));

  parameter Integer z = 1
    "Ion valence with sign (K+ -> 1, Na+ -> 1, Ca2+ -> 2, Cl- -> -1)"
    annotation(Dialog(group = "Ion properties"));

  parameter Modelica.Units.SI.Temperature T = PatchClamp.Constants.T_body
    "Temperature [K] (default: 310.15 K = 37 degC)"
    annotation(Dialog(group = "Ion properties"));

  parameter Real gamma(unit = "S") = 100.0e-12
    "Unitary (single-channel) conductance [S]
     Typical: BK K+ ~ 200-300 pS,  Kv ~ 8-15 pS,  Nav ~ 10-25 pS,  AMPA ~ 8-10 pS"
    annotation(Dialog(group = "Channel properties"));

  parameter Integer n_channels(min = 1) = 1
    "Number of identical channels in the patch"
    annotation(Dialog(group = "Channel properties"));

  parameter Modelica.Units.SI.Voltage V_half = -0.020
    "Intrinsic half-activation voltage [V] (before ligand shift)"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Voltage k_v = 0.010
    "Activation slope factor [V]
     Positive: opens with depolarization (typical)
     Negative: opens with hyperpolarization (HCN, some K+ channels)"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Time tau_max = 5.0e-3
    "Maximum gating time constant [s] -- at V = V_half + delta_V_half"
    annotation(Dialog(group = "Gating kinetics"));

  // Many channels shift their activation curve when a ligand binds, e.g.
  // Ca2+ shifting BK's V_half negative, or NMDA needing glycine+glutamate.
  // Modeled here as a simple additive shift: V_half_eff = V_half + delta_V_half.
  parameter Modelica.Units.SI.Voltage delta_V_half = 0.0
    "Ligand-induced shift of V_half [V]
     Negative: ligand facilitates opening (e.g. Ca2+ on BK channel)
     Positive: ligand inhibits / requires depolarization for opening
     Zero:     no ligand effect (voltage-gated only, default)"
    annotation(Dialog(group = "Ligand modulation"));

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Positive pin -- pipette electrode (command voltage)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Negative pin -- bath electrode (ground reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Real P_open(start = 0.0, fixed = true)
    "Channel open probability [0-1] (mean-field / deterministic Markov)";

  Modelica.Units.SI.Voltage V_m
    "Membrane voltage across the patch [V] (pipette - bath)";

  Modelica.Units.SI.Voltage E_rev
    "Ion reversal (Nernst) potential [V] -- from the effective concentrations";

  Modelica.Units.SI.Current i_unitary
    "Single-channel current [A] = gamma * (V_m - E_rev)";

  Modelica.Units.SI.Current I_patch
    "Total patch current [A] = P_open * n_channels * i_unitary";

  Real P_open_inf "Steady-state open probability -- Boltzmann function of V_m";

  Modelica.Units.SI.Time tau_channel "Instantaneous gating time constant [s]";

  Modelica.Units.SI.Voltage V_half_eff
    "Effective half-activation voltage including the ligand shift [V]";

  Real c_in_eff(unit  = "mol/m3")
    "Effective intracellular-face concentration [mM] -- set by config";
  Real c_out_eff(unit = "mol/m3")
    "Effective extracellular-face concentration [mM] -- set by config";

equation
  V_m = membrane_p.v - membrane_n.v;

  // OnCell (1): intracell = cell native | extracell = pipette
  // InsideOut (2): intracell = bath | extracell = pipette
  // OutsideOut (3): intracell = pipette | extracell = bath
  if config == 1 then
    c_in_eff  = c_cell_native;
    c_out_eff = c_pipette;
  elseif config == 2 then
    c_in_eff  = c_bath;
    c_out_eff = c_pipette;
  else
    c_in_eff  = c_pipette;
    c_out_eff = c_bath;
  end if;

  E_rev = PatchClamp.Media.Functions.nernstPotential(T, z, c_out_eff, c_in_eff);

  V_half_eff = V_half + delta_V_half;

  P_open_inf  = 1.0 / (1.0 + exp(-(V_m - V_half_eff) / k_v));
  tau_channel = tau_max / cosh((V_m - V_half_eff) / (2.0 * k_v));
  der(P_open) = (P_open_inf - P_open) / tau_channel;

  i_unitary = gamma * (V_m - E_rev);
  I_patch    = P_open * n_channels * i_unitary;

  membrane_p.i = I_patch;
  membrane_p.i + membrane_n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>SingleChannelPatch</h2>
      <p>
        Extends <code>MarkovChannel</code> with explicit patch geometry and
        solution assignment. The key parameter is <em>config</em>, which
        determines which solution contacts which face of the channel:
      </p>

      <table border='1'>
        <tr>
          <th>config</th><th>Name</th>
          <th>Extracellular face</th><th>Intracellular face</th>
          <th>What the student controls</th>
        </tr>
        <tr>
          <td>1</td><td>On-cell</td>
          <td>c_pipette</td><td>c_cell_native</td>
          <td>Pipette voltage; cannot access cytoplasm</td>
        </tr>
        <tr>
          <td>2</td><td>Inside-out</td>
          <td>c_pipette (fixed)</td><td>c_bath</td>
          <td>Bath composition: Ca&#178;&#8314;, nucleotides, lipids</td>
        </tr>
        <tr>
          <td>3</td><td>Outside-out</td>
          <td>c_bath</td><td>c_pipette (fixed)</td>
          <td>Bath composition: neurotransmitters, toxins, drugs</td>
        </tr>
      </table>

      <h3>Ligand modulation -- delta_V_half</h3>
      <p>
        Many channels change their voltage-activation curve when a ligand
        binds, modeled as a shift of the half-activation voltage:
      </p>
      <pre>  V_half_eff = V_half + delta_V_half</pre>
      <ul>
        <li><b>BK channel + Ca&#178;&#8314; (inside-out, config=2):</b> increasing c_bath
            Ca&#178;&#8314; shifts V_half negative by roughly -10 to -30 mV per decade;
            e.g. delta_V_half = -0.020 for [Ca&#178;&#8314;]=1 &#956;M vs 0.1 &#956;M.</li>
        <li><b>AMPA receptor (outside-out, config=3):</b> glutamate in the
            bath activates the channel; delta_V_half = -0.100 (a large shift
            moving activation into the physiological range) when present.</li>
        <li><b>Kv7/KCNQ inhibition by PIP2 depletion:</b>
            delta_V_half = +0.020 to +0.040 (activation shifts positive,
            harder to open at rest).</li>
      </ul>

      <h3>Sign convention</h3>
      <p>
        <em>I_patch &gt; 0</em> is outward current (cations leaving the
        cell, or anions entering it), consistent with the rest of the
        package and with the Hodgkin-Huxley formalism. In a real inside-out
        recording the intracellular face now faces the bath electrode
        (ground), but the amplifier still measures pipette current vs.
        ground as in whole-cell, so polarity is unaffected.
      </p>

      <h3>Relationship to MarkovChannel</h3>
      <p>
        Same gating equations as <code>MarkovChannel</code>, plus (1) the
        configuration selector that assigns c_in_eff/c_out_eff, (2) the
        ligand-shift parameter delta_V_half, and (3) documentation of which
        solution is experimentally accessible in each configuration. Use
        <code>MarkovChannel</code> directly for the bare channel biophysics;
        use this model to compare configurations or apply ligands.
      </p>

      <blockquote>
        Hamill OP et al. (1981). Improved patch-clamp techniques for
        high-resolution current recording from cells and cell-free membrane
        patches (the original description of the on-cell, inside-out, and
        outside-out configurations). <em>Pfl&#252;gers Arch</em> <b>391</b>: 85-100.<br/>
        Marty A, Neher E (1985). Potassium channels in cultured bovine
        adrenal chromaffin cells. <em>J Physiol</em> <b>367</b>: 117-141.
      </blockquote>
    </html>"),
    experiment(
      StopTime  = 0.200,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/SingleChannelPatch.png")
    }),
    Diagram(graphics = {
      Polygon(
        points = {{-145, 25}, {-145, -25}, {-35, 0}},
        lineColor = {130, 0, 160},
        lineThickness = 1.5,
        fillColor = {215, 180, 255},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-145, 38}, {-35, 30}},  textString = "Pipette",        textColor = {100, 0, 130}, fontSize = 10),
      Text(extent = {{-145, 28}, {-35, 20}},  textString = "c_pipette",      textColor = {100, 0, 130}, fontSize = 9),
      Rectangle(
        extent = {{-30, 40}, {30, 28}},
        lineColor = {120, 90, 20},
        fillColor = {255, 220, 120},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-30, -28}, {30, -40}},
        lineColor = {120, 90, 20},
        fillColor = {255, 220, 120},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-10, 48}, {10, -48}},
        lineColor = {130, 0, 160},
        lineThickness = 2.0,
        fillColor = {230, 200, 255},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-10, 58}, {90, 48}}, textString = "Channel pore", textColor = {100, 0, 130}, fontSize = 9),
      Text(extent = {{35, 40}, {160, 30}},   textString = "config=1 OnCell:     c_out=pipette  c_in=cell",  textColor = {130, 0, 160}, fontSize = 8),
      Text(extent = {{35, 26}, {160, 16}},   textString = "config=2 Inside-out: c_out=pipette  c_in=bath",  textColor = {130, 0, 160}, fontSize = 8),
      Text(extent = {{35, 12}, {160, 2}},    textString = "config=3 Outside-out:c_out=bath     c_in=pipette",textColor = {130, 0, 160}, fontSize = 8),
      Text(extent = {{35, -12}, {160, -22}}, textString = "E_rev = Nernst(c_out_eff, c_in_eff)", textColor = {80, 0, 100}, fontSize = 8),
      Text(extent = {{35, -26}, {160, -36}}, textString = "V_half_eff = V_half + delta_V_half",   textColor = {80, 0, 100}, fontSize = 8),
      Text(extent = {{35, -52}, {160, -62}},  textString = "Bath",    textColor = {0, 100, 60}, fontSize = 10),
      Text(extent = {{35, -62}, {160, -72}},  textString = "c_bath",  textColor = {0, 100, 60}, fontSize = 9)
    })
  );
end SingleChannelPatch;
