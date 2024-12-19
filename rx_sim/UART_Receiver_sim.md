
# UART Receiver and Testbench

The purpose of this assignment is to create a UART receiver module and verify that it operates correctly with a custom testbench.

## UART Receiver Module

The primary goal of this assignment is to design a UART receiver module that can receive data from a UART transmitter.
Create a UART receiver module that actively monitors the input "data in" signal receives a single byte of data and a parity bit.
There is a ECEN 320 lab description for the [UART Receiver](https://byu-cpe.github.io/ecen320/labs/lab-11/) but the requirements for this receiver may be slightly different.

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
  * A '0' is not sampled in the middle of the first start bit
  * The received parity is incorrect
  * A stop bit is not received (i.e., you do not receive a '1' in the middle of the stop bit)

<!--
    If you get a reset and the input din is a '0' then you should go to some sort of "Startup" type state that just sits there and waits until din goes high. Once din goes high you can go into an idle state to wait for din to go to 0 again. The reason for this is that you do not want to just immediately start receiveing a character upon reset. You want to start up in a known state.
-->

Note that you must follow the [Level 2](../resources/coding_standard.md#level-2) coding standards for your Verilog files.

## Receiver Testbench

Create a dedicated testbench for your receiver with the following requirements:
  * Provide the parameters of BAUD_RATE and PARITY to your receiver module so you can change the baud rate and parity in your testbench
  * Provide a testbench parameter `NUMBER_OF_CHARS` with a default value of 10 that indicates the number of characters to transmit    
  * Instance your UART transmitter from the first assignment and set the parameters of your transmitter based on the paramters of your top-level testbench
  * Instance your receiver module and hook up the transmitter to the receiver (Again, set the parameters of your receiver)
    * Hook up the transmit out signal from the transmitter to the receive in signal of the receiver (simulate a loop back)
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
You may refer to and model your testbench after the [ECEN 220 Transmitter testbench](http://ecen220wiki.groups.et.byu.net/resources/testbenches/tb_tx.sv) as well.
When your transmitter operates correctly with the testbench, create a makefile with the `sim_rx` rule that will simulate your transmitter with the testbench from the command line.
In addition, create a makefile rule `sim_rx_115200_even` that simulates the receiver with a baud rate of 115200 and even parity.

## Receiver Synthesis

Although we will not be downloading the receiver to the FPGA, you should still synthesize your receiver to make sure it is synthesizable.
For this step, perform "out of context" synthesis on your receiver module.
"Out of context" means that the synthesizer will not put I/O buffers on your module and will synthesize your module as if it were a black box.
The following Vivado commands demonstrate how to synthesize your receiver module in "out of context" mode:

```
read_verilog -sv rx.sv
synth_desig -top rx -mode out_of_context
```
Create a make rule `synth_rx` that will synthesize your receiver module and make sure to generate a log file for this step.

## Assignment Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
    * `sim_rx`: 
    * `sim_rx_115200_even`: 
    * `synth_rx`:
1. You need to have at least 4 "Error" commits in your repository
2. Assignment specific Questions:
    1. Provide a table listing the state and the encoding that the synthesis tool used for your receiver state machine.
    1. Indicate what type of 'encoding' style was used for your state machine (search for the phrase "using encoding '<style>' in module '<module>'" in the synthesis log file)
    1. Indicate the total number of "cells" generated by the synthesis tool

<!--
Future Changes:
* The synthesis tool couldn't extract a FSM from some students. Need to figure out what is going on. Perhaps make a requirement that it has to find it?
* ask them to manually change the FSM encoding type when thhey synthesize to see the impact.
* Any _new_ coding standards to add? It would be nice to add something for this assignment
* Have them create a function in the testbench
* Be more clear on what should be in the report for cells
-->