within PatchClamp.Cells.Interfaces;
partial model PartialExcitableCell
  "Base interface for excitable cell models (patch clamp)"

  parameter Modelica.Units.SI.Capacitance C_m = 10e-12
    "Membrane capacitance [F] (typical: 10 pF for a small neuron)";

  parameter Real A(unit = "m2") = 1000e-12
    "Membrane area [m2] (typical: 1000 um2 = 1e-9 m2)";

  Modelica.Units.SI.Voltage V_m(start = -0.065, fixed = true)
    "Membrane potential [V] (intracellular relative to extracellular)";

  Real I_total(unit = "A")
    "Total ionic current across the membrane [A] (positive: outward)";

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Intracellular pin (positive)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Extracellular pin (negative, reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

equation
  V_m = membrane_p.v - membrane_n.v;

  // Membrane equation: C_m * dV_m/dt = I_ext - I_total, with I_ext entering
  // through membrane_p.i (positive = into the node)
  C_m * der(V_m) = membrane_p.i - I_total;

  membrane_p.i + membrane_n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>PartialExcitableCell</h2>
      <p>
        Defines the common interface shared by every concrete cell model;
        each one extends this partial and supplies its own equation for
        <code>I_total</code>.
      </p>
      <p>
        <b>C_m</b> is the membrane capacitance (typical: 10 pF), <b>A</b> the
        membrane area (typical: 1000 &#956;m2 = 1e-9 m2), and the membrane
        equation is:
      </p>
      <pre>  C_m * dV_m/dt = I_ext - I_total</pre>
      <p>
        with I_ext the current injected by the pipette (via
        <code>membrane_p.i</code>) and I_total the total ionic current
        defined by each concrete submodel. <code>membrane_p</code>
        (intracellular, positive) connects to the patch pipette;
        <code>membrane_n</code> (extracellular, negative) connects to the
        bath electrode.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PartialExcitableCell.png")
    })
  );
end PartialExcitableCell;
