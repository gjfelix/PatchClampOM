within PatchClamp.Electrodes;
model Ground "Absolute potential reference -- fixes v = 0 V at the connected node"

  PatchClamp.Interfaces.ElectricalPin_p p
    "Ground terminal -- v = 0 V (the circuit's absolute reference)"
    annotation(Placement(transformation(extent = {{-10, 90}, {10, 110}})));

equation
  p.v = 0;

  annotation(
    Documentation(info = "<html>
      <h2>Ground</h2>
      <p>
        Fixes the electrical potential at the connected node to exactly
        0 V, the reference against which every other voltage in the circuit
        (V_m, E_K, V_command, ...) is measured.
      </p>
      <p>
        In a real patch clamp rig this role is played by the bath
        electrode; <code>BathElectrode</code> models its contact resistance
        explicitly, while this block is the ideal (R = 0) version, useful
        when that drop is irrelevant to the simulation -- e.g. connecting
        <code>Ground.p</code> to the same extracellular node as
        <code>GoldmanMembrane.membrane_n</code> in
        <code>Step10_GoldmanRestingPotential</code>, so that
        V_m = membrane_p.v directly.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Ground.png")
    })
  );
end Ground;
