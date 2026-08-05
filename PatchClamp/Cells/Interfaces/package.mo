within PatchClamp.Cells;
package Interfaces "Partial interfaces for excitable cell models"
  annotation(
    Documentation(info = "<html>
      <h2>Cells.Interfaces</h2>
      <p>
        Defines the partial model establishing the common interface shared
        by every excitable cell model in the package. Every cell model
        extends <code>PartialExcitableCell</code> and provides its own
        equation for the total current <code>I_total</code>.
      </p>
    </html>"),
    Icon(graphics = {
      Bitmap(
        extent = {{-100, -100}, {100, 100}},
        fileName = "modelica://PatchClamp/Icons/PartialExcitableCell.png")
    })
  );
end Interfaces;
