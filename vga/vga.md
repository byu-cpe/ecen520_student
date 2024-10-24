# VGA

In this assignment you will practice your VHDL design skills by createing a VGA controller.

## VGA Controller Review

Learn about how a VGA display works by reading the [VGA](https://digilent.com/reference/programmable-logic/nexys-4-ddr/reference-manual) section of the Nexys4 DDR reference manual (this is section 9).

You will need to implement a VGA controller that outputs a 1280x1024 resolution @ 60Hz.
This resolution includes a total of 1688 horizontal pixels where only 1280 are displayed.
The horizontal front porch is 48 pixels and the horizontal sync pulse is 112 pixels.
The resolution includes a total of 1066 vertical lines where only 1024 are displayed.
The vertical front porch is one line and the vertical sync pulse is three lines.

To operate this VGA controller, you will need to generate a 108 MHz pixel clock: 1688 * 1066 * 60 = 108 MHz (107.964 Mhz).
You will need to generate this clock using the MMCM primitive later in the assignment.

## VHDL VGA Controller

Create an architecture in VHDL in a file named `vga.vhd` that implements the timing signals for the VGA controller that outputs a 1280x1024 resolution @ 60Hz.
Create a top-level entity with the following ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock (108 MHz/9.26 ns) |
| rst | Input | 1 | Reset |
| hreg | Output | 11 | Value of horizontal counter |
| vreg | Output | 11 | Value of vertical counter |
| hsync | Output | 1 | Horizontal Sync |
| vsync | Output | 1 | Vertical Sync |

Your `hreg` and `vreg` signals should be glitch free.

### VGA Controller Testbench

Create a testbench, `tb_vga.sv`, in system verilog that demonstrates the operation of your VGA controller.
The testbnech should generate a 108 MHz clock and provide a reset signal.
Provide statements in your testbench that indicate the time each of your vertical and horizontal synch signals change to demonstrate proper operation.

Create a makefile rule named `sim_vga` that runs this simulation from the command line.

## VGA Top-level Design

Create a top-level design named `vga_top.sv` with your VHDL VGA controller that displays a simple color bar pattern.
You can create this top-level design in System Verilog
Design your top-level as follows:
* Create a MMCM primitive that generates a 108 MHz clock.
* Instance your VHDL VGA controller and reset it with the MMCM primitive
* Generate the color bar pattern by displaying a different color for each vertical line. You will need to set the 12 color signals to the appropriate color for each vertical line.
  * [1-159] : RRRRGGGGBBBB = 12'h000
  * [160-319] : RRRRGGGGBBBB = 12'h00F
  * [320-479] : RRRRGGGGBBBB = 12'h0F0
  * [480-639] : RRRRGGGGBBBB = 12'h0FF
  * [640-799] : RRRRGGGGBBBB = 12'hF00
  * [800-959] : RRRRGGGGBBBB = 12'hF0F
  * [960-1119] : RRRRGGGGBBBB = 12'hFF0
  * [1120-1279] : RRRRGGGGBBBB = 12'hFFF

<!-- Other ideas 
* Instance your seven segment display controller and count the number of frames that have been displayed in real time
* Press a button to: blank screen, make screen white, display a color as specified by the switches
-->

### VGA Top-level Testbench

Create a testbench, `tb_vga_top.sv`, in system verilog that demonstrates the operation of your top-level design.
Provide statements in your testbench that indicate the time each of your vertical and horizontal synch signals change to demonstrate proper operation.
Create a makefile rule named `sim_vga_top` that runs this simulation from the command line.

### VGA Implementation and Download

After verifying that your top-level design works properly, create a makefile rule for generating a bitstream for your design.
The makefile rule should be named: `gen_bit` and should generate a bitstream named `vga.bit`.

## Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
  * `sim_vga`
  * `sim_vga_top`
  * `gen_bit`
2. You need to have at least 4 "Error" commits in your repository
3. Assignment specific Questions:
