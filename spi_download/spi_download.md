# SPI ADXL362 Download

In this assignment, you will use your create a top-level design that communicate with the ADXL362 accelerometer on the Nexys4 board using the SPI protocol.

## Synthesis of SPI Controller Modules

Before proceeding with the top-level SPI design, it is important to make sure that your SPI controller and adxl362 controller from the previous assignment are properly synthesizable.
Create a makefile rule named `synth_adxl362_cntrl` that performs "out of context" synthesis of the adxl362 controller module from the preivous assignment (see the [instructions](../rx_sim/UART_Receiver_sim.md#receiver-synthesis) on how to do this).
Make sure all synthesis warnings and errors are resolved before proceeding with the top-level design.
If you made any changes to your modules to resolve synthesis errors, rerun the testbenches from the previous assignment to make sure they operate correctly.

## SPI Top-Level Design

Create a top-level design that uses the following top-level ports:

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
| ACL_SCLK | Input | 1 | ADXL362 SPI SCLK |
| ACL_CSN | Input | 1 | ADXL362 SPI CSN|
| ACL_MOSI | Input | 1 | ADXL362 SPI MOSI |
| AN | [7:0] | Output | Anode signals for the seven segment display |
| CA, CB, CC, CD, CE, CF, CG | [6:0] | Output | Seven segment display cathode signals |
| DP | Output | 1 | Seven segment display digit point signal |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| SEGMENT_DISPLAY_US  | 1_000 | The amount of time in microseconds to display each digit (1 ms) |
| DEBOUNCE_TIME_US | integer | 1_000 | Specifies the minimum debounce delay in micro seconds (1 us) |
| SCL_FREQUENCY | integer | 1_000_000 | ADXL SPI SCLK rate |


Create a top-level circuit that includes the following:
* Instances your ADXL362 SPI controller and attach it to the top-level SPI pins on the Nexys4 board. 
  * The accelerometer provides two interrupt pins (`ACL_INT[1]` and `ACL_INT[2]`) that you do not need to use for this assignment (do not hook up these pins).
  * Turn on LED16_B when your ADXL362 SPI controller unit is busy.
* The lower 8 switches should be used to specify the 8-bit address of the adxl362 register to read/write
* The upper 8 switches should be used to specify the 8-bit data used for adxl362 register writes
* The 16 LEDs should follow the value of the switches to allow the user can easily verify that the address/data is properly set.
* The left button (BTNL) should be used to initiate a write to the accelerometer (where the address and data to write are specfied by the switches)
* The right button (BTNR) should be used to initiate a read from the accelerometer
* Instance your seven segment display controller and hook it up so that the last byte received from a register read is displayed on the _right two digits_ of the seven segment display.
* Read the X, Y, and Z accelerator values periodically and continuously write the values to the seven segment display (one value per digit)
  * The X-Axis (register 0x08) should be displayed on the digits 2 and 3 (where digit 0 is the rightmost digit)
  * The Y-Axis (register 0x09) should be displayed on the digits 4 and 5
  * The Z-Axis (register 0x0A) should be displayed on the digits 6 and 7
  * Add a parameter `DISPLAY_RATE` that indicates how many times a second these values should be updated. The default should be set to 2 (i.e., 2 times a second).

## SPI Top-Level Testbench

Create a top-level testbench of your top-level design that tests the operation of your top-level AXDL362L controller.
This testbench should be designed as follows:
* Make the top-level testbench parameterizable with the top-level parameters
* Create a free-running clock
* Instance your top-level design
* Instance the [ADXL362 simulation](../spi_cntrl/adxl362_model.sv) model
  * attach the SPI signals from the top-level design to the SPI signals of the simulation
* Perform the following sequence of events for your testbench:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switchces)
  * Wait for a few clock cycle, assert the reset for a few clock cycles, deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform the following operations within your testbench by setting the buttons and switches:
    * Read the DEVICEID register (0x0). Should get 0xad
    * Read the PARTID (0x02) to make sure you are getting consistent correct data (0xF2)
    * Read the status register (0x0b): should get 0x40 on power up (0xC0?)
    * Write the value 0x52 to register 0x1F for a soft reset

Make sure your top-level design successfully passes this testbench.
Add makefile rules named `sim_top`, using default parameters, and `sim_top_100`, that uses a 100_000 SCLK frequency, that will perform this simulation from the command line.


### Implementation and Download

At this point you are ready to implement your design, generate a bitfile and download your design to your board.
Create a new makefile rule named `gen_bit` that will generate a bitfile named `spi_adx362l.bit` for your top-level design with the default top-level parameters.
Create a new makefile rule named `gen_bit_100` that will generate a bitfile named `spi_adx362l_100.bit` with a 100_000 SCLK frequency.

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
  * `gen_bit_100`: geneates `spi_adxl362_100.bit`
1. You need to have at least 3 "Error" commits in your repository
2. Assignment specific Questions:
    1. Provide a table summarizing the resources your design uses from the implementation utilization report.
    1. Review the timing report and summarize the following:
       * Determine the "Worst Negative Slack" (or WNS). 
       * Summarize the `no_input_delay` and `no_output_delay` section of the report.
       * How many total endpoints are there on your clock signal?
       * Find the first net in the `Max Delay Paths` section and indicate the source and destination of this maximum path.
    1. Indicate how many times you had to synthesize and download your bitstream before your circuit worked.

<!--
- Add an exercise where the students do one of the following:
  1. Open the fpga layout tool and browse around the design. Find the I/O and logic resources.
  2. Start going through the timing report in more detail.
-->