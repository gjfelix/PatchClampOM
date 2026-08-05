within PatchClamp.Interfaces;
connector ElectricalPin "Acausal electrical connector (potential + current)"

  Modelica.Units.SI.Voltage v
    "Electrical potential at the terminal [V]";

  flow Modelica.Units.SI.Current i
    "Current flowing into the terminal [A] -- flow variable (sum = 0 at a node)";

  annotation(
    Documentation(info = "<html>
      <h2>ElectricalPin</h2>
      <p>
        Base electrical connector with two conjugate variables: <b>v</b>
        (potential), equated automatically across connected pins per
        Kirchhoff's voltage law, and <b>i</b> (flow), the current entering
        the terminal, for which Modelica enforces &sum;i = 0 at every node
        (Kirchhoff's current law).
      </p>
      <p>
        Sign convention: positive current flows into the component (the
        standard Modelica/MSL receiver convention). Patch clamp currents are
        typically on the order of picoamps; use <code>displayUnit=\"pA\"</code>
        on a parameter or result variable to plot in those units.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/ElectricalPin.png")
    })
  );
end ElectricalPin;
