within PatchClamp;
package Amplifiers "Patch clamp amplifiers and stimulation protocols"
  annotation(
    Documentation(info = "<html>
      <h2>Amplifiers</h2>
      <p>
        Models the patch clamp amplifier and the stimulation protocols most
        common in electrophysiology. The amplifier is the central
        instrument of the experiment: it controls the voltage or current
        applied to the cell and records the resulting signal.
      </p>
      <ul>
        <li><b>VoltageClampAmplifier</b> -- voltage clamp: holds the membrane potential at V_cmd and measures the ionic current I_m, via ideal negative feedback.</li>
        <li><b>CurrentClampAmplifier</b> -- current clamp: injects a command current I_cmd and records the membrane voltage V_m.</li>
        <li><b>SealTest</b> -- low-amplitude square-pulse protocol for estimating the seal resistance R_seal (and, by manual fit, the membrane capacitance C_m) before the experiment proper.</li>
      </ul>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Amplifiers.png")
    })
  );
end Amplifiers;
