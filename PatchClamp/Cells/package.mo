within PatchClamp;
package Cells "Excitable cell models for patch clamp experiments"
  annotation(
    Documentation(info = "<html>
      <h2>Cells</h2>
      <p>
        The cell models that act as the biological preparation in a virtual
        patch clamp experiment. All of them implement
        <code>PatchClamp.Cells.Interfaces.PartialExcitableCell</code>, so any
        one can be substituted for another without rewiring.
      </p>
      <ul>
        <li><b>PassiveCell</b> -- passive RC membrane (R_m || C_m); the starting point for learning voltage clamp.</li>
        <li><b>SimplifiedNeuron</b> -- leaky integrate-and-fire (LIF) model, a quick introduction to neuronal excitability.</li>
        <li><b>HodgkinHuxleyNeuron</b> -- the classic Hodgkin-Huxley (1952) squid axon model with voltage-gated Na+ and K+ channels.</li>
        <li><b>FitzHughNagumoNeuron</b> -- reduced two-variable excitability model.</li>
        <li><b>MorrisLecarNeuron</b> -- conductance-based model spanning Type I and Type II excitability.</li>
        <li><b>CardiacVentricularCell</b> -- ventricular action potential with a plateau phase.</li>
        <li><b>PacemakerCell</b> -- spontaneously firing (autorhythmic) cell.</li>
      </ul>
      <p>Membrane equation common to all excitable cells here:</p>
      <pre>
  C_m * dV/dt = -g_Na*m^3*h*(V-E_Na)
               -g_K*n^4*(V-E_K)
               -g_L*(V-E_L)
               + I_ext / A
      </pre>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Cells.png")
    })
  );
end Cells;
