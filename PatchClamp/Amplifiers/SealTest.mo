within PatchClamp.Amplifiers;
model SealTest
  "Seal-test protocol: repeated square pulse to estimate R_seal and C_m"

  parameter Modelica.Units.SI.Voltage V_pulse = -5.0e-3
    "Test pulse amplitude [V] (typical: -5 mV, small enough not to activate channels)";

  parameter Real t_period(unit = "s") = 0.020
    "Period of the repeated square pulse [s] (typical: 20 ms -> 50 Hz)";

  parameter Real t_pulse_width(unit = "s") = 0.010
    "Active pulse duration [s] (typical: 10 ms, 50% duty cycle)";

  parameter Real t_start(unit = "s") = 0.002
    "Start time of the first pulse [s] (lets the circuit settle first)";

  parameter Modelica.Units.SI.Resistance R_pipette_nom = 4.0e6
    "Nominal pipette resistance [Ohm] (entered manually by the experimenter)";

  // tau_filt is kept deliberately small (2% of the pulse width) relative to
  // the physical transients of interest (>= tens of us in this library's
  // examples). Any first-order filter shows its own exponential relaxation
  // when responding to a step; if tau_filt were large, that filter
  // relaxation would be easy to mistake for a real RC transient of the
  // circuit. With tau_filt small, I_steady tracks I_measured almost
  // immediately, and only acts as a genuine filter in the examples with
  // slower time constants (Step02, Step04).
  parameter Real tau_filt(unit = "s") = t_pulse_width * 0.02
    "Filter time constant used to estimate I_steady [s]";

  PatchClamp.Interfaces.ElectricalPin_p p
    "Output terminal (connect to PatchPipette.p_amp)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference/ground terminal (connect to BathElectrode.n)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  Modelica.Units.SI.Voltage V_command "Instantaneous command voltage [V]";

  Modelica.Units.SI.Current I_measured
    "Current measured at the pipette [A] (positive = out of the amplifier)";

  // I_steady tracks I_measured through a first-order low-pass filter; during
  // the active pulse it converges to the steady-state value, at a rate set
  // by tau_filt.
  Real I_steady(start = 0.0) "Estimated steady-state current [A] (filtered)";

  Real R_seal_est(unit = "Ohm")
    "Estimated seal resistance [Ohm] (= V_pulse / I_steady during the pulse;
     = R_pipette_nom outside the pulse, where V_command = 0 and there is no
     signal to estimate from -- see the note below)";

  Boolean pulse_active
    "True during the active half-cycle (pulse on)";

equation
  pulse_active = (time >= t_start) and
                 (mod(time - t_start, t_period) < t_pulse_width);

  V_command = if pulse_active then V_pulse else 0.0;

  // Ideal voltage source
  p.v - n.v = V_command;

  I_measured = -p.i;

  // First-order estimate of the steady-state current: I_steady ~ I_measured
  // once settled, and lags behind (ignoring) the capacitive transient
  tau_filt * der(I_steady) = I_measured - I_steady;

  // R_seal = V_pulse / I_steady while the pulse is active. Outside the
  // pulse there's no signal to estimate anything from; rather than an
  // out-of-scale sentinel (e.g. 1e12 Ohm, which flattens a linear plot to
  // ~0), hold R_pipette_nom so the trace stays in a plottable range.
  R_seal_est = noEvent(
    if pulse_active and abs(I_steady) > 1e-15 then
      abs(V_pulse / I_steady)
    else
      R_pipette_nom);

  annotation(
    Documentation(info = "<html>
      <h2>SealTest</h2>
      <p>
        Generates a train of low-amplitude square pulses to estimate the
        seal resistance (R_seal) and membrane capacitance (C_m) before or
        after obtaining a whole-cell configuration.
      </p>

      <h3>Equivalent circuit (cell-attached)</h3>
      <pre>
  Amp.          Pipette                Seal
  +------+      +------------------------------+
  |      |--p-->| R_pip ---------------+------- |--> ground
  |  V   |      |                      |        |
  |  cmd |      |      C_pip        R_seal      |
  |      |<-n--+|         |             |       |
  +------+      +------------------------------+

  I_ss   = V_pulse / R_seal    (steady-state current)
  tau    = R_pip * C_pip       (transient time constant)
      </pre>

      <h3>Equivalent circuit (whole-cell)</h3>
      <pre>
  Amp.          Pipette                Cell
  +------+      +------------------------------+
  |      |--p-->| R_pip ---------------+------- |--> ground
  |  V   |      |                      |        |
  |  cmd |      |                   C_m || R_m  |
  |      |<-n--+ +------------------------------+
  +------+

  I_ss   = V_pulse / R_m       (steady-state current)
  tau    = R_pip * C_m         (transient time constant)
      </pre>

      <h3>Protocol</h3>
      <pre>
  t &lt; t_start:          V_command = 0
  t in [0, t_width):     V_command = V_pulse   (pulse active)
  t in [t_width, T):      V_command = 0         (rest)
  ... repeats every T seconds ...
      </pre>

      <h3>Estimating R_seal from a simulation</h3>
      <ol>
        <li>Simulate for 3-4 periods to let the circuit settle.</li>
        <li>Read <code>I_measured</code> near the end of a pulse (t &#8776; t_start + t_width).</li>
        <li>Compute <code>R_seal = V_pulse / I_ss</code>.</li>
        <li>
          <code>R_seal_est</code> automates this with an internal filter
          (time constant <code>tau_filt</code>); outside the pulse it holds
          <code>R_pipette_nom</code> instead of an out-of-scale sentinel, so
          the trace stays plottable.
        </li>
      </ol>

      <h3>Estimating C_pip / C_m from a simulation</h3>
      <p>This model doesn't compute a capacitance automatically -- fit it by hand:</p>
      <ol>
        <li>Read <code>I_measured</code> at the start of a pulse (t = t_start).</li>
        <li>Fit the initial decay to <code>I(t) = I_ss + A*exp(-t/tau)</code>.</li>
        <li>Compute <code>C = tau_fit / R_pipette_nom</code>.</li>
        <li>
          This only works if there's a capacitance downstream of
          <code>R_pipette</code> (e.g. the cell's C_m, Step03 onward). With
          the amplifier connected to a free bath and no cell (Step01) there
          is no transient to fit -- see
          <code>Step01_PipetteSealTest</code>.
        </li>
      </ol>

      <h3>Typical acceptance criteria</h3>
      <pre>
  R_seal  &gt;  1 GOhm   -> acceptable seal for whole-cell
  R_seal  &gt;  5 GOhm   -> excellent (gigaohm) seal
  C_pip   ~  2-5 pF   -> typical borosilicate pipette capacitance
  C_m     ~  5-20 pF  -> typical cell membrane capacitance
      </pre>

      <h3>Recommended parameters</h3>
      <pre>
  V_pulse = -5 mV,  t_period = 20 ms,  t_pulse_width = 10 ms
  R_pipette_nom = 4 MOhm  (read from the pipette's label)
      </pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/SealTest.png")
    }),
    experiment(
      StopTime = 0.1,
      Interval = 1e-5,
      Tolerance = 1e-8)
  );
end SealTest;
