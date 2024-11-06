

# UART Receiver

The purpose of this assignment is to create a top-level UART receiver/transmitter in SystemVerilog and a testbench to validate your receiver.
You will also create a seven segment display controller for displaying data from your UART on the seven segment display.

## Seven Segment Controller and Testbench

For this assignment and for most future assignments you will need to display values on the seven segment display of the Nexys DDR board.
To make this easier, you will create a seven segment display controller that will drive the seven segment display.

Create a "seven segment controller" module that will drive the seven segment display of the Nexys DDR board. 
This module can be based on the [segment sevent display](http://ecen220wiki.groups.et.byu.net/labs/lab-05/) module developed in ECEN 220.
Note that there are eight digits on the seven segment display for this board so you will need to support all eight digits with your module. 
Include the following ports and parameters in your module:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| display_val | Input | 32 | 32-bit value to display |
| dp | Input | 8 | Digit point (one for each segment) |
| blank | Input | 1 | When asserted, blank the display |
| segments | Output | 7 | The seven segment drivers (see table below) |
| dp_out | Output | 1 | The output digit point driver signal |
| an_out | Output | 8 | Anode signal for each segment |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUECY | 100_000_000 | The clock frequency |
| MIN_SEGMENT_DISPLAY_US  | 10_000 | The amount of time to display each digit  |
 
The anode signals should be driven in a round-robin fashion so that each digit is displayed for a short amount of time.
These signals are low asserted. 
The cathode signals are also low asserted and are defined as follows:

```
    ----A----
    |       |
    |       |
    F       B
    |       |
    |       |
    ----G----
    |       |
    |       |
    E       C
    |       |
    |       |
    ----D----
```

The seven segments are organized into a multi-bit bus (segments[6:0]) where segments(6) corresponds to segment 'A' and segments(0) corresponds to segment 'G'.

A testbench ([ssd_tb.sv](ssd_tb.sv)) is provided for you to validate your seven segment display controller.
There is also a simulation model ([seven_segment_check.sv](seven_segment_check.sv)) of the SSD controller that you will need to compile with your testbench.
Make sure your seven segment display controller passes this testbench before moving on to the next step.
Create a makefile rule `make sim_ssd` for this simulation.

After your seven segment display controller is working correctly, create a makefile rule `make synth_ssd` that will synthesize your controller in out-of-context mode.
See the instructions from the [previous assignment](../rx_sim/UART_Receiver_sim.md#receiver-synthesis) to describe how to do this.

## Create top-level design

Create a top-level design that uses the following top-level ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| SW | Input | 8 | Switches (8 data bits to send) |
| BTNC | Input | 1 | Control signal to start a transmit operation |
| LED | Output | 16 | Board LEDs (used for data and busy) |
| UART_RXD_OUT | Output | 1 | Transmitter output signal |
| UART_TXD_IN | Input | 1 | Receiver input signal |
| LED16_B | Output | 1 | Used for TX busy signal |
| LED17_R | Output | 1 | Used for RX busy signal |
| LED17_G | Output | 1 | Used for RX error signal |
| AN | [7:0] | Output | Anode signals for the seven segment display |
| CA, CB, CC, CD, CE, CF, CG | [6:0] | Output | Seven segment display cathode signals |
| DP | Output | 1 | Seven segment display digit point signal |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| BAUD_RATE | 19_200 | Specify the receiver baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |
| MIN_SEGMENT_DISPLAY_US  | 1_000 | The amount of time in microseconds to display each digit (1 ms) |
| DEBOUNCE_TIME_US | integer | 1_000 | Specifies the minimum debounce delay in micro seconds (1 ms) |

Design your top-level circuit as follows:
* Attach the `CPU_RESETN` signal to two flip-flops to synchronize it to the clock. Use this synchronized signal for the reset in your design (note that the input reset polarity is negative asserted)
* Hook up the center button (BTNC) to your circuit through a debouncer. Make sure you pass in the top-level debounce time parameter. Create one-shot logic for the tx_write signal from the debounce output.
* Instance your transmitter
  * Hook the TX output signal to the top-level `UART_RXD_OUT` pin of the board (i.e., to the host)
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART).
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the tx busy signal to the LED16_B signal to provide a blue LED indicator when the transmitter is busy
* Instance your receiver
  * Add a two flip-flop synchronizer between the RX input signal (`UART_TXD_IN`) and the input rx signal to your receiver. This is necessary to avoid metastibilty and properly synchronize the asynchronous input.
  * Hook up the upper 8 LEDs to the data received by your receiver. These LEDs should display the last value received by the receiver. You should only update these LEDs when the 'data_strobe' indicates a new character has been received
  * Attach the rx busy signal to the LED17_R signal to provide a red LED indicator when the receiver is busy
  * Attach the rx error signal to the LED17_G signal to provide a green LED indicator when the receiver has an error
* Create four 8-bit registers that hold the last four values received by your receiver
  * When the data_strobe occurs, load the value received by the receiver into the first register and shift the values in the other registers.
* Instance your seven segment display controller as described below
  * Drive the data to display with the four 8-bit registers described above. The most recent value received should be driven on the right two digits, the second value received should be driven on the left two digits, and so on.
  * Drive all zeros on the digit point input and tie the "blank" signal to zero. 
  * Hook up the seven segment display outputs to the top-level outputs of the design (i.e., AN, CA, CB, CC, CD, CE, CF, CG, DP)

## Top-level testbench

Create testbench for your top-level rx/tx design by copying and modifying the [tx_top_tb.sv](../tx_download/tx_top_tb.sv) file from the tx download assignment and renaming to rxtx_top_tb.sv:
The following adaptations should be made to the structure of this testbench:
* Add a parameter MIN_SEGMENT_DISPLAY_US to the testbench with a default of 200. The defaults for the testbench should be a baud rate of 19200, a clock frequency of 100 MHz, and odd parity.
* Remove the rx_model simulation model
* Instance your rxtx_top design instead of the tx_top design
  * Pass the testbench parameters down to the rxtx_top design
  * Attach the `UART_RXD_OUT` output of your top-level design (i.e., transmitter output) to the `UART_TXD_IN` input of your top-level design (i.e., receiver input). This way when you transmit a character from your transmit module, it will be received by your receiver module.
* Hook up the seven_segment_check model to your top-level design so you can see the output of the seven segment display (see ssd_tb.sv)

This testbench should be designed as follows:
* Perform the following sequence of events for your testbench:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switchces)
  * Wait for a few clock cycle, Assert the reset for a few clock cycles, Deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform at least 8 character transfers as follows:
    * Choose a random value for the character you want to send
    * Set the switch values to this value
    * Press btnc long enough to make it through your debouncer
    * Wait until the tx_busy and rx_busy LED values are both zero
    * Check to make sure the upper LEDs match the value you sent
    * Check to make sure there is no error

Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_rxtop` that will perform this simulation from the command line.

When simulating, you can [change the top-level parameters](../resources/vivado_command_line.md#setting-parameters-for-simulation) of your testbench or module to simulate different conditions of your system.
Create another makefile rule named `sim_rxtop_115200_even` that will simulate your top-level design with a baud rate of 115200 and even parity.
You will need to add the command line option to change the baud rate of your top-level design as described [here](../resources/vivado_command_line.md#setting-parameters-for-simulation).

## Implementation and Download

At this point you are ready to implement your design, generate a bitfile and download it to your board.
Ideally, you will just synthesize your design, generate a bitfile, and it will work the first time you download it.
In reality, most people will have to go through this process a few times to resolve synthesis and implementation issues.
**Make sure you keep track of the number of times you 'synthesize' and the number of times you 'download' your bitstream.** 
This will be required for your assignment report.

Create a new makefile rule named `gen_bit` that will generate a bitfile named `rxtx_top.bit` for your top-level design with the default top-level parameters.
Download your design to your board and use 'putty' to make sure the UART receiver is working correctly using Putty or some other terminal emulator. You will need to transmit signals from 'putty' to your board, you can do this by pressing 'ctrl+j' in the 'putty' emulator, and then using your keyboard to send char values.

After demonstrating that your uart works properly, create a new makefile rule named `gen_bit_115200_even` that will generate a bitfile operating with a baud rate of 115200 and even parity and named `rxtx_top_115200_even.bit`.
To generate such a bitfile you will need to change the top-level BAUD_RATE parameter to 115200 during the logic synthesis.
Instructions for setting top-level parameters during synthesis can be found [here](../resources/vivado_command_line.md#setting-parameters-for-synthesis).
Download this different bitfile with a different baud rate and make sure it is operating correctly in Putty.

The synthesis step is a very important part of the implementation process and you should always check the logs for warnings that are generated during this step.
It is a good practice to address _all_ warnings generated from the synthesis process. 
In many cases you will need to change your orginal HDL code to address the warnings.
Review your synthesis logs and try to address all of the warnings that you can.
In some cases you can ignore the warning.
If you are certain that you can ignore the warning, you will want to change the synthesis settings such that the particular warning is changed to an "INFO" or less severe message in the logs.
Review the instructions on [adjusting the message severity level](../resources/vivado_command_line.md#adjusting-message-severity-levels) to see how to do this.
These instructions list messages that can be downgraded and those that should be upgraded. 
You will need to make sure that you don't have *any* synthesis warnings in your implementation.

Note that you should add the following to your .xdc file to get rid of the "Missing CFGBVS and CONFIG_VOLTAGE Design Properties" warning:

```
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
```

## Submission and Grading


The following assignment specific items should be included in your repository:

1. Required Makefile rules:
    * `sim_ssd`:
    * `synth_ssd`:
    * `sim_rxtop`: performs command line simulation of the top testbench
    * `sim_rxtop_115200_even`: performs command line simulation of the top testbench
    * `gen_bit`: Generates a bitstream for your top-level design
    * `gen_bit_115200_even`: Generates a bitstream for your top-level design
2. You need to have at least 5 "Error" commits in your repository
3. Tag your repo 'rx_download'
4. Assignment specific Questions:
    1. Provide a table summarizing the resources your design uses from the implementation utilization report.
    1. Review the timing report and summarize the following:
       * Determine the "Worst Negative Slack" (or WNS). 
       * Summarize the `no_input_delay` and `no_output_delay` section of the report.
       * How many total endpoints are there on your clock signal?
       * Find the first net in the `Max Delay Paths` section and indicate the source and destination of this maximum path.
    1. Indicate how many times you had to synthesize and download your bitstream before your circuit worked. Provide two numbers: one for synthesis attempts and one for download attempts.


<!--
Notes:
- Need to improve the ssd_check and testbench.
- Clarify that the digit points should not be driven
- Warnings:
  - Teach them how to set the tools to ignore warnings and how to get rid of warnings
  - Tell them that they should not have *any* warnings during synthesis
-- Any _new_ coding standards to add? It would be nice to add something for this assignment

- Future:
  - Make sure that the data displayed on the LEDs doesn't change/flicker (i.e., latch the data)
  - Note that many studens struggled debugging their receiver and the transmitter model at the same time. It wasn't clear which one has the problem.
     - Suggestion: create a top-level testbench that just hooks up my receiver model to their transmitter model and is used to validate their transmitter model. This way, they can have a known good transmitter model to test their receiver.
  - seven segment display model/checker
    - Students don't know how to use it and are confused. Provide more documentation and expectations on what it does.
    - Explain how to use the "check signal" or end of line
    - Get rid of the initial warning
    - Sample the data every cycle instead of at the end of a segment to avoid one cycle off issue
-->
