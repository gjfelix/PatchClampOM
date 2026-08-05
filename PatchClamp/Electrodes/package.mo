within PatchClamp;
package Electrodes "Electrode and glass pipette models for patch clamp"
  annotation(
    Documentation(info = "<html>
      <h2>Electrodes</h2>
      <p>
        Models the physical components that make electrical contact with
        the cell: the borosilicate pipette and the reference electrode
        submerged in the perfusion bath.
      </p>
      <ul>
        <li><b>PatchPipette</b> -- glass pipette with tip resistance R_pip (1-20 M&#937;), wall capacitance C_pip, and a liquid-junction potential.</li>
        <li><b>BathElectrode</b> -- reference electrode in the bath (the circuit's virtual ground).</li>
        <li><b>AgAgClElectrode</b> -- Ag/AgCl electrode model converting ionic current to electronic current.</li>
      </ul>
      <p>
        The pipette is modeled as a series resistance to the membrane, plus
        a parallel capacitance that produces transient currents on voltage
        steps.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/Electrodes.png")
    })
  );
end Electrodes;
