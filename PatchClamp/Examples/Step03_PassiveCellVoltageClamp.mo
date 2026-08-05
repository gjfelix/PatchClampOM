within PatchClamp.Examples;
model Step03_PassiveCellVoltageClamp
  "Passive cell under voltage clamp -- RC response to a voltage step"

  PatchClamp.Amplifiers.VoltageClampAmplifier amplifier(
    V_hold       = -0.070,
    V_step       = -0.050,
    t_step_start = 0.050,
    t_step_end   = 0.150,
    V_ljp_correction = -11.0e-3)
    "Voltage-clamp amplifier: -70 mV -> -50 mV step protocol (100 ms)"
    annotation(Placement(transformation(extent={{-190,-40},{-110,40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    "Patch pipette: R=4 MOhm, C=3 pF, LJP=-11 mV"
    annotation(Placement(transformation(extent={{-90,-40},{-10,40}})));

  PatchClamp.Cells.PassiveCell cell(
    C_m = 10.0e-12,
    R_m = 1.0e9)
    "Passive cell: C_m=10 pF, R_m=1 GOhm, tau=10 ms"
    annotation(Placement(transformation(extent={{10,-40},{90,40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: R=100 Ohm, sets the 0 V reference"
    annotation(Placement(transformation(extent={{110,-40},{190,40}})));

equation
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points={{-110,0},{-90,0}}, color={0,0,255}));

  connect(pipette.p_cell, cell.membrane_p)
    annotation(Line(points={{-10,0},{10,0}}, color={0,0,255}));

  connect(cell.membrane_n, bath.p)
    annotation(Line(points={{90,0},{110,0}}, color={0,0,255}));

  connect(amplifier.n, bath.n)
    annotation(Line(points={{-190,0},{-190,-80},{190,-80},{190,0}}, color={0,0,255}));

  connect(pipette.n, bath.n)
    annotation(Line(points={{-50,-40},{-50,-80},{190,-80},{190,0}}, color={0,0,255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step03 -- Passive cell under voltage clamp</h2>

      <h3>Learning objective</h3>
      <p>
        This example is set in the whole-cell configuration, after the
        patch has already ruptured (see <code>Step01_PipetteSealTest</code>
        and <code>Step02_GigasealFormation</code> for the steps leading up
        to it, and <code>Step04_WholeCellBreakIn</code> for the rupture
        transient itself). The goal here is the electrophysiology
        fundamental: the response of an RC membrane circuit to a
        voltage-clamp step -- the basis for interpreting any current
        recording in a real cell.
      </p>

      <h3>Equivalent circuit</h3>
      <pre>
  Amp.       Pipette         Cell             Bath
  [V-clamp]--[R_pip]------+--[C_m]--+------[R_bath]--GND
              [C_pip]      +--[R_m]--+
      </pre>

      <h3>Protocol</h3>
      <pre>
  t = 0    - 50 ms:   V_command = -70 mV  (holding)
  t = 50   - 150 ms:  V_command = -50 mV  (+20 mV step)
  t = 150  - 200 ms:  V_command = -70 mV  (back to holding)
      </pre>

      <h3>What to look for</h3>
      <ul>
        <li>
          At the step onset (t=50 ms): a ~5 nA capacitive current spike
          decaying with tau_pip = R_pip * C_m = 4 MOhm * 10 pF = 40 us --
          C_m charging through the pipette.
        </li>
        <li>
          Steady state (after the transient): the resistive current
          I_ss = DeltaV / R_m = 20 mV / 1 GOhm = 20 pA -- invisible on an
          nA scale, so switch to pA to see it.
        </li>
        <li>At the step's end (t=150 ms): a symmetric inverse spike (-5 nA).</li>
      </ul>
      <p>
        Note: tau_m = R_m * C_m = 10 ms is the cell's time constant under
        CURRENT clamp (how fast V_m charges under injected current). Under
        voltage clamp, the amplifier forces V_m quickly through R_pip, so
        the transient visible in I_measured reflects tau_pip (40 us), not
        tau_m (10 ms); see the current-clamp examples to observe tau_m directly.
      </p>

      <pre>
  tau_pip = R_pip * C_m = 4e6 * 10e-12 = 40 us  (visible in I_measured)
  tau_m   = R_m   * C_m = 1e9 * 10e-12 = 10 ms  (visible in V_m under current clamp)
  I_ss    = DeltaV / R_m  = 0.020 / 1e9 = 20 pA  (pA scale, after the transient)
  I_peak  = DeltaV / R_pip = 0.020 / 4e6 = 5 nA  (capacitive peak)
      </pre>

      <h3>Questions worth exploring</h3>
      <ol>
        <li>If C_m doubles from 10 pF to 20 pF, how do tau and the capacitive peak change?</li>
        <li>If R_m drops to 100 MOhm, how does the steady-state current change?</li>
        <li>Why is the capacitive current at the step onset so much larger than the steady-state current?</li>
        <li>What does the time constant tau_m = R_m * C_m represent physically?</li>
      </ol>

      <p>
        This replicates a whole-cell voltage-clamp protocol on a
        low-conductance (resting, channel-free) cell model, the same check
        used in practice to verify a cell's electrical parameters before
        starting the real experimental protocol.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.200,
      Interval  = 1e-4,
      Tolerance = 1e-8),
    Diagram(graphics = {
      Line(
        points = {{-190,-80},{190,-80}},
        color = {0,0,255},
        thickness = 0.5),
      Text(
        extent = {{-190,-82},{-120,-96}},
        textString = "GND bus",
        textColor = {0,0,200},
        fontSize = 9),
      Text(
        extent = {{-240,60},{-110,44}},
        textString = "V-clamp",
        textColor = {100,0,150},
        fontSize = 9),
      Text(
        extent = {{-100,60},{30,44}},
        textString = "Pipette",
        textColor = {0,100,0},
        fontSize = 9),
      Text(
        extent = {{10,60},{100,44}},
        textString = "PassiveCell",
        textColor = {0,0,180},
        fontSize = 9),
      Text(
        extent = {{110,60},{200,44}},
        textString = "Bath",
        textColor = {150,80,0},
        fontSize = 9)
    }),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {100, 0, 150},
        fillColor = {248, 240, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step03",
        textColor = {80, 0, 130},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "Passive Cell",
        textColor = {100, 0, 150},
        fontSize = 13)
    })
  );
end Step03_PassiveCellVoltageClamp;
