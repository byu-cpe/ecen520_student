# MicroBlaze IP Integrator Assignment

In this assignment you will be creating several MicroBlaze based systems using the IP Integrator tool in Vivado.
You will also create a system that integrates your custom IP core from the previous assignment into a MicroBlaze system.

## IP Integrator and MicroBlaze Demos

The first part of this assignment is to complete the MicroBlaze IP Integrator demo described [here](./demo_io.md).
This demonstration walks you through the steps of creating a MicroBlaze system with basic IO peripherals.
This demo also describe how to create a simple C application that runs on your processor.

When you have completed this demonstration, you should be able to build the bitfile and the corresponding .elf file with the following makefile rules: `make demo_io`, `make demo_io_vitis`.

## MicroBlaze UART System

After successfully completing the IO demo, you will create a MicroBlaze system that uses your custom UART core from the previous assignment.
Follow the instructions [here](./microblaze/mb_uart.md) to build your microblaze with your UART.

