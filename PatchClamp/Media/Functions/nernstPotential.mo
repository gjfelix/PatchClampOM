within PatchClamp.Media.Functions;
function nernstPotential
  "Nernst equilibrium potential for a single ion"

  input Real T(unit = "K", min = 273.15)
    "Solution temperature [K] (physiological: 310.15 K = 37 degC)";

  input Integer z
    "Signed ion valence (K+ -> 1, Ca2+ -> 2, Cl- -> -1)";

  input Real c_out(unit = "mol/m3", min = 0)
    "Extracellular ion concentration [mol/m3 = mM]";

  input Real c_in(unit = "mol/m3", min = 0)
    "Intracellular ion concentration [mol/m3 = mM]";

  output Real E(unit = "V")
    "Nernst equilibrium potential [V]";

algorithm
  assert(c_out > 0,
    "nernstPotential: c_out must be > 0 mol/m3. Got: " + String(c_out));
  assert(c_in > 0,
    "nernstPotential: c_in must be > 0 mol/m3. Got: " + String(c_in));
  assert(z <> 0,
    "nernstPotential: valence z cannot be zero.");

  E := (PatchClamp.Constants.R * T) /
       (z * PatchClamp.Constants.F) *
       Modelica.Math.log(c_out / c_in);

  annotation(
    Inline = true,
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/nernstPotential.png")
    }),
    Documentation(info = "<html>
      <h2>nernstPotential</h2>
      <p>
        Computes the potential at which a given ion is in electrochemical
        equilibrium -- no net flux across the membrane, since the electrical
        and diffusive driving forces exactly cancel.
      </p>
      <p>$$E_{ion} = \\frac{R \\cdot T}{z \\cdot F} \\ln\\frac{c_{out}}{c_{in}}$$</p>
      <p>
        R = 8.314 J/(mol*K), F = 96485 C/mol; c_out and c_in must share the
        same units (e.g. both mM or both mol/m3) since only their ratio
        matters. Typical physiological values at 37 degC:
      </p>
      <table border='1' cellpadding='4'>
        <tr><th>Ion</th><th>c_out (mM)</th><th>c_in (mM)</th><th>E (mV)</th></tr>
        <tr><td>K+</td><td>5</td><td>140</td><td>&#8776; -89</td></tr>
        <tr><td>Na+</td><td>145</td><td>10</td><td>&#8776; +72</td></tr>
        <tr><td>Cl-</td><td>110</td><td>10</td><td>&#8776; -64</td></tr>
        <tr><td>Ca2+</td><td>2</td><td>0.0001</td><td>&#8776; +132</td></tr>
      </table>
    </html>")
  );
end nernstPotential;
