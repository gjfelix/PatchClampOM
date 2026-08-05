within PatchClamp.Amplifiers;
model VoltageClampAmplifier
  "Voltage-clamp amplifier with a configurable step protocol"

  parameter Modelica.Units.SI.Voltage V_hold = -0.070
    "Holding potential [V] (typical: -70 mV)";

  parameter Modelica.Units.SI.Voltage V_step = -0.050
    "Test step potential [V] (typical: -50 mV)";

  parameter Real t_step_start(unit = "s") = 0.050
    "Start time of the voltage step [s]";

  parameter Real t_step_end(unit = "s") = 0.150
    "End time of the voltage step [s]";

  parameter Modelica.Units.SI.Voltage V_ljp_correction = -11.0e-3
    "LJP correction applied to the command [V] (typical: -11 mV for KCl/ACSF)";

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier output terminal (connect to PatchPipette.p_amp)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground, connect to BathElectrode.n)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  Modelica.Units.SI.Current I_measured
    "Current measured by the amplifier [A]
     (positive = flows from the amplifier into the pipette)";

  Modelica.Units.SI.Voltage V_command "Instantaneous command voltage [V]";

equation
  // The LJP correction is applied before the step protocol
  V_command = (if time < t_step_start or time >= t_step_end
               then V_hold
               else V_step) - V_ljp_correction;

  // Ideal voltage source between p and n
  p.v - n.v = V_command;

  // p.i < 0 in Modelica (current flows out of the component), so
  // I_measured = -p.i is positive when current flows into the pipette
  I_measured = -p.i;

  annotation(
    Documentation(info = "<html>
      <h2>VoltageClampAmplifier</h2>
      <p>
        An ideal-feedback voltage-clamp amplifier: holds the membrane
        potential at the command value and measures the resulting ionic
        current.
      </p>

      <pre>
  Amplifier                     Pipette          Cell
  +--------------+
  |  V_command   |---- p ----[PatchPipette]---- [Cell]
  |  (ideal V    |                                 |
  |   source)    |                                 |
  |              |---- n --------------------------[Bath]
  +--------------+
  I_measured = current flowing from p into the pipette
      </pre>

      <p>Step protocol:</p>
      <pre>
  V_command(t) =
    V_hold - V_ljp_correction    if t &lt; t_step_start or t &gt;= t_step_end
    V_step - V_ljp_correction    if t_step_start &lt;= t &lt; t_step_end
      </pre>

      <p>
        The LJP is subtracted from the command so the voltage the cell
        actually experiences is the intended one:
        V_cell = V_command + V_ljp_correction = V_hold (or V_step).
      </p>

      <p>
        <code>I_measured &gt; 0</code> means outward current (the amplifier
        injects current into the pipette); in most excitable cells, Na+
        current shows up as a NEGATIVE (inward) peak in I_measured.
      </p>

      <p>
        Default parameters (V_hold = -70 mV, V_step = -50 mV,
        t_step_start = 50 ms, t_step_end = 150 ms) match
        <code>Step03_PassiveCellVoltageClamp</code>.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/VoltageClampAmplifier.png")
    })
  );
end VoltageClampAmplifier;
