
# UART Receiver and Testbench

The purpose of this assignment is to create and verify a UART receiver module and create and verify an 8-digit seven segment display.
<!--
They won't have had much experience with testbenches at this point. Change the assignment to:
- Focus on synthesis logs and synthesis options
- 
-->

## UART Receiver Module

Create a UART receiver module that actively monitors the input "data in" signal receives a single byte of data and a parity bit.
Follow the guidelines in Exercise #1 of the ECEN 320 [UART Receiver](https://byu-cpe.github.io/ecen320/labs/rx-lab/#exercise-1---asynchronous-receiver-module) lab.
Note that you must follow the [Level 2](../resources/coding_standard.md#level-2) coding standards for your SystemVerilog files.
Make sure you use the same ports and parameters as this assignment with the following additions:
  * add a parameter named `PARITY` with a default of '1' (or odd) that sets the type of parity to use for incoming bytes. This parameter is used to generate the 'parityErr' signal
  * add an output signal named `busy` that indicates when the rx module is busy processing a byte

<!-- 
Create your receiver with the following ports and parameters

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| din | Input | 1 | RX input signal |
| dout | Output | 8 | Received data values |
| busy | Output | 1 | Indicates that the transmitter is in the middle of a transmit |
| data_strobe | Output | 1 | Indicates that a new data value has been received |
| rx_error | Output | 1 | Indicates that there was an error when receiving |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY | 100_000_000 | Specify the clock frequency |
| BAUD_RATE  | 19_200 | Specify the receiver baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |

Design your receiver such that:
* The 'busy' signal is asserted whenever you are in the middle of a transmission
* The 'rst' signal will initialize the internal state machine to idle
* Provide a single cycle 'data_strobe' signal when you have received a new data value. The `dout` signal should have the new data value when the `data_strobe` signal is asserted.
* When your state machine is reset, it should check to make sure the 'din' input is '1' before going to an IDLE state and accepting received data. The purpose of this is to avoid the case when the input line starts out low on reset.
* Set the `rx_error` signal low every time you start a new transaction. When a transaction is complete, set the `rx_error` signal to '1' if any of the three conditions occur:
  * A '0' is not sampled in the _middle_ of the first start bit
  * The received parity is incorrect
  * A stop bit is not received (i.e., you do not receive a '1' in the _middle_ of the stop bit) 
  -->

<!--
    If you get a reset and the input din is a '0' then you should go to some sort of "Startup" type state that just sits there and waits until din goes high. Once din goes high you can go into an idle state to wait for din to go to 0 again. The reason for this is that you do not want to just immediately start receiveing a character upon reset. You want to start up in a known state.
-->

### Receiver .do Simulation

After creating your receiver module, simulate the receiving of a single byte using the guidelines listed below.
Create a file named `sim_rx.do` that performs the following:
  * Run the simulation for 100ns without setting any values
  * Create a 100 MHz oscillating clock and run for a few clock cycles
  * Set the reset to ‘1’ and default values for all inputs and run for a few clock cycles
  * De-assert the reset signal and run for a few clock cycles
  * Emulate the transmission of the following byte: 0x41 (ASCII ‘A’) using a baud rate of 19,200 and correct ODD parity.
  * Run for at least 100 us after the end of the serial transmission
  * Assert ‘ReceiveAck’ and run for 10 us

After your module simulates successfully, take a screenshot of the simulation and name the file `sim_rx.png`.

### Receiver Testbench

Once you have demonstrated your module working with a .do file, test your module with the `tb_rx.sv` testbench.
Create a makefile rule named `sim_rx` that will simulate your transmitter with the testbench from the command line with default parameters and save the output to the file `sim_rx.log`.
Make sure you have no errors with your testbench.
Next, create a rule named `sim_rx_115200_even` that will simulate your transmitter with a baud rate of 115200 and using even parity. 
Log this simulation to a file named `sim_rx_115200_even.log`.

<!-- 
Create a dedicated testbench for your receiver with the following requirements:
  * Provide the parameters of BAUD_RATE and PARITY to your receiver module so you can change the baud rate and parity in your testbench
  * Provide a testbench parameter `NUMBER_OF_CHARS` with a default value of 10 that indicates the number of characters to transmit    
  * Instance your UART transmitter from the first assignment and set the parameters of your transmitter based on the parameters of your top-level testbench
  * Instance your receiver module and hook up the transmitter to the receiver (set the parameters of your receiver)
    * Hook up the 'transmit out' signal from the transmitter to the 'receive in' signal of the receiver (simulate a loop back)
  * Generate a free oscillating clock
  * Create a testbench task that takes as input an 8-bit value to send. Write this task to do the following:
    * Set the value to send based on the parameter of the task
    * Assert the transmitter start signal
    * Make sure that the transmitter busy signal is asserted
    * Wait until the transmitter is no longer busy and print a message based on the value received by the receiver:
      * Print an "ok" message if the value received is the same as the value sent
      * Print an "error" message if the value received is not the same as the value sent
  * Create an `initial` block that manages the testbench as follows:
    * Provide a few clocks to the receiver/transmitter with undefined inputs. This should put both modules in a bad state
    * Provide initial default values for the inputs to your modules (but do not start the receiver)
    * Provide a few more clocks to clock in these inputs
    * Issue a reset by waiting a few clock cycles, issuing the reset for a few clock cycles, and then deasserting the reset
    * Create a loop that iterates `NUMBER_OF_CHARS` as follows:
      * Wait a random number of clock cycles before starting a transmission (you can choose the range)
      * Call the task to send a random 8-bit value
    * End the simulation with `$stop`

You may want to review the [testbench](../tx_sim/tx_tb.sv) that was created for you in the previous assignment as an example to get started.
 -->

### Receiver Synthesis

Although we will not be downloading the receiver to the FPGA, you should still synthesize your receiver to make sure it is synthesizable.
For this step, perform "out of context" synthesis on your receiver module.
"Out of context" means that the synthesizer will not put I/O buffers on your module and will synthesize your module as if it were a black box.
The following Vivado commands demonstrate how to synthesize your receiver module in "out of context" mode:

```
read_verilog -sv rx.sv
synth_design -top rx -mode out_of_context
```
Create a make rule `synth_rx` that will synthesize your receiver module and generate a log file named `synth_rx.log` for this step.
Review the synthesis log for the state encoding and add the encoding to your report.

Create a make rule `synth_rx_gray` that will synthesize your receiver using a gray code encoding.
Add the flag `-fsm_extraction gray` to your synthesize command to force a gray encoding.
Review the synthesis log for the state encoding and add the encoding to your report.

## Seven Segment Display

For this assignment and for most future assignments you will need to display values on the seven segment display of the Nexys4 DDR board.
To make this easier, you will create a seven segment display controller that will drive the seven segment display.

Create a "seven segment controller" module named `seven_segment8` in a file named `seven_segement8.sv` that will drive the seven segment display of the Nexys DDR board. 
This module can be based on the [seven segment display](https://byu-cpe.github.io/ecen320/labs/multi-segment/) module developed in ECEN 320.
Note that there are eight digits on the seven segment display for this board so you will need to support all eight digits with your module. 
Include the following ports and parameters in your module:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| data_in | Input | 32 | 32-bit value to display |
| dp_in | Input | 8 | Digit point (one for each segment) |
| blank | Input | 1 | When asserted, blank the display |
| segment | Output | 8 | The seven segment drivers (see table below) |
| anode | Output | 8 | Anode signal for each digit |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUECY | 100_000_000 | The clock frequency |
| REFRESH_RATE  | 200 | Specifies the display refresh rate in Hz  |
 
<!-- 
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
 -->

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

The seven segments are organized into a multi-bit bus (segment[6:0]) where segment(6) corresponds to segment 'A' and segment(0) corresponds to segment 'G'.
segment[7] corresponds to the digit point.

**Note**: The seven segment ordering for the 320 lab instructions are different for this board.
For the ECEN 320 lab, segment(0) corresponds to segment 'A' and segment(6) corresponds to segment 'G'.
For this board, segment(6) corresponds to segment 'A' and segment(0) corresponds to segment 'G'.

### Seven Segment Display Testbench

A testbench ([ssd_tb.sv](ssd_tb.sv)) is provided for you to validate your seven segment display controller.
There is also a simulation model ([seven_segment_check.sv](seven_segment_check.sv)) of the SSD controller that you will need to compile with your testbench.
Make sure your seven segment display controller passes this testbench before moving on to the next step.
Create a makefile rule `make sim_ssd` for this simulation.

### Seven Segment Display Synthesis

After your seven segment display controller is working correctly, create a makefile rule `make synth_ssd` that will synthesize your controller in out-of-context mode.
Create a file `synth_ssd.log` file for this synthesis process.

## Assignment Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Add all of the required makefile rules and execute the `passoff.py` script
1. You need to have at least 4 "Error" commits in your repository
2. Assignment specific Questions:
    1. Provide a table listing the state and the encoding that the synthesis tool used for your receiver state machine.
    1. Indicate what type of 'encoding' style was used for your state machine (search for the phrase "using encoding '<style>' in module '<module>'" in the synthesis log file)
    1. Indicate the total number of "cells" generated by the synthesis tool

<!--
Future Changes:
* Have them read through the testbench in some detail and answer questions about the testbench. They are not writing testbenches but I should ask them to read through it and understand it.
* The synthesis tool couldn't extract a FSM from some students. Need to figure out what is going on. Perhaps make a requirement that it has to find it?
-->