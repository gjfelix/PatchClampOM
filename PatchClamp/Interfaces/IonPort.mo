within PatchClamp.Interfaces;
connector IonPort "Ionic connector: concentrations and molar flow of a single ion species"

  parameter String  ionName = "?"
    "Ion name (e.g. Na+, K+, Cl-, Ca2+)";

  parameter Integer charge = 1
    "Signed valence of the ion (K+ -> 1, Ca2+ -> 2, Cl- -> -1)";

  Modelica.Units.SI.MolarConcentration c_in
    "Intracellular concentration of the ion [mol/m3] (1 mM = 1 mol/m3)";

  Modelica.Units.SI.MolarConcentration c_out
    "Extracellular concentration of the ion [mol/m3]";

  flow Modelica.Units.SI.MolarFlowRate q
    "Net molar flow of the ion [mol/s] -- positive is inward";

  annotation(
    Documentation(info = "<html>
      <h2>IonPort</h2>
      <p>
        Represents the exchange of one ion species between the intracellular
        and extracellular compartments; used to connect membranes, channels,
        and solution blocks.
      </p>
      <p>
        <code>q</code> is a flow variable (&sum;q = 0 at a node), positive
        into the cell. The associated ionic current is
        I = z*F*q (F = 96485 C/mol, <code>PatchClamp.Constants.F</code>),
        and the associated Nernst potential is
        E_ion = (R*T)/(z*F) * ln(c_out/c_in), computed by
        <code>PatchClamp.Media.Functions.nernstPotential</code>.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/IonPort.png")
    }),
    Diagram(graphics = {
      Ellipse(
        extent = {{-17, 17}, {17, -17}},
        lineColor = {0, 150, 100},
        fillColor = {200, 255, 230},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-11, 9}, {11, -9}},
        textString = "ion",
        textColor = {0, 100, 60},
        fontSize = 8)
    })
  );
end IonPort;
