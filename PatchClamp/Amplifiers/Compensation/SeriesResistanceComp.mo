within PatchClamp.Amplifiers.Compensation;
model SeriesResistanceComp
  "Series resistance (R_s) compensation: corrects the voltage error under current flow"

  parameter Modelica.Units.SI.Resistance R_s = 4.0e6
    "Series resistance to compensate [Ohm] (typical: PatchPipette's R_pipette)"
    annotation(
      Dialog(group = "R_s compensation"),
      displayUnit = "MOhm");

  parameter Real alpha(min = 0.0, max = 0.9) = 0.0
    "R_s compensation fraction [0..0.9]
     0 = no compensation (ideal), 0.9 = practical stability limit.
     Values above ~0.8 can cause oscillation in a real amplifier's feedback loop."
    annotation(Dialog(group = "R_s compensation"));

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier command-signal terminal"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  input Modelica.Units.SI.Current I_measured = 0.0
    "Current measured by the amplifier [A] (connect from VoltageClampAmplifier.I_measured)";

  Modelica.Units.SI.Voltage V_error
    "Uncompensated membrane voltage error [V] = R_s * I_measured";

  Modelica.Units.SI.Voltage V_cmd_corrected
    "Corrected command voltage [V] -- what the amplifier would need to output
     so the cell actually receives V_cmd";

  Modelica.Units.SI.Voltage V_cmd
    "Present command voltage at pin p relative to n [V]";

equation
  V_cmd = p.v - n.v;

  // Ohmic drop across R_s under the measured current: this is how far the
  // real membrane potential deviates from the command
  V_error = R_s * I_measured;

  // Partial compensation alpha: a real amplifier adds this offset
  // automatically inside its feedback loop
  V_cmd_corrected = V_cmd + alpha * V_error;

  p.i = 0;
  n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>SeriesResistanceComp</h2>
      <p>
        Models series-resistance (R_s) compensation, arguably the most
        important compensation in voltage-clamp experiments: the voltage
        error it corrects can otherwise completely distort the apparent
        kinetics of ionic channels.
      </p>
      <p>
        In whole-cell configuration, ionic current flows through the
        pipette resistance (R_s = R_pipette), displacing the real membrane
        potential from the command:
      </p>
      <pre>
  V_m_real = V_cmd - R_s * I_measured

  Example: R_s = 10 MOhm, I_Na_peak = -2 nA
    -&gt; V_error = 10e6 * 2e-9 = 20 mV  (huge for Na+ channel kinetics)
      </pre>
      <p>
        The amplifier adds a fraction <code>alpha</code> of the error back
        to the command to correct it:
      </p>
      <pre>
  V_cmd_corr = V_cmd + alpha * R_s * I_measured

  alpha = 0.8 (80%) leaves a residual error of (1 - 0.8) * 20 mV = 4 mV
      </pre>
      <p>
        On real hardware, R_s compensation is a positive-feedback loop that
        becomes unstable above alpha &#8776; 0.9-0.95, hence the 0.9 cap on
        <code>alpha</code> here.
      </p>
      <p>Typical use, alongside a VoltageClampAmplifier instance:</p>
      <pre>
  rs_comp.I_measured = amp.I_measured;
  V_m_estimated = amp.p.v - rs_comp.V_error * (1 - alpha);
      </pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/SeriesResistanceComp.png")
    })
  );
end SeriesResistanceComp;
