within PatchClamp.Examples;
model Step09_GHKReversalPotential
  "Reversal potential -- I-V curve of a GHK channel under a voltage ramp (direct algebraic calculation)"

  // This model computes the GHK current directly as a function of voltage,
  // with no electrical components -- letting V_m sweep the ramp from
  // -100 to +60 mV gets the full I-V curve in one simulation. Plot I_ghk
  // (Y) vs V_m (X) in OMEdit to see it.
  //
  // Worth trying: the default K+ channel (curve crosses I=0 at
  // E_rev ~ -89 mV, and is visibly nonlinear -- the GHK intrinsic
  // rectification); c_out=50 (hyperkalemia, E_rev shifts to
  // (RT/F)*ln(50/140) ~ -27 mV); a Na+ channel (z=1, c_in=10, c_out=145,
  // P=4e-10, E_rev ~ +70 mV, inward current for V_m < +70 mV); a Ca2+
  // channel (z=2, c_in=0.0001, c_out=2, P=1e-11, E_rev ~ +122 mV, and an
  // even more asymmetric I-V curve since z=2); comparing I_ghk to the
  // matched-conductance ohmic line I_ohm = G*(V_m - E_rev) to see the
  // rectification directly; or changing T (293.15 vs 310.15 K) to see the
  // slope -- and E_rev slightly -- shift with temperature.

  parameter Modelica.Units.SI.Voltage V_start = -0.100
    "Starting ramp voltage [V] (-100 mV)"
    annotation(Dialog(group = "Ramp protocol"));
  parameter Modelica.Units.SI.Voltage V_end   =  0.060
    "Final ramp voltage [V] (+60 mV)"
    annotation(Dialog(group = "Ramp protocol"));
  parameter Modelica.Units.SI.Time t_ramp     =  0.500
    "Ramp duration [s]"
    annotation(Dialog(group = "Ramp protocol"));

  parameter Integer z = 1
    "Ion valence (K+/Na+ -> 1, Ca2+ -> 2, Cl- -> -1)"
    annotation(Dialog(group = "Ion channel"));
  parameter Real P(unit = "m/s") = 1.0e-8
    "Membrane permeability [m/s] (K+~1e-8, Na+~4e-10, Cl-~4.5e-9)"
    annotation(Dialog(group = "Ion channel"));
  parameter Real c_in(unit = "mol/m3") = 140.0
    "Intracellular ion concentration [mM] (K+ typical: 140 mM)"
    annotation(Dialog(group = "Ion channel"));
  parameter Real c_out(unit = "mol/m3") = 5.0
    "Extracellular ion concentration [mM] (K+ typical: 5 mM)"
    annotation(Dialog(group = "Ion channel"));
  parameter Real A(unit = "m2") = 1000.0e-12
    "Membrane area [m2] (typical: 1000 um2)"
    annotation(Dialog(group = "Ion channel"));
  parameter Real T(unit = "K") = PatchClamp.Constants.T_body
    "Temperature [K]"
    annotation(Dialog(group = "Ion channel"));

  Modelica.Units.SI.Voltage V_m "Membrane voltage (linear ramp) [V]";
  Modelica.Units.SI.Current I_ghk "Total GHK current [A] (positive = outward)";
  Real J_ghk(unit = "A/m2") "GHK current density [A/m2]";
  Modelica.Units.SI.Voltage E_rev "Reversal potential = the ion's Nernst potential [V] (constant)";
  Modelica.Units.SI.Current I_ohm "Matched ohmic current, for comparison with I_ghk [A]";
  Real G_ohm(unit = "S") "Matched ohmic conductance [S] = I_ghk(V=0) / (-E_rev)";

equation
  V_m = V_start + (V_end - V_start) * (time / t_ramp);

  J_ghk = PatchClamp.Media.Functions.ghkCurrentDensity(P, z, V_m, T, c_in, c_out);
  I_ghk = J_ghk * A;

  E_rev = PatchClamp.Media.Functions.nernstPotential(T, z, c_out, c_in);

  // G_ohm is estimated as the chord conductance at V_m = 0, using the
  // L'Hopital limit J_ghk(V=0) = P*z*F*(c_in - c_out)
  G_ohm = abs(PatchClamp.Media.Functions.ghkCurrentDensity(P, z, 0.0, T, c_in, c_out) * A)
          / (abs(E_rev) + 1.0e-9);
  I_ohm = G_ohm * (V_m - E_rev);

  annotation(
    Documentation(info = "<html>
      <h2>Step09 -- GHK channel I-V curve and reversal potential</h2>
      <p>
        Computes a GHK ion channel's current while the membrane voltage
        ramps linearly from -100 mV to +60 mV. Plotting <code>I_ghk</code>
        vs. <code>V_m</code> gives the full I-V curve; the voltage where
        I_ghk = 0 is the reversal potential, matching the Nernst potential
        computed directly in <code>E_rev</code>.
      </p>

      <h3>Viewing the I-V curve in OMEdit</h3>
      <p>
        None of the parameter sweeps above (c_out, z, c_in, P, T) require
        editing code -- select this block and open its Parameters dialog,
        with fields already grouped (\"Ramp protocol\", \"Ion channel\").
      </p>
      <ol>
        <li>Simulate with the default parameters.</li>
        <li>In the results window, select <code>I_ghk</code>.</li>
        <li>In the plot menu, change the X axis from 'time' to <code>V_m</code>.</li>
        <li>The resulting curve is the GHK I-V curve for K+.</li>
        <li>Its I=0 crossing should match <code>E_rev</code> ~ -89 mV.</li>
      </ol>

      <h3>Voltage ramp</h3>
      <pre>
  V_m (mV)
  +60 |                                /
      |                            /
    0 |                         /
      |                      /
  -89 |             X     /      E_K: I_ghk = 0 here
      |          /
 -100 |_______/
      |_________________________
      t=0                    t=500ms
      </pre>

      <h3>Key variables</h3>
      <ul>
        <li><code>V_m</code> -- membrane voltage (ramp, -100 to +60 mV)</li>
        <li><code>I_ghk</code> -- total GHK current [A]</li>
        <li><code>J_ghk</code> -- current density [A/m2]</li>
        <li><code>E_rev</code> -- reversal potential = E_Nernst [V] (constant)</li>
        <li><code>I_ohm</code> -- matched ohmic current, for comparison</li>
        <li><code>G_ohm</code> -- matched ohmic conductance [S]</li>
      </ul>

      <h3>GHK's intrinsic rectification</h3>
      <p>
        The GHK current is not linear around E_rev. For K+
        (c_in=140 mM &gt;&gt; c_out=5 mM), the inward current (V &lt; E_K)
        is larger in magnitude than the outward current at the same
        |delta-V| -- intrinsic rectification set purely by the
        concentration gradient, not by voltage-gating. Overlay
        <code>I_ghk</code> and <code>I_ohm</code> to see the difference
        quantitatively.
      </p>

      <h3>Reference E_rev by ion</h3>
      <table border='1'>
        <tr><th>Ion (parameters)</th><th>E_rev (approx.)</th><th>Note</th></tr>
        <tr><td>K+  c_in=140, c_out=5</td>   <td>-89 mV</td> <td>neuronal rest</td></tr>
        <tr><td>K+  c_in=140, c_out=50</td>  <td>-27 mV</td> <td>hyperkalemia</td></tr>
        <tr><td>Na+ c_in=10,  c_out=145</td> <td>+70 mV</td> <td>Na+ driving force (AP)</td></tr>
        <tr><td>Ca2+ z=2 c_in=0.0001, c_out=2</td><td>+122 mV</td><td>Ca2+ driving force</td></tr>
        <tr><td>Cl- z=-1 c_in=10, c_out=110</td>  <td>-65 mV</td><td>inhibitory reversal potential</td></tr>
      </table>

      <h3>Related examples</h3>
      <ul>
        <li><b>Step08</b> computes E_rev algebraically (Nernst); this one measures it graphically from the I-V curve.</li>
        <li><b>Step10</b> visualizes the two intra/extracellular compartments.</li>
        <li><b>GHKConductance</b> is the equivalent electrical block for use in whole-cell circuits.</li>
      </ul>
    </html>"),
    experiment(
      StopTime  = 0.500,
      Interval  = 5e-4,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 130, 80},
        lineThickness = 2.0,
        fillColor = {230, 255, 240},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {0, 80, 30},
        fillColor = {0, 20, 10},
        fillPattern = FillPattern.Solid),
      Line(points = {{-85, 18}, {85, 18}},   color = {0, 60, 20}),
      Line(points = {{-20, 65}, {-20, -30}},  color = {0, 60, 20}),
      Line(
        points = {{-85, -22}, {-60, -18}, {-20, 0}, {10, 20}, {40, 38}, {85, 55}},
        color = {0, 220, 120},
        thickness = 2.5),
      Line(
        points = {{-85, -16}, {-20, 0}, {85, 48}},
        color = {255, 160, 40},
        thickness = 1.5),
      Ellipse(
        extent = {{-24, 4}, {-16, -4}},
        lineColor = {255, 220, 0},
        fillColor = {255, 220, 0},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step09 Reversal I-V",
        textColor = {0, 100, 0},
        fontSize = 10)
    })
  );
end Step09_GHKReversalPotential;
