within PatchClamp.Amplifiers;
model CurrentClampAmplifier
  "Current-clamp amplifier with a configurable pulse protocol"

  parameter Modelica.Units.SI.Current I_hold = 0.0
    "Holding current [A] (typical: 0 pA at rest)";

  parameter Modelica.Units.SI.Current I_pulse = 10.0e-12
    "Injected current pulse amplitude [A] (typical: 10 pA for HH)";

  parameter Real t_pulse_start(unit = "s") = 0.010
    "Start time of the current pulse [s]";

  parameter Real t_pulse_end(unit = "s") = 0.015
    "End time of the current pulse [s] (duration = t_pulse_end - t_pulse_start)";

  // Optional second pulse, off by default. To enable it, set
  // t_pulse2_start < t_pulse2_end within stopTime -- e.g. for a
  // refractory-period protocol:
  //   t_pulse2_start = 0.010 + t2_delay,  t_pulse2_end = 0.012 + t2_delay
  parameter Real t_pulse2_start(unit = "s") = 1.0e10
    "Start time of the second pulse [s]. Default 1e10 s = disabled."
    annotation(Dialog(group = "Second pulse (optional)"));
  parameter Real t_pulse2_end(unit = "s") = 1.0e10
    "End time of the second pulse [s]. Default 1e10 s = disabled."
    annotation(Dialog(group = "Second pulse (optional)"));
  parameter Modelica.Units.SI.Current I_pulse2 = 10.0e-12
    "Second pulse amplitude [A]; may differ from the first."
    annotation(Dialog(group = "Second pulse (optional)"));

  parameter Modelica.Units.SI.Resistance R_bridge = 4.0e6
    "Bridge resistance for pipette voltage-drop compensation [Ohm]
     (should match R_pipette to cancel the pipette transient)";

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier output terminal (connect to PatchPipette.p_amp)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground, connect to BathElectrode.n)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  Modelica.Units.SI.Current I_command "Instantaneous command current [A]";

  Modelica.Units.SI.Voltage V_membrane
    "Measured membrane voltage, bridge-compensated [V]";

equation
  I_command = if (time >= t_pulse_start and time < t_pulse_end) then I_pulse
              else if (time >= t_pulse2_start and time < t_pulse2_end) then I_pulse2
              else I_hold;

  // Ideal current source; I_command > 0 is depolarizing (positive into the
  // cell), while p.i < 0 means current leaves the amplifier toward the pipette
  p.i = -I_command;

  // n.i is left undetermined here -- it's set by the external circuit's own
  // KCL at the ground node, and declaring it here would over-determine it

  // Bridge compensation removes the R_pipette voltage drop from the raw
  // reading: V_raw = p.v - n.v, V_membrane = V_raw - I_command * R_bridge
  V_membrane = (p.v - n.v) - I_command * R_bridge;

  annotation(
    Documentation(info = "<html>
      <h2>CurrentClampAmplifier</h2>
      <p>
        A current-clamp amplifier: injects a configured command current and
        records the resulting membrane voltage, with bridge compensation to
        reduce the pipette-resistance artifact.
      </p>

      <pre>
  Amplifier                     Pipette          Cell
  +--------------+
  |  I_command   |-->--- p ----[PatchPipette]---- [Cell]
  |  (ideal I    |                                   |
  |   source)    |                                   |
  |              |---- n --------------------------- [Bath]
  +--------------+
  V_membrane = measured, bridge-compensated membrane voltage
      </pre>

      <p>Pulse protocol:</p>
      <pre>
  I_command(t) =
    I_hold     if t &lt; t_pulse_start or t &gt;= t_pulse_end
    I_pulse    if t_pulse_start &lt;= t &lt; t_pulse_end
      </pre>

      <p>
        In current clamp, R_pipette produces a voltage drop that contaminates
        the V_membrane reading. Bridge compensation subtracts it:
        V_membrane = V_raw - I_command * R_bridge. Set
        <code>R_bridge = R_pipette</code> for perfect compensation; any
        residual mismatch shows up as an instantaneous step at the start of
        the current pulse (the pipette's capacitive artifact).
      </p>

      <p>
        <code>I_command &gt; 0</code> is depolarizing (positive current
        injected into the cell); <code>I_command &lt; 0</code> is
        hyperpolarizing.
      </p>

      <p>
        Used with these defaults (I_hold = 0 pA, I_pulse = 10 pA,
        t_pulse_start = 10 ms, t_pulse_end = 15 ms, R_bridge = 4 MOhm) in
        models such as <code>Step05_PassiveCellCurrentClamp</code> and
        <code>Step06_HodgkinHuxleyActionPotential</code> (which override
        I_pulse for its own protocol).
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/CurrentClampAmplifier.png")
    })
  );
end CurrentClampAmplifier;
