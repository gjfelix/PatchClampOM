within PatchClamp.Examples;
model Step06_HodgkinHuxleyActionPotential
  "Step06: Hodgkin-Huxley neuron action potential under current clamp"

  // ── Circuit components ───────────────────────────────────────────────
  PatchClamp.Amplifiers.CurrentClampAmplifier amplifier(
    I_hold        = 0.0,
    I_pulse       = 30.0e-12,
    t_pulse_start = 0.010,
    t_pulse_end   = 0.015,
    R_bridge      = 4.0e6)
    "Current-clamp amplifier: 30 pA pulse for 5 ms (t=10-15 ms); rheobase ~29 pA"
    annotation(Placement(transformation(extent={{-190,-40},{-110,40}})));

  PatchClamp.Electrodes.PatchPipette pipette(
    R_pipette  = 4.0e6,
    C_pipette  = 3.0e-12,
    V_junction = -11.0e-3)
    "Patch pipette: R=4 MOhm, C=3 pF, LJP=-11 mV"
    annotation(Placement(transformation(extent={{-90,-40},{-10,40}})));

  PatchClamp.Cells.HodgkinHuxleyNeuron neuron(
    C_m     = 10.0e-12,
    A       = 1000.0e-12,
    g_Na_max = 1200.0,
    g_K_max  = 360.0,
    g_L      = 3.0,
    E_Na     = 0.050,
    E_K      = -0.077,
    E_L      = -0.0544)
    "Hodgkin-Huxley neuron: canonical conductances, 6.3 degC equivalent"
    annotation(Placement(transformation(extent={{10,-40},{90,40}})));

  PatchClamp.Electrodes.BathElectrode bath(
    R_bath = 100.0)
    "Bath electrode: reference at 0 V"
    annotation(Placement(transformation(extent={{110,-40},{190,40}})));

equation
  // ── Circuit connections ──────────────────────────────────────────────
  // Amplifier → Pipette
  connect(amplifier.p, pipette.p_amp)
    annotation(Line(points={{-110,0},{-90,0}}, color={0,0,255}));

  // Pipette → Neuron
  connect(pipette.p_cell, neuron.membrane_p)
    annotation(Line(points={{-10,0},{10,0}}, color={0,0,255}));

  // Neuron → Bath electrode
  connect(neuron.membrane_n, bath.p)
    annotation(Line(points={{90,0},{110,0}}, color={0,0,255}));

  // Ground bus: amplifier and bath electrode
  connect(amplifier.n, bath.n)
    annotation(Line(points={{-190,0},{-190,-80},{190,-80},{190,0}}, color={0,0,255}));

  // Pipette ground to the ground bus
  connect(pipette.n, bath.n)
    annotation(Line(points={{-50,-40},{-50,-80},{190,-80},{190,0}}, color={0,0,255}));

  annotation(
    Documentation(info = "<html>
      <h2>Step06 -- Hodgkin-Huxley action potential under current clamp</h2>

      <h3>Learning objective</h3>
      <p>
        Generate and analyze an action potential (AP) in the classic
        Hodgkin-Huxley (1952) model. Understand how injecting a threshold
        current triggers an all-or-nothing response, and how the gating
        variables m, h, and n describe the kinetics of the Na+ and K+
        channels during the AP.
      </p>

      <h3>Protocol</h3>
      <pre>
  t = 0    - 10 ms:  I_command = 0 pA   (rest)
  t = 10   - 15 ms:  I_command = 10 pA  (threshold stimulus)
  t = 15   - 50 ms:  I_command = 0 pA   (observe response)
      </pre>

      <h3>What to observe</h3>
      <ul>
        <li>
          Variables to plot: neuron.V_m (membrane potential in V),
          neuron.m, neuron.h, neuron.n (dimensionless gating variables),
          neuron.I_Na, neuron.I_K (ionic currents in A).
        </li>
        <li>
          Resting potential: V_m = -65 mV (initial condition set by the
          steady-state initial values of m, h, and n).
        </li>
        <li>
          Firing threshold: approximately -55 mV. Below threshold no AP is
          generated; above it a full AP fires.
        </li>
        <li>
          AP sequence: rapid depolarization from Na+ channel opening
          (m rises, h stays high), repolarization from Na+ inactivation
          (h falls) and K+ channel opening (n rises), and a transient
          after-hyperpolarization while K+ closes (n falls).
        </li>
      </ul>

      <h3>Reference values</h3>
      <pre>
  V_rest     = -65 mV
  V_threshold = approx -55 mV
  V_peak     = approx +35 mV
  AP duration = approx 2-3 ms (at 6.3 degC equivalent)
  I_Na peak  = order of nA, well above I_K
      </pre>

      <h3>Discussion questions</h3>
      <ol>
        <li>
          Reduce I_pulse to 5 pA. Does an AP still fire? What about 8 pA?
          This illustrates the all-or-nothing threshold concept.
        </li>
        <li>
          Watch the m variable during depolarization: it is the Na+
          activation gate. Why does it rise so much faster than n?
        </li>
        <li>
          Why is there an after-hyperpolarization following the AP?
          Which channels produce it, and how long does it last?
        </li>
        <li>
          Apply a second pulse at t=30 ms (during the refractory period).
          Does a second AP fire? Why or why not?
        </li>
        <li>
          Increase I_pulse to a sustained 50 pA (remove t_pulse_end).
          How many action potentials are generated? This is called a
          firing train.
        </li>
      </ol>

      <h3>Experimental equivalent</h3>
      <p>
        Replicates the original Hodgkin and Huxley experiment on the squid
        (Loligo) giant axon, adapted here to whole-cell current clamp in a
        generic mammalian cortical-style neuron. The model uses the
        original parameters from Hodgkin and Huxley (1952) J. Physiol.
        117:500-544.
      </p>

      <h3>Reference</h3>
      <p>
        Hodgkin AL, Huxley AF (1952). A quantitative description of membrane
        current and its application to conduction and excitation in nerve.
        J Physiol 117:500-544.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.050,
      Interval  = 1e-5,
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
        textString = "I-clamp",
        textColor = {0,80,160},
        fontSize = 9),
      Text(
        extent = {{-100,60},{30,44}},
        textString = "Pipette",
        textColor = {0,100,0},
        fontSize = 9),
      Text(
        extent = {{10,60},{100,44}},
        textString = "HH Neuron",
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
        lineColor = {0, 80, 160},
        fillColor = {230, 242, 255},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step06",
        textColor = {0, 60, 130},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "HH Action Potential",
        textColor = {0, 80, 160},
        fontSize = 11)
    })
  );
end Step06_HodgkinHuxleyActionPotential;
