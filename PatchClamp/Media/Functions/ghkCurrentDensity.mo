within PatchClamp.Media.Functions;
function ghkCurrentDensity
  "Goldman-Hodgkin-Katz ionic current density"

  input Real P(unit = "m/s", min = 0)
    "Membrane permeability to the ion [m/s]";

  input Integer z
    "Signed ion valence (K+ -> 1, Ca2+ -> 2, Cl- -> -1)";

  input Real V(unit = "V")
    "Membrane voltage [V] (V_in - V_out, intracellular convention)";

  input Real T(unit = "K", min = 273.15)
    "Solution temperature [K]";

  input Real c_in(unit = "mol/m3", min = 0)
    "Intracellular ion concentration [mol/m3 = mM]";

  input Real c_out(unit = "mol/m3", min = 0)
    "Extracellular ion concentration [mol/m3 = mM]";

  output Real J(unit = "A/m2")
    "Ionic current density [A/m2] -- positive is inward";

protected
  Real x "Dimensionless argument z*V*F/(R*T)";
  Real F = PatchClamp.Constants.F "C/mol";
  Real R = PatchClamp.Constants.R "J/(mol*K)";

algorithm
  x := z * V * F / (R * T);

  if abs(x) < 1.0e-6 then
    // L'Hopital limit as V -> 0: only the concentration gradient (pure
    // Fickian diffusion) contributes
    J := P * z * F * (c_in - c_out);
  else
    J := P * z^2 * (V * F^2) / (R * T) *
         (c_in - c_out * Modelica.Math.exp(-x)) /
         (1.0 - Modelica.Math.exp(-x));
  end if;

  annotation(
    Inline = true,
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/ghkCurrentDensity.png")
    }),
    Documentation(info = "<html>
      <h2>ghkCurrentDensity</h2>
      <p>
        Computes the ionic current density through a permeable membrane,
        accounting for both the concentration gradient (diffusion) and the
        electric field (drift) at once -- the quantitative basis of the
        constant-field membrane permeability model.
      </p>
      <p>With x = z*V*F/(R*T):</p>
      <pre>  J = P * z^2 * (V*F^2)/(R*T) * (c_in - c_out*exp(-x)) / (1 - exp(-x))</pre>
      <p>
        For |x| &lt; 1e-6 (V effectively zero), this reduces via L'Hopital's
        rule to J = P*z*F*(c_in - c_out), the pure-diffusion limit, avoiding
        a 0/0 division.
      </p>
      <p>
        Typical resting permeabilities: P_K &#8776; 1e-8 m/s, P_Na &#8776; 1e-9 m/s.
        Multiply J by the membrane area A to get total current, I = J*A; a
        10 &#956;m spherical cell has A &#8776; 3.14e-10 m2.
      </p>
    </html>")
  );
end ghkCurrentDensity;
