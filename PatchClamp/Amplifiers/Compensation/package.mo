within PatchClamp.Amplifiers;
package Compensation "Electronic compensation models for the patch clamp amplifier"
  annotation(
    Documentation(info = "<html>
      <h2>Amplifiers.Compensation</h2>
      <p>
        Models the electronic compensation circuitry of a real patch clamp
        amplifier (e.g. Axopatch 200B, HEKA EPC-10). These extend or
        complement the base amplifiers without modifying them.
      </p>

      <ul>
        <li><b>PipetteCapacitanceComp</b> -- C-fast compensation: cancels the pipette glass wall's capacitive current, revealing the ionic current beneath the fast capacitive artifact.</li>
        <li><b>WholeCellCapacitanceComp</b> -- C-slow compensation: cancels the whole-cell membrane's capacitive current, leaving only the active ionic currents.</li>
        <li><b>SeriesResistanceComp</b> -- R_s compensation: corrects the voltage error produced by the series (pipette) resistance under current flow; the alpha parameter sets the compensation fraction (0..0.9).</li>
        <li><b>CompensatedVClampAmp</b> -- a complete voltage-clamp amplifier with all three compensations integrated; a starting point for more advanced experiments.</li>
      </ul>

      <p>
        Swap <code>VoltageClampAmplifier</code> for
        <code>CompensatedVClampAmp</code> in any existing example to observe
        each compensation's effect independently.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Compensation.png")
    })
  );
end Compensation;
