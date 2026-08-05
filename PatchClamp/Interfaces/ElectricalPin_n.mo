within PatchClamp.Interfaces;
connector ElectricalPin_n "Negative (-) electrical terminal"
  extends PatchClamp.Interfaces.ElectricalPin;

  annotation(
    Documentation(info = "<html>
      <h2>ElectricalPin_n</h2>
      <p>
        Extends <code>ElectricalPin</code> to represent the
        <strong>negative (-)</strong> terminal of a component, following the
        Modelica Standard Library's blue-for-negative convention. In a patch
        clamp amplifier, the negative terminal connects to the reference
        electrode submerged in the bath (<em>bath electrode</em>), which acts
        as the circuit's virtual ground.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/ElectricalPin_N.png"),
      Text(
        extent = {{-75, -75}, {75, 75}},
        textString = "-",
        textColor = {0, 0, 255},
        textStyle = {TextStyle.Bold})
    }),
    Diagram(graphics = {
      Rectangle(
        extent = {{-17, 17}, {17, -17}},
        lineColor = {0, 0, 255},
        fillColor = {0, 0, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-11, 11}, {11, -11}},
        textString = "-",
        textColor = {255, 255, 255},
        fontSize = 14)
    })
  );
end ElectricalPin_n;
