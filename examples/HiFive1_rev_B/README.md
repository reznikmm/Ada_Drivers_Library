SiFive's HiFive1 rev B is an Arduino compatible dev kit featuring the RISC-V
Freedom E310-G002 micro-controller.

You can get it at [sifive.com](https://www.sifive.com/boards/hifive1-rev-b).

## How to setup the Ada development environment for the HiFive1 rev B

You can use GNAT FSF riscv64-elf and GPRbuild releases from the Alire project,
download [here](https://github.com/alire-project/GNAT-FSF-builds/releases).

A public release of GNAT Studio is also available
[here](https://github.com/AdaCore/gnatstudio/releases).

## Building the example

To build the example, make sure sure you have all the tools in your PATH and
run:

`$ gprbuild -f -p -P hifive1_rev_B_example.gpr -XPLATFORM_BUILD=Debug`

This will create a folder named `obj` in the same directory with the elf-formated
binary plus some auxiliary files. Inside this folder run the following command
to create the `hex` file:

`$ riscv64-elf-objcopy -O ihex main main.hex`

This new revision of the HiFive board allows the `hex` file to be uploaded
through the USB connection that should appear in your file manager. Just copy
the newly created `main.hex` into the board and press the restart button.

If you have issues with the board not appearing as a connected device, please
go to the [SiFive Forum](https://forums.sifive.com/) and state your issue.
