within PatchClamp;
package Examples "Patch clamp experiments, ready to simulate in OMEdit"
  annotation(
    Documentation(info = "<html>
      <h2>Examples</h2>
      <p>
        Twenty-five virtual experiments (<code>Step01_PipetteSealTest</code>
        through <code>Step25_LigandGatedSingleChannel</code>) demonstrating
        the PatchClamp package, sequenced to introduce one new concept at a
        time. Each runs directly from OMEdit with no additional code. A few
        representative ones:
      </p>
      <ul>
        <li><b>Step03_PassiveCellVoltageClamp</b> -- a passive cell (R_m*C_m) under voltage clamp, showing the exponential response to a voltage step.</li>
        <li><b>Step06_HodgkinHuxleyActionPotential</b> -- a Hodgkin-Huxley neuron under current clamp, firing action potentials once the injected current crosses threshold.</li>
        <li><b>Step08_NernstEquilibriumPotential</b> -- measures E_K while varying extracellular K+, an experimental demonstration of the Nernst equation.</li>
        <li><b>Step12_SodiumChannelIVCurve</b> -- the Na+ channel's current-voltage (I-V) curve via a voltage-ramp protocol.</li>
      </ul>
      <p>To simulate from the command line:</p>
      <pre>  omc -s PatchClamp.Examples.Step03_PassiveCellVoltageClamp -stopTime=0.1</pre>
      <p>
        See <code>docs/examples-reference.md</code> in the repository for
        the full list with concept summaries.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Examples.png")
    })
  );
end Examples;
