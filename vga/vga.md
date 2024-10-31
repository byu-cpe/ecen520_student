# VGA

In this assignment you will practice your VHDL design skills by createing a VGA controller.

## VGA Controller Review

Learn about how a VGA display works by reading the [VGA](https://digilent.com/reference/programmable-logic/nexys-4-ddr/reference-manual) section of the Nexys4 DDR reference manual (this is section 9).

You will need to implement a VGA controller that outputs a 1280x1024 resolution @ 60Hz.
This resolution includes a total of 1688 horizontal pixels where only 1280 are displayed and 1066 vertical lines where only 1024 are displayed.

The horizontal front porch is 48 pixels and the horizontal sync pulse is 112 pixels.
The resolution includes a total of 1066 vertical lines where only 1024 are displayed.
The vertical front porch is one line and the vertical sync pulse is three lines.

To operate this VGA controller, you will need to generate a 108 MHz pixel clock: 1688 * 1066 * 60 = 108 MHz (107.964 Mhz).
You will need to generate this clock using the MMCM primitive later in the assignment.

## VHDL VGA Controller

Create an architecture in VHDL in a file named `vga_timing.vhd` that implements the timing signals for the VGA controller that outputs a 1280x1024 resolution @ 60Hz.
Create a top-level entity with the following ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock (108 MHz/9.26 ns) |
| rst | Input | 1 | Reset |
| hcount | Output | 11 | Value of horizontal counter |
| vcount | Output | 11 | Value of vertical counter |
| hsync | Output | 1 | Horizontal Sync |
| vsync | Output | 1 | Vertical Sync |
| blank | Output | 1 | Blank signal |
| last_column | Output | 1 | Last column signal |
| last_row | Output | 1 | Last row signal |

This resolution includes a total of 1688 horizontal pixels where only 1280 are displayed and 1066 vertical lines where only 1024 are displayed.
Create horizontal and vertical counters that keeps track of the current horizontal column and vertical row.
The horizontal counter should repeatedly count from 0 to 1687 (a total count of 1688 horizontal slots) every clock cycle.
The vertical counter should be incremented by one every time the horizontal counter reaches its last column (1687).
This counter should count from 0 to 1065 (a total count of 1066 vertical lines).
These counters should drive the `hcount` and `vcount` output signals.

The `last_column` signal should be asserted when the horizontal counter is at the last displayable column (1279) and the `last_row` signal should be asserted when the vertical counter is at the last displayable row (1023).
The `blank` signal should be asserted when the horizontal/vertical counters are at a position that is not displayed (i.e., horizontal counter > 1279 or vertical counter > 1023).

The synchronization signals must be set based on the 1280x1066 display mode timing requirements.
In this mode, these signals are high asserted.
The `hsync` signal should be asserted after the "front porch" delay (48 columns) from the last displayable position and should be disasserted after the horizontal "sync pulse" delay (112 columns) (see the timing diagram at the [VGA](https://digilent.com/reference/programmable-logic/nexys-4-ddr/reference-manual) section of the Nexys4 DDR reference manual).
The `vsync` signal should be asserted after the "front porch" delay (1 row) from the last displayable position and should be disasserted after the vertical "sync pulse" delay (3 rows).

Use the command `vcom` to compile your VHDL file for questasim.

### VGA Controller Testbench

Create a testbench, `tb_vga.sv`, in system verilog that demonstrates the operation of your VGA controller.
The testbnech should generate a 108 MHz clock and provide a reset signal.
Provide statements in your testbench that indicate the time each of your vertical and horizontal synch signals change to demonstrate proper operation.

Create a makefile rule named `sim_vga` that runs this simulation from the command line.

## VGA Top-level Design

Create a top-level design in VHDL named `vga_top.vhd` with your VHDL VGA controller that displays a simple color bar pattern.

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| BTNC | Input | 1 | Button C - Blank |
| BTNU | Input | 1 | Button U - Color |
| BTND | Input | 1 | Button D - White |
| SW | Input | 12 | Switches (Specify color) |
| LED | Output | 12 | Board LEDs (used for data and busy) |
| AN | Output | 8 | Anode signals for the seven segment display |
| CA, CB, CC, CD, CE, CF, CG | 1 each | Output | Seven segment display cathode signals |
| DP | Output | 1 | Seven segment display digit point signal |
| VGA_R | Output | 4 | VGA Red |
| VGA_G | Output | 4 | VGA Green |
| VGA_B | Output | 4 | VGA Blue |
| VGA_HS | Output | 1 | VGA Horizontal Sync |
| VGA_VS | Output | 1 | VGA Vertical Sync |


Design your top-level as follows:
* Create a MMCM primitive that generates a 108 MHz clock for your vga timing module. Reset the MMCM with the CPU_RESETN signal (properly synchronized). The component declaration in VHDL of the MMCM is: `<xilinx>/data/vhdl/src/unisims/unsim_VCOMP.vhd`. To obtain a 108 MHz clock use a `CLKFBOUT_MULT_F` of 11.875 and a `CLKOUT0_DIVIDE_F` of 11.000 (it will not be exactly 108 MHz but will be close enough).
* Instance your VHDL VGA timing controller and reset it with the MMCM primitive reset (properly synchronized)
* Generate the colors on the RGB as follows:
  * When no button is pressed, display the color bar pattern (see below)
  * When BTNC is pressed, blank the screen (display black)
  * When BTNU is pressed, display a white screen
  * When BTND is pressed, display the screen with the color specified by the switches where the 12 switches specify the color as follows:
    * [11:8] : Red
    * [7:4] : Green
    * [3:0] : Blue
* Create a 32-bit counter that counts the number of frames that have been displayed
* Instance your seven segment controller and display the frame count on the display

The color bar pattern displays a different color for each vertical line.
You will need to set the 12 color signals to the appropriate color for each vertical line.
  * [1-159] : RRRRGGGGBBBB = 12'h000
  * [160-319] : RRRRGGGGBBBB = 12'h00F
  * [320-479] : RRRRGGGGBBBB = 12'h0F0
  * [480-639] : RRRRGGGGBBBB = 12'h0FF
  * [640-799] : RRRRGGGGBBBB = 12'hF00
  * [800-959] : RRRRGGGGBBBB = 12'hF0F
  * [960-1119] : RRRRGGGGBBBB = 12'hFF0
  * [1120-1279] : RRRRGGGGBBBB = 12'hFFF


Make sure the VGA signals are registered (glitch free)

### VGA Top-level Testbench

Create a testbench, `tb_vga_top.sv`, in system verilog that demonstrates the operation of your top-level design.
Provide statements in your testbench that indicate the time each of your vertical and horizontal synch signals change to demonstrate proper operation.
Create a makefile rule named `sim_vga_top` that runs this simulation from the command line.

### VGA Implementation and Download

After verifying that your top-level design works properly, create a makefile rule for generating a bitstream for your design.
The makefile rule should be named: `gen_bit` and should generate a bitstream named `vga_top.bit`.

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
  * Review the timing report for your VGA controller. Complete the clock domain table below for each clock domain. 
  * 

**Clock Domain Report** 

| Clock Domain | Frequency/Period | Setup Worst Slack | Hold Worst Slack |
| ---- | ---- | ---- | --- |


<!--
Timing group example:
```
From Clock:  sys_clk_pin
  To Clock:  sys_clk_pin
```

-->