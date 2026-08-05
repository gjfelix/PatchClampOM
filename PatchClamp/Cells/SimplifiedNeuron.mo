within PatchClamp.Cells;
model SimplifiedNeuron
  "Leaky integrate-and-fire (LIF) neuron with automatic reset"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 10e-12,
    A   = 1000e-12);

  parameter Modelica.Units.SI.Resistance R_m = 10e6
    "Membrane resistance [Ohm] (typical LIF: 10-100 MOhm)";

  parameter Modelica.Units.SI.Voltage V_threshold = -0.055
    "Firing threshold [V] (typical: -55 mV)";

  parameter Modelica.Units.SI.Voltage V_reset = -0.070
    "Reset potential after a spike [V] (typical: -70 mV)";

  parameter Modelica.Units.SI.Voltage V_rest = -0.065
    "Resting potential [V] (typical: -65 mV)";

  Boolean spiking(start = false) "True during a spike event";

equation
  // Ohmic leak current, same form as PassiveCell
  I_total = (V_m - V_rest) / R_m;

  when V_m >= V_threshold then
    reinit(V_m, V_reset);
  end when;

  spiking = V_m >= V_threshold;

  annotation(
    Documentation(info = "<html>
      <h2>SimplifiedNeuron</h2>
      <p>
        A leaky integrate-and-fire neuron -- a quick introduction to
        excitability before tackling the full Hodgkin-Huxley model.
      </p>
      <pre>
  C_m * dV_m/dt = -(V_m - V_rest) / R_m + I_ext

  if V_m &gt;= V_threshold: reinit(V_m, V_reset)
      </pre>
      <p>
        Defaults: R_m = 10 MOhm, V_threshold = -55 mV,
        V_reset = -70 mV (post-spike hyperpolarization), V_rest = -65 mV,
        giving tau_m = R_m * C_m = 10e6 * 10e-12 = 0.1 ms.
      </p>
      <p>
        With no injected current, V_m decays exponentially toward V_rest;
        with enough I_ext, V_m climbs to V_threshold and fires (an instant
        reset to V_reset) -- higher I_ext gives a higher firing rate (the
        f-I relationship). Unlike <code>HodgkinHuxleyNeuron</code>, the LIF
        model reproduces neither the action potential waveform nor
        voltage-gated channel kinetics.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/SimplifiedNeuron.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-90, 85}, {90, 74}},
        textString = "LIF: leaky integrate-and-fire model",
        textColor = {120, 120, 120},
        fontSize = 12),
      Line(points = {{-80, 50}, {-80, -50}}, color = {0, 0, 200}, thickness = 1.5),
      Line(points = {{80, 50}, {80, -50}}, color = {0, 150, 0}, thickness = 1.5),
      Text(
        extent = {{-110, 68}, {-55, 57}},
        textString = "membrane_p",
        textColor = {0, 0, 200},
        fontSize = 9),
      Text(
        extent = {{55, 68}, {110, 57}},
        textString = "membrane_n",
        textColor = {0, 150, 0},
        fontSize = 9),
      // C_m branch (capacitor)
      Line(points = {{-80, 30}, {-10, 30}}, color = {0, 0, 200}),
      Line(points = {{-10, 18}, {-10, 42}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{10, 18}, {10, 42}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{10, 30}, {80, 30}}, color = {0, 150, 0}),
      Text(
        extent = {{-40, 48}, {40, 40}},
        textString = "C_m = 10 pF",
        textColor = {80, 80, 80},
        fontSize = 11),
      // R_m + V_rest battery branch
      Line(points = {{-80, -10}, {-55, -10}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-55, 0}, {-15, -20}},
        lineColor = {80, 80, 80},
        fillColor = {255, 250, 220},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-50, -1}, {-20, -18}},
        textString = "R_m",
        textColor = {80, 80, 80},
        fontSize = 11),
      Line(points = {{-15, -10}, {5, -10}}, color = {80, 80, 80}),
      Line(points = {{5, -4}, {5, -16}}, color = {180, 120, 0}, thickness = 2.5),
      Line(points = {{15, -7}, {15, -13}}, color = {180, 120, 0}, thickness = 1),
      Line(points = {{15, -10}, {80, -10}}, color = {0, 150, 0}),
      Text(
        extent = {{10, 2}, {80, -6}},
        textString = "V_rest = -65 mV",
        textColor = {180, 120, 0},
        fontSize = 9),
      Line(
        points = {{-80, -58}, {80, -58}},
        color = {200, 0, 0},
        pattern = LinePattern.Dash),
      Text(
        extent = {{-78, -52}, {78, -62}},
        textString = "V_threshold = -55 mV  ->  reinit(V_m, V_reset = -70 mV)",
        textColor = {200, 0, 0},
        fontSize = 9)
    })
  );
end SimplifiedNeuron;
