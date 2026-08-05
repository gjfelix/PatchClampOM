within PatchClamp.Amplifiers.Compensation;
model WholeCellCapacitanceComp
  "C-slow compensation: cancels the whole-cell membrane's capacitive current"

  parameter Modelica.Units.SI.Capacitance C_slow = 10.0e-12
    "Membrane capacitance to compensate [F] (should match the cell's C_m)"
    annotation(
      Dialog(group = "C-slow compensation"),
      displayUnit = "pF");

  parameter Modelica.Units.SI.Resistance R_s_est = 4.0e6
    "Estimated series resistance [Ohm] (typical: R_pipette)"
    annotation(
      Dialog(group = "C-slow compensation"),
      displayUnit = "MOhm");

  parameter Real fraction(min = 0.0, max = 1.0) = 1.0
    "Compensation fraction applied [0..1] (1.0 = full compensation)";

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier command-signal terminal"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Voltage V_m_est(start = -0.065, fixed = true)
    "Internal estimate of the membrane potential [V], used to compute I_comp";

  Modelica.Units.SI.Current I_comp
    "Injected C-slow compensation current [A]
     (subtract from the amplifier's I_measured to cancel the membrane artifact)";

equation
  // Internal RC model of the membrane charging transient (tau_s = R_s_est * C_slow)
  R_s_est * C_slow * der(V_m_est) = (p.v - n.v) - V_m_est;

  I_comp = fraction * C_slow * der(V_m_est);

  p.i = 0;
  n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>WholeCellCapacitanceComp</h2>
      <p>
        Models the membrane-capacitance (<em>C-slow</em>) compensation of a
        patch clamp amplifier, canceling the slow capacitive transient
        produced by charging the cell's membrane through the series
        resistance.
      </p>
      <p>
        On a voltage step in whole-cell configuration, current flows
        through R_s to charge C_m, giving an exponential transient:
      </p>
      <pre>
  tau_s = R_s * C_m
  I_Cm(t) = (V_step / R_s) * exp(-t / tau_s)
      </pre>
      <p>
        This model replicates that transient internally and subtracts it
        from the measured signal, via a first-order estimator equivalent to
        the real amplifier's internal analog RC circuit:
      </p>
      <pre>
  tau_s * dV_m_est/dt = V_cmd - V_m_est
  I_comp = C_slow * dV_m_est/dt
      </pre>
      <p>
        Set <code>C_slow</code> to match the cell's C_m (typically 10-100 pF,
        measured with the SealTest protocol) and <code>R_s_est</code> to
        <code>PatchPipette.R_pipette</code>; adjust
        <code>fraction</code> until the slow transient disappears. Apply as:
      </p>
      <pre>  I_corrected = amp.I_measured - comp_slow.I_comp;</pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/WholeCellCapacitanceComp.png")
    })
  );
end WholeCellCapacitanceComp;
