# PatchClampOM

**PatchClampOM** is a free, open-source [OpenModelica](https://openmodelica.org) package for
teaching patch clamp electrophysiology. Students assemble virtual patch clamp experiments
(pipette, bath, amplifier, cell or channel) by dragging and connecting blocks in OMEdit, with
no code and no equations to write, and then simulate them.

This site is the reference documentation for the package. It accompanies the article
*PatchClampOM: An Open-Source OpenModelica Package for Teaching Patch Clamp Electrophysiology*.
The source code, the Modelica library and the issue tracker are in the
[GitHub repository](https://github.com/gjfelix/PatchClampOM/).

## Where to start

- **Install and run a first simulation:** [Getting started](getting-started.md)
- **Build an experiment from scratch, step by step:** the [tutorials](#tutorials) below (one for each of the 25 examples; start with the basics page)
- **See what each of the 25 examples teaches:** [Examples reference](examples-reference.md)
- **Look up a block, its parameters and equations:** [Block reference](block-reference.md) and [Model reference](model-reference.md)
- **Check the physics behind the models:** [Physics background](physics-background.md)
- **Verify the numbers:** [Validation results](validation-results.md)

```{toctree}
:caption: Using the package
:maxdepth: 1

getting-started
examples-reference
testing-guide
```

```{toctree}
:caption: Reference
:maxdepth: 1

block-reference
model-reference
physics-background
compensation-guide
acausal-modeling-guide
validation-results
```

(tutorials)=
```{toctree}
:caption: Tutorials: start here
:maxdepth: 1

../Tutorials/00_BuildingModelsInOMEdit
../Tutorials/Step01_PipetteSealTest_Tutorial
../Tutorials/Step02_GigasealFormation_Tutorial
../Tutorials/Step03_PassiveCellVoltageClamp_Tutorial
../Tutorials/Step04_WholeCellBreakIn_Tutorial
../Tutorials/Step05_PassiveCellCurrentClamp_Tutorial
```

```{toctree}
:caption: Tutorials: Hodgkin–Huxley and ion electrochemistry
:maxdepth: 1

../Tutorials/Step06_HodgkinHuxleyActionPotential_Tutorial
../Tutorials/Step07_RefractoryPeriod_Tutorial
../Tutorials/Step08_NernstEquilibriumPotential_Tutorial
../Tutorials/Step09_GHKReversalPotential_Tutorial
../Tutorials/Step10_GoldmanRestingPotential_Tutorial
../Tutorials/Step11_GHK_IVCurve_Tutorial
../Tutorials/Step12_SodiumChannelIVCurve_Tutorial
```

```{toctree}
:caption: Tutorials: amplifier compensation
:maxdepth: 1

../Tutorials/Step13_SeriesResistanceCompensation_Tutorial
../Tutorials/Step22_PipetteCapacitanceCompensation_Tutorial
../Tutorials/Step23_WholeCellCapacitanceCompensation_Tutorial
../Tutorials/Step24_AccessResistanceCompensation_Tutorial
```

```{toctree}
:caption: Tutorials: excitable cells
:maxdepth: 1

../Tutorials/Step14_FitzHughNagumoExcitability_Tutorial
../Tutorials/Step15_MorrisLecarExcitability_Tutorial
../Tutorials/Step16_CardiacActionPotential_Tutorial
../Tutorials/Step17_PacemakerAutorhythmicity_Tutorial
```

```{toctree}
:caption: Tutorials: single channels
:maxdepth: 1

../Tutorials/Step18_OnCellSingleChannel_Tutorial
../Tutorials/Step19_InsideOutSingleChannel_Tutorial
../Tutorials/Step20_OutsideOutSingleChannel_Tutorial
../Tutorials/Step21_StochasticSingleChannel_Tutorial
../Tutorials/Step25_LigandGatedSingleChannel_Tutorial
```

```{toctree}
:caption: Contributing
:maxdepth: 1

../CONTRIBUTING
```

## How to cite

If you use PatchClampOM in teaching or research, please cite the accompanying article
(citation to be added on publication) and the software repository.
