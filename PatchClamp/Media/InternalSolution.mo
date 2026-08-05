within PatchClamp.Media;
model InternalSolution
  "Typical patch clamp intracellular (pipette-filling) solution"

  parameter Real c_K(unit = "mol/m3", min = 0) = 140.0
    "Intracellular K+ concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Na(unit = "mol/m3", min = 0) = 10.0
    "Intracellular Na+ concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Cl(unit = "mol/m3", min = 0) = 10.0
    "Intracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Ionic composition"));

  parameter Real c_Ca(unit = "mol/m3", min = 0) = 1.0e-4
    "Free intracellular Ca2+ concentration [mM] (EGTA-buffered)"
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
      <h2>InternalSolution</h2>
      <p>
        Models the solution filling the patch pipette, which dialyzes the
        cell interior once the membrane ruptures (whole-cell configuration).
        Its ionic composition sets the Nernst equilibrium potential of each
        ion.
      </p>
      <table border='1' cellpadding='4'>
        <tr><th>Ion</th><th>Concentration (mM)</th><th>Note</th></tr>
        <tr><td>K+</td><td>140</td><td>main intracellular cation</td></tr>
        <tr><td>Na+</td><td>10</td><td>kept low at rest by the Na/K-ATPase</td></tr>
        <tr><td>Cl-</td><td>10</td><td>varies by cell type</td></tr>
        <tr><td>Ca2+</td><td>0.0001</td><td>free fraction, EGTA-buffered</td></tr>
      </table>
      <p>
        The default composition gives an osmolarity of about 160 mOsm/L; in
        practice this is topped up with sucrose or extra KCl to ~295 mOsm/L
        to stay isosmotic. Adjust c_K, c_Na, c_Cl to match your protocol.
        <code>solutionPort</code> exposes T, p, and osmolarity to any
        connected block that needs them (e.g. a channel model computing a
        Nernst potential).
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/InternalSolution.png")
    })
  );
end InternalSolution;
