within PatchClamp.Membranes;
model CellAttachedPatch
  "Cell-attached (gigaseal) membrane patch: R_seal || (R_patch || C_patch)"

  // This is the electrical equivalent circuit of the pipette tip pressed
  // against the cell membrane: R_seal, R_patch, and C_patch all connect
  // the pipette node (p_pip) to the bath node (p_ext) in parallel.
  //
  // R_seal: resistance of the glass-to-membrane seal. Pre-seal (loose
  //   contact) ~10 MOhm, seal-test current ~350 pA; partial seal
  //   ~100 MOhm, ~35 pA; gigaseal ~1 GOhm, ~5 pA (down at the noise floor).
  // R_patch: resistance of the patch's own channels (closed ~GOhm; opening
  //   a single channel roughly divides it by 50 GOhm/n_open).
  // C_patch: patch capacitance (~0.1 pF for ~1 um2 of membrane), which
  //   produces the capacitive transients bracketing each seal-test pulse.
  //
  // Reducing R_seal from 1 GOhm to 10 MOhm in steps shows the seal-test
  // background current rising ~200-fold -- a direct illustration of why
  // the gigaseal is essential for resolving 1-5 pA single-channel currents.

  parameter Modelica.Units.SI.Resistance R_seal = 1.0e9
    "Seal resistance between pipette and membrane [Ohm].
     Gigaseal: >= 1 GOhm | partial seal: 100 MOhm | no seal: 10 MOhm.
     Seal-test leak current: I_leak = V_pulse / R_seal."
    annotation(
      Dialog(group = "Seal properties"),
      displayUnit = "Ohm");

  parameter Modelica.Units.SI.Resistance R_patch = 50.0e9
    "Membrane patch resistance with channels closed [Ohm] (~50 GOhm);
     decreases as channels open. In practice this is much larger than
     R_seal and can be ignored when estimating R_seal from a seal-test."
    annotation(
      Dialog(group = "Patch properties"),
      displayUnit = "Ohm");

  parameter Modelica.Units.SI.Capacitance C_patch = 0.1e-12
    "Membrane patch capacitance [F] (typical: 0.05-0.2 pF for ~1 um2),
     producing the transients at the start and end of each seal-test pulse."
    annotation(
      Dialog(group = "Patch properties"),
      displayUnit = "pF");

  PatchClamp.Interfaces.ElectricalPin_p p_pip
    "Pipette tip terminal (connect to PatchPipette.p_cell)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_p p_ext
    "Extracellular/bath terminal (connect to BathElectrode.p)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Voltage V_patch
    "Voltage across the patch and seal (pip - ext) [V]";

  Modelica.Units.SI.Current I_seal
    "Current through the seal [A] (leak between pipette and membrane)";

  Modelica.Units.SI.Current I_R_patch
    "Resistive current through the patch [A] (ionic channels)";

  Modelica.Units.SI.Current I_C_patch
    "Capacitive current of the patch [A] (charging/discharging C_patch)";

equation
  V_patch = p_pip.v - p_ext.v;

  I_seal = V_patch / R_seal;
  I_R_patch = V_patch / R_patch;
  I_C_patch = C_patch * der(V_patch);

  // All current entering p_pip leaves through p_ext
  p_pip.i = I_seal + I_R_patch + I_C_patch;
  p_ext.i = -(I_seal + I_R_patch + I_C_patch);

  annotation(
    Documentation(info = "<html>
      <h2>CellAttachedPatch</h2>
      <p>
        The equivalent circuit of the pipette tip pressed against the
        membrane in the cell-attached configuration (or any step leading up
        to the gigaseal): R_seal, R_patch, and C_patch all connect the
        pipette node (p_pip) to the bath node (p_ext) in parallel.
      </p>
      <table border='1'>
        <tr><th>R_seal</th><th>Seal state</th><th>I_steady (V=5 mV)</th></tr>
        <tr><td>10 MOhm</td><td>no seal (pipette free in bath)</td><td>500 pA</td></tr>
        <tr><td>100 MOhm</td><td>partial seal</td><td>50 pA</td></tr>
        <tr><td>1 GOhm</td><td>gigaseal</td><td>5 pA</td></tr>
        <tr><td>10 GOhm</td><td>excellent gigaseal</td><td>0.5 pA</td></tr>
      </table>
      <p>
        Typical wiring, in series with <code>SealTest</code> and
        <code>PatchPipette</code>: see <code>Step02_GigasealFormation</code>
        for the full worked example.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/CellAttachedPatch.png")
    })
  );
end CellAttachedPatch;
