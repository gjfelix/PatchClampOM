within PatchClamp.Electrodes;
model PatchPipette "Glass patch pipette (R_pip + C_pip + liquid-junction correction)"

  parameter Modelica.Units.SI.Resistance R_pipette = 4.0e6
    "Pipette tip resistance [Ohm] (typical: 3-5 MOhm for whole-cell)"
    annotation(
      Dialog(group = "Pipette properties"),
      displayUnit = "MOhm");

  parameter Modelica.Units.SI.Capacitance C_pipette = 3.0e-12
    "Glass wall capacitance [F] (typical: 2-5 pF)"
    annotation(
      Dialog(group = "Pipette properties"),
      displayUnit = "pF");

  parameter Modelica.Units.SI.Voltage V_junction = -11.0e-3
    "Liquid-junction potential (LJP) [V] (typical: -11 mV, internal KCl / external ACSF)"
    annotation(
      Dialog(group = "LJP correction"),
      displayUnit = "mV");

  PatchClamp.Interfaces.ElectricalPin_p p_amp
    "Amplifier terminal (command signal)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_p p_cell
    "Cell terminal (pipette tip)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Reference terminal (shared ground)"
    annotation(Placement(transformation(extent = {{-10, -110}, {10, -90}})));

protected
  Modelica.Units.SI.Voltage V_node
    "Voltage at the pipette's internal node (after LJP) [V]";

  Modelica.Units.SI.Current i_R "Current through R_pipette [A]";
  Modelica.Units.SI.Current i_C "Current through C_pipette [A]";

equation
  // LJP correction: the voltage the cell sees includes the junction offset
  V_node = p_amp.v + V_junction;

  i_R = (V_node - p_cell.v) / R_pipette;

  // C_pipette in parallel with R_pipette produces the capacitive transient
  // on voltage steps
  i_C = C_pipette * der(V_node - n.v);

  p_amp.i  = i_R + i_C;
  p_cell.i = -i_R;
  n.i      = -i_C;

initial equation
  // Start the pipette capacitor at steady state. Without this, V_node
  // defaults to 0 V while p_cell.v = V_m (resting) ~ -65 mV; that mismatch
  // injects i_R = (0 - (-0.065)) / R_pipette ~ 16 nA at t=0, triggering a
  // spurious action potential regardless of I_pulse. V_node = p_cell.v
  // gives zero resistive drop at t=0 (valid when I_hold = 0).
  V_node = p_cell.v;

  annotation(
    Documentation(info = "<html>
      <h2>PatchPipette</h2>
      <p>
        Models the electrical behavior of the borosilicate pipette that
        interfaces the amplifier with the cell.
      </p>
      <pre>
  p_amp ----+---- R_pipette ---- p_cell
            |
         C_pipette
            |
            n (ground)
      </pre>
      <ul>
        <li>
          <b>R_pipette</b> -- series resistance set by the glass tip diameter
          (4 MOhm is typical for whole-cell recording in neurons); it
          contributes to the series-resistance voltage error, V_error = I_m * R_pip.
        </li>
        <li>
          <b>C_pipette</b> -- wall capacitance of the glass submerged in the
          bath, producing a transient current at the start of each voltage
          step; can be reduced by coating the pipette with Sylgard.
        </li>
        <li>
          <b>V_junction</b> -- liquid-junction potential between the pipette
          and bath solutions (typically -11 mV for internal KCl / external
          ACSF), corrected by adding it to the command voltage.
        </li>
      </ul>
      <p>
        Questions worth exploring: how does R_pipette affect the speed of
        the voltage clamp? What shape does the C_pipette transient take on a
        voltage step? Why does correcting the LJP matter for measuring
        reversal potentials?
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PatchPipette.png")
    })
  );
end PatchPipette;
