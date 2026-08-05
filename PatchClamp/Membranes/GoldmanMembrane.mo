within PatchClamp.Membranes;
model GoldmanMembrane
  "Multi-ion membrane: Nernst, Goldman, and GHK currents for K+, Na+, Cl-, Ca2+"

  // Edit these in OMEdit (double-click the block) to explore how
  // permeability shapes the resting potential and the I-V curve.
  parameter Real P_K(unit = "m/s")  = 1.00e-8
    "K+ permeability [m/s] (resting neuron: ~1e-8 m/s)"
    annotation(Dialog(group = "Membrane permeabilities"));
  parameter Real P_Na(unit = "m/s") = 4.00e-10
    "Na+ permeability [m/s] (resting neuron: ~4e-10 m/s = 4% of P_K)"
    annotation(Dialog(group = "Membrane permeabilities"));
  parameter Real P_Cl(unit = "m/s") = 4.50e-9
    "Cl- permeability [m/s] (resting neuron: ~4.5e-9 m/s = 45% of P_K)"
    annotation(Dialog(group = "Membrane permeabilities"));
  parameter Real P_Ca(unit = "m/s") = 1.00e-11
    "Ca2+ permeability [m/s] (very low at rest: ~0.1% of P_K)"
    annotation(Dialog(group = "Membrane permeabilities"));

  // In Step10/Step11 these are assigned automatically from int_sol/ext_sol
  // via modifiers (membrane(c_K_in = int_sol.c_K, ...)); changing the
  // composition there is the right way to explore concentration effects
  // in the block diagram.
  parameter Real c_K_in(unit  = "mol/m3", min = 0) = 140.0
    "Intracellular K+ concentration [mM]"
    annotation(Dialog(group = "Intracellular concentrations"));
  parameter Real c_Na_in(unit = "mol/m3", min = 0) = 10.0
    "Intracellular Na+ concentration [mM]"
    annotation(Dialog(group = "Intracellular concentrations"));
  parameter Real c_Cl_in(unit = "mol/m3", min = 0) = 10.0
    "Intracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Intracellular concentrations"));
  parameter Real c_Ca_in(unit = "mol/m3", min = 0) = 1.0e-4
    "Intracellular Ca2+ concentration [mM] (free fraction, EGTA-buffered)"
    annotation(Dialog(group = "Intracellular concentrations"));

  parameter Real c_K_out(unit  = "mol/m3", min = 0) = 5.0
    "Extracellular K+ concentration [mM]"
    annotation(Dialog(group = "Extracellular concentrations"));
  parameter Real c_Na_out(unit = "mol/m3", min = 0) = 145.0
    "Extracellular Na+ concentration [mM]"
    annotation(Dialog(group = "Extracellular concentrations"));
  parameter Real c_Cl_out(unit = "mol/m3", min = 0) = 110.0
    "Extracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Extracellular concentrations"));
  parameter Real c_Ca_out(unit = "mol/m3", min = 0) = 2.0
    "Extracellular Ca2+ concentration [mM]"
    annotation(Dialog(group = "Extracellular concentrations"));

  parameter Real A(unit = "m2") = 1000.0e-12
    "Membrane area [m2] (default: 1000 um2 = 1e-9 m2, a typical cell)"
    annotation(Dialog(group = "Geometry and temperature"));
  parameter Real T(unit = "K") = PatchClamp.Constants.T_body
    "Temperature [K] (default: 310.15 K = 37 degC)"
    annotation(Dialog(group = "Geometry and temperature"));

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Intracellular pin (potential V_in, pipette side)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Extracellular pin (reference, bath side)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Voltage V_m
    "Membrane voltage V_in - V_out [V] (set by the external circuit)";

  Modelica.Units.SI.Voltage E_K  "K+ Nernst potential [V] (typical: -89 mV)";
  Modelica.Units.SI.Voltage E_Na "Na+ Nernst potential [V] (typical: +72 mV)";
  Modelica.Units.SI.Voltage E_Cl "Cl- Nernst potential [V] (typical: -64 mV)";
  Modelica.Units.SI.Voltage E_Ca "Ca2+ Nernst potential [V] (typical: +132 mV)";

  Modelica.Units.SI.Voltage V_Goldman
    "Goldman-Hodgkin-Katz resting potential [V].
     Computed algebraically -- does not depend on V_m. Matches V_m where
     I_total = 0 for K+, Na+, Cl- (assuming P_Ca ~ 0).";

  Modelica.Units.SI.Current I_K  "K+ GHK current [A] (positive = outward)";
  Modelica.Units.SI.Current I_Na "Na+ GHK current [A]";
  Modelica.Units.SI.Current I_Cl "Cl- GHK current [A]";
  Modelica.Units.SI.Current I_Ca "Ca2+ GHK current [A]";
  Modelica.Units.SI.Current I_total
    "Net GHK current [A] = I_K + I_Na + I_Cl + I_Ca; zero at the multi-ion
     reversal potential V_rev";

equation
  V_m = membrane_p.v - membrane_n.v;

  E_K  = PatchClamp.Media.Functions.nernstPotential(T,  1, c_K_out,  c_K_in);
  E_Na = PatchClamp.Media.Functions.nernstPotential(T,  1, c_Na_out, c_Na_in);
  E_Cl = PatchClamp.Media.Functions.nernstPotential(T, -1, c_Cl_out, c_Cl_in);
  E_Ca = PatchClamp.Media.Functions.nernstPotential(T,  2, c_Ca_out, c_Ca_in);

  // Goldman-Hodgkin-Katz equation (K+, Na+, Cl-). Cl-'s in/out indices are
  // swapped relative to the cations -- an exact consequence of its z = -1,
  // not a typo.
  V_Goldman = (PatchClamp.Constants.R * T / PatchClamp.Constants.F) *
              log((P_K * c_K_out  + P_Na * c_Na_out + P_Cl * c_Cl_in) /
                  (P_K * c_K_in   + P_Na * c_Na_in  + P_Cl * c_Cl_out));

  // Individual GHK currents (each internally L'Hopital-safe at V=0)
  I_K  = PatchClamp.Media.Functions.ghkCurrentDensity(P_K,   1, V_m, T, c_K_in,  c_K_out)  * A;
  I_Na = PatchClamp.Media.Functions.ghkCurrentDensity(P_Na,  1, V_m, T, c_Na_in, c_Na_out) * A;
  I_Cl = PatchClamp.Media.Functions.ghkCurrentDensity(P_Cl, -1, V_m, T, c_Cl_in, c_Cl_out) * A;
  I_Ca = PatchClamp.Media.Functions.ghkCurrentDensity(P_Ca,  2, V_m, T, c_Ca_in, c_Ca_out) * A;

  I_total = I_K + I_Na + I_Cl + I_Ca;
  membrane_p.i = I_total;
  membrane_p.i + membrane_n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>GoldmanMembrane</h2>
      <p>
        A complete four-ion (K+, Na+, Cl-, Ca2+) membrane model using the
        Goldman-Hodgkin-Katz equation. Unlike <code>GHKConductance</code>
        (a single ion), this block computes the net current across all four
        ions and the Goldman resting potential in one component.
      </p>
      <p>
        Double-clicking the block in OMEdit shows three parameter groups:
        <b>membrane permeabilities</b> (P_K, P_Na, P_Cl, P_Ca in m/s --
        setting P_Na = 0, say, simulates a blocked Na+ channel);
        <b>intra/extracellular concentrations</b> (typically driven from
        <code>int_sol</code>/<code>ext_sol</code> in Step10/Step11 --
        change the composition there rather than here); and
        <b>geometry and temperature</b> (A, T).
      </p>
      <table border='1' cellpadding='4'>
        <tr><th>Variable</th><th>Meaning</th><th>Typical</th></tr>
        <tr><td>E_K</td>  <td>K+ Nernst potential</td>  <td>-89 mV</td></tr>
        <tr><td>E_Na</td> <td>Na+ Nernst potential</td> <td>+72 mV</td></tr>
        <tr><td>E_Cl</td> <td>Cl- Nernst potential</td> <td>-64 mV</td></tr>
        <tr><td>E_Ca</td> <td>Ca2+ Nernst potential</td><td>+132 mV</td></tr>
        <tr><td>V_Goldman</td><td>Resting potential (Goldman)</td><td>-65 mV</td></tr>
        <tr><td>I_K, I_Na, I_Cl, I_Ca</td><td>Individual GHK currents</td><td>depends on V_m</td></tr>
        <tr><td>I_total</td><td>Net current (= 0 at V_rev)</td><td>depends on V_m</td></tr>
        <tr><td>V_m</td>  <td>Voltage set by the external circuit</td><td>e.g. a -100..+60 mV ramp</td></tr>
      </table>
      <p>
        To trace the I-V curve as in <code>Step11_GHK_IVCurve</code>,
        connect <code>RampVoltageSource.p</code> to <code>membrane_p</code>
        and <code>RampVoltageSource.n</code> to the extracellular node
        shared with <code>Ground.p</code>; simulate with stopTime = 0.5 s
        and plot <code>I_total</code> vs. <code>V_m</code>.
      </p>
      <pre>
  V_Goldman = (RT/F) * ln[ P_K*c_K_out  + P_Na*c_Na_out + P_Cl*c_Cl_in  ]
                          [ P_K*c_K_in   + P_Na*c_Na_in  + P_Cl*c_Cl_out ]
      </pre>
      <table border='1' cellpadding='4'>
        <tr><th>Ion</th><th>P (m/s)</th><th>ratio to P_K</th></tr>
        <tr><td>K+</td>  <td>1.00e-8</td> <td>1.00 (reference)</td></tr>
        <tr><td>Na+</td> <td>4.00e-10</td><td>0.04 (4%)</td></tr>
        <tr><td>Cl-</td> <td>4.50e-9</td> <td>0.45 (45%)</td></tr>
        <tr><td>Ca2+</td><td>1.00e-11</td><td>0.001 (0.1%)</td></tr>
      </table>
      <blockquote>
        Goldman D (1943). Potential, impedance, and rectification in
        membranes. <em>J Gen Physiol</em> <b>27</b>: 37-60.<br/>
        Hodgkin AL, Katz B (1949). The effect of sodium ions on the
        electrical activity of the giant axon of the squid.
        <em>J Physiol</em> <b>108</b>: 37-77.
      </blockquote>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/GoldmanMembrane.png")
    }),
    experiment(
      StopTime  = 0.5,
      Interval  = 0.001,
      Tolerance = 1e-8)
  );
end GoldmanMembrane;
