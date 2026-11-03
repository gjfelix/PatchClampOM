within PatchClamp.Examples;
model Step07_RefractoryPeriod
  "Refractory period of the HH neuron -- two-pulse protocol"

  parameter Real t2_delay(unit = "s") = 5.0e-3
    "Delay of the second pulse relative to the first [s]. Range: 3-20 ms.
     3 ms -> absolute refractory (no second AP); 6 ms -> relative
     refractory (smaller second AP); 12 ms -> full recovery (full second AP)."
    annotation(Dialog(group = "Two-pulse protocol"));

  PatchClamp.Amplifiers.CurrentClampAmplifier amplifier(
    I_hold         = 0.0,
    I_pulse        = 300.0e-12,
    t_pulse_start  = 0.010,
    t_pulse_end    = 0.012,
    I_pulse2       = 300.0e-12,
    t_pulse2_start = 0.010 + t2_delay,
    t_pulse2_end   = 0.012 + t2_delay,
    R_bridge       = 4.0e6)
    "Pulse 1: 300 pA at t=10-12 ms. Pulse 2: 300 pA at t=10+t2_delay ms (2 ms each)."
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.HodgkinHuxleyNeuron neuron(
    C_m      = 10.0e-12,
    A        = 1000.0e-12,
    g_Na_max = 1200.0,
    g_K_max  = 360.0,
    g_L      = 3.0,
    E_Na     = 0.050,
    E_K      = -0.077,
    E_L      = -0.0544)
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pipette.p_cell, neuron.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(neuron.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));
  connect(amplifier.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pipette.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step07 -- Hodgkin-Huxley refractory period</h2>
      <p>
        A two-pulse protocol using a single <code>CurrentClampAmplifier</code>
        (its optional second-pulse parameters t_pulse2_start, t_pulse2_end,
        I_pulse2), otherwise wired the same as Step06.
      </p>
      <p>
        The refractory period comes from two gates recovering on different
        timescales: during the absolute refractory period, h_Na (Na+
        inactivation) is still near 0, so I_Na = g_Na*m^3*h*(V-E_Na) stays
        essentially off regardless of stimulus (h recovers with
        tau_h ~ 3-4 ms at -65 mV); during the relative refractory period,
        h_Na is partially recovered (roughly 0.1-0.7) and n_K (K+
        activation) is still elevated, giving a smaller or delayed second
        spike; full recovery is h ~ 0.6, n ~ 0.3, the resting values.
      </p>
      <table border='1' cellpadding='3'>
        <tr><th>t2_delay</th><th>h at t2</th><th>Result</th></tr>
        <tr><td>3 ms</td><td>~0.08</td><td>no 2nd AP (absolute)</td></tr>
        <tr><td>5 ms</td><td>~0.21</td><td>no 2nd AP (absolute)</td></tr>
        <tr><td>8 ms</td><td>~0.43</td><td>reduced AP, peak ~+27 mV (relative)</td></tr>
        <tr><td>12 ms</td><td>~0.57</td><td>full 2nd AP, peak ~+40 mV</td></tr>
      </table>
      <p>
        Variables worth plotting: <code>neuron.V_m</code> (one or two APs
        depending on t2_delay), <code>neuron.h</code> (Na+ inactivation,
        the key to refractoriness), and <code>neuron.n</code> (K+
        activation, the post-AP hyperpolarization).
      </p>
    </html>"),
    experiment(
      StopTime  = 0.050,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 80, 160},
        fillColor = {230, 242, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step07",
        textColor = {0, 60, 130},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "Refractory Period",
        textColor = {0, 80, 160},
        fontSize = 11)
    })
  );
end Step07_RefractoryPeriod;
