within PatchClamp.Amplifiers.Compensation;
model CompensatedVClampAmp
  "Voltage-clamp amplifier with integrated C-fast, C-slow, and R_s compensation"

  parameter Modelica.Units.SI.Voltage V_hold = -0.070
    "Holding potential [V] (typical: -70 mV)";

  parameter Modelica.Units.SI.Voltage V_step = -0.050
    "Test step potential [V] (typical: -50 mV)";

  parameter Real t_step_start(unit = "s") = 0.050
    "Start time of the voltage step [s]";

  parameter Real t_step_end(unit = "s") = 0.150
    "End time of the voltage step [s]";

  parameter Modelica.Units.SI.Voltage V_ljp_correction = -11.0e-3
    "LJP correction applied to the command [V] (typical: -11 mV)";

  parameter Modelica.Units.SI.Capacitance C_fast = 3.0e-12
    "Pipette capacitance to compensate [F] (match PatchPipette's C_pipette)"
    annotation(
      Dialog(group = "C-fast compensation"),
      displayUnit = "pF");

  parameter Real frac_fast(min = 0.0, max = 1.0) = 0.0
    "C-fast compensation fraction [0..1] (0 = off, 1 = full)"
    annotation(Dialog(group = "C-fast compensation"));

  parameter Modelica.Units.SI.Capacitance C_slow = 10.0e-12
    "Membrane capacitance to compensate [F] (match the cell's C_m)"
    annotation(
      Dialog(group = "C-slow compensation"),
      displayUnit = "pF");

  parameter Modelica.Units.SI.Resistance R_s_est = 4.0e6
    "Estimated R_s for C-slow compensation [Ohm] (match PatchPipette's R_pipette)"
    annotation(
      Dialog(group = "C-slow compensation"),
      displayUnit = "MOhm");

  parameter Real frac_slow(min = 0.0, max = 1.0) = 0.0
    "C-slow compensation fraction [0..1] (0 = off, 1 = full)"
    annotation(Dialog(group = "C-slow compensation"));

  parameter Modelica.Units.SI.Resistance R_s = 4.0e6
    "Series resistance to compensate [Ohm] (match PatchPipette's R_pipette)"
    annotation(
      Dialog(group = "R_s compensation"),
      displayUnit = "MOhm");

  parameter Real alpha(min = 0.0, max = 0.9) = 0.0
    "R_s compensation fraction [0..0.9] (0 = no correction, 0.9 = stability limit)"
    annotation(Dialog(group = "R_s compensation"));

  parameter Modelica.Units.SI.Time tau_comp = 15.0e-6
    "Time constant of the R_s compensation loop [s] -- the finite bandwidth
     of the correction circuit (5-20 us is typical on real amplifiers).
     Only matters when alpha > 0: without this delay, ideal (infinite
     bandwidth) feedback is unstable for alpha > 0 -- see the note below.
     15 us is the smallest value verified by simulation to stay stable
     across the full declared alpha range (up to 0.9), even with
     frac_fast = frac_slow = 1.0 simultaneously; smaller values (e.g. 10 us)
     can go unstable near alpha = 0.9."
    annotation(Dialog(group = "R_s compensation"));

  PatchClamp.Interfaces.ElectricalPin_p p
    "Amplifier output terminal (connect to PatchPipette.p_amp)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (ground, connect to BathElectrode.n)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  Modelica.Units.SI.Voltage V_m_est(start = -0.065, fixed = true)
    "Internal V_m estimate used for C-slow compensation [V]";

  Modelica.Units.SI.Current I_raw_filt(start = 0.0, fixed = true)
    "Filtered (tau_comp-delayed) version of I_raw, used ONLY in the R_s
     compensation feedback. Breaks the instantaneous algebraic loop
     p.v -> I_raw -> p.v that would otherwise be unstable for alpha > 0
     under ideal infinite-bandwidth feedback.";

  Modelica.Units.SI.Current I_raw "Raw (uncompensated) measured current [A]";

  Modelica.Units.SI.Current I_comp_fast "C-fast compensation current [A]";

  Modelica.Units.SI.Current I_comp_slow "C-slow compensation current [A]";

  Modelica.Units.SI.Current I_measured
    "Total compensated current [A] = I_raw - I_comp_fast - I_comp_slow
     -- the net ionic current, equivalent to what a real amplifier displays";

  Modelica.Units.SI.Voltage V_command
    "Base command voltage applied [V] (before R_s correction)";

  Modelica.Units.SI.Voltage V_error
    "Voltage error from the R_s drop [V] = R_s * I_raw";

  Modelica.Units.SI.Voltage V_m_estimated
    "Estimate of the real membrane potential [V]
     V_m_real = V_command - V_error * (1 - alpha)";

equation
  V_command = (if time < t_step_start or time >= t_step_end
               then V_hold
               else V_step) - V_ljp_correction;

  // With R_s compensation, the amplifier adds alpha * V_error to the
  // command so the cell receives exactly V_command.
  //
  // Note 1 (algebraic loop, alpha = 0): alpha*R_s*I_raw with I_raw = -p.i
  // forms an algebraic loop through the amplifier's own current. At
  // alpha = 0 (the default) that loop's pivot is exactly zero, which
  // leaves the DAE structurally singular for the solver (DASKR reports
  // "ITERATION MATRIX IS SINGULAR" at t=0) even though the term
  // mathematically vanishes. Since alpha is a parameter, not a signal, the
  // "if" below is resolved at compile time -- with alpha = 0 the loop is
  // removed from the generated model entirely, not just zeroed out.
  //
  // Note 2 (instability, alpha > 0): even past that, feeding back the
  // instantaneous, infinite-bandwidth I_raw is unstable for alpha > 0: two
  // capacitive elements in the loop (PatchPipette's C_pipette, plus the
  // cell's C_m) combined with delay-free algebraic feedback produce a
  // singular iteration matrix later in the simulation, not just at t=0.
  // Real R_s-compensation circuits have finite bandwidth by design
  // (time constant tau_comp, typically 5-20 us) precisely to avoid this;
  // this model uses I_raw_filt (the delayed version of I_raw, see the
  // filter equation below) instead of I_raw in the feedback, which breaks
  // the instantaneous algebraic coupling.
  if alpha > 0 then
    p.v - n.v = V_command + alpha * R_s * I_raw_filt;
  else
    p.v - n.v = V_command;
  end if;

  I_raw = -p.i;

  // Finite-bandwidth filter for the R_s compensation feedback loop
  tau_comp * der(I_raw_filt) = I_raw - I_raw_filt;

  I_comp_fast = frac_fast * C_fast * der(p.v - n.v);

  R_s_est * C_slow * der(V_m_est) = (p.v - n.v) - V_m_est;
  I_comp_slow = frac_slow * C_slow * der(V_m_est);

  I_measured = I_raw - I_comp_fast - I_comp_slow;

  V_error = R_s * I_raw;
  V_m_estimated = V_command - V_error * (1.0 - alpha);

  annotation(
    Documentation(info = "<html>
      <h2>CompensatedVClampAmp</h2>
      <p>
        Combines all three amplifier compensations in one block. Every
        compensation is off by default (fractions = 0, alpha = 0), so the
        baseline behavior matches <code>VoltageClampAmplifier</code> exactly.
      </p>

      <h3>Suggested exploration</h3>
      <ol>
        <li>Swap in for <code>VoltageClampAmplifier</code> in an existing example (e.g. <code>Step13_SeriesResistanceCompensation</code>).</li>
        <li>Simulate with every compensation at 0: observe the raw signal with its capacitive transients.</li>
        <li>Set <code>frac_fast = 1.0</code>: the fast C_pipette transient disappears from <code>I_measured</code>.</li>
        <li>Set <code>frac_slow = 1.0</code>: the slow C_m transient disappears, leaving only the active ionic currents.</li>
        <li>Raise <code>alpha</code> from 0 to 0.7-0.8: the voltage error shrinks and channel kinetics sharpen.</li>
      </ol>

      <h3>Signals worth plotting</h3>
      <ul>
        <li><code>I_raw</code> -- the raw current (everything included)</li>
        <li><code>I_comp_fast</code> -- the C_pipette artifact alone</li>
        <li><code>I_comp_slow</code> -- the C_m artifact alone</li>
        <li><code>I_measured</code> -- net (compensated) ionic current</li>
        <li><code>V_error</code> -- voltage error from R_s</li>
        <li><code>V_m_estimated</code> -- best estimate of the real V_m</li>
      </ul>

      <h3>Key parameters</h3>
      <ul>
        <li><b>C_fast</b>: match <code>PatchPipette.C_pipette</code>.</li>
        <li><b>C_slow</b>: match the cell's <code>C_m</code>.</li>
        <li><b>R_s_est</b> and <b>R_s</b>: match <code>PatchPipette.R_pipette</code>.</li>
        <li><b>alpha</b>: 0..0.9; don't exceed 0.9 (instability).</li>
        <li>
          <b>tau_comp</b>: R_s compensation loop bandwidth (5-20 us
          typical), relevant only when alpha &gt; 0; values much larger
          (comparable to tau_slow = R_access*C_m) degrade compensation
          quality.
        </li>
      </ul>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/CompensatedVClampAmp.png")
    })
  );
end CompensatedVClampAmp;
