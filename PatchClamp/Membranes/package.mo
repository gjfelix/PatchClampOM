within PatchClamp;
package Membranes "Unitary-channel-level membrane models (advanced)"
  annotation(
    Documentation(info = "<html>
      <h2>Membranes</h2>
      <p>
        Membrane models at the level of a single ion channel, for students
        working with single-channel recording configurations.
      </p>
      <ul>
        <li><b>CellAttachedPatch</b> -- pipette-membrane contact before break-in.</li>
        <li><b>GHKConductance</b> -- membrane conductance via the GHK equation.</li>
        <li><b>GoldmanMembrane</b> -- multi-ion resting potential (Goldman equation).</li>
        <li><b>MarkovChannel</b> -- a deterministic (mean-field) 2-state Markov channel.</li>
        <li><b>SingleChannelPatch</b> -- like MarkovChannel, with a configuration selector (on-cell / inside-out / outside-out) and ligand modulation.</li>
        <li><b>StochasticChannel</b> -- the STOCHASTIC counterpart of SingleChannelPatch: each channel opens and closes at random (discrete events) instead of solving an ODE for the average open probability.</li>
      </ul>
      <p>
        For whole-cell, mean-field membrane models, see
        <code>PatchClamp.Cells</code> (HodgkinHuxleyNeuron, PassiveCell, ...),
        which model the averaged behavior of a large channel population.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Memebranes.png")
    })
  );
end Membranes;
