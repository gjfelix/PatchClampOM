within PatchClamp.Membranes;
model MarkovChannel
  "Ion channel -- 2-state Markov model (Closed <-> Open), unitary conductance"

  parameter Integer z = 1
    "Ion valence (K+->1, Na+->1, Ca2+->2, Cl-->-1)"
    annotation(Dialog(group = "Ion properties"));

  parameter Real c_in(unit = "mol/m3", min = 1e-9) = 140.0
    "Intracellular concentration [mM]
     Typical: K+=140, Na+=10, Ca2+=0.0001, Cl-=10"
    annotation(Dialog(group = "Ion properties"));

  parameter Real c_out(unit = "mol/m3", min = 1e-9) = 5.0
    "Extracellular concentration [mM]
     Typical: K+=5, Na+=145, Ca2+=2, Cl-=110"
    annotation(Dialog(group = "Ion properties"));

  parameter Modelica.Units.SI.Temperature T = PatchClamp.Constants.T_body
    "Temperature [K]  (default: 310.15 K = 37 C)"
    annotation(Dialog(group = "Ion properties"));

  parameter Real gamma(unit = "S") = 100.0e-12
    "Unitary (single-channel) conductance [S]
     Typical: BK K+ ~ 200-300 pS,  Kv ~ 5-20 pS,  Nav ~ 10-25 pS,  AMPA ~ 8-10 pS"
    annotation(Dialog(group = "Channel properties"));

  parameter Integer n_channels(min = 1) = 1
    "Number of identical channels in the patch (1 = true single-channel recording)"
    annotation(Dialog(group = "Channel properties"));

  // 2-state Markov gating kinetics (Boltzmann steady-state + bell-shaped
  // time constant). The gating uses the same formalism as the
  // Morris-Lecar K+ gate:
  //     P_open_inf  = 1 / (1 + exp(-(V_m - V_half)/k_v))   [Boltzmann]
  //     tau_channel = tau_max / cosh((V_m - V_half)/(2*k_v)) [bell-shaped]
  //     dP_open/dt  = (P_open_inf - P_open) / tau_channel
  //
  //   This is equivalent to a 2-state Markov model with:
  //     alpha(V) = P_open_inf(V) / tau_channel(V)      [C -> O opening rate]
  //     beta(V)  = (1 - P_open_inf(V)) / tau_channel(V) [O -> C closing rate]
  //
  parameter Modelica.Units.SI.Voltage V_half = -0.020
    "Half-activation voltage [V]  (voltage where P_open_inf = 0.5)
     Typical: Kv -30 to -10 mV,  BK -20 to +20 mV,  Nav -30 to -20 mV"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Voltage k_v = 0.010
    "Activation slope [V]  (positive -> opens with depolarization;
     negative -> opens with hyperpolarization, e.g. HCN/If channels)
     Typical: 5-15 mV for most voltage-gated channels"
    annotation(Dialog(group = "Gating kinetics"));

  parameter Modelica.Units.SI.Time tau_max = 5.0e-3
    "Maximum gating time constant [s] -- occurs at V = V_half
     (tau decreases symmetrically for voltages away from V_half)
     Typical: fast Nav ~ 0.1-0.5 ms,  Kv ~ 1-10 ms,  HCN ~ 100-300 ms"
    annotation(Dialog(group = "Gating kinetics"));

  PatchClamp.Interfaces.ElectricalPin_p membrane_p
    "Positive electrical pin -- pipette electrode side"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n membrane_n
    "Negative electrical pin -- bath / ground side"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Real P_open(start = 0.0, fixed = true)
    "Channel open probability [0-1]
     (deterministic mean-field: ensemble average over many identical channels)";

  Modelica.Units.SI.Voltage V_m
    "Membrane voltage across the patch [V]  (pipette - bath)";

  Modelica.Units.SI.Voltage E_rev
    "Reversal (Nernst equilibrium) potential [V]
     Computed from c_in, c_out, z, T";

  Modelica.Units.SI.Current i_unitary
    "Single-channel current [A]  = gamma * (V_m - E_rev)
     Ohmic around E_rev; negative = inward (depolarizing for cations)";

  Modelica.Units.SI.Current I_channel
    "Total macroscopic patch current [A]  = P_open * n_channels * i_unitary
     This is what the patch-clamp amplifier measures";

  Real P_open_inf
    "Steady-state open probability -- Boltzmann curve in V_m";

  Modelica.Units.SI.Time tau_channel
    "Instantaneous gating time constant [s] -- bell-shaped, max at V_half";

equation
  V_m = membrane_p.v - membrane_n.v;

  E_rev = PatchClamp.Media.Functions.nernstPotential(T, z, c_out, c_in);

  P_open_inf  = 1.0 / (1.0 + exp(-(V_m - V_half) / k_v));
  tau_channel = tau_max / cosh((V_m - V_half) / (2.0 * k_v));
  der(P_open) = (P_open_inf - P_open) / tau_channel;

  // Ohmic unitary current model: i = gamma * (V_m - E_rev). GHK would be
  // more accurate, but ohmic is the standard convention for reporting gamma.
  i_unitary = gamma * (V_m - E_rev);
  I_channel  = P_open * n_channels * i_unitary;

  membrane_p.i = I_channel;
  membrane_p.i + membrane_n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>MarkovChannel -- 2-State Markov Ion Channel</h2>
      <p>
        Models a membrane patch containing <em>n_channels</em> identical ion
        channels using a <strong>deterministic 2-state Markov scheme</strong>:
      </p>
      <pre>  Closed (C) ↔ Open (O)</pre>

      <h3>Gating kinetics</h3>
      <p>The gate uses a Boltzmann steady-state and a bell-shaped time constant
      (same formalism as the Morris-Lecar K⁺ gate):</p>
      <pre>
  P_open_inf  = 1 / (1 + exp(-(V_m - V_half)/k_v))    [Boltzmann]
  tau_channel = tau_max / cosh((V_m - V_half)/(2·k_v)) [bell-shaped]
  dP_open/dt  = (P_open_inf - P_open) / tau_channel
      </pre>
      <p>This corresponds to 2-state Markov transition rates:</p>
      <pre>
  alpha(V) = P_open_inf(V) / tau(V)       [C → O, opening rate, s⁻¹]
  beta(V)  = (1-P_open_inf(V)) / tau(V)   [O → C, closing rate, s⁻¹]
      </pre>

      <h3>Macroscopic current</h3>
      <pre>
  i_unitary = gamma * (V_m - E_rev)            [single-channel current]
  I_channel = P_open * n_channels * i_unitary  [patch current]
      </pre>
      <p>
        The unitary current uses an <strong>ohmic</strong> model because
        <em>gamma</em> (in pS) is the standard experimentally reported quantity.
        For GHK-shaped single-channel I-V curves, use GHKConductance instead.
      </p>

      <h3>Why deterministic (mean-field)?</h3>
      <p>
        Real ion channels open and close <em>stochastically</em>. This model
        uses the mean-field approximation: <em>P_open</em> is the
        <strong>probability</strong> of being open, equal to the average open
        fraction in a large ensemble. For n_channels = 1, the output is the
        <em>expected</em> current, not a noisy single-channel trace.
        This approach is numerically robust and reveals activation curves,
        reversal potentials, and kinetics without random noise obscuring the physics.
      </p>
      <p>
        To simulate stochastic gating (discrete openings visible in a real
        recording), see <code>PatchClamp.Membranes.StochasticChannel</code>,
        which implements the same alpha(V)/beta(V) rates as a genuine
        discrete-event Markov chain (random per-channel state transitions)
        using only standard OpenModelica facilities -- no stochastic ODE
        solver is required.
      </p>

      <h3>Activation curve parameters</h3>
      <p>
        Set a slow voltage ramp and plot <em>P_open</em> vs <em>V_m</em>
        to measure the activation curve. The result is the Boltzmann function:
      </p>
      <pre>  P_open_inf(V) = 1 / (1 + exp(-(V - V_half)/k_v))</pre>
      <p>
        <em>V_half</em> is the midpoint (50% activation).
        <em>k_v</em> is the slope factor: small k_v = steep activation.
        Negative k_v → channel opens with hyperpolarization (e.g. HCN/If).
      </p>

      <h3>Typical unitary conductances</h3>
      <table border='1'>
        <tr><th>Channel type</th><th>γ (pS)</th><th>V_half (mV)</th><th>tau_max</th></tr>
        <tr><td>BK (large-conductance K⁺)</td><td>200-300</td><td>Ca²⁺-dependent, −20 to +20</td><td>1-5 ms</td></tr>
        <tr><td>SK (small-conductance K⁺)</td><td>10-20</td><td>voltage-independent</td><td>--</td></tr>
        <tr><td>Kv1.x (voltage-gated K⁺)</td><td>8-15</td><td>−20 to −10</td><td>2-10 ms</td></tr>
        <tr><td>Nav1.x (voltage-gated Na⁺)</td><td>10-25</td><td>−35 to −25</td><td>0.1-0.5 ms</td></tr>
        <tr><td>AMPA receptor</td><td>8-10</td><td>ligand-gated</td><td>2-5 ms</td></tr>
        <tr><td>HCN (If, pacemaker)</td><td>1-3</td><td>−80 to −60 (k_v &lt; 0)</td><td>100-300 ms</td></tr>
      </table>

      <h3>Connection to whole-cell models</h3>
      <p>
        In a whole-cell model, the maximum conductance relates to single-channel
        parameters as:
      </p>
      <pre>  g_max [S/m²] = (n_channels / A) * gamma</pre>
      <p>
        where <em>A</em> is membrane area. Setting n_channels = g_max * A / gamma
        in this block reproduces the same macroscopic current as the whole-cell
        Hodgkin-Huxley formulation (when P_open_inf matches the HH gate variable).
      </p>

      <h3>Reference</h3>
      <p>Colquhoun D, Hawkes AG (1981). On the stochastic properties of single ion
      channels. Proc R Soc Lond B 211:205-235.</p>
    </html>"),
    experiment(
      StopTime  = 0.100,
      Interval  = 1e-5,
      Tolerance = 1e-8),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/MarkovChannel.png")
    }),
    Diagram(graphics = {
      // Bilayer
      Rectangle(
        extent = {{-80, 20}, {80, 8}},
        lineColor = {120, 90, 20},
        fillColor = {255, 220, 120},
        fillPattern = FillPattern.Solid),
      Rectangle(
        extent = {{-80, -8}, {80, -20}},
        lineColor = {120, 90, 20},
        fillColor = {255, 220, 120},
        fillPattern = FillPattern.Solid),
      // Pore
      Rectangle(
        extent = {{-10, 28}, {10, -28}},
        lineColor = {0, 110, 60},
        lineThickness = 2.0,
        fillColor = {175, 255, 195},
        fillPattern = FillPattern.Solid),
      // Labels for bilayer faces
      Text(extent = {{-160, 38}, {-20, 28}}, textString = "Extracellular (pipette)", textColor = {80, 80, 80}, fontSize = 9),
      Text(extent = {{-160, -28}, {-20, -38}}, textString = "Intracellular (bath)", textColor = {80, 80, 80}, fontSize = 9),
      // Equations
      Text(extent = {{30, 50}, {160, 40}}, textString = "P_inf = Boltzmann(V_m, V_half, k_v)", textColor = {0, 80, 40}, fontSize = 9),
      Text(extent = {{30, 36}, {160, 26}}, textString = "tau  = tau_max / cosh(...)",           textColor = {0, 80, 40}, fontSize = 9),
      Text(extent = {{30, 22}, {160, 12}}, textString = "dP/dt = (P_inf - P) / tau",            textColor = {0, 80, 40}, fontSize = 9),
      Text(extent = {{30, -12}, {160, -22}},textString = "i = gamma * (V_m - E_rev)",           textColor = {0, 80, 40}, fontSize = 9),
      Text(extent = {{30, -26}, {160, -36}},textString = "I = P_open * n * i",                  textColor = {0, 80, 40}, fontSize = 9)
    })
  );
end MarkovChannel;
