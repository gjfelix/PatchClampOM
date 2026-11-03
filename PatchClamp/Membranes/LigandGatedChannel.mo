within PatchClamp.Membranes;
model LigandGatedChannel
  "Membrane patch with STOCHASTIC ligand-gated channels (2-state Markov, agonist-dependent opening)"

  // Ligand-gated counterpart of StochasticChannel. Opening is driven by the
  // agonist concentration c_L(t), NOT by membrane voltage:
  //
  //     C  <==>  O      k_open = k_close * (c_L/EC50)^n_hill      (C -> O)
  //                     k_close                                    (O -> C)
  //
  // so the steady-state open probability is the Hill equation
  //     P_open_inf = c_L^n / (c_L^n + EC50^n)
  // and the relaxation time constant is tau = 1/(k_open + k_close).
  //
  // The agonist is applied as a rectangular pulse (a fast-perfusion
  // "concentration jump" on an outside-out patch). The ensemble-average
  // P_open_mean(t) is integrated alongside as an ODE, so the discrete
  // stochastic trace and its mean-field limit can be overlaid.

  parameter Integer n_channels(min = 1) = 1
    "Number of INDEPENDENT channels in the patch (1 = true single-channel recording)"
    annotation(Dialog(group = "Channel properties"));

  parameter Real gamma(unit = "S") = 30.0e-12
    "Unitary conductance [S]  (typical nonselective cation channel: 30-60 pS)"
    annotation(Dialog(group = "Channel properties"));

  parameter Modelica.Units.SI.Voltage E_rev = 0.0
    "Reversal potential [V]  (0 V = nonselective cation channel, e.g. nAChR, AMPA, 5-HT3)"
    annotation(Dialog(group = "Channel properties"));

  parameter Real EC50(unit = "mol/m3", min = 1e-12) = 0.010
    "Agonist concentration for half-maximal P_open [mM]  (0.010 mM = 10 uM)"
    annotation(Dialog(group = "Ligand binding"));

  parameter Real n_hill(min = 0.1) = 2.0
    "Hill coefficient (number of cooperative agonist binding sites)"
    annotation(Dialog(group = "Ligand binding"));

  parameter Real k_close(unit = "1/s", min = 1e-3) = 200.0
    "Closing rate O -> C [1/s]  (mean open time = 1/k_close = 5 ms by default)"
    annotation(Dialog(group = "Ligand binding"));

  parameter Real c_agonist(unit = "mol/m3", min = 0) = 0.030
    "Agonist concentration during the pulse [mM]  (0.030 mM = 30 uM)"
    annotation(Dialog(group = "Agonist application"));

  parameter Modelica.Units.SI.Time t_agonist_on = 0.050
    "Time at which the agonist pulse starts [s]"
    annotation(Dialog(group = "Agonist application"));

  parameter Modelica.Units.SI.Time t_agonist_off = 0.200
    "Time at which the agonist pulse ends [s]"
    annotation(Dialog(group = "Agonist application"));

  parameter Modelica.Units.SI.Time dt = 5.0e-5
    "Sampling period for the stochastic state update [s]
     (must satisfy k_open*dt << 1 at the highest concentration used)"
    annotation(Dialog(group = "Stochastic simulation"));

  parameter Boolean useAutomaticSeed = false
    "= false: reproducible sequence (fixedSeed); = true: seed from OS (different trace every run)"
    annotation(Dialog(group = "Stochastic simulation"));

  parameter Integer fixedSeed = 1
    "Seed used when useAutomaticSeed = false"
    annotation(Dialog(group = "Stochastic simulation"));

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Positive pin -- pipette electrode (command voltage)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Negative pin -- bath electrode (ground reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

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

  Real c_L(unit = "mol/m3") "Agonist concentration at the patch [mM]";

  Real k_open(unit = "1/s") "Agonist-dependent opening rate C -> O [1/s]";

  Real P_open_inf "Steady-state open probability at the current c_L (Hill equation)";

  Real P_open_mean(start = 0, fixed = true)
    "Ensemble-average open probability (deterministic ODE) -- the smooth curve the stochastic trace fluctuates around";

  Boolean isOpen[n_channels](each start = false, each fixed = true)
    "True/false open state of each individual channel";

  Modelica.Units.SI.Current i_unitary
    "Single-channel current when open [A]: gamma*(V_m - E_rev)";

  Modelica.Units.SI.Current I_patch
    "Total patch current [A] (discrete steps when n_channels is small)";

  Modelica.Units.SI.Current I_mean
    "Mean-field patch current [A] = n_channels * i_unitary * P_open_mean";

  Integer nOpenChannels(start = 0, fixed = true)
    "Number of channels currently open [0..n_channels]";

equation
  V_m = membrane_p.v - membrane_n.v;

  c_L = if time >= t_agonist_on and time < t_agonist_off then c_agonist else 0;

  k_open     = k_close * (c_L / EC50) ^ n_hill;
  P_open_inf = k_open / (k_open + k_close);

  der(P_open_mean) = k_open * (1 - P_open_mean) - k_close * P_open_mean;

  // Exact discrete-time transition probabilities of a 2-state Markov chain
  for i in 1:n_channels loop
    when sample(0, dt) then
      isOpen[i] = if pre(isOpen[i])
        then not (draw[i].y < 1 - exp(-k_close * dt))
        else      (draw[i].y < 1 - exp(-k_open * dt));
    end when;
  end for;

  i_unitary = gamma * (V_m - E_rev);
  I_patch   = sum(if isOpen[i] then i_unitary else 0 for i in 1:n_channels);
  I_mean    = n_channels * i_unitary * P_open_mean;
  nOpenChannels = sum(if isOpen[i] then 1 else 0 for i in 1:n_channels);

  membrane_p.i = I_patch;
  membrane_p.i + membrane_n.i = 0;

  assert(k_close * dt <= 0.1, "LigandGatedChannel: dt should satisfy k_close*dt <= 0.1. Reduce dt.", AssertionLevel.warning);

  annotation(
    Documentation(info = "<html>
      <h2>LigandGatedChannel — Stochastic Ligand-Gated Channel Patch</h2>
      <p>
        Two-state (closed/open) Markov channel whose opening rate depends on the
        <em>agonist concentration</em> instead of membrane voltage:
      </p>
      <pre>
  k_open  = k_close * (c_L/EC50)^n_hill     [C -> O, s^-1]
  k_close = constant                         [O -> C, s^-1]
  P_open_inf = c_L^n / (c_L^n + EC50^n)      [Hill equation]
  tau        = 1 / (k_open + k_close)
      </pre>
      <p>
        The agonist is applied as a rectangular pulse between <em>t_agonist_on</em>
        and <em>t_agonist_off</em>, mimicking a fast-perfusion concentration jump
        on an outside-out patch. Unlike a voltage-gated channel, the channel is
        silent at any voltage until the ligand arrives, and closes again
        (deactivation) when it is removed.
      </p>
      <p>
        Each channel is updated every <em>dt</em> with the exact transition
        probabilities 1-exp(-k*dt). The ensemble-average <em>P_open_mean</em> is
        integrated as an ODE and gives the smooth mean-field current
        <em>I_mean</em>, which <em>I_patch</em> fluctuates around.
      </p>
      <p>
        Note: this simple model has no desensitization. Real ligand-gated channels
        (nAChR, AMPA, GABA-A) typically show a decaying current during sustained
        agonist application.
      </p>
    </html>"),
    experiment(
      StopTime  = 0.300,
      Interval  = 5e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/LigandStochasticChannel.png")
    }),
    Diagram(graphics = {
      Rectangle(extent = {{-80, 20}, {80, 8}}, lineColor = {20, 110, 60}, fillColor = {170, 220, 185}, fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-80, -8}, {80, -20}}, lineColor = {20, 110, 60}, fillColor = {170, 220, 185}, fillPattern = FillPattern.Solid),
      Ellipse(extent = {{-8, 44}, {8, 28}}, lineColor = {200, 60, 20}, fillColor = {255, 170, 120}, fillPattern = FillPattern.Solid),
      Text(extent = {{30, 50}, {160, 40}}, textString = "k_open = k_close*(c_L/EC50)^n", textColor = {20, 110, 60}, fontSize = 9),
      Text(extent = {{30, -12}, {160, -22}}, textString = "I_patch = sum(isOpen[i] * gamma*(V_m-E_rev))", textColor = {20, 110, 60}, fontSize = 9)
    })
  );
end LigandGatedChannel;
