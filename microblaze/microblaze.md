# MicroBlaze IP Integrator Assignment

In this assignment you will be creating several MicroBlaze based systems using the IP Integrator tool in Vivado.
You will also create a system that integrates your custom IP core from the previous assignment into a MicroBlaze system.

## IP Integrator and MicroBlaze Demos

The first part of this assignment is to complete the MicroBlaze IP Integrator demo described [here](./microblaze/demo_io.md).
This demonstration walks you through the steps of creating a MicroBlaze system with basic IO peripherals.
This demo also describe how to create a simple C application that runs on your processor.

When you have completed this demonstration, you should be able to build the bitfile and the corresponding .elf file with the following makefile rules: `build_demo_io`, `build_demo_io_vitis`.

## MicroBlaze UART System

After successfully completing the IO demo, you will create a MicroBlaze system that uses your custom UART core from the previous assignment.
Follow the instructions [here](./microblaze/mb_uart.md) to build your microblaze with your UART.
You should have two makefile rules for building this project and the corresponding vitis project: `build_mb_uart` and `build_mb_uart_vitis`.

## Custom MicroBlaze UART Application

Once you have a working system and project, create your own C file to do something interesting with your system.
The intent is to have you come up with something different than the given C code to demonstrate your microblaze.
Name your C code `custom.c` and create a makefile rule `build_custom_vitis` that generates an elf file named  `./mb_uart/vitis/custom/build/custom.elf`

# Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

<!-- Future
- I don't have a good way of grading this. I need to figure out how to create a bitfile that has the elf integrated into it. This bitfile should bre required.
- Ask for resource utiliztion in report.
- Make the report more interesting and involved
- Adding instructions on the debugging flow for this assignment would be helpful, as well as some tips on what how to identify and correct common issues.
- Vitis GUI instructions
-  * Suggestion 1 - A complete list of deliverables for passoff. Many of the steps require a specific name or file structure, the instructions should list these things explicitly. The passoff scripts takes long enough to run that an error will only show up after a significant amount of time.
  * Suggestion 2 - Common Vivado errors. While it's not possible to cover every source of error, many of us ran into the same issues with Vivado while synthesizing, implementing, and generating the bitstream. The issue with the .xdc file and top level module is one of them. IO port naming (gpio_LED"_tri_o", etc.) was another which didn't have much explanation and many of us debugged independently.
-->