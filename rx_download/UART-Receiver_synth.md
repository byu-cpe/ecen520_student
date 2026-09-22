

# UART Receiver Synthesis and Download

The purpose of this assignment is to create a top-level UART receiver/transmitter in SystemVerilog and a testbench to validate your receiver.
<!-- You will also create a seven segment display controller for displaying data from your UART on the seven segment display. -->

## Top-Level Design

Create a top-level module named `rxtx_top` in a file named `rxtx_top.sv` that uses the following top-level ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| SW | Input | 8 | Switches (8 data bits to send) |
| BTNC | Input | 1 | Control signal to start a transmit operation |
| BTND | Input | 1 | Blank the seven segment display |
| LED | Output | 16 | Board LEDs (used for data and busy) |
| UART_RXD_OUT | Output | 1 | Transmitter output signal |
| UART_TXD_IN | Input | 1 | Receiver input signal |
| LED16_B | Output | 1 | Used for TX busy signal |
| LED17_R | Output | 1 | Used for RX busy signal |
| LED17_G | Output | 1 | Used for RX error signal |
| AN | Output | 8 | Anode signals for the seven segment display |
| CA, CB, CC, CD, CE, CF, CG | Output | 1 bit each | Seven segment display cathode signals |
| DP | Output | 1 | Seven segment display digit point signal |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| BAUD_RATE | 19_200 | Specify the receiver baud rate |
| PARITY | 1 | Specify the parity bit (0 = even, 1 = odd) |
| REFRESH_RATE  | 200 | Specifies the display refresh rate in Hz of seven segment display |
| DEBOUNCE_TIME_US | 10_000 | Specifies the minimum debounce delay in micro seconds (10 ms) |

Design your top-level circuit as follows:
* Attach the `CPU_RESETN` signal to two flip-flops to synchronize it to the clock. Use this synchronized signal for the reset in your design (note that the input reset polarity is negative asserted)
* Hook up the center button (BTNC) to your circuit through a debouncer. Make sure you pass in the top-level debounce time parameter. Create one-shot logic for the tx_write signal from the debounce output.
* Instance your transmitter
  * Hook the TX output signal to a flip-flop to remove glitches. Attach the output of the flip-flop to the top-level `UART_RXD_OUT` pin of the board (i.e., to the host)
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART).
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the tx busy signal to the LED16_B signal to provide a blue LED indicator when the transmitter is busy
* Instance your receiver
  * Add a two flip-flop synchronizer between the RX input signal (`UART_TXD_IN`) and the input rx signal to your receiver. This is necessary to avoid metastability and properly synchronize the asynchronous input.
  * Hook up the upper 8 LEDs to the data received by your receiver. These LEDs should display the last value received by the receiver.
  <!-- You should only update these LEDs when the 'data_strobe' indicates a new character has been received -->
  * Attach the rx busy signal to the LED17_R signal to provide a red LED indicator when the receiver is busy
  * Attach the rx error signal to the LED17_G signal to provide a green LED indicator when the receiver has an error
* Create four 8-bit registers that hold the last four values received by your receiver
  * When a new character has been  received, load the value received by the receiver into the first register and shift the values in the other registers.
* Instance your seven segment display controller as described below
  * Drive the data to display with the four 8-bit registers described above. The most recent value received should be driven on the right two digits, the second value received should be driven on the left two digits, and so on.
  * Drive all zeros on the digit point input (no digit points should be displayed).
  * Hook up the BTND signal through two synchronizing flip-flops and then to the "blank" signal (so you can blank the display when pressing BTND)
  * Hook up the seven segment display outputs to the top-level outputs of the design (i.e., AN, CA, CB, CC, CD, CE, CF, CG, DP)

### .xdc File

Once you have created your top-level design, create a `.xdc` file that maps the top-level pins of your circuit to the appropriate FPGA pin on this board.
Make sure all of the top-level ports have a corresponding entry in the .xdc file.

### Synthesize Top-Level Design

After creating a complex top-level design like this, it is sometimes preferrable to perform synthesis before simulation just to make sure you hooked up the modules correctly and are following all synthesis rules.
Create a makefile rule named `synth_rxtx_top` that runs the synthesis step of your design (not the implementation or bitstream generation).
This rule should generate the following files:
  * a log file named `synth_rxtx_top.log`
  * a synthesis checkpoint file named `rxtx_top_synth.dcp`

You will likely need to make changes to your design to address synthesis related errors.
At this point, don't worry about the design correctness. 
The purpose of the synthesis step is to resolve structural design issues before simulation.

## Top-Level Verification

In this phase of the assignment you will be verifying your design to make sure it works before proceeding with implementation and download.

<!-- 
### Top-level .do files
 -->

### Top-level testbench

Create testbench for your top-level rx/tx design named `rxtx_top_tb` in a file named `rxtx_top_tb.sv`.
You may model this testbench after the [tx_top_tb.sv](../tx_download/tx_top_tb.sv) file from the tx download assignment.
Include each of the following in your top-level testbench:
* Parameters for all parameters of your top-level design. Modify the testbench parameters as follows:
  * DEBOUNCE_TIME_US = 10
  * REFRESH_RATE = 2_000
* Create a parameter named `NUMBER_OF_CHARS` with a default of 8 that indicates how many characters to test
* Generate a free running clock
* Instance the [gen_bounce.sv](../tx_download/gen_bounce.sv) module to simulate button bouncing and pass in the DEBOUNCE_TIME_US parameter to the WAIT_TIME_US parameter
* Instance your top-level design and hook up testbench signals to the ports
* Attach the `UART_RXD_OUT` output of your top-level design (i.e., transmitter output) to the `UART_TXD_IN` input of your top-level design (i.e., receiver input). This way when you transmit a character from your transmit module, it will be received by your receiver module.
* Hook up the [seven_segment_check.sv](../rx_sim/seven_segment_check.sv) model to your top-level design so you can see the output of the seven segment display (see [ssd_tb.sv](../rx_sim/ssd_tb.sv))

Create an initial block and other testbench logic that does the following:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switchces)
  * Wait for a few clock cycle, Assert the reset for a few clock cycles, Deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform N character transfers (where N=NUMBER_OF_CHARS) as follows:
    * Choose a random value for the character you want to send
    * Set the switch values to this value
    * Make sure the LEDs follow the switches
    * Press btnc long enough to make it through your debouncer
      * Print a message when transmission starts: "Transmitting character 0x%x"
    * Wait until the tx_busy and rx_busy LED values are both zero
    * Check to make sure the upper LEDs match the value you sent. 
      * Print a message if the transmission is successful or if it was a failure
    * Check to make sure there is no error
  * At the end of the simulation print the following message:
    * "Successful transmission of %d characters" if all character transmissions were successful
    * "ERROR: %d errors in simulation" if there were any errors

Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_rxtx_top` that will perform this simulation from the command line and save the results to a file named `sim_rxtx_top.log`.

<!-- When simulating, you can [change the top-level parameters](../resources/vivado_command_line.md#setting-parameters-for-synthesis) of your testbench or module to simulate different conditions of your system. -->

Create another makefile rule named `sim_rxtx_top_115200_even` that will simulate your top-level design with a baud rate of 115200 and even parity and generate a log file named `sim_rxtx_top_115200_even.log`.

<!-- You will need to add the command line option to change the baud rate of your top-level design as described [here](../resources/vivado_command_line.md#setting-parameters-for-synthesis). -->

## Implementation and Download

At this point you are ready to implement your design, generate a bitfile and download it to your board.
Ideally, you will just synthesize your design, generate a bitfile, and it will work the first time you download it.
In reality, most people will have to go through this process a few times to resolve synthesis and implementation issues.
**Make sure you keep track of the number of times you 'synthesize' and the number of times you 'download' your bitstream.** 
This will be required for your assignment report.

Create a new makefile rule named `implement_rxtx_top` that performs placement and routing on your top-level design using the `rxtx_top_synth.dcp` checkpoint generated by the `synth_rxtx_top` rule.
This rule should generate the following files:
  * a log file named `implement_rxtx_top.log`
  * an implementation checkpoint file named `rxtx_top.dcp`
  * a bitfile named `rxtx_top.bit`
  * a utilization report named `utilization.rpt` and a timing report named `timing.rpt`

Download your design to your board and use 'putty' to make sure the UART receiver is working correctly using Putty or some other terminal emulator.
You will need to transmit signals from 'putty' to your board, you can do this by pressing 'ctrl+j' in the 'putty' emulator, and then using your keyboard to send char values.
**Note**: Make sure your seven segment display operates correctly and does not flicker (you will lose points if your display is not working correctly).

After demonstrating that your uart works properly, create a bitfile that operates with a baud rate of 115200 and even parity.
To generate such a bitfile you will need to change the top-level BAUD_RATE parameter to 115200 and the PARITY parameter to 0 during the logic synthesis.
Instructions for setting top-level parameters during synthesis can be found [here](../resources/vivado_command_line.md#setting-parameters-for-synthesis).
Create a makefile rule named `synth_rxtx_top_115200_even` that synthesizes your design with these parameters and generates the following files:
  * a log file named `synth_rxtx_top_115200_even.log`
  * a synthesis checkpoint file named `rxtx_top_115200_even_synth.dcp`

Then create a makefile rule named `implement_rxtx_top_115200_even` that performs placement and routing using the `rxtx_top_115200_even_synth.dcp` checkpoint and generates the following files:
  * a log file named `implement_rxtx_top_115200_even.log`
  * an implementation checkpoint file named `rxtx_top_115200_even.dcp`
  * a bitfile named `rxtx_top_115200_even.bit`
  * a utilization report named `utilization_115200_even.rpt` and a timing report named `timing_115200_even.rpt`

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
    * `sim_rxtx_top`: performs command line simulation of the top-level testbench (`rxtx_top_tb.sv`) and generates `sim_rxtx_top.log`
    * `sim_rxtx_top_115200_even`: performs command line simulation of the top-level testbench at 115200 baud with even parity and generates `sim_rxtx_top_115200_even.log`
    * `synth_rxtx_top`: synthesizes `rxtx_top.sv` and generates `synth_rxtx_top.log` and `rxtx_top_synth.dcp`
    * `synth_rxtx_top_115200_even`: synthesizes `rxtx_top.sv` at 115200 baud with even parity and generates `synth_rxtx_top_115200_even.log` and `rxtx_top_115200_even_synth.dcp`
    * `implement_rxtx_top`: implements `rxtx_top_synth.dcp` and generates `implement_rxtx_top.log`, `rxtx_top.dcp`, `rxtx_top.bit`, `utilization.rpt`, and `timing.rpt`
    * `implement_rxtx_top_115200_even`: implements `rxtx_top_115200_even_synth.dcp` and generates `implement_rxtx_top_115200_even.log`, `rxtx_top_115200_even.dcp`, `rxtx_top_115200_even.bit`, `utilization_115200_even.rpt`, and `timing_115200_even.rpt`
3. Tag your repo 'rx_download'
4. Complete the assignment specific questions in your report

<!-- 2. You need to have at least 5 "Error" commits in your repository -->

<!--
Notes:
-- Any _new_ coding standards to add? It would be nice to add something for this assignment
  ? Experiment with different encoding styles?
  - Note that many studens struggled debugging their receiver and the transmitter model at the same time. It wasn't clear which one has the problem.
     - Suggestion: create a top-level testbench that just hooks up my receiver model to their transmitter model and is used to validate their transmitter 

- Future:
  - Describe how to use seven segmetn checker model. This way, they can have a known good transmitter model to test their receiver.
-->
