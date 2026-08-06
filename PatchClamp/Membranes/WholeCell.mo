within PatchClamp.Membranes;
model WholeCell
  "Whole-cell membrane: R_access in series with (C_m || R_m). Models the ruptured patch."

  parameter Real R_access(unit = "Ohm") = 10.0e6
    "Access resistance (pipette-to-cytoplasm) [Ohm]. Typical: 5-30 MOhm";
  parameter Real C_m(unit = "F") = 50.0e-12
    "Total membrane capacitance [F]. Typical: 10-200 pF depending on cell size";
  parameter Real R_m(unit = "Ohm") = 200.0e6
    "Resting membrane resistance [Ohm]. Typical: 100 MOhm - 1 GOhm";
  parameter Real V_m_init(unit = "V") = 0.0
    "Initial membrane voltage [V] (0 V for a seal-test; -60 mV for a real experiment)";

  // Uses PatchClamp's own connectors (not Modelica.Electrical.Analog) for
  // consistency with the rest of the package, and because connecting two
  // different connector types via connect() left the DAE structurally
  // singular during integration (DASKR: "ITERATION MATRIX IS SINGULAR" at
  // t=0). See PatchClamp.Examples.Step04_WholeCellBreakIn.
  PatchClamp.Interfaces.ElectricalPin_p p_pip
    "Pipette-side connector (current input)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  PatchClamp.Interfaces.ElectricalPin_n p_ext
    "Bath-side connector (external reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Real V_pip(unit = "V")     "Voltage at the pipette tip [V]";
  Real V_cell(unit = "V")    "Voltage at the intracellular node (past R_access) [V]";
  Real V_m(unit = "V", start = V_m_init, fixed = true)
    "Membrane voltage = V_cell - V_ext [V] (state variable, C_m's capacitor)";

  Real I_total(unit = "A")   "Total current entering p_pip [A]";
  Real I_access(unit = "A")  "Current through R_access [A]";
  Real I_Cm(unit = "A")      "Membrane capacitive current [A] -- the slow transient";
  Real I_Rm(unit = "A")      "Ionic (resistive) membrane current [A]";

  final parameter Real tau_slow(unit = "s") = R_access * C_m
    "Time constant of the slow transient [s]";
  final parameter Real tau_membrane(unit = "s") = R_m * C_m
    "Membrane time constant [s]";

equation
  // Equivalent circuit (explicit equations, no MSL components): p_pip
  // connects through R_access to node_cell, which splits into C_m and R_m
  // in parallel down to p_ext. node_cell is eliminated algebraically:
  // V_m = V_cell - p_ext.v is the only state (the C_m capacitor's voltage).

  V_pip  = p_pip.v;
  V_cell = V_m + p_ext.v;

  I_access = (V_pip - V_cell) / R_access;

  // Capacitive (slow transient) and resistive (DC) branches in parallel
  // between node_cell and p_ext
  I_Cm = C_m * der(V_m);
  I_Rm = V_m / R_m;

  I_access = I_Cm + I_Rm;

  p_pip.i = I_access;
  p_ext.i = -I_access;

  I_total = p_pip.i;

  annotation(
    Documentation(info = "<html>
      <h2>WholeCell</h2>
      <p>
        Models electrical access to the cell interior after the patch
        ruptures, as three elements:
      </p>
      <ul>
        <li><b>R_access</b>: resistance of the membrane opening (5-30 MOhm), setting clamp quality and the slow transient's speed.</li>
        <li><b>C_m</b>: total membrane capacitance (10-200 pF), the source of the slow capacitive transient visible in a seal-test.</li>
        <li><b>R_m</b>: resting membrane resistance (no active channels), setting the steady-state DC current.</li>
      </ul>
      <pre>
  tau_slow     = R_access * C_m   (transient visible in the seal-test)
  tau_membrane = R_m      * C_m   (slow discharge, ms-to-s timescale)
      </pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/WholeCell.png")
    })
  );
end WholeCell;
