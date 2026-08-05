within PatchClamp.Interfaces;
connector SolutionPort "Connector for a bulk ionic solution (temperature, pressure, osmolarity)"

  Modelica.Units.SI.Temperature T
    "Solution temperature [K] (physiological reference: 310.15 K = 37 degC)";

  Modelica.Units.SI.Pressure p
    "Hydrostatic pressure of the solution [Pa] (reference: 101325 Pa = 1 atm)";

  Real osmolarity(unit = "mol/m3")
    "Total osmolarity of the solution [mol/m3] (physiological: ~290 mOsm)";

  annotation(
    Documentation(info = "<html>
      <h2>SolutionPort</h2>
      <p>
        Carries the macroscopic thermodynamic state of a physiological
        solution (intracellular or extracellular) to any block that needs
        it -- temperature, hydrostatic pressure, and total osmolarity
        (Osm = &sum; phi_i * c_i, with phi_i the osmotic coefficient of ion i).
      </p>
      <p>
        In this version, individual ion species are carried separately via
        one <code>IonPort</code> per species rather than bundled here; a
        future version may fold a full ion-composition array into this
        connector.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/SolutionPort.png")
    }),
    Diagram(graphics = {
      Rectangle(
        extent = {{-17, 17}, {17, -17}},
        lineColor = {0, 100, 180},
        fillColor = {210, 240, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-11, 9}, {11, -9}},
        textString = "Sol",
        textColor = {0, 60, 130},
        fontSize = 8)
    })
  );
end SolutionPort;
