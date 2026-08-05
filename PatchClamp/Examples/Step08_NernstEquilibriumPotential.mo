within PatchClamp.Examples;
model Step08_NernstEquilibriumPotential
  "Nernst equilibrium potential as a function of extracellular [K+]"

  parameter Real K_out(unit = "mol/m3", min = 0.5) = 5.0
    "Extracellular K+ concentration [mM] -- sweep 1 to 150 mM for the curve"
    annotation(Dialog(group = "Sweep: extracellular [K+]"));

  parameter Real K_in(unit = "mol/m3")   = 140.0
    "Intracellular K+ concentration [mM] (typical pipette-filling value)"
    annotation(Dialog(group = "Intracellular solution (fixed)"));
  parameter Real Na_in(unit = "mol/m3")  = 10.0
    "Intracellular Na+ concentration [mM]"
    annotation(Dialog(group = "Intracellular solution (fixed)"));
  parameter Real Cl_in(unit = "mol/m3")  = 10.0
    "Intracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Intracellular solution (fixed)"));
  parameter Real Ca_in(unit = "mol/m3")  = 1.0e-4
    "Intracellular Ca2+ concentration [mM] (free fraction, at rest)"
    annotation(Dialog(group = "Intracellular solution (fixed)"));

  parameter Real Na_out(unit = "mol/m3") = 145.0
    "Extracellular Na+ concentration [mM] (typical Ringer/ACSF)"
    annotation(Dialog(group = "Extracellular solution (fixed)"));
  parameter Real Cl_out(unit = "mol/m3") = 110.0
    "Extracellular Cl- concentration [mM]"
    annotation(Dialog(group = "Extracellular solution (fixed)"));
  parameter Real Ca_out(unit = "mol/m3") = 2.0
    "Extracellular Ca2+ concentration [mM]"
    annotation(Dialog(group = "Extracellular solution (fixed)"));

  parameter Real T(unit = "K") = PatchClamp.Constants.T_body
    "Temperature [K] (default: 37 degC = 310.15 K)"
    annotation(Dialog(group = "Temperature"));

  Real E_K(unit  = "V")  "K+ equilibrium potential [V] -- follows Nernst with K_out";
  Real E_Na(unit = "V")  "Na+ equilibrium potential [V]";
  Real E_Cl(unit = "V")  "Cl- equilibrium potential [V]";
  Real E_Ca(unit = "V")  "Ca2+ equilibrium potential [V]";

  // Goldman approximation using typical resting-neuron relative
  // permeabilities, P_K : P_Na : P_Cl = 1 : 0.04 : 0.45
  parameter Real P_K  = 1.0   "Relative K+ permeability (normalized)"
    annotation(Dialog(group = "Goldman permeabilities"));
  parameter Real P_Na = 0.04  "Relative Na+ permeability at rest"
    annotation(Dialog(group = "Goldman permeabilities"));
  parameter Real P_Cl = 0.45  "Relative Cl- permeability at rest"
    annotation(Dialog(group = "Goldman permeabilities"));

  Real V_Goldman(unit = "V") "Resting membrane potential via the Goldman equation [V]";

equation
  E_K  = PatchClamp.Media.Functions.nernstPotential(T,  1, K_out,  K_in);
  E_Na = PatchClamp.Media.Functions.nernstPotential(T,  1, Na_out, Na_in);
  E_Cl = PatchClamp.Media.Functions.nernstPotential(T, -1, Cl_out, Cl_in);
  E_Ca = PatchClamp.Media.Functions.nernstPotential(T,  2, Ca_out, Ca_in);

  // Goldman-Hodgkin-Katz resting potential:
  // V_m = (RT/F) * ln[ (P_K*K_out + P_Na*Na_out + P_Cl*Cl_in) /
  //                    (P_K*K_in  + P_Na*Na_in  + P_Cl*Cl_out) ]
  V_Goldman = (PatchClamp.Constants.R * T / PatchClamp.Constants.F) *
              log((P_K * K_out  + P_Na * Na_out + P_Cl * Cl_in) /
                  (P_K * K_in   + P_Na * Na_in  + P_Cl * Cl_out));

  annotation(
    Documentation(info = "<html>
      <h2>Step08 -- Nernst equilibrium potential</h2>

      <h3>Learning objective</h3>
      <p>
        See how an ion's concentration gradient sets its electrical
        equilibrium potential (the Nernst potential), and how the resting
        membrane potential depends on extracellular K+ -- the physiological
        basis underlying the action potential and cardiac electrophysiology.
      </p>

      <h3>Background</h3>
      <p>The Nernst equation for an ion of charge z:</p>
      <pre>  E_ion = (RT / zF) * ln([ion]_out / [ion]_in)</pre>
      <p>For K+ at 37 degC with [K+]_in=140 mM, [K+]_out=5 mM:</p>
      <pre>
  E_K = (8.314 * 310.15) / (1 * 96485) * ln(5/140)
      = 0.02671 * ln(0.0357)
      = 0.02671 * (-3.335)
      = -89.1 mV
      </pre>

      <h3>Using this model</h3>
      <p>
        This is a static model (no ODEs) -- every variable is computed
        algebraically at each instant. To change concentrations, no code
        editing is needed: select the block in OMEdit (diagram or Libraries
        Browser) and open its Parameters dialog, where fields are grouped
        just like any other block in the package (\"Sweep: extracellular
        [K+]\", \"Intracellular solution\", \"Extracellular solution\",
        \"Goldman permeabilities\", \"Temperature\"). To sweep K_out and
        build the full Nernst curve automatically, from OMShell:
      </p>
      <pre>
  loadFile('PatchClamp/package.mo');
  for K_ext in {1, 2, 5, 10, 20, 50, 100, 150} loop
    m := PatchClamp.Examples.Step08_NernstEquilibriumPotential(K_out=K_ext);
    simulate(m, stopTime=1.0, numberOfIntervals=1,
             outputFormat='csv', fileNamePrefix='step08_K'+String(K_ext));
  end for;
      </pre>
      <p>
        Or just change K_out directly in OMEdit and compare the resulting
        E_K in the results window.
      </p>

      <h3>Reference values</h3>
      <pre>
  [K+]_out (mM)  |  E_K (mV)   |  V_Goldman (mV)
  ---------------+-------------+-----------------
      1          |   -118      |   -82
      5          |    -89      |   -65 (typical resting value)
     10          |    -71      |   -59
     20          |    -54      |   -51
     50          |    -28      |   -38
    100          |    -11      |   -26
    150          |     -1      |   -20
      </pre>

      <h3>What to look for</h3>
      <ul>
        <li>E_K follows a logarithmic curve -- at low extracellular K+ it's strongly negative (a large electrochemical gradient).</li>
        <li>V_Goldman is always more positive than E_K, since Na+ and Cl- also contribute to the resting potential.</li>
        <li>When K_out = K_in = 140 mM, E_K = 0 mV (no gradient, no driving force).</li>
        <li>Hyperkalemia (high K_out) depolarizes the membrane (V_Goldman moves toward 0), reducing cell excitability.</li>
      </ul>

      <h3>Questions worth exploring</h3>
      <ol>
        <li>Compute E_K for [K+]_out = 150 mM (severe hyperkalemia). What voltage does the membrane potential approach, and why is that dangerous for cardiac tissue?</li>
        <li>Change P_Na from 0.04 to 0.5 (simulating massive Na+ channel opening, as during an action potential). How does V_Goldman change?</li>
        <li>Why are E_Na and E_Ca positive while E_K and E_Cl are negative?</li>
        <li>This model predicts V_Goldman &#8776; -65 mV at [K+]_out=5 mM. Do the cell models in Cells/ use V_rest=-65 mV too?</li>
      </ol>

      <p>
        This reproduces the classic Hodgkin and Katz (1949) experiment
        measuring the squid giant axon's membrane potential across
        different external K+ concentrations, which established the
        experimental basis for the Nernst equation in cell physiology.
      </p>

      <blockquote>
        Hodgkin AL, Katz B (1949). The effect of sodium ions on the
        electrical activity of the giant axon of the squid. <em>J Physiol</em>
        <b>108</b>: 37-77.
      </blockquote>
    </html>"),
    experiment(
      StopTime  = 1.0,
      Interval  = 1.0,
      Tolerance = 1e-8),
    Icon(graphics = {
      Rectangle(
        extent = {{-100, -100}, {100, 100}},
        lineColor = {0, 130, 80},
        fillColor = {230, 255, 240},
        fillPattern = FillPattern.Solid),
      Text(
        extent = {{-90, 30}, {90, -10}},
        textString = "Step08",
        textColor = {0, 100, 60},
        fontSize = 22),
      Text(
        extent = {{-90, -10}, {90, -40}},
        textString = "Nernst Potential",
        textColor = {0, 130, 80},
        fontSize = 11)
    })
  );
end Step08_NernstEquilibriumPotential;
