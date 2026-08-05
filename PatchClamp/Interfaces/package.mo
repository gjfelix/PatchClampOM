within PatchClamp;
package Interfaces "Reusable connectors for electrical and ionic signals"
  annotation(
    Documentation(info = "<html>
      <h2>Interfaces</h2>
      <p>
        Defines the connectors used to wire together the blocks of a patch
        clamp experiment:
      </p>
      <ul>
        <li><b>ElectricalPin</b> -- electrical potential (V) and current (A); base for the +/- terminals below.</li>
        <li><b>ElectricalPin_p</b> / <b>ElectricalPin_n</b> -- the positive and negative circuit terminals.</li>
        <li><b>IonPort</b> -- ionic concentration and molar flow for one species (Na+, K+, Cl-, Ca2+, ...).</li>
        <li><b>SolutionPort</b> -- bulk solution state (temperature, pressure, osmolarity).</li>
      </ul>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Interfaces.png")
    })
  );
end Interfaces;
