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
- **Follow a build-it-yourself walkthrough:** the [tutorials](#tutorials) below
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
:caption: Tutorials
:maxdepth: 1

../Tutorials/Step01_PipetteSealTest_Tutorial
../Tutorials/Step02_GigasealFormation_Tutorial
../Tutorials/Step03_PassiveCellVoltageClamp_Tutorial
../Tutorials/Step04_WholeCellBreakIn_Tutorial
../Tutorials/Step05_PassiveCellCurrentClamp_Tutorial
../Tutorials/Step06_HodgkinHuxleyActionPotential_Tutorial
../Tutorials/Step09_GHKReversalPotential_Tutorial
../Tutorials/Step11_GHK_IVCurve_Tutorial
```

```{toctree}
:caption: Contributing
:maxdepth: 1

../CONTRIBUTING
```

## How to cite

If you use PatchClampOM in teaching or research, please cite the accompanying article
(citation to be added on publication) and the software repository.
