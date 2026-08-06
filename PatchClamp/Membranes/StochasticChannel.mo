within PatchClamp.Membranes;
model StochasticChannel
  "Membrane patch with STOCHASTIC gating (discrete 2-state Markov) -- config: on-cell, inside-out, outside-out"

  // The stochastic counterpart of SingleChannelPatch: instead of solving an
  // ODE for the ensemble-average open probability P_open(t), each channel
  // opens and closes at random, at a per-step probability derived from the
  // same alpha(V)/beta(V) rates used in MarkovChannel and SingleChannelPatch.
  // Same three patch configurations as SingleChannelPatch (config 1/2/3 =
  // on-cell/inside-out/outside-out).

  parameter Integer config(min = 1, max = 3) = 1
    "Patch configuration:  1 = OnCell   2 = InsideOut   3 = OutsideOut"
    annotation(Dialog(group = "Patch configuration"));

  parameter Real c_pipette(unit = "mol/m3", min = 1e-9) = 5.0
    "Ion concentration in PIPETTE solution [mM]"
    annotation(Dialog(group = "Solution concentrations"));

  parameter Real c_bath(unit = "mol/m3", min = 1e-9) = 5.0
    "Ion concentration in BATH solution [mM]"
    annotation(Dialog(group = "Solution concentrations"));

  parameter Real c_cell_native(unit = "mol/m3", min = 1e-9) = 140.0
    "Native INTRACELLULAR concentration in the intact cell [mM] (on-cell mode only)"
    annotation(Dialog(group = "Solution concentrations"));

  parameter Integer z = 1
    "Ion valence with sign  (K+->1, Na+->1, Ca2+->2, Cl-->-1)"
    annotation(Dialog(group = "Ion properties"));

  parameter Modelica.Units.SI.Temperature T = PatchClamp.Constants.T_body
    "Temperature [K]  (default: 310.15 K = 37 C)"
    annotation(Dialog(group = "Ion properties"));

  parameter Real gamma(unit = "S") = 100.0e-12
    "Unitary (single-channel) conductance [S]"
    annotation(Dialog(group = "Channel properties"));

  parameter Integer n_channels(min = 1) = 1
    "Number of INDEPENDENT stochastic channels in the patch
     (use 1 for a true single-channel recording; higher values let students
     see the macroscopic current emerge as the law of large numbers).
     Validated up to n_channels ~ 20-50: at larger counts the simultaneous
     discrete state updates combined with a voltage-clamp feedback loop can
     overload the nonlinear solver. For n_channels beyond ~50, use
     SingleChannelPatch (deterministic mean-field) instead -- that is
     precisely the regime where the mean-field approximation is accurate
     and the stochastic detail is no longer the pedagogical point."
    annotation(Dialog(group = "Channel properties"));

  // Same Boltzmann gating formula as SingleChannelPatch
  parameter Modelica.Units.SI.Voltage V_half = -0.020
    "Intrinsic half-activation voltage [V] (before ligand shift)"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Voltage k_v = 0.010
    "Activation slope factor [V]"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Time tau_max = 5.0e-3
    "Maximum gating time constant [s] -- at V = V_half + delta_V_half"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Voltage delta_V_half = 0.0
    "Ligand-induced shift of V_half [V] (see SingleChannelPatch for examples)"
    annotation(Dialog(group = "Ligand modulation"));

  parameter Modelica.Units.SI.Time dt = 5.0e-5
    "Sampling period for the stochastic state update [s].
     Must be much smaller than tau(V) for an accurate discrete-time
     approximation of the continuous-time Markov process (rule of thumb:
     dt <= tau_max / 10). Smaller dt = more accurate but slower simulation."
    annotation(Dialog(group = "Stochastic simulation"));

  parameter Boolean useAutomaticSeed = false
    "= false: reproducible sequence (fixedSeed below); = true: seed from OS
     (different random trace every run -- use once results are understood)"
    annotation(Dialog(group = "Stochastic simulation"));

  parameter Integer fixedSeed = 1
    "Seed used when useAutomaticSeed = false (change to get a different,
     still-reproducible random trace)"
    annotation(Dialog(group = "Stochastic simulation"));

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Positive pin -- pipette electrode (command voltage)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Negative pin -- bath electrode (ground reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  // Self-contained random number generation
  inner Modelica.Blocks.Noise.GlobalSeed globalSeed(
    useAutomaticSeed = useAutomaticSeed,
    fixedSeed        = fixedSeed);

  Modelica.Blocks.Noise.UniformNoise draw[n_channels](
    each samplePeriod = dt,
    each y_min = 0,
    each y_max = 1)
    "One independent uniform[0,1] random draw per channel, every dt";

  Modelica.Units.SI.Voltage V_m
    "Membrane voltage across the patch [V] (pipette - bath)";

  Modelica.Units.SI.Voltage E_rev
    "Ion reversal (Nernst) potential [V]";

  Modelica.Units.SI.Voltage V_half_eff
    "Effective half-activation voltage including ligand shift [V]";

  Real P_open_inf
    "Steady-state open probability -- Boltzmann function of V_m (same for every channel)";

  Modelica.Units.SI.Time tau_channel
    "Instantaneous gating time constant [s]";

  Real alpha(unit = "1/s") "Opening rate C -> O";
  Real beta(unit = "1/s")  "Closing rate O -> C";

  Boolean isOpen[n_channels](each start = false, each fixed = true)
    "True/false open state of each individual channel (the stochastic event)";

  Modelica.Units.SI.Current i_unitary[n_channels]
    "Per-channel current [A]: gamma*(V_m - E_rev) when open, 0 when closed";

  Modelica.Units.SI.Current I_patch
    "Total patch current [A] = sum of the (0/1)*i_unitary of every channel
     -- this is what a real amplifier would measure: discrete steps, not a
     smooth curve, when n_channels is small";

  Integer nOpenChannels(start = 0, fixed = true)
    "Number of channels currently open [0..n_channels] -- useful for
     amplitude-histogram-style teaching exercises";

  Real c_in_eff(unit  = "mol/m3") "Effective intracellular-face concentration [mM]";
  Real c_out_eff(unit = "mol/m3") "Effective extracellular-face concentration [mM]";

equation
  V_m = membrane_p.v - membrane_n.v;

  // Concentration assignment by configuration, same as SingleChannelPatch
  if config == 1 then
    c_in_eff  = c_cell_native;
    c_out_eff = c_pipette;
  elseif config == 2 then
    c_in_eff  = c_bath;
    c_out_eff = c_pipette;
  else
    c_in_eff  = c_pipette;
    c_out_eff = c_bath;
  end if;

  E_rev = PatchClamp.Media.Functions.nernstPotential(T, z, c_out_eff, c_in_eff);

  V_half_eff = V_half + delta_V_half;

  // Transition rates, same formalism as MarkovChannel/SingleChannelPatch
  P_open_inf  = 1.0 / (1.0 + exp(-(V_m - V_half_eff) / k_v));
  tau_channel = tau_max / cosh((V_m - V_half_eff) / (2.0 * k_v));
  alpha = P_open_inf / tau_channel;
  beta  = (1.0 - P_open_inf) / tau_channel;

  // Stochastic update: an independent 2-state Markov chain per channel
  for i in 1:n_channels loop
    when sample(0, dt) then
      isOpen[i] = if pre(isOpen[i])
        then not (draw[i].y < beta * dt)
        else      (draw[i].y < alpha * dt);
    end when;
    i_unitary[i] = if isOpen[i] then gamma * (V_m - E_rev) else 0;
  end for;

  I_patch = sum(i_unitary);
  nOpenChannels = sum(if isOpen[i] then 1 else 0 for i in 1:n_channels);

  membrane_p.i = I_patch;
  membrane_p.i + membrane_n.i = 0;

  assert(dt <= tau_max / 10, "StochasticChannel: dt should be at most tau_max/10 for an accurate discrete-time approximation of the continuous Markov process. Reduce dt or increase tau_max.", AssertionLevel.warning);

  annotation(
    Documentation(info = "<html>
      <h2>StochasticChannel -- Stochastic Single-Channel Patch</h2>
      <p>
        Stochastic counterpart of <code>SingleChannelPatch</code>. Instead of solving
        an ODE for the ensemble-average open probability <em>P_open(t)</em>, each of
        the <em>n_channels</em> independent channels flips randomly between closed
        and open at every sampling instant, with a per-step probability derived from
        the same voltage-dependent rates used throughout the <code>Membranes</code>
        package:
      </p>
      <pre>
  P_open_inf(V) = 1 / (1 + exp(-(V - V_half_eff)/k_v))     [Boltzmann]
  tau(V)        = tau_max / cosh((V - V_half_eff)/(2*k_v)) [bell-shaped]
  alpha(V)      = P_open_inf(V) / tau(V)                   [C -> O rate, s^-1]
  beta(V)       = (1 - P_open_inf(V)) / tau(V)              [O -> C rate, s^-1]
      </pre>
      <p>
        At every sampling period <em>dt</em>, a uniform random draw decides whether
        each channel switches state, with probability <em>alpha*dt</em> (if closed)
        or <em>beta*dt</em> (if open). This is the standard discrete-time
        approximation of a continuous-time 2-state Markov chain, valid whenever
        <em>dt &lt;&lt; tau(V)</em> (a warning fires if dt exceeds tau_max/10).
      </p>

      <h3>Why this needs no special solver</h3>
      <p>
        A common misconception is that stochastic channel gating requires a
        stochastic differential equation (SDE) solver, unavailable in standard
        OpenModelica. In fact, only two standard ingredients are needed, both
        present in the Modelica Standard Library: (1) <code>Modelica.Blocks.Noise</code>
        for reproducible random numbers, and (2) discrete-event <code>when sample(...)</code>
        constructs, part of the Modelica language itself. No SDE integrator is
        involved -- this is an ordinary discrete-event (hybrid) simulation, the same
        mechanism used for sampled-data control systems.
      </p>

      <h3>What you see with n_channels = 1</h3>
      <p>
        <em>I_patch</em> becomes a genuine single-channel trace: rectangular jumps
        between 0 and <em>i_unitary</em>, with random dwell times, exactly like a
        real excised-patch or cell-attached recording. Compare this trace with
        <code>SingleChannelPatch</code> under identical parameters: that model shows
        the smooth <em>average</em> this stochastic trace fluctuates around.
      </p>
      <h3>What you see with larger n_channels</h3>
      <p>
        As <em>n_channels</em> increases, <em>I_patch</em> increasingly resembles the
        smooth macroscopic current of <code>SingleChannelPatch</code> / <code>MarkovChannel</code>
        -- a direct, hands-on demonstration of the law of large numbers linking
        single-channel and whole-cell (mean-field) descriptions.
      </p>

      <h3>Patch configurations</h3>
      <p>Identical semantics to <code>SingleChannelPatch</code>: config=1 On-cell,
      config=2 Inside-out, config=3 Outside-out. See that model's documentation
      for the full solution-assignment table and ligand-modulation examples
      (delta_V_half).</p>

      <h3>Reproducibility</h3>
      <p>
        By default (<em>useAutomaticSeed = false</em>), every run with the same
        <em>fixedSeed</em> produces the identical random trace -- important so that
        students can compare their simulation results against expected values.
        Change <em>fixedSeed</em> to see a different (but still reproducible)
        realization of the same stochastic process.
      </p>

      <h3>Relationship to MarkovChannel and SingleChannelPatch</h3>
      <p>
        All three models share the same alpha(V)/beta(V) gating formalism. Use
        <code>MarkovChannel</code> for the simplest deterministic building block,
        <code>SingleChannelPatch</code> to teach the three patch configurations and
        ligand modulation with a smooth, easy-to-read mean-field trace, and
        <code>StochasticChannel</code> when the pedagogical goal is specifically to
        observe discrete channel-gating events and connect them to real
        single-channel amplitude histograms.
      </p>

      <h3>References</h3>
      <ul>
        <li>Colquhoun D, Hawkes AG (1981). On the stochastic properties of single ion
        channels. Proc R Soc Lond B 211:205-235.</li>
        <li>Hamill OP et al. (1981). Improved patch-clamp techniques for
        high-resolution current recording from cells and cell-free membrane
        patches. Pflugers Arch 391:85-100.</li>
      </ul>
    </html>"),
    experiment(
      StopTime  = 0.200,
      Interval  = 5e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/StochasticChannel.png")
    }),
    Diagram(graphics = {
      Rectangle(extent = {{-80, 20}, {80, 8}}, lineColor = {120, 90, 20}, fillColor = {255, 220, 120}, fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-80, -8}, {80, -20}}, lineColor = {120, 90, 20}, fillColor = {255, 220, 120}, fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-10, 28}, {10, -28}}, lineColor = {160, 60, 0}, lineThickness = 2.0, fillColor = {255, 200, 175}, fillPattern = FillPattern.Solid),
      Text(extent = {{-160, 38}, {-20, 28}}, textString = "Extracellular (pipette)", textColor = {80, 80, 80}, fontSize = 9),
      Text(extent = {{-160, -28}, {-20, -38}}, textString = "Intracellular (bath)", textColor = {80, 80, 80}, fontSize = 9),
      Text(extent = {{30, 50}, {160, 40}}, textString = "alpha(V) = P_inf/tau, beta(V) = (1-P_inf)/tau", textColor = {140, 50, 0}, fontSize = 9),
      Text(extent = {{30, 36}, {160, 26}}, textString = "when sample(0,dt): random flip per channel", textColor = {140, 50, 0}, fontSize = 9),
      Text(extent = {{30, -12}, {160, -22}}, textString = "I_patch = sum(isOpen[i] * gamma*(V_m-E_rev))", textColor = {140, 50, 0}, fontSize = 9)
    })
  );
end StochasticChannel;
