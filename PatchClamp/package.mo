within ;
package PatchClamp "OpenModelica package for teaching the patch clamp technique"
  annotation(
    version = "1.0.0",
    versionDate = "2026-05-04",
    uses(Modelica(version = "4.0.0")),
    Documentation(info = "<html>
      <h2>PatchClamp</h2>
      <p>
        Models the components and typical experiments of <em>patch clamp</em>,
        the electrophysiological technique used to record ionic currents
        across cell membranes down to single-channel resolution. Blocks are
        drag-and-drop in OMEdit, and parameters are named with explicit
        physiological units, so it targets students of biophysics and
        physiology rather than programmers.
      </p>
      <ul>
        <li><b>Constants</b> — physical (R, F) and physiological (T_body) constants.</li>
        <li><b>Interfaces</b> — reusable electrical and ionic connectors.</li>
        <li><b>Media</b> — physiological solutions and the Nernst/GHK functions.</li>
        <li><b>Electrodes</b> — glass pipette and bath electrode models.</li>
        <li><b>Cells</b> — cell models (passive, Hodgkin-Huxley, integrate-and-fire, ...).</li>
        <li><b>Amplifiers</b> — voltage-clamp and current-clamp amplifiers.</li>
        <li><b>Membranes</b> — channel-level membrane models (advanced).</li>
        <li><b>Examples</b> — complete, ready-to-simulate experiments.</li>
      </ul>
      <p>Requires OpenModelica 4.x and the Modelica Standard Library 4.x.</p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PatchClampOM.png")
    })
  );
end PatchClamp;
