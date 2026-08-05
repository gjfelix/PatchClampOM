within PatchClamp.Examples;
model Step10_GoldmanRestingPotential
  "Two ionic compartments -- Nernst and Goldman potentials, and osmotic balance"

  // See how intra/extracellular composition sets the ionic equilibrium
  // potentials, the resting potential, and the osmotic balance a real
  // patch clamp experiment has to respect.
  //
  // Default composition (typical neuron): E_K ~ -89 mV, E_Na ~ +70 mV,
  // E_Cl ~ -65 mV, E_Ca ~ +122 mV, V_Goldman ~ -65 mV. Note osm_warning is
  // true by default -- these minimal solutions are not isosmotic
  // (osm_deficit_in ~ +135 mOsm) until a lab supplements them.
  //
  // Try: int_sol.c_K = 275 (an extreme osmotic top-up to ~295 mOsm)
  // destroys most of the K+ gradient (E_K moves from -89 to ~-2 mV) --
  // illustrating why osmotic adjustment must use a solute that isn't the
  // ion of interest (sucrose, HEPES, gluconate, not more KCl).
  //
  // ext_sol.c_K = 8 (mild hyperkalemia) raises E_K to ~-77 mV and
  // depolarizes V_Goldman to ~-60 mV (more excitable); ext_sol.c_K = 50
  // (severe hyperkalemia) gives E_K ~ -27 mV, V_Goldman ~ -38 mV --
  // chronic depolarization, as seen in severe hyperkalemic muscle.
  //
  // int_sol.c_Cl = 30 mM (as in immature neurons or KCC2 knockout) shifts
  // E_Cl from ~-65 mV to ~-45 mV, flipping GABA from inhibitory (clamping
  // V_m near rest) to depolarizing -- the textbook mechanism behind GABA's
  // excitatory action in neonatal neurons.
  //
  // int_sol.T = 293.15 (20 degC, room temperature) vs 310.15 (37 degC,
  // physiological) changes the RT/F factor from 26.7 to 25.3 mV, shifting
  // E_K by under 1 mV -- small but measurable, which is why real recordings
  // at room temperature get corrected in analysis.
  //
  // Compare with Step08 (Nernst for one ion, K_out swept algebraically)
  // and Step09 (E_rev measured graphically from a single channel's I-V
  // curve); this model shows the whole multi-ion system at once. See also
  // Step11_GHK_IVCurve, which reuses this same membrane block but drives
  // it with a RampVoltageSource to trace I_total vs. V_m -- here,
  // membrane_p is left unconnected, so I_total = 0 naturally and the
  // solver finds V_m = V_Goldman, modeling the open-circuit resting state.

  PatchClamp.Media.InternalSolution int_sol(
    c_K  = 140.0,
    c_Na = 10.0,
    c_Cl = 10.0,
    c_Ca = 1.0e-4,
    T    = PatchClamp.Constants.T_body,
    p    = 101325.0)
    annotation(Placement(transformation(origin = {-70, 0}, extent = {{-160, -40}, {-80, 40}})));

  PatchClamp.Media.ExternalSolution ext_sol(
    c_K  = 5.0,
    c_Na = 145.0,
    c_Cl = 110.0,
    c_Ca = 2.0,
    T    = PatchClamp.Constants.T_body,
    p    = 101325.0)
    annotation(Placement(transformation(extent = {{80, -40}, {160, 40}})));

  // To change permeabilities, double-click the membrane block in OMEdit's
  // diagram view ("Membrane permeabilities" group); to change
  // concentrations, double-click int_sol or ext_sol instead.
  PatchClamp.Membranes.GoldmanMembrane membrana(
    c_K_in   = int_sol.c_K,
    c_Na_in  = int_sol.c_Na,
    c_Cl_in  = int_sol.c_Cl,
    c_Ca_in  = int_sol.c_Ca,
    c_K_out  = ext_sol.c_K,
    c_Na_out = ext_sol.c_Na,
    c_Cl_out = ext_sol.c_Cl,
    c_Ca_out = ext_sol.c_Ca,
    T        = int_sol.T,
    P_K      = 1.00e-8,
    P_Na     = 4.00e-10,
    P_Cl     = 4.50e-9,
    P_Ca     = 1.00e-11,
    A        = 1000.0e-12)
    annotation(Placement(transformation(origin = {0, -2}, extent = {{-25, -25}, {25, 25}})));

  PatchClamp.Electrodes.Ground gnd
    "Extracellular reference, v = 0 V"
    annotation(Placement(transformation(extent = {{50, -70}, {90, -30}})));

  // Convenience aliases so these show up directly in OMEdit's Variables Browser
  Modelica.Units.SI.Voltage E_K       = membrana.E_K       "Alias of membrana.E_K (typical: -89 mV)";
  Modelica.Units.SI.Voltage E_Na      = membrana.E_Na      "Alias of membrana.E_Na (typical: +72 mV)";
  Modelica.Units.SI.Voltage E_Cl      = membrana.E_Cl      "Alias of membrana.E_Cl (typical: -64 mV)";
  Modelica.Units.SI.Voltage E_Ca      = membrana.E_Ca      "Alias of membrana.E_Ca (typical: +132 mV)";
  Modelica.Units.SI.Voltage V_Goldman = membrana.V_Goldman "Alias of membrana.V_Goldman (typical: -65 mV)";

  parameter Real osm_target(unit = "mol/m3") = 295.0
    "Target physiological osmolarity [mOsm = mol/m3]"
    annotation(Dialog(group = "Osmotic balance"));

  Real osm_in(unit  = "mol/m3") "Intracellular solution osmolarity [mOsm]";
  Real osm_out(unit = "mol/m3") "Extracellular solution osmolarity [mOsm]";
  Real delta_osm(unit = "mol/m3") "Osmotic difference: osm_out - osm_in [mOsm] (0 = isosmotic)";
  Real osm_deficit_in(unit  = "mol/m3") "Amount to add to the intracellular solution to reach osm_target [mOsm]";
  Real osm_deficit_out(unit = "mol/m3") "Amount to add to the extracellular solution to reach osm_target [mOsm]";
  Boolean osm_warning
    "True if |delta_osm| > 20 mOsm: solutions are not isosmotic (edema risk)";

  Real nernst_factor(unit = "V") "RT/F factor [V] (25.3 mV at 20 degC, 26.7 mV at 37 degC)";

equation
  // membrane_p is left unconnected, so flux = 0 and I_total = 0 at rest;
  // the solver finds V_m as the root of sum(GHK currents) = 0, which is
  // exactly V_Goldman -- this models the cell in open circuit.
  connect(gnd.p, membrana.membrane_n);

  osm_in  = int_sol.osmolarity;
  osm_out = ext_sol.osmolarity;
  delta_osm = osm_out - osm_in;

  osm_deficit_in  = osm_target - osm_in;
  osm_deficit_out = osm_target - osm_out;

  // A >20 mOsm intra/extracellular mismatch drives osmotic water flow and
  // cell swelling or shrinkage
  osm_warning = abs(delta_osm) > 20.0;

  nernst_factor = PatchClamp.Constants.R * int_sol.T / PatchClamp.Constants.F;

  annotation(
    Documentation(info = "<html>
      <h2>Step10 -- Two ionic compartments</h2>
      <p>
        A static model of the two compartments in a whole-cell patch clamp
        experiment: <b>int_sol</b> (the pipette's contents, i.e. the cell
        interior after membrane rupture) and <b>ext_sol</b> (the bath
        solution, i.e. the cell exterior). From these two compositions it
        computes all four Nernst potentials, the Goldman resting potential,
        and the osmotic balance.
      </p>

      <h3>Default-parameter results</h3>
      <table border='1'>
        <tr><th>Variable</th><th>Typical value</th><th>Meaning</th></tr>
        <tr><td>E_K</td>  <td>-89 mV</td> <td>K+ tends outward (chemical gradient beats the field)</td></tr>
        <tr><td>E_Na</td> <td>+70 mV</td> <td>Na+ tends inward (both gradients agree)</td></tr>
        <tr><td>E_Cl</td> <td>-65 mV</td> <td>Cl- near equilibrium at rest</td></tr>
        <tr><td>E_Ca</td> <td>+122 mV</td><td>a huge inward driving force for Ca2+</td></tr>
        <tr><td>V_Goldman</td><td>-65 mV</td><td>resting potential (P_K-dominated)</td></tr>
        <tr><td>osm_in</td>   <td>160 mOsm</td><td>hypo-osmotic (needs adjustment)</td></tr>
        <tr><td>osm_out</td>  <td>262 mOsm</td><td>also hypo-osmotic (a simplified ACSF)</td></tr>
        <tr><td>osm_warning</td><td>true</td><td>delta_osm = 102 mOsm: edema risk</td></tr>
      </table>

      <h3>Why the default solutions aren't isosmotic</h3>
      <p>
        The minimal composition here (just K+, Na+, Cl-, Ca2+) gives only
        ~160-262 mOsm, well below the physiological 295 mOsm. In a real lab
        this gets topped up with K-gluconate or K-methylsulfate (replacing
        some KCl without perturbing [Cl-], which would shift E_Cl), HEPES
        or EGTA (buffers that add osmolarity without being permeant ions),
        or sucrose (a pure osmotic adjustment with no ionic side effect).
      </p>

      <h3>Goldman equation -- why Cl- is inverted</h3>
      <pre>
  V_Goldman = (RT/F) * ln[ P_K*[K]_out + P_Na*[Na]_out + P_Cl*[Cl]_IN  ]
                          [ P_K*[K]_in  + P_Na*[Na]_in  + P_Cl*[Cl]_OUT ]
      </pre>
      <p>
        Cl-'s in/out indices are swapped because it carries negative
        charge (z=-1): deriving the Goldman equation from GHK for an anion
        flips c_out/c_in to c_in/c_out inside the log.
      </p>

      <h3>Reading V_Goldman</h3>
      <p>
        V_Goldman is the voltage where the combined net K+/Na+/Cl- current
        is zero -- not a simple average of the individual E_ion values, but
        one weighted by both permeability and concentration. That's why it
        sits closer to E_K than to E_Na even though both contribute.
      </p>

      <h3>Related examples</h3>
      <ul>
        <li><b>Step08</b> sweeps [K+]_out to trace K+'s Nernst curve.</li>
        <li><b>Step09</b> gets the I-V curve and reversal potential of a single channel.</li>
        <li><b>Step06, Step15, Step16</b> use exactly these E_ion values as their cell models' E_Na, E_K, E_Ca parameters.</li>
      </ul>

      <blockquote>
        Hodgkin AL, Katz B (1949). The effect of sodium ions on the
        electrical activity of the giant axon of the squid.
        <em>J Physiol</em> <b>108</b>: 37-77.
      </blockquote>
    </html>"),
    experiment(
      StopTime  = 1.0,
      Interval  = 1.0,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 160},
        lineThickness = 2.0,
        fillColor = {235, 248, 255},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-95, 55}, {-5, -55}},
        lineColor = {0, 80, 160},
        lineThickness = 1.5,
        fillColor = {180, 220, 255},
        fillPattern = FillPattern.Solid),
      Text(extent = {{-90, 48}, {-10, 35}}, textString = "Int", textColor = {0, 60, 140}, fontSize = 11),
      Text(extent = {{-90, 30}, {-10, 22}}, textString = "K+140", textColor = {0, 60, 140}, fontSize = 8),
      Text(extent = {{-90, 20}, {-10, 12}}, textString = "Na+10", textColor = {0, 60, 140}, fontSize = 8),
      Text(extent = {{-90, 10}, {-10, 2}},  textString = "Cl-10",  textColor = {0, 60, 140}, fontSize = 8),
      Text(extent = {{-90, 0},  {-10, -8}}, textString = "Ca2+0", textColor = {0, 60, 140}, fontSize = 8),
      Rectangle(
        extent = {{-5, 55}, {5, -55}},
        lineColor = {100, 60, 0},
        lineThickness = 1.0,
        fillColor = {255, 230, 150},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{5, 55}, {95, -55}},
        lineColor = {0, 120, 80},
        lineThickness = 1.5,
        fillColor = {190, 245, 215},
        fillPattern = FillPattern.Solid),
      Text(extent = {{10, 48}, {90, 35}}, textString = "Ext",   textColor = {0, 90, 60}, fontSize = 11),
      Text(extent = {{10, 30}, {90, 22}}, textString = "K+5",   textColor = {0, 90, 60}, fontSize = 8),
      Text(extent = {{10, 20}, {90, 12}}, textString = "Na+145",textColor = {0, 90, 60}, fontSize = 8),
      Text(extent = {{10, 10}, {90, 2}},  textString = "Cl-110", textColor = {0, 90, 60}, fontSize = 8),
      Text(extent = {{10, 0},  {90, -8}}, textString = "Ca2+2",  textColor = {0, 90, 60}, fontSize = 8),
      Text(
        extent = {{-90, -65}, {90, -95}},
        textString = "Step10 Two Compartments",
        textColor = {0, 80, 140},
        fontSize = 9)
    }),
    Diagram(graphics = {Text(textColor = {0, 60, 140}, extent = {{-160, 55}, {-80, 47}}, textString = "InternalSolution", fontSize = 10), Text(textColor = {100, 100, 100}, extent = {{-160, 44}, {-80, 37}}, textString = "(pipette / int_sol)", fontSize = 8), Rectangle(lineColor = {120, 80, 0}, fillColor = {255, 230, 150}, fillPattern = FillPattern.Solid, lineThickness = 2, extent = {{-30, 35}, {30, -35}}), Text(textColor = {100, 60, 0}, extent = {{-28, 32}, {28, 22}}, textString = "MEMBRANE", fontSize = 8), Text(textColor = {0, 0, 200}, extent = {{-28, 15}, {-4, 7}}, textString = "K+ ->", fontSize = 9), Text(textColor = {200, 0, 0}, extent = {{-28, 3}, {-4, -5}}, textString = "Na+ <-", fontSize = 9), Text(textColor = {0, 150, 0}, extent = {{-28, -9}, {-4, -17}}, textString = "Cl- <-", fontSize = 9), Text(textColor = {200, 80, 0}, extent = {{-28, -21}, {-4, -29}}, textString = "Ca2+ <-", fontSize = 9), Text(textColor = {0, 0, 200}, extent = {{32, 15}, {110, 7}}, textString = "E_K  ~ -89 mV", fontSize = 9), Text(textColor = {200, 0, 0}, extent = {{32, 3}, {110, -5}}, textString = "E_Na ~ +70 mV", fontSize = 9), Text(textColor = {0, 150, 0}, extent = {{32, -9}, {110, -17}}, textString = "E_Cl ~ -65 mV", fontSize = 9), Text(textColor = {200, 80, 0}, extent = {{32, -21}, {110, -29}}, textString = "E_Ca ~+122 mV", fontSize = 9), Text(textColor = {80, 80, 80}, extent = {{-160, -52}, {160, -62}}, textString = "V_Goldman ~ -65 mV   |   osm_in ~ 160 mOsm   osm_out ~ 262 mOsm   osm_warning = true", fontSize = 9), Text( textColor = {0, 90, 60}, extent = {{80, 55}, {160, 47}}, textString = "ExternalSolution", fontSize = 10), Text(textColor = {100, 100, 100}, extent = {{80, 44}, {160, 37}}, textString = "(bath / ext_sol)", fontSize = 8)}));
end Step10_GoldmanRestingPotential;
