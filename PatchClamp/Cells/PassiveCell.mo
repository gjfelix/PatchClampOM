within PatchClamp.Cells;
model PassiveCell "Passive cell: parallel RC membrane circuit (R_m || C_m)"
  extends PatchClamp.Cells.Interfaces.PartialExcitableCell(
    C_m = 10e-12,
    A   = 1000e-12,
    V_m(fixed = false));
  // fixed=false: in voltage clamp the amplifier sets V_m at t=0; in current
  // clamp the solver falls back to start=-0.065 as the initial condition.

  parameter Modelica.Units.SI.Resistance R_m = 1e9
    "Membrane resistance [Ohm] (typical: 1 GOhm for a sealed cell)";

  parameter Modelica.Units.SI.Voltage E_L = -0.065
    "Leak reversal potential [V] (resting potential, -65 mV)";

equation
  // Ohmic leak current toward E_L: I_total = 0 when V_m = E_L, so
  // equilibrium sits at V_m = -65 mV, not 0 V
  I_total = (V_m - E_L) / R_m;

  annotation(
    Documentation(info = "<html>
      <h2>PassiveCell</h2>
      <p>Membrane modeled as C_m and R_m in parallel between membrane_p and membrane_n.</p>
      <p>
        The starting point for learning voltage clamp: a voltage step
        produces the characteristic transient capacitive current.
      </p>
      <p>
        Default C_m = 10 pF (a small neuron) and R_m = 1 GOhm (whole-cell
        with a gigaohm seal). The state equation is:
      </p>
      <pre>  C_m * dV_m/dt = I_ext - (V_m - E_L) / R_m</pre>
      <p>
        Equilibrium (I_ext = 0, dV_m/dt = 0) is at V_m = E_L = -65 mV -- the
        ionic current is proportional to the deviation from E_L, not from
        0 V. The membrane time constant is
        tau_m = R_m * C_m = 1e9 * 10e-12 = 10 ms.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PassiveCell.png")
    }),
    Diagram(graphics = {
      Text(
        extent = {{-90, 85}, {90, 74}},
        textString = "Passive RC membrane circuit",
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
      // R_m branch
      Line(points = {{-80, 25}, {-50, 25}}, color = {0, 0, 200}),
      Rectangle(
        extent = {{-50, 35}, {50, 15}},
        lineColor = {80, 80, 80},
        fillColor = {255, 250, 220},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-45, 33}, {45, 17}},
        textString = "R_m = 1 GOhm",
        textColor = {80, 80, 80},
        fontSize = 11),
      Line(points = {{50, 25}, {80, 25}}, color = {0, 150, 0}),
      // C_m branch (capacitor symbol)
      Line(points = {{-80, -25}, {-10, -25}}, color = {0, 0, 200}),
      Line(points = {{-10, -13}, {-10, -37}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{10, -13}, {10, -37}}, color = {80, 80, 80}, thickness = 3),
      Line(points = {{10, -25}, {80, -25}}, color = {0, 150, 0}),
      Text(
        extent = {{-40, -10}, {40, -18}},
        textString = "C_m = 10 pF",
        textColor = {80, 80, 80},
        fontSize = 11)
    })
  );
end PassiveCell;
