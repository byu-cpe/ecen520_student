# SPI ADXL362 Download

In this assignment, you will create a top-level design that communicate with the ADXL362 accelerometer on the Nexys4 board using the SPI protocol.

## SPI Top-Level Design

Create a top-level design in a file named `adxl362_top.sv` that uses the following top-level ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset |
| SW | Input | 16 | Switches  |
| BTNL | Input | 1 |  |
| BTNR | Input | 1 |  |
| LED | Output | 16 | Board LEDs  |
| LED16_B | Output | 1 |  |
| ACL_MISO | Input | 1 | ADXL362 SPI MISO |
| ACL_SCLK | Output | 1 | ADXL362 SPI SCLK |
| ACL_CSN | Output | 1 | ADXL362 SPI CSN|
| ACL_MOSI | Output | 1 | ADXL362 SPI MOSI |
| AN  | Output | 8 | Anode signals for the seven segment display |
| CA, CB, CC, CD, CE, CF, CG | Output | 1 each | Seven segment display cathode signals |
| DP | Output | 1 | Seven segment display digit point signal |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| REFRESH_RATE  | 200 | Display refresh rate |
| DEBOUNCE_TIME_US | 10_000 | Specifies the minimum debounce delay in micro seconds (1 us) |
| SCLK_FREQUENCY | 1_000_000 | ADXL SPI SCLK rate |
| DISPLAY_RATE | 2 | How many times a second the accelerometer values should be updated on the seven segment display |

Create a top-level circuit that includes the following:
* Instance your ADXL362 SPI controller and attach it to the top-level SPI pins on the Nexys4 board. 
  * The accelerometer provides two interrupt pins (`ACL_INT[1]` and `ACL_INT[2]`) that you do not need to use for this assignment (do not hook up these pins).
  * Turn on LED16_B when your ADXL362 SPI controller unit is busy.
  * Create a state machine that reads the X, Y, and Z accelerator values periodically and continuously write the values to the seven segment display (see below for details on now to display the values).
  * The `DISPLAY_RATE` parameter that indicates how many times a second these values should be updated.
* Switches
  * The lower 8 switches should be used to specify the 8-bit address of the adxl362 register to read/write
  * The upper 8 switches should be used to specify the 8-bit data used for adxl362 register writes
  * The 16 LEDs should follow the value of the switches to allow the user can easily verify that the address/data is properly set.
* Buttons
  * The left button (BTNL) should be used to initiate a write operation to the accelerometer (where the address and data to write are specified by the switches)
  * The right button (BTNR) should be used to initiate a read from the accelerometer
  * Note that if the interface to the accelerometer is busy when either a BTNL or BTNR is pressed, the operation should proceed when the interface is no longer busy.
  * You should add a two flip-flop synchronizer for each button and a debouncer to make sure that the buttons are properly synchronized to the clock and debounced.
    * The first flip-flop in the two flip-flop synchronizer should be given the `(* ASYNC_REG = "TRUE" *)` attribute. This insures that the synthesis tool will place this as close as possible to the input pin, not optimize the flip-flop, and properly handle the timing analysis. An example of how to do this is as follows: `(* ASYNC_REG = "TRUE" *) logic btnl_sync_0;`
* Seven Segment Display
  * Instance your seven segment display controller and hook it up so that the last byte received from a register read is displayed on the _right two digits_ of the seven segment display.
  * Display the continuous accelerometer data as follows:
    * The X-Axis (register 0x08) should be displayed on the digits 2 and 3 (where digit 0 is the rightmost digit)
    * The Y-Axis (register 0x09) should be displayed on the digits 4 and 5
    * The Z-Axis (register 0x0A) should be displayed on the digits 6 and 7

### SPI Top-Level Testbench

Create a top-level testbench of your top-level design in a file named `adxl362_top_tb.sv` that tests the operation of your top-level AXDL362L controller.
This testbench should be designed as follows:
* Make the top-level testbench parameterizable with the top-level parameters
* Create a free-running clock
* Instance your top-level design
* Instance the [ADXL362 simulation](../spi_cntrl/adxl362_model.sv) model
  * attach the SPI signals from the top-level design to the SPI signals of the simulation
* Perform the following sequence of events for your testbench:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switches)
  * Wait for a few clock cycles, assert the reset for a few clock cycles, deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform the following operations within your testbench by setting the buttons and switches:
    * Read the DEVICEID register (0x0). Should get 0xad
    * Read the PARTID (0x02) to make sure you are getting consistent correct data (0xF2)
    * Read the status register (0x0b): should get 0x40 on power up (0xC0?)
    * Write the value 0x52 to register 0x1F for a soft reset

Make sure your top-level design successfully passes this testbench.
Add makefile rules named `sim_adxl362_top` that runs your testbench and generates a log file named `sim_adxl362_top.log`.

 <!-- using default parameters, and `sim_top_100`, that uses a 100_000 SCLK_FREQUENCY, that will perform this simulation from the command line. -->

## ADXL362 Implementation and Download

### Synthesis

Create a .xdc constraints file to specify the ports and clock frequency of your top-level design.
For this assignment we want to add more constraints to more fully specify the timing in the design.
Add the following constraint to specify the jitter of the clock as 100 ps:

`set_input_jitter [get_clocks -of_objects [get_ports CLK100MHZ]] 0.1`

None of the inputs are registered and we do not care about the timing between the input pad and the incoming synchronizer flip-flop.
Add a `set_false_path` constraint for each of the inputs of your design (except the clock).
The following example demonstrates how to do this for several inputs:

```
# False input paths
set_false_path -from [get_ports { SW[*] } ]
set_false_path -from [get_ports { BTNL } ]
```

The outputs are also not registered and we do not care about the timing between the signal and the output pad.
Add a `set_false_path` constraint for each of the outputs of your design.
The following example demonstrates how to do this for several outputs:

```
# False output paths
set_false_path -to [get_ports { LED[*] } ]
set_false_path -to [get_ports { LED16_B } ]
```

Once you have created your constraints file, create a makefile rule named `synth_adxl362_top` that synthesizes your top-level design using the default parameters.
This makefile rule should generate a log file named `synth_adxl362_top.log` and a .dcp file named `adxl362_top_synth.dcp`.
Make sure all synthesis warnings and errors are resolved before proceeding with the implementation of your design.
Carefully track the number of times you synthesize your design as this number will be required in the report section of this assignment.

### Implementation

Create makefile rule named `implement_adxl362_top` that performs the placement, routing, report, bitstream, and dcp file generation.
This makefile rule should generate a log file named `implement_adxl362_top.log`, a .dcp file named `adxl362_top.dcp`, and a bitfile named `adxl362_top.bit`.
In addition, generate the following report files as part of your implementation script:
```
report_timing_summary -max_paths 2 -report_unconstrained -file timing_adxl362_top.rpt -warn_on_violation
report_utilization -file utilization_adxl362_top.rpt
report_drc -file drc_adxl362_top.rpt
```

After implementation is complete, open Vivado in GUI mode and open the implemented checkpoint file `adxl362_top.dcp`.
Create the following screenshots of your implemented design (see the 320 [design layout tutorial](https://byu-cpe.github.io/ecen320/tutorials/vivado/vivado_design_layout/)): 
* 


## Download

and track the number of times you had to download your design on the board.
These numbers will be required in the report section of this assignment.



Once you have created your design and downloaded it to the board.
Test the board by running the commands listed below on the switches and buttons.
Note that the part may not be in the state as described below as the state may have been modified by a previous student.
Make sure the board is working properly by doing the following:
  * Read the DEVICEID register (0x0). You should get 0xad
  * Read the PARTID (0x02). You should get 0xF2
  * Read the REVID (0x03). You should get 0x02
  * Read the status register (0x0b): should get 0x41 (after initial power up)
    * Note that I once received a 0xC0 after power up and had to do a write to a register to get it out of this mode
  * Read register 0x2C (you should get a 0x13)
    * Write the value 0x14 to register 0x2C to set the Filter Control Register control register (50Hz)
    * Read register 0x2C to make sure you obtained the value 0x14 that you just wrote
  * Read the various accelerometer values to see changes in the acceleration (You can rotate the board around different axis to see changes in the readings)
    * Register 0x08 for XDATA
      * The x-axis goes from left to right while looking at the board. Tilting the board away from you and towards you should change this value.
    * Register 0x09 for YDATA
      * The y-axis goes from top to bottom while looking at the board. Tilting the board righ and to the left will change this axis value.
    * Register 0x0A for ZDATA
      * The z-axis goes through the board (i.e., gravitational direction). The way to get this value to change is to lift or drop the board (i.e., accelerate in Z direction)

Other operations:
  * Write the value 0x52 to register 0x1F for a soft reset
  * Write the value 0x00 to register 0x1F to clear the soft reset
  * Write the value 0x02 to register 0x2D to set "enable measure command"
  
## Submission and Grading

1. Required Makefile rules:
  * `synth_adxl362_cntrl`
  * `sim_top`:
  * `sim_top_100`:
  * `gen_bit`: generates `spi_adxl362.bit`
  * `gen_bit_100`: generates `spi_adxl362_100.bit`
2. Assignment specific Questions:
    1. Provide a table summarizing the resources your design uses from the implementation utilization report.
    1. Review the timing report and summarize the following:
       * Determine the "Worst Negative Slack" (or WNS). 
       * Summarize the `no_input_delay` and `no_output_delay` section of the report.
       * How many total endpoints are there on your clock signal?
       * Find the first net in the `Max Delay Paths` section and indicate the source and destination of this maximum path.
    1. Indicate how many times you had to (1) synthesize your design and (2) download your bitstream before your circuit worked. Note that two different numbers are needed for this response.

<!--
- Add an exercise where the students do one of the following:
  1. Open the fpga layout tool and browse around the design. Find the I/O and logic resources.
  2. Start going through the timing report in more detail.
  3. Have a constraint that requires the SPICLK and MOSI/MISO flip flps to be very close to the I/O. Need to make sure the a the timing delay between CLK/MISO/MOSI is as small as possible.
    set_property IOB TRUE [get_cells <register_name>]
- Provide instructions for putting board in a known state. Many boards are "locked" based on previous student user. Provide instructions on how to "unlock" and put the board in an initial state.
-->
