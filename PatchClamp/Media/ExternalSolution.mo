within PatchClamp.Media;
model ExternalSolution
  "Ringer/ACSF-type extracellular solution (perfusion bath)"

  parameter Real c_K(unit = "mol/m3", min = 0) = 5.0
    "Extracellular K+ concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Na(unit = "mol/m3", min = 0) = 145.0
    "Extracellular Na+ concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Cl(unit = "mol/m3", min = 0) = 110.0
    "Extracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Ca(unit = "mol/m3", min = 0) = 2.0
    "Extracellular Ca2+ concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Modelica.Units.SI.Temperature T = PatchClamp.Constants.T_body
    "Solution temperature [K]"
    annotation(Dialog(group = "Thermodynamics"));

  parameter Modelica.Units.SI.Pressure p = 101325.0
    "Hydrostatic pressure [Pa]"
    annotation(Dialog(group = "Thermodynamics"));

  PatchClamp.Interfaces.SolutionPort solutionPort
    "Output port carrying the solution's properties"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Real osmolarity(unit = "mol/m3")
    "Total osmolarity of the solution [mOsm/L = mol/m3]";

equation
  // Ideal-solution approximation: osmolarity = sum of ionic concentrations
  // (osmotic coefficient = 1)
  osmolarity = c_K + c_Na + c_Cl + c_Ca;

  solutionPort.T          = T;
  solutionPort.p          = p;
  solutionPort.osmolarity = osmolarity;

  annotation(
    Documentation(info = "<html>
      <h2>ExternalSolution</h2>
      <p>
        Models the perfusion bath surrounding the cell. Its ionic
        composition is what the extracellular face of the channels \"sees\",
        and sets the transmembrane concentration gradients.
      </p>
      <table border='1' cellpadding='4'>
        <tr><th>Ion</th><th>Concentration (mM)</th><th>Note</th></tr>
        <tr><td>K+</td><td>5</td><td>kept low; gives E_K &#8776; -89 mV</td></tr>
        <tr><td>Na+</td><td>145</td><td>main extracellular cation</td></tr>
        <tr><td>Cl-</td><td>110</td><td>main extracellular anion</td></tr>
        <tr><td>Ca2+</td><td>2</td><td>free extracellular fraction</td></tr>
      </table>
      <p>
        The default composition gives an osmolarity of about 262 mOsm/L; in
        practice it is supplemented with glucose (10 mM), HEPES (10 mM), and
        NaHCO3 (26 mM) to reach ~295 mOsm/L, though these uncharged solutes
        don't affect the Nernst potentials.
      </p>
      <p>
        To study how the K+ equilibrium potential depends on extracellular
        concentration, sweep <code>c_K</code> from 1 to 150 mM and check that
        E_K follows the Nernst slope of 26.7 mV/decade at 37 degC.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/ExternalSolution.png")
    })
  );
end ExternalSolution;
