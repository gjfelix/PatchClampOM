within PatchClamp.Amplifiers.Compensation;
model PipetteCapacitanceComp
  "C-fast compensation: cancels the glass pipette's capacitive current"

  parameter Modelica.Units.SI.Capacitance C_fast = 3.0e-12
    "Pipette capacitance to compensate [F] (should match PatchPipette's C_pipette)"
    annotation(
      Dialog(group = "C-fast compensation"),
      displayUnit = "pF");

  parameter Real fraction(min = 0.0, max = 1.0) = 1.0
    "Compensation fraction applied [0..1] (1.0 = full compensation)";

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier command-signal terminal"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Current I_comp
    "Injected C-fast compensation current [A]
     (subtract from the amplifier's I_measured to cancel the artifact)";

equation
  // The pipette's own capacitive current is I_Cpip = C_pipette * d(V_cmd)/dt;
  // this is a computed signal, not a real current path between p and n
  I_comp = fraction * C_fast * der(p.v - n.v);

  p.i = 0;
  n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>PipetteCapacitanceComp</h2>
      <p>
        Models the pipette-capacitance (<em>C-fast</em>) compensation found
        on amplifiers like the Axopatch 200B or HEKA EPC-10.
      </p>
      <p>
        A voltage step drives a fast transient current through the pipette
        glass wall's capacitance, I_Cpip(t) = C_pipette * dV_cmd/dt. Real
        hardware injects this current in antiphase through an internal
        trim capacitor so it cancels in the measurement channel; here,
        subtract <code>I_comp</code> from the amplifier's
        <code>I_measured</code> to do the same:
      </p>
      <pre>  I_corrected = amp.I_measured - comp_fast.I_comp;</pre>
      <p>
        With <code>fraction = 1.0</code>, the fast capacitive transient
        disappears, revealing the ionic currents and the slower membrane
        transient underneath. Set <code>C_fast</code> to match
        <code>PatchPipette.C_pipette</code> (typically ~3 pF); on real
        hardware, <code>fraction</code> is adjusted until the fast
        transient disappears without ringing.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PipetteCapacitanceComp.png")
    })
  );
end PipetteCapacitanceComp;
