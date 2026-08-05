within PatchClamp.Electrodes;
model AgAgClElectrode "Silver/silver-chloride (Ag/AgCl) electrode -- simplified model"

  parameter Modelica.Units.SI.Voltage V_ref = 0.222
    "Standard Ag/AgCl electrode potential vs. NHE at 25 degC [V]"
    annotation(Dialog(group = "Electrode properties"));

  parameter Real c_Cl(unit = "mol/m3", min = 1.0e-6) = 150.0
    "Cl- concentration at the electrode surface [mM]"
    annotation(Dialog(group = "Solution conditions"));

  parameter Real c_Cl_ref(unit = "mol/m3", min = 1.0e-6) = 150.0
    "Reference (standard-condition) Cl- concentration [mM]"
    annotation(Dialog(group = "Solution conditions"));

  parameter Modelica.Units.SI.Temperature T = PatchClamp.Constants.T_body
    "Solution temperature [K]"
    annotation(Dialog(group = "Solution conditions"));

  parameter Modelica.Units.SI.Resistance R_contact = 10.0
    "Metal-solution contact resistance [Ohm]"
    annotation(Dialog(group = "Electrode properties"));

  PatchClamp.Interfaces.ElectricalPin_p p
    "Electrode's positive terminal (toward the amplifier)"
    annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));

  PatchClamp.Interfaces.ElectricalPin_n n
    "Negative terminal (electrode reference)"
    annotation(Placement(transformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Units.SI.Voltage V_electrode
    "Ag/AgCl half-cell potential, dependent on [Cl-] [V]";

equation
  // Half-cell reaction: AgCl + e- <-> Ag + Cl-. The sign is negative
  // because Cl- is the potential-determining ion.
  V_electrode = V_ref
    - (PatchClamp.Constants.R * T / PatchClamp.Constants.F)
    * Modelica.Math.log(c_Cl / c_Cl_ref);

  p.v - n.v = V_electrode + p.i * R_contact;
  p.i + n.i = 0;

  annotation(
    Documentation(info = "<html>
      <h2>AgAgClElectrode</h2>
      <p>
        Simplified model of the Ag/AgCl electrode, the most common choice
        in patch clamp for converting the solution's ionic current into the
        amplifier's electronic current with low noise and no polarization.
      </p>
      <pre>
  AgCl(s) + e-  &lt;--&gt;  Ag(s) + Cl-(aq)
      </pre>
      <p>
        The reaction is reversible -- current in one direction reduces AgCl
        to Ag, current in the other oxidizes Ag back to AgCl -- which is
        what keeps the electrode from polarizing during the experiment.
        The half-cell (Nernst) potential is:
      </p>
      <pre>
  V_electrode = V_ref - (R*T/F) * ln([Cl-] / [Cl-]_ref)
      </pre>
      <p>
        with V_ref = +0.222 V vs. NHE at 25 degC, and a slope of
        -26.7 mV per decade of [Cl-] at 37 degC.
      </p>
      <p>
        If the pipette and bath solutions have different Cl- concentrations,
        each electrode develops a different potential, contributing to the
        experiment's total offset potential -- hence the usual advice to
        match [Cl-] on both sides, or to correct for the liquid-junction
        potential in the <code>PatchPipette</code> model instead.
      </p>
      <p>
        Worth considering: how does V_electrode change if [Cl-] goes from
        150 mM to 300 mM? Why is Ag/AgCl preferred over bare silver? What
        happens once the electrode's AgCl coating is depleted?
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/AgAgClElectrode.png")
    })
  );
end AgAgClElectrode;
