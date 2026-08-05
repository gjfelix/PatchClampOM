within PatchClamp.Electrodes;
model BathElectrode "Reference electrode submerged in the perfusion bath (virtual ground)"

  parameter Modelica.Units.SI.Resistance R_bath = 100.0
    "Bath electrode contact resistance [Ohm] (typical: 50-200 Ohm)"
    annotation(Dialog(group = "Electrode properties"));

  PatchClamp.Interfaces.ElectricalPin_p p
    "Active terminal (connects to the cell circuit)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Ground terminal (absolute reference = 0 V)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

equation
  // The bath electrode sets the circuit's reference potential; the drop
  // across R_bath is small and doesn't affect the membrane potential
  p.v - n.v = p.i * R_bath;

  n.v = 0;
  p.i + n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>BathElectrode</h2>
      <p>
        Models the electrode submerged in the perfusion bath that serves as
        the experiment's potential reference -- in practice an Ag/AgCl
        electrode contacting the extracellular solution through an
        agar-KCl bridge.
      </p>
      <p>
        It fixes the extracellular potential to 0 V, so every other voltage
        in the circuit (membrane potential, command voltage, Nernst
        potentials) is defined relative to this point; without it the
        circuit would float with no potential reference.
      </p>
      <p>
        R_bath introduces a small voltage drop when current flows. For
        typical patch clamp currents (1-10 nA) and R_bath = 100 Ohm, the
        error is 0.1-1 mV -- negligible, though it can warrant compensation
        in voltage-ramp experiments with larger currents.
      </p>
      <p>
        Worth considering: what happens if the bath electrode isn't fully
        submerged? Why use an agar-KCl bridge instead of bare metal contact
        with the solution?
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/BathElectrode.png")
    })
  );
end BathElectrode;
