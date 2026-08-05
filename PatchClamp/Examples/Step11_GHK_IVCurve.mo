within PatchClamp.Examples;
model Step11_GHK_IVCurve
  "Multi-ion I-V curve via GHK -- voltage-clamp ramp protocol"

  // This is a voltage-clamp experiment: the amplifier (vClamp) imposes the
  // membrane voltage via a linear ramp and measures the current needed to
  // hold it there. Unlike Step10 (where I_total = 0 and V_m settles at
  // V_Goldman at rest), here V_m is CONTROLLED by the external circuit:
  //   V_m(t) = V_start + (V_end - V_start) * t / t_ramp
  // and the membrane produces whatever GHK current that voltage demands.
  //
  // To trace the I-V curve in OMEdit: simulate with stopTime = 0.5 s, then
  // Plot -> Parametric Plot (XY Parametric) with X = membrana.V_m,
  // Y = membrana.I_total. The I_total = 0 crossing is the reversal potential.
  //
  // Single-ion reversal: double-click the membrane block ("Membrane
  // permeabilities" group) and set P_Na=P_Cl=P_Ca=0, leaving only P_K.
  // Expect V_rev ~ E_K ~ -89 mV -- with a single ion, GHK reduces to
  // Nernst (cross-check against membrana.E_K, or Step10).
  //
  // Multi-ion (Goldman) reversal: restore the defaults
  // (P_K=1e-8, P_Na=4e-10, P_Cl=4.5e-9, P_Ca=1e-11). Expect
  // V_rev ~ V_Goldman ~ -65 mV, same as Step10 -- the net current is
  // exactly zero where V_m equals the Goldman-Hodgkin-Katz potential.
  //
  // Nonlinearity: with default permeabilities, the I-V curve is visibly
  // not a straight line (Goldman-Katz rectification) -- inward current
  // (V_m below V_rev) is larger in magnitude than outward current at the
  // same |deltaV| above V_rev, and the curve passes smoothly through the
  // origin (thanks to the L'Hopital-safe GHK function at V=0). This
  // rectification comes from the exponential term in the GHK equation
  // itself, not from any voltage-gated channel.
  //
  // Also worth trying: ext_sol.c_K = 50 mM (hyperkalemia) shifts the
  // single-ion V_rev from -89 to ~-27 mV, and the multi-ion V_rev upward
  // (depolarizing) too; a slower ramp (t_ramp = 1.0, stopTime = 1.0); or
  // isolating Ca2+ alone (P_K=P_Na=P_Cl=0, P_Ca=1e-11), where
  // V_rev ~ E_Ca ~ +132 mV sits almost outside the -100..+60 mV ramp range.

  PatchClamp.Media.InternalSolution int_sol(
    c_K  = 140.0,
    c_Na = 10.0,
    c_Cl = 10.0,
    c_Ca = 1.0e-4,
    T    = PatchClamp.Constants.T_body,
    p    = 101325.0)
    annotation(Placement(transformation(extent = {{-160, -40}, {-80, 40}})));

  PatchClamp.Media.ExternalSolution ext_sol(
    c_K  = 5.0,
    c_Na = 145.0,
    c_Cl = 110.0,
    c_Ca = 2.0,
    T    = PatchClamp.Constants.T_body,
    p    = 101325.0)
    annotation(Placement(transformation(extent = {{80, -40}, {160, 40}})));

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
    annotation(Placement(transformation(extent = {{-25, -25}, {25, 25}})));

  // Sweeps V_m from V_start to V_end over t_ramp seconds. p (positive,
  // right) connects to the intracellular side (membrane_p); n (negative,
  // left) connects to the extracellular node (shared with gnd).
  PatchClamp.Amplifiers.RampVoltageSource vClamp(
    V_start = -0.100,
    V_end   =  0.060,
    t_ramp  = 0.500)
    annotation(Placement(transformation(origin = {24, 86}, extent = {{-90, -20}, {-45, 20}})));

  // Fixes the extracellular potential to 0 V, standing in for the bath
  // electrode tied to the amplifier's ground in a real rig
  PatchClamp.Electrodes.Ground gnd
    annotation(Placement(transformation(extent = {{50, -70}, {90, -30}})));

equation
  // vClamp forces p.v - n.v = V_ramp(t) with p.i + n.i = 0 (Kirchhoff); gnd
  // fixes membrane_n.v = 0 V, so V_m = membrane_p.v - 0 = V_ramp(t).
  connect(vClamp.p, membrana.membrane_p);
  connect(vClamp.n, membrana.membrane_n);
  connect(gnd.p,    membrana.membrane_n);

  annotation(
    Documentation(info = "<html>
      <h2>Step11 -- Multi-ion I-V curve (GHK voltage clamp)</h2>

      <p>
        A voltage-clamp experiment with a linear ramp protocol: the
        amplifier (RampVoltageSource) imposes V_m(t), and the membrane
        (GoldmanMembrane) responds with the net GHK current I_total(t).
      </p>

      <h3>Key difference from Step10</h3>
      <table border='1' cellpadding='4'>
        <tr><th>Step10_GoldmanRestingPotential</th><th>Step11_GHK_IVCurve</th></tr>
        <tr>
          <td>Open-circuit cell (no amplifier).<br/>
              I_total = 0 at rest.<br/>
              V_m is determined endogenously, = V_Goldman.<br/>
              Answers: <em>what voltage does the cell rest at?</em></td>
          <td>Cell under voltage clamp.<br/>
              V_m imposed by an external ramp.<br/>
              I_total measured as a function of V_m.<br/>
              Answers: <em>how much current flows at each voltage?</em></td>
        </tr>
      </table>

      <h3>Tracing the I-V curve in OMEdit</h3>
      <ol>
        <li>Simulate with stopTime = 0.5 s, Interval = 0.001 s.</li>
        <li>Open <b>Plot &rarr; Parametric Plot</b> (XY Parametric).</li>
        <li>X axis: <code>membrana.V_m</code></li>
        <li>Y axis: <code>membrana.I_total</code></li>
        <li>This is the multi-ion GHK membrane's I-V curve.</li>
        <li>The I = 0 crossing is the reversal potential (V_rev).</li>
      </ol>

      <h3>Key variables</h3>
      <table border='1' cellpadding='4'>
        <tr><th>Variable</th><th>Meaning</th></tr>
        <tr><td>membrana.V_m</td><td>ramp-imposed voltage (X axis)</td></tr>
        <tr><td>membrana.I_total</td><td>net GHK current (Y axis)</td></tr>
        <tr><td>membrana.I_K</td><td>K+ GHK current alone</td></tr>
        <tr><td>membrana.I_Na</td><td>Na+ GHK current alone</td></tr>
        <tr><td>membrana.I_Cl</td><td>Cl- GHK current alone</td></tr>
        <tr><td>membrana.I_Ca</td><td>Ca2+ GHK current alone</td></tr>
        <tr><td>membrana.V_Goldman</td><td>theoretical (Goldman) reversal potential</td></tr>
        <tr><td>membrana.E_K, E_Na, E_Cl, E_Ca</td><td>individual Nernst potentials</td></tr>
        <tr><td>vClamp.V_out</td><td>instantaneous ramp voltage</td></tr>
      </table>

      <h3>Sanity checks</h3>
      <ul>
        <li>With P_Na=P_Cl=P_Ca=0, V_rev should equal E_K ~ -89 mV.</li>
        <li>With default permeabilities, V_rev ~ V_Goldman ~ -65 mV.</li>
        <li>The I-V curve should show visible Goldman-Katz rectification (not a straight line).</li>
      </ul>

      <blockquote>
        Goldman D (1943). Potential, impedance, and rectification in
        membranes. <em>J Gen Physiol</em> <b>27</b>: 37-60.
      </blockquote>
    </html>"),
    experiment(
      StopTime  = 0.5,
      Interval  = 0.001,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 100, 160},
        lineThickness = 2.0,
        fillColor = {235, 248, 255},
        fillPattern = FillPattern.Solid),
      Line(points = {{-70, -60}, {70, -60}}, color = {120, 120, 120}, thickness = 1.0),
      Line(points = {{-70, -60}, {-70, 70}},  color = {120, 120, 120}, thickness = 1.0),
      Line(
        points = {{-60, 65}, {-40, 30}, {-10, -10}, {10, -35}, {30, -50}, {50, -55}},
        color  = {0, 0, 200},
        thickness = 2.0,
        smooth = Smooth.Bezier),
      Line(points = {{-10, -60}, {-10, -10}}, color = {200, 0, 0}, thickness = 1.0,
        pattern = LinePattern.Dash),
      Text(extent = {{60, -55}, {85, -68}}, textString = "V_m", textColor = {80, 80, 80}, fontSize = 9),
      Text(extent = {{-100, 75}, {-72, 62}}, textString = "I",   textColor = {80, 80, 80}, fontSize = 9),
      Text(extent = {{-20, -45}, {15, -57}}, textString = "V_rev", textColor = {200, 0, 0}, fontSize = 8),
      Text(
        extent = {{-88, -68}, {88, -95}},
        textString = "Step11 I-V Curve",
        textColor  = {0, 80, 140},
        fontSize   = 9)
    })
  );
end Step11_GHK_IVCurve;
