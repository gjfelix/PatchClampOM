within PatchClamp.Membranes;
model GHKConductance
  "Goldman-Hodgkin-Katz membrane conductance -- single ion, configurable area"

  parameter Integer z = 1
    "Signed ion valence (K+ -> 1, Na+ -> 1, Ca2+ -> 2, Cl- -> -1)"
    annotation(Dialog(group = "Ion properties"));
  parameter Real P(unit = "m/s") = 1.0e-8
    "Membrane permeability to the ion [m/s]
     Reference (resting neuron): P_K~1e-8, P_Na~4e-10, P_Cl~4.5e-9"
    annotation(Dialog(group = "Ion properties"));

  parameter Real c_in(unit = "mol/m3", min = 0) = 140.0
    "Intracellular ion concentration [mM = mol/m3]
     Typical: K+ 140 mM, Na+ 10 mM, Ca2+ 0.0001 mM, Cl- 10 mM"
    annotation(Dialog(group = "Concentrations"));
  parameter Real c_out(unit = "mol/m3", min = 0) = 5.0
    "Extracellular ion concentration [mM = mol/m3]
     Typical: K+ 5 mM, Na+ 145 mM, Ca2+ 2 mM, Cl- 110 mM"
    annotation(Dialog(group = "Concentrations"));

  parameter Real A(unit = "m2") = 1000.0e-12
    "Membrane area [m2] (default: 1000 um2 = 1e-9 m2, a typical cell)"
    annotation(Dialog(group = "Geometry"));
  parameter Real T(unit = "K") = PatchClamp.Constants.T_body
    "Temperature [K] (default: 310.15 K = 37 degC)"
    annotation(Dialog(group = "Geometry"));

  // p = intracellular face (pipette, potential V_in); n = extracellular
  // face (bath, GND reference)
  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Intracellular pin (V_in, positive current is inward)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Extracellular pin (V_out, GND reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Voltage V_m "Membrane voltage = V_in - V_out [V]";
  Modelica.Units.SI.Current I_ghk
    "Total GHK current [A] (positive = outward, toward extracellular)";
  Real J_ghk(unit = "A/m2") "GHK current density [A/m2]";

  // Informational only: I_ghk = 0 exactly at V_m = E_rev
  Modelica.Units.SI.Voltage E_rev
    "Reversal potential = the ion's Nernst potential [V] (informational)";

equation
  V_m = membrane_p.v - membrane_n.v;

  J_ghk = PatchClamp.Media.Functions.ghkCurrentDensity(P, z, V_m, T, c_in, c_out);

  I_ghk = J_ghk * A;
  membrane_p.i = I_ghk;
  membrane_p.i + membrane_n.i = 0;

  E_rev = PatchClamp.Media.Functions.nernstPotential(T, z, c_out, c_in);

  annotation(
    Documentation(info = "<html>
      <h2>GHKConductance</h2>
      <p>
        The full Goldman-Hodgkin-Katz equation for a single ion species.
        Unlike Ohm's law (I = g*(V-E)), GHK captures intrinsic
        rectification: the current-voltage relationship is nonlinear
        because the concentration asymmetry itself breaks I-V symmetry.
      </p>
      <p>With x = z*V*F/(R*T):</p>
      <pre>
  J = P * z^2 * (V*F^2)/(R*T) * (c_in - c_out*exp(-x)) / (1 - exp(-x))
  I = J * A
      </pre>
      <p>which reduces via L'Hopital to a singularity-free limit at V = 0:</p>
      <pre>  J(V=0) = P * z * F * (c_in - c_out)</pre>
      <p>
        The current vanishes exactly at V_m = E_rev, the ion's Nernst
        potential -- hence \"reversal potential\": the voltage where the I-V
        curve crosses zero.
      </p>
      <pre>  E_rev = (R*T) / (z*F) * ln(c_out / c_in)</pre>
      <p>
        Unlike the straight line of Ohm's law, the GHK I-V curve is
        genuinely rectifying: for K+ with c_in = 140 mM and c_out = 5 mM,
        the current is larger (more negative) at a given negative V than
        it is at the same positive V.
      </p>
      <h3>Typical voltage-clamp use</h3>
      <ol>
        <li>Connect p to the V-clamp amplifier's output.</li>
        <li>Connect n to the bath electrode (GND).</li>
        <li>Apply a voltage ramp from -100 mV to +60 mV.</li>
        <li>Plot I_ghk vs. V_m to see the I-V curve and E_rev.</li>
        <li>Vary c_out and watch E_rev shift according to Nernst.</li>
      </ol>
      <h3>Reference permeabilities (neuron)</h3>
      <table border='1'>
        <tr><th>Ion</th><th>P [m/s]</th><th>relative to P_K</th></tr>
        <tr><td>K+</td>  <td>1.0e-8</td>  <td>1.00</td></tr>
        <tr><td>Na+</td> <td>4.0e-10</td> <td>0.04</td></tr>
        <tr><td>Cl-</td> <td>4.5e-9</td>  <td>0.45</td></tr>
        <tr><td>Ca2+</td><td>1.0e-11</td> <td>0.001</td></tr>
      </table>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/GHKConductance.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-110, 75}, {110, 65}},
        textString = "GHKConductance: I = P*z^2*(VF^2/RT)*(c_in - c_out*exp(-x))/(1-exp(-x)) * A",
        textColor = {80, 80, 80},
        fontSize = 9),
      Rectangle(extent = {{-80, 15}, {80, 5}},
        lineColor = {0, 80, 40}, fillColor = {180, 230, 200}, fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-80, -5}, {80, -15}},
        lineColor = {0, 80, 40}, fillColor = {180, 230, 200}, fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-10, 15}, {10, -15}},
        lineColor = {0, 120, 80}, lineThickness = 1.5,
        fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid),
      Line(points = {{0, 12}, {0, -12}}, color = {0, 150, 80}, thickness = 2.0),
      Polygon(points = {{0, -12}, {-4, -4}, {4, -4}},
        lineColor = {0, 150, 80}, fillColor = {0, 150, 80}, fillPattern = FillPattern.Solid),
      Text(extent = {{-110, 5}, {-85, -5}},   textString = "p (in)",  textColor = {0, 0, 200}, fontSize = 9),
      Text(extent = {{85,  5}, {110, -5}},     textString = "n (out)", textColor = {0, 0, 200}, fontSize = 9),
      Text(extent = {{-80, 30}, {-15, 22}},    textString = "c_in",    textColor = {0, 80, 160}, fontSize = 9),
      Text(extent = {{15,  -22}, {80, -30}},   textString = "c_out",   textColor = {0, 80, 160}, fontSize = 9)
    })
  );
end GHKConductance;
