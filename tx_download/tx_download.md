
For this assignment you will create a top-level design for your UART transmitter, synthesize the transmitter, and download it to the FPGA board.

**Assignment reminders**

* As with the previous assignment, you must place your assignment code within a specific assignment directory as described in the [assignments overview](../README.md) page.
Make sure your add this directory to your repository and place all assignment specific code in this directory.
* You will also need to tag your repository when you are ready to submit.
* You are required to make frequent commits when you have design failures as described [here](../resources/assignment_mechanics.md#github-commits)

## Top-Level Transmitter Design

There are several steps needed to create a working UART transmitter design from your transmitter module from the last assignment.
You will need to create a top-level design that includes your transmitter module, a debouncer, and a one-shot detector.
You will need to create an xdc file that maps the pins of the FPGA to the ports of your design and you will need to run your full design files and xdc file through the Xilinx synthesis tools. 
The instructions below will guide you through these steps.

### Debouncer

Before creating the top-level design, create a debouncer module to debounce the buttons on the FPGA board.
A debouncer is needed to prevent a single press of the button from being interpreted as multiple presses and thus causing multiple characters to be transmitted over the UART.
You will use this module in several of your future assignments during the semester.

A detailed description of the debouncer can be found in the ECEN 320 [debouncer lab](https://byu-cpe.github.io/ecen320/labs/debouncer/) under Exercise #1. 
Create your debouncer module using the same ports and parameters as listed in the lab.
You are welcome to use the debouncer you created in a previous class but you may need to modify the debouncer so that it matches the ports and parameters described in the ECEN 320 lab.

<!--
Create a module named `debounce` with the following top-level ports and parameters:
| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ---- |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Synchronous reset |
| async_in | Input | 1 | Asynchronous input signal to be debounced |
| debounce_out | Output | 1 | Debounced output signal |

| Parameter Name | Type | Default | Purpose |
| ---- | ---- | ---- | ---- |
| DEBOUNCE_CLKS | integer | 1_000| Number of clocks for debounce delay |

There is a [lab description](https://byu-cpe.github.io/ecen320/labs/lab-08/) of a debouncer that you can use as a reference.
Your debouncer will need to have a parameter that specifies the number of clocks needed for the debounce delay.
This way you can simulate your debouncer with relatively short debounce times but synthesize your debouncer with a longer debounce time.

Design your debouncer with the following requirements:
* Place a two flip-flop synchronizer on the input `async_in` signal to synchronizer the input signal to the clock domain.
* Create a counter within your module to count the `DEBOUNCE_CLKS` before transitioning the output signal. You can use the `$clog2` function to determine how many bits are needed for the counter (i.e., `$clog2(DEBOUNCE_CLKS)`)
-->

When you have created your debouncer, simulate your debouncer with the testbench `debouncer_tb.sv` until your debouncer passes all tests.
Create a makefile rule named `sim_debouncer` that will perform this simulation from the command line using the default module parameters.

### Create a top-level FPGA design

Create a top-level design that instances your transmitter and hooks it up to the I/O pins of the FPGA board.
For this assignment and throughout the class we will be using the [Nexys 4 DDR](https://reference.digilentinc.com/programmable-logic/nexys-4-ddr/start) board and the top-level ports will correspond to the port names on this board.
Create a top-level module named `tx_top` with the following ports and parameters (the port names are derived from the nexys4 DDR XDC file):

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| SW | Input | 8 | Switches (8 data bits to send) |
| BTNC | Input | 1 | Control signal to start a transmit operation |
| LED | Output | 8 | Board LEDs (used for data) |
| UART_RXD_OUT | Output | 1 | Transmitter output signal |
| LED16_B | Output | 1 | Used for TX busy signal |

| Parameter Name | Type | Default | Purpose |
| ---- | ---- | ---- | ----  |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| BAUD_RATE | integer | 19_200 | Baud rate of the design |
| PARITY | integer | 1 | Parity type (0 = Even, 1 = Odd) |
| DEBOUNCE_TIME_US | integer | 10_000 | Specifies the minimum debounce delay in micro seconds (default 10 ms) |

Create your top-level design as follows:
  * Instance your debouncer module and hook up the `BTNC` button to the input of the debouncer. In addition, create a "one-shot" circuit on the output of the debouncer. The purpose of the one-shot circuit is to generate a single pulse when the button is pressed and to ignore any additional presses until the pulse has completed. If you do not add a one-shot circuit then the button press will be interpreted as multiple presses and multiple characters will be transmitted over the UART. The output of the debouncer plus one-shot circuits will go into the `send` input of your transmitter module.
  * Instance your transmitter component from the previous assignment (**Note**: do not copy your file into this assignment directory. Instead, use a relative path to the file in the previous assignment directory. If you need to make changes to the transmitter, make them in the previous directory. Your original submission should be properly tagged).
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART). Insert a register between the switches and the transmitter input to synchronize the input to the global clock.
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the `tx_busy` signal from your transmitter to the LED16_B signal. This is the "blue" color for tri-color LED 16 on the board (it should flash blue when the transmitter is busy)
  * Attach the CPU reset so that when pressed, the system will be reset (note that the input reset polarity is negative asserted). Add two synchronizing flip-flops between the reset button and your internal reset signal to synchronize the reset signal to the global clock. We will discuss the purpose of these synchronizing flip flops later in the class

**TODO**: Put the synchrnooizer in the top level design (not the debouncer)

Note that you must follow the [Level 2](../resources/coding_standard.md#level_2) coding standards for your Verilog files.

A top-level testbench, [top_tb.sv](./top_tb.sv), has been created for you to test your top-level design.
This testbench also uses the [rx_model.sv](../tx_sim/rx_model.sv) simulation model from the previous assignment.
Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_tx_top` that will perform this simulation from the command line using the default parameters.
In addition, make a second makefile rule named `sim_tx_top_115200_even` that performs this simulation with the parameters changed as follows: baud rate = 115200 and even parity.
Note that the testbench has significnatly shortened the debounce delay time to shorten the simulation.
Do not proceed to the next step until you have successfully simulated your top-level design for both baud rates and parities.

## Design Implementation

After verifying your design, the next step in this assignment is to synthesize your design and download it to the FPGA board.
If your design is properly verified and written in a way that synthesizes without any problems then this step can be relatively easy.
For this class we will be using the command line tools in non-project mode for the synthesis and implementation.
This is unlike previous classes where you might have used the Vivado GUI and used Vivado projects to manage your implementation flow.

### XDC Constraints File

The first step in this process is to create a top-level `.xdc` file that maps the top-level pins of your circuit to the appropriate FPGA pin on this board.
The easiest way to do this is to start with the master [`.xdc`](../resources/Nexys-4-DDR-Master.xdc) file for the Nexys 4 DDR board and uncomment the appropriate pins used by your design.
If you have named your top-level ports as suggested above, there is no need to edit the `.xdc` file.
If you named your top-level ports as described above, then you can uncomment the corresponding lines in the `.xdc` file.
Note that you have to uncomment both lines related to the clock (the pin constraint and the timing constraint).
In addition to the pin constraints, you will need to add the following constraints to your `.xdc` file to set the voltage and I/O standard for the pins:
```
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
```
Make sure you commit your `.xdc` file to your repository.

### Design Implementation Tutorial

You will need to perform the following steps on your design within the FPGA design implementation tools:
1. Synthesis
2. Placement
3. Routing
4. Report generation
5. Checkpoint generation
6. Bitstream generation

For this class, we will be using the command line version of the Vivado tools.
The [following tutorial](../resources/vivado_implementation.md) will guide you through the steps of implementing your design with the command line tools.

For this assignment you will need to create two different bitfiles:
* `tx_top.bit`: This uses the default parameters of your top-level design (i.e., default clock rate, 19_200 baud rate, odd parity, and debounce delay of 10 ms)
* `tx_top_115200_even.bit`: This bitfile should be generated with several changes to the top-level default parameters. BAUD_RATE = 115_200 and PARITY = 0.
You will need to have custom vivado tcl implementation scripts to generate these two files.

Create a makefile rule `gen_tx_bit` to generate the `tx_top.bit` bitfile and a makefile rule `gen_tx_bit_115200_even` to generate the `tx_top_115200_even.bit` bitfile.
The following example demonstrates such a rule.
```
gen_tx_bit:
  vivado -mode batch -source tx_top_synth.tcl
```

## Design Download

After successfully synthesizing your design and generating a bitfile, download your design to a Nexys4 DDR board and demonstrate it working correctly. 
Instructions for downloading your design can be found [here](../resources/download.md).

Use the "Putty" tool to send characters from your board to the computer. 
There is a tutorial on [Putty](https://byu-cpe.github.io/ecen320/tutorials/other/01_putty_setup/) that can help you run this tool.
After generating a bitstream, download your bitstream and make sure your transmitter bitstream works with a terminal emulator.
You may want to view an [ASCII Table](https://commons.wikimedia.org/wiki/File:ASCII-Table-wide.svg) to test a variety of characters.

<!--
(didn't work for me)
screen /dev/ttyUSB2 115200,cs8,parenb,-parodd,-cstopb
-->

## Common Problems

* Incorrectly set the terminal settings. In particularly, not setting "parity = odd". If you leave parity to none then you may get incorrect results.
* `PuTTY: unable to load font "server:fixed"`. Go into 'fonts', click 'Change', and select a font such as 'Ubuntu Mono'.

## Assignment Submission

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
    * `sim_debouncer`: Simulate your debouncer
    * `sim_tx_top`:
    * `sim_tx_top_115200_even`:
    * `gen_tx_bit`: Generate a bitfile for your transmitter
    * `gen_tx_bit_115200_even`: Generate a bitfile for your transmitter with a baud rate of 115200 and even parity
2. You need to have at least 4 "Error" commits in your repository as described [here](../resources/assignment_mechanics.md#github-commits).
3. Assignment specific Questions:
    1. The synthesis log will summarize any state machines that it created. Provide a table listing the state and the encoding that the synthesis tool used for your transmitter state machine.
    1. Provide a table summarizing the resources your design uses. Use the template table below. You can get this information from the implementation utilization report.
    1. Determine the "Worst Negative Slack" (or WNS). This is found in the timing report and indicates how much timing you slack you have with the current clocking (we will discuss this later in the semester).
    1. Indicate how many times you had to synthesize your design
    1. Indicate how many times you had to download your bitstream before your circuit worked. Note that I want two numbers: number of synthesis attempts and number of download attempts. Do not mix these together.


<!--
Preparation:
- Make sure students can use putty on the lab machines. Try it out on the labs ahead of time.
Future Changes:
- Enforce certain warnings not showing up (CFG_Voltage, etc, parallel synthesis). Make it easier to earch for these warnings in grading.
- Better instructions on how to download
- add instructions in the lab instructions for how to set a parameter from the TCL script
- Need to explain in more detail the need to carefully review the syntehsis logs. Perhaps provide a few examples of what to look for in the logs.
- Have them save the synthesis and implementation logs as a specific file in their directory that we can look at later
- The debounce module uses clock cycles, but tx_top uses microseconds. The need to translate wasn't clear until I was failing testbenches.
- Several students had problems with the debouncer parameters. They would do a multiplication that resulted in a large number that didn't fit in 32 bits and then when dividing they would have an invalid number. Provide additional instructions or more exmaples on how to create this parameter without the overflow issue.
  - Related to this, we need to have a testbench for the debouncer at the larger time scale so that we can catch this in simulation.
- We should be adding the following attribute to all synchronier flip-flops in the download labs. Add this to the tx_download and all future download labs
   (* ASYNC_REG = "TRUE" *) logic [31:0] ssd_sync;
* Suggestion 1 Make a note that the testbenches don't check for latches and that if your download fails but synthesis succeeds then this is a likely cause. 
Future Ideas:
  - Have them experiment with different state encoding values to see how it affects reousrce utilization.

-->