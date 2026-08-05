within PatchClamp;
package Media "Physiological solutions and electrochemistry functions (Nernst, GHK)"
  annotation(
    Documentation(info = "<html>
      <h2>Media</h2>
      <p>
        Models the ionic solutions surrounding and filling the cell during a
        patch clamp experiment: the <em>intracellular solution</em> (pipette)
        and the <em>extracellular solution</em> (perfusion bath).
      </p>
      <ul>
        <li><b>InternalSolution</b> -- configurable intracellular solution (K+, Na+, Cl-, buffered Ca2+).</li>
        <li><b>ExternalSolution</b> -- Ringer/ACSF-type extracellular solution.</li>
        <li><b>Functions</b> -- pure functions <code>nernstPotential</code> and <code>ghkCurrentDensity</code>.</li>
      </ul>
      <p>Nernst potential for ion i: E_i = (R*T)/(z_i*F) * ln(c_out/c_in).</p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Media.png")
    })
  );
end Media;
