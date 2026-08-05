within PatchClamp;
package Constants "Physical and physiological constants used throughout the package"

  constant Real R = 8.314
    "J/(mol*K) -- universal gas constant";

  constant Real F = 96485
    "C/mol -- Faraday constant (charge of one mole of electrons)";

  constant Real T_body = 310.15
    "K (37 degC) -- reference body temperature";

  annotation(
    Documentation(info = "<html>
      <h2>Constants</h2>
      <p>
        Centralizes the numeric constants used across the package, so no
        magic numbers appear in the models -- everything references
        <code>PatchClamp.Constants.R</code>, etc.
      </p>
      <ul>
        <li><b>R</b> -- appears in the RT/zF term of the Nernst and GHK equations.</li>
        <li><b>F</b> -- converts a molar charge flux into a current: I = z*F*J.</li>
        <li><b>T_body</b> -- 37 degC, the default temperature in the physiological models.</li>
      </ul>
      <pre>
  E_K = (PatchClamp.Constants.R * T) /
        (1 * PatchClamp.Constants.F) *
        log(c_K_out / c_K_in);
      </pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Constants.png")
    })
  );

end Constants;
