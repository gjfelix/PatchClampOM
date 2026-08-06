within PatchClamp.Examples;
model Step17_PacemakerAutorhythmicity
  "Sinoatrial pacemaker cell -- spontaneous automaticity with no external stimulus"

  // With the default parameters (I_hold = 0, I_pulse = 0) the cell fires
  // on its own -- plot cell.V_m, cell.y, cell.I_f, cell.I_Ca and watch the
  // slow diastolic depolarization driven by I_f (expected rate ~1.5 Hz,
  // 60-90 bpm).
  //
  // Sympathetic-like effect: cell.g_f = 0.040 (up from 0.014, x2.9) --
  // more I_f during diastolic depolarization speeds it up, giving a period
  // of ~0.58 s (~103 bpm) vs. the ~0.80 s baseline. (V_f_half has little
  // effect here since tau_y = 600 ms is much longer than the ~400 ms
  // diastolic window, so y never reaches y_inf before the next spike.)
  //
  // Parasympathetic-like effect: cell.g_f = 0.006 (down from 0.014,
  // x0.43) slows diastolic depolarization, giving a period of ~1.4 s
  // (~43 bpm, marked bradycardia).
  //
  // I_f block (as with ivabradine): cell.g_f = 0.0 removes the funny
  // current entirely -- automaticity stops, and V_m settles into a damped
  // oscillation.
  //
  // I_Ca block (as with verapamil): cell.g_Ca = 0.0 removes the AP
  // upstroke -- no automaticity. Unlike neurons, the SAN's upstroke
  // depends on Ca2+, not Na+.
  //
  // Compare with the ventricular cell (Step16): it needs an external
  // stimulus (I_pulse > 0) to fire, while this one fires on its own --
  // the defining feature of the SA node.

  PatchClamp.Amplifiers.CurrentClampAmplifier amp(
    I_hold        = 0.0,
    I_pulse       = 0.0,
    t_pulse_start = 0.500,
    t_pulse_end   = 0.501,
    R_bridge      = 0.0)
    "Zero injected current -- demonstrates automaticity"
    annotation(Placement(transformation(extent = {{-190, -40}, {-110, 40}})));

  PatchClamp.Electrodes.PatchPipette pip(
    R_pipette  = 5.0e6,
    C_pipette  = 2.0e-12,
    V_junction = 0.0)
    annotation(Placement(transformation(extent = {{-90, -40}, {-10, 40}})));

  PatchClamp.Cells.PacemakerCell cell(
    C_m      = 20.0e-12,
    g_f      = 0.014,
    E_f      = -0.010,
    V_f_half = -0.058,
    k_f      = 0.007,
    tau_y    = 600.0e-3,
    g_Ca     = 0.5,
    E_Ca     = 0.060,
    V_d_half = -0.030,
    k_d      = 0.008,
    g_K      = 4.0,
    E_K      = -0.080,
    V_n_half = -0.020,
    k_n      = 0.012,
    tau_n    = 150.0e-3,
    g_L      = 0.02,
    E_L      = -0.080)
    annotation(Placement(transformation(extent = {{10, -40}, {90, 40}})));

  PatchClamp.Electrodes.BathElectrode bath
    annotation(Placement(transformation(extent = {{110, -40}, {190, 40}})));

equation
  connect(amp.p, pip.p_amp)
    annotation(Line(points = {{-110, 0}, {-90, 0}}, color = {0, 0, 255}));
  connect(pip.p_cell, cell.membrane_p)
    annotation(Line(points = {{-10, 0}, {10, 0}}, color = {0, 0, 255}));
  connect(cell.membrane_n, bath.p)
    annotation(Line(points = {{90, 0}, {110, 0}}, color = {0, 0, 255}));
  connect(amp.n, bath.n)
    annotation(Line(points = {{-190, 0}, {-190, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));
  connect(pip.n, bath.n)
    annotation(Line(points = {{-50, -40}, {-50, -80}, {190, -80}, {190, 0}}, color = {0, 0, 255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step17 -- Sinoatrial automaticity</h2>
      <p>
        The SA node pacemaker cell fires rhythmic action potentials with no
        external stimulus. I_f (the funny current) is the driver: it flows
        in slowly during diastole, carrying V_m up to I_Ca's threshold
        (~-10 mV).
      </p>

      <p>
        Circuit: <code>CurrentClampAmp</code> (I_command = 0 A -- the cell
        fires on its own) -&gt; <code>PatchPipette</code> -&gt;
        <code>PacemakerCell</code> -&gt; <code>BathElectrode</code>.
      </p>

      <h3>Variables worth plotting</h3>
      <ul>
        <li><code>cell.V_m</code> -- membrane potential [V]</li>
        <li><code>cell.y</code> -- HCN/I_f gate (0-1)</li>
        <li><code>cell.n</code> -- IKr gate (0-1)</li>
        <li><code>cell.d_inf</code> -- L-type Ca2+ activation (0-1)</li>
        <li><code>cell.I_f</code> -- funny (HCN) current [A]</li>
        <li><code>cell.I_Ca</code> -- L-type Ca2+ current [A]</li>
        <li><code>cell.I_K</code> -- K+ current [A]</li>
      </ul>

      <h3>Autonomic modulation</h3>
      <table border='1'>
        <tr><th>Condition</th><th>Parameter</th><th>Value</th><th>Approx. rate</th></tr>
        <tr><td>Normal (default)</td><td>V_f_half</td><td>-58 mV</td><td>~1.5 Hz (90 bpm)</td></tr>
        <tr><td>Sympathetic (adrenaline)</td><td>V_f_half</td><td>-50 mV</td><td>~2.5 Hz (150 bpm)</td></tr>
        <tr><td>Parasympathetic (acetylcholine)</td><td>V_f_half</td><td>-80 mV</td><td>~0.8 Hz (48 bpm)</td></tr>
        <tr><td>Ivabradine (I_f block)</td><td>g_f</td><td>0.0</td><td>0 Hz (no automaticity)</td></tr>
      </table>

      <h3>Excitable cell models in this package</h3>
      <table border='1'>
        <tr><th>Model</th><th>Type</th><th>ODEs</th><th>Automaticity</th><th>Example</th></tr>
        <tr><td>PassiveCell</td>         <td>passive RC</td>            <td>1</td>  <td>no</td>  <td>Step03</td></tr>
        <tr><td>SimplifiedNeuron</td>    <td>LIF</td>                   <td>1</td>  <td>no</td>  <td>--</td></tr>
        <tr><td>HodgkinHuxleyNeuron</td> <td>classic Na+/K+</td>        <td>4</td>  <td>no</td>  <td>Step06</td></tr>
        <tr><td>FitzHughNagumoNeuron</td><td>2D reduction</td>          <td>2</td>  <td>no</td>  <td>Step14</td></tr>
        <tr><td>MorrisLecarNeuron</td>   <td>Ca2+/K+ bifurcation</td>   <td>2</td>  <td>no</td>  <td>Step15</td></tr>
        <tr><td>CardiacVentricularCell</td><td>simplified Beeler-Reuter</td><td>4</td><td>no</td> <td>Step16</td></tr>
        <tr><td>PacemakerCell</td>       <td>SAN + I_f (HCN)</td>       <td>3</td>  <td>yes</td>  <td>Step17</td></tr>
      </table>
    </html>"),
    experiment(
      StopTime  = 3.000,
      Interval  = 1e-4,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {180, 0, 0},
        lineThickness = 2.0,
        fillColor = {255, 235, 235},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-85, 65}, {85, -30}},
        lineColor = {120, 0, 0},
        fillColor = {30, 0, 0},
        fillPattern = FillPattern.Solid),
      Line(points = {{-85, 18}, {85, 18}}, color = {80, 0, 0}),
      Line(points = {{0, 65}, {0, -30}},   color = {80, 0, 0}),
      Line(
        points = {{-82, -15}, {-62, 0}, {-52, 50}, {-45, -22}, {-35, -12},
                  {-20, 5},  {-10, 50}, {-3, -22}, {7, -12},
                  {22, 5},   {32, 50},  {39, -22}, {49, -12}, {82, 10}},
        color = {255, 80, 80},
        thickness = 2.0),
      Text(
        extent = {{-90, -45}, {90, -95}},
        textString = "Step17 Pacemaker",
        textColor = {140, 0, 0},
        fontSize = 11)
    }),
    Diagram(graphics = {
      Text(
        extent = {{-200, 68}, {200, 58}},
        textString = "Step17: Sinoatrial automaticity -- I_ext = 0, spontaneous firing via I_f (HCN)",
        textColor = {80, 80, 80},
        fontSize = 12),
      Text(extent = {{-190, 48}, {-110, 40}}, textString = "I=0 (auto)", textColor = {100, 0, 150}, fontSize = 9),
      Text(extent = {{-90,  48}, {-10, 40}},  textString = "Pipette",    textColor = {100, 80, 0},  fontSize = 9),
      Text(extent = {{10,   48}, {90,  40}},  textString = "Pacemaker",  textColor = {180, 0, 0},   fontSize = 9),
      Text(extent = {{110,  48}, {190, 40}},  textString = "Bath",       textColor = {0, 100, 0},   fontSize = 9),
      Line(points = {{-190, -80}, {190, -80}}, color = {0, 0, 0}, thickness = 2.0),
      Text(extent = {{-50, -72}, {50, -84}}, textString = "GND bus", textColor = {80, 80, 80}, fontSize = 9)
    })
  );
end Step17_PacemakerAutorhythmicity;
