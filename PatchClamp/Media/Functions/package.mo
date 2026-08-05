within PatchClamp.Media;
package Functions "Pure functions for electrochemical calculations (Nernst, GHK)"
  annotation(
    Documentation(info = "<html>
      <h2>Functions</h2>
      <p>
        Stateless functions for the potentials and currents that govern
        ionic transport across biological membranes:
      </p>
      <ul>
        <li><b>nernstPotential</b> -- Nernst equilibrium potential, E = (RT/zF)*ln(c_out/c_in).</li>
        <li><b>ghkCurrentDensity</b> -- Goldman-Hodgkin-Katz current density, with a numerically safe limit as V -&gt; 0.</li>
      </ul>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Media_Functions.png")
    })
  );
end Functions;
