within PatchClamp.Cells;
model FitzHughNagumoNeuron
  "FitzHugh-Nagumo neuron (FHN 1961): phenomenological 2D excitability model"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 1e-12,
    A   = 100e-12);
  // C_m = 1 pF (a small phenomenological neuron). With V_scale = 0.05 V and
  // tau_u = 2 ms: I_scale = C_m*V_scale/tau_u = 25 pA/unit. The AP threshold
  // needs about du = 0.4 units; with C_pipette = 0.5 pF
  // (Step14_FitzHughNagumoExcitability) that's roughly 50 pA for a 2 ms pulse.

  // Equations use dimensionless variables (u, w) mapped onto voltage via
  // V_m = V_rest + u * V_scale.
  // Reference: FitzHugh (1961) Biophys J 1:445; Nagumo et al. (1962) Proc IRE 50:2061.

  parameter Modelica.Units.SI.Voltage V_rest = -0.005
    "Voltage offset for u [V], V_m = V_rest + u * V_scale.
     With V_rest = -0.005 and V_scale = 0.05, the FHN equilibrium (u* = -1.2)
     maps to V_m = -0.005 + (-1.2)*0.05 = -0.065 V (the biological resting
     potential). Note: V_rest is not itself a resting potential -- it's the
     offset of the u <-> V_m mapping.";

  parameter Modelica.Units.SI.Voltage V_scale = 0.050
    "Voltage scale for the dimensionless variable u [V], V_m = V_rest + u * V_scale.
     At V_scale = 50 mV: AP peak (u ~ +2) -> ~+95 mV; threshold (u ~ -0.8) ->
     ~-45 mV; undershoot (u ~ -1.5) -> ~-80 mV -- physiologically reasonable amplitudes.";

  parameter Real a = 0.7
    "FHN parameter a [-] (excitability threshold, typical: 0.5-0.9)";

  parameter Real b = 0.8
    "FHN parameter b [-] (recovery rate, typical: 0.6-1.0)";

  parameter Real epsilon = 0.08
    "FHN parameter epsilon [-] (timescale separation, typical: 0.04-0.15);
     smaller values give slower recovery and wider action potentials";

  parameter Real tau_u(unit = "s") = 2.0e-3
    "Time constant of the fast variable u [s] (typical: 1-5 ms)";

  Real u(start = -1.2)
    "Fast dimensionless variable [-] (scaled membrane potential).
     Algebraic: always determined by u = (V_m - V_rest) / V_scale.
     Canonical FHN equilibrium (a=0.7, b=0.8): u* = -1.199 (stable left branch of the cubic).";

  Real w(start = -0.625, fixed = true)
    "Slow recovery variable [-] (inactivation/recovery).
     Initial condition w_eq = (u*+a)/b = (-1.2+0.7)/0.8 = -0.625, the
     canonical FHN equilibrium, which with V_rest = -0.005 sits on the
     cubic's stable left branch.";

  Real I_ext_norm(unit = "1")
    "Normalized external current [-] = membrane_p.i / (V_scale/tau_u * C_m)";

equation
  // PartialExcitableCell already defines V_m = membrane_p.v - membrane_n.v;
  // this imposes the FHN state equation in terms of u
  u = (V_m - V_rest) / V_scale;

  I_ext_norm = membrane_p.i * tau_u / (C_m * V_scale);

  // Canonical FHN fast dynamics: tau_u * du/dt = u - u^3/3 - w + I_ext_norm.
  // Combined with PartialExcitableCell's membrane equation
  // (C_m * dV_m/dt = membrane_p.i - I_total, i.e.
  // C_m*V_scale*du/dt = membrane_p.i - I_total) and the I_ext_norm
  // definition above, solving for I_total gives the bias-free form used
  // here: I_total = C_m*V_scale/tau_u * (w - u + u^3/3).
  I_total = C_m * V_scale / tau_u * (w - u + (u^3) / 3.0);

  der(w) = epsilon * (u + a - b * w) / tau_u;

  annotation(
    Documentation(info = "<html>
      <h2>FitzHughNagumoNeuron</h2>
      <p>
        The FitzHugh-Nagumo (FHN) phenomenological model, a 2D reduction of
        Hodgkin-Huxley -- the simplest model that still captures the
        essential mechanisms of neuronal excitability.
      </p>
      <blockquote>
        FitzHugh R (1961). Impulses and physiological states in theoretical
        models of nerve membrane. <em>Biophys J</em> <b>1</b>: 445-466.<br/>
        Nagumo J et al. (1962). An active pulse transmission line simulating
        nerve axon. <em>Proc IRE</em> <b>50</b>: 2061-2070.
      </blockquote>
      <pre>
  tau_u * du/dt = u - u^3/3 - w + I_ext_norm
  dw/dt = epsilon * (u + a - b*w) / tau_u

  u = (V_m - V_rest) / V_scale                    (fast variable)
  w                                                (slow recovery variable)
  I_ext_norm = I_ext * tau_u / (C_m * V_scale)     (normalized current)
      </pre>
      <p>
        Loosely, <b>u</b> plays the role of Na+-driven depolarization and
        <b>w</b> a combined stand-in for Na+ inactivation and K+ activation
        (HH's h and n gates); small <b>epsilon</b> gives wider spikes and
        longer refractoriness.
      </p>
      <p>
        With no stimulus the system sits at its stable fixed point; a brief
        suprathreshold pulse produces a single excursion (one action
        potential) back to rest; sustained suprathreshold current produces
        repetitive firing whose rate rises with I_ext. Sweeping I_ext near
        threshold reveals a Hopf bifurcation -- contrast with
        <code>SimplifiedNeuron</code> (LIF), whose bifurcation is of SNIC type.
      </p>
      <p>
        Defaults a = 0.7, b = 0.8, epsilon = 0.08, tau_u = 2 ms give a
        threshold around I_ext_norm &#8776; 0.34 and repetitive firing over
        roughly I_ext_norm in [0.34, 1.4].
      </p>
      <p>
        Compared to HH, this model has only 2 ODEs (so the (u, w) phase
        plane is directly visualizable), shows bifurcations by varying a
        single parameter, has no numerical singularities, and simulates
        roughly 10x faster.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/FitzHughNagumoNeuron.png")
    })
  );
end FitzHughNagumoNeuron;
