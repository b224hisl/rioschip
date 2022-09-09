
[![multi_tool](https://github.com/mattvenn/zero_to_asic_mpw7/actions/workflows/multi_tool.yaml/badge.svg)](https://github.com/mattvenn/zero_to_asic_mpw7/actions/workflows/multi_tool.yaml)

# Zero to ASIC Group submission MPW7

This ASIC was designed by members of the [Zero to ASIC course](https://zerotoasiccourse.com).

This submission was configured and built by the [multi project tools](https://github.com/mattvenn/multi_project_tools) at commit [8be9641236aa5c055f6195d3d903eb63e4f1336e](https://github.com/mattvenn/multi_project_tools/commit/8be9641236aa5c055f6195d3d903eb63e4f1336e).

The configuration files are [projects.yaml](projects.yaml) & [local.yaml](local.yaml). See the CI for how the build works.

    # clone all repos, and include support for shared OpenRAM
    ./multi_tool.py --clone-repos --clone-shared-repos --create-openlane-config --copy-gds --copy-project --openram

    # run all the tests
    ./multi_tool.py --test-all --force-delete

    # build user project wrapper submission
    cd $CARAVEL_ROOT; make user_project_wrapper

    # create docs
    ./multi_tool.py --generate-doc --annotate-image

![multi macro](pics/multi_macro_annotated.png)

# Project Index

## Function generator

* Author: Matt Venn
* Github: https://github.com/mattvenn/wrapped_function_generator
* commit: 701095fd880ad3bb80d6cec1d214a04e5676a65d
* Description: arbitary function generator, using shared RAM as the output data

![Function generator](pics/function_generator.png)

## ibnalhaytham

* Author: Farhad Modaresi
* Github: https://github.com/sfmth/wrapped_ibnalhaytham
* commit: 0627452464db56b813a3aae8899e8339a358fac9
* Description: 32-bit RISC-V based processor

![ibnalhaytham](pics/layout.png)

## Educational tpu

* Author: Camilo Soto
* Github: https://github.com/tucanae47/wrapped_etpu
* commit: 748d3cc0bcba8abb06acd40ab13ed89ff307ede6
* Description: 3x3 systolic array 

![Educational tpu](pics/etpu.png)

