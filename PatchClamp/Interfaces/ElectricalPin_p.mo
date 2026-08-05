within PatchClamp.Interfaces;
connector ElectricalPin_p "Positive (+) electrical terminal"
  extends PatchClamp.Interfaces.ElectricalPin;

  annotation(
    Documentation(info = "<html>
      <h2>ElectricalPin_p</h2>
      <p>
        Extends <code>ElectricalPin</code> to represent the
        <strong>positive (+)</strong> terminal of a component, following the
        Modelica Standard Library's red-for-positive convention. In a patch
        clamp amplifier, the positive terminal connects to the pipette
        (signal input); by the receiver convention, positive conventional
        current flows into this terminal.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/ElectricalPin_P.png"),
      Text(
        extent = {{-75, -75}, {75, 75}},
        textString = "+",
        textColor = {255, 0, 0},
        textStyle = {TextStyle.Bold})
    }),
    Diagram(graphics = {
      Rectangle(
        extent = {{-17, 17}, {17, -17}},
        lineColor = {255, 0, 0},
        fillColor = {255, 0, 0},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-11, 11}, {11, -11}},
        textString = "+",
        textColor = {255, 255, 255},
        fontSize = 14)
    })
  );
end ElectricalPin_p;
