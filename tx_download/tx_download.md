
# TX Download

For this assignment you will create a top-level design for your UART transmitter, synthesize the transmitter, and download it to the FPGA board.

**Assignment reminders**

As with the previous assignment, you must place your assignment code within a specific assignment directory as described in the [assignments overview](../README.md) page.
Make sure your add this directory to your repository and place all assignment specific code in this directory.
<!-- * You will also need to tag your repository when you are ready to submit.
* You are required to make frequent commits when you have design failures as described [here](../resources/assignment_mechanics.md#github-commits) -->


## Debouncer

You will need a "debouncer" circuit to debounce the button input sent to your TX module.
Without a debouncer, you will be sending multiple button presses to your TX module, which can cause it to transmit more than one byte every time you press the button.
Start this assignment by creating a debouncer module.
You will use this module in several of your future assignments during the semester.

A detailed description of the debouncer can be found in the ECEN 320 [debouncer lab](https://byu-cpe.github.io/ecen320/labs/debouncer/) under Exercise #1. 
Create your debouncer module using the same module name, ports, and parameters as listed in the ECEN 320 lab.
You are welcome to use the debouncer you created in a previous class, but you may need to modify the debouncer so that it matches the ports and parameters described in the ECEN 320 lab.

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

### Debouncer .do Simulation

Simulate the debouncer in Modelsim with the GUI to see if your module operates properly using the default module parameters.
Create a file named `debounce_sim.do` that adds waveform signals to the waveform viewer, stimulates the input by creating a few short pulses and then completes a full high to low and low to high transition on the debouncer output.
Set the WAIT_TIME_US time to 10 us for your simulation.
Include in the waveform view your state machine state and any counters used by the debouncer.
After properly simulating your module, take a screenshot of the Modelsim waveform showing the proper operation.
Name your screenshot `debounce_sim.png`

### Debouncer Testbench Simulation

When you have created your debouncer, simulate your debouncer with the testbench `tb_debouncer.sv` until your debouncer passes all tests.
This testbench uses a module `gen_bounce.sv` to generate a bouncy signal.
You will need to compile this file as well as part of the testbench.
Create a makefile rule named `sim_debouncer` that will perform this simulation from the command line using the default module parameters.
Save the output to a file named `sim_debouncer.log` 

The testbench has a short default WAIT_TIME_US for shorter simulations (5 us).
Create a makefile rule that simulates your debouncer with a WAIT_TIME_US = 10000 (10 ms).
Create a makefile rule named `sim_debouncer_10ms` that will perform this simulation from the command line.
Save the output to a file named `sim_debouncer_10ms.log` 

## Top-Level Transmitter Design

Create a top-level design that instances your debouncer and transmitter and hooks it up to the I/O pins of the FPGA board.
For this assignment and throughout the class we will be using the [Nexys4 DDR](https://reference.digilentinc.com/programmable-logic/nexys-4-ddr/start) board and the top-level ports will correspond to the port names on this board.
Create a top-level module named `tx_top` with the following ports and parameters (the port names are derived from the Nexys4 DDR XDC file):

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
  * Instance your transmitter component from the previous assignment (**Note**: do not copy your file into this assignment directory. Instead, use a relative path to the file in the previous assignment directory. If you need to make changes to the transmitter, make them in the previous directory. Your original submission should be properly tagged).
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART). Insert a register between the switches and the transmitter input to synchronize the input to the global clock.
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the `tx_busy` signal from your transmitter to the LED16_B signal. This is the "blue" color for tricolor LED 16 on the board (it should flash blue when the transmitter is busy)
  * Attach the CPU reset so that when pressed, the system will be reset (note that the input reset polarity is negative asserted). Add two synchronizing flip-flops between the reset button and your internal reset signal to synchronize the reset signal to the global clock.
  * Create the 'send' signal for your tx module from the 'BTNC' on the board
    * Add a two flip-flop synchronizer for the 'BTNC' button to synchronize the button to the global clock
    * Instance your debouncer module and hook up the output of the synchronizer to the debouncer module
    * Create a "one-shot" circuit on the output of the debouncer. The purpose of the one-shot circuit is to generate a single pulse when the button is pressed and to ignore any additional presses until the pulse has completed. If you do not add a one-shot circuit then the button press will be interpreted as multiple presses and multiple characters will be transmitted over the UART. The output of the one-shot circuit will go into the `send` input of your transmitter module.

You must follow the [Level 2](../resources/coding_standard.md#level_2) coding standards for your Verilog files.

### Top-Level .do Simulation

Simulate your top-level circuit with a .do file named `sim_tx_top.do`.
In this .do file, add waveforms for signals at the top-level, your internal transmitter, and the debouncer.
Simulate the top-level with the default baud rate and a debouncer wait time of 5us to make the simulation shorter.
Create a screenshot of the simulation and name it `sim_tx_top.png`.

### Top-Level Testbench

A top-level testbench, [top_tb.sv](./top_tb.sv), has been created for you to test your top-level design.
This testbench also uses the [rx_model.sv](../tx_sim/rx_model.sv) simulation model from the previous assignment and the gen_bounce.sv from this assignment.
Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_tx_top_tb` that will perform this simulation from the command line using the default parameters.
Save the output of this simulation to a file named `sim_tx_top_tb.log`
In addition, make a second makefile rule named `sim_tx_top_tb_115200_even` that performs this simulation with the parameters changed as follows: baud rate = 115200 and even parity (save the output to a file named `sim_tx_top_tb_115200_even.log`).
Do not proceed to the next step until you have successfully simulated your top-level design for both baud rates and parities.

## Design Implementation

After verifying your design, the next step in this assignment is to synthesize your design and download it to the FPGA board.
If your design is properly verified and written in a way that synthesizes without any problems then this step can be relatively easy.
For this class we will be using the command line tools in non-project mode for the synthesis and implementation.
This is unlike previous classes where you might have used the Vivado GUI and used Vivado projects to manage your implementation flow.
The following steps are needed to complete the design implementation:

1. Create .xdc constraints file
2. Synthesis
3. Implementation
4. Bitstream generation
5. Bitstream download

### 1. XDC Constraints File

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

### 2. Synthesis

The next step is to 'synthesize' your design into a 'netlist' mappex to the FPGA logic primitives.
Read through the following [synthesis tutorial](https://byu-cpe.github.io/ecen320/tutorials/vivado/vivado_command_line_synthesis/) to learn how to perform synthesis for your tx_top design.
Note that in this class we are using the `xc7a100tcsg324-1` part (you will need to change your synthesis scripts accordingly).

Create a makefile rule named `synth_tx_top` that does the following:
  * generates a log file named `synth_tx_top.log` of the synthesis process
  * generates a checkpoint file named `tx_top_synth.dcp`
Carefully review your synthesis log and make sure there are no Warnings.

In addition to synthesizing your design with default parameters, create a second makefile rule named `synth_tx_top_115200_even` that synthesizes your design with the parameters changed as follows: BAUD_RATE = 115200 and PARITY=0 (even parity).
This rule should generate:
  * a log file named `synth_tx_top_115200_even.log`
  * a checkpoint file named `tx_top_115200_even_synth.dcp`

To change the parameters during the synthesis step, you need to add additional parameters to the `synth_design` command in your synthesis .tcl script.
The following example demonstrates how to setup your parameters for this script:

```
synth_design -top tx_top -part xc7a100tcsg324-1 -verbose -generic {BAUD_RATE=115200} -generic {PARITY=0}
```

<!--
How many FDxE cells are used by the design?
How many total LUT resources are used by the design? (add up all the LUT* resources)
How many total IBUF and OBUF resources do you have in the design?
-->

### 3. Implementation

The implementation step involves converting the FPGA netlist into a design mapped on a specific FPGA and ultimately a bitstream.
The 'placement' step will place the primivites to specific sites on the FPGA.
The 'routing' step will route the nets in the design to specific FPGA routing resources.
The 'bitgen' step will convert the routed design into a bitstream that can be downloaded to the FPGA.
You will also generate reports during these steps and generate checkpoint of your final design.
Review the ECEN 320 [implementation tutorial](https://byu-cpe.github.io/ecen320/tutorials/vivado/vivado_command_line_implementation/) to learn how to do this in the command line.

Create a makefile rule named `implement` that does the following:
  * Performs placement and routing on your top level design using the `tx_top_synth.dcp` checkpoint file from the synthesis step
  * generates a log file named `implement.log` of the synthesis process
  * generates a dcp file named `tx_top_synth.dcp`
  * generates a bitfile named `tx_top.bit`
  * generates a utilization report named `utilization.rpt` and a timing report named `timing.rpt`  

In addition, create a makefile rule named `synth_115200_even` that generates the following files:
  * Performs placement and routing on your top level design using the `tx_top_115200_even_synth.dcp` checkpoint file from the synthesis step
  * generates a log file named `implement_115200_even.log` of the synthesis process
  * generates a dcp file named `tx_top_115200_even.dcp`
  * generates a bitfile named `tx_top_115200_even.bit`
  * generates a utilization report named `utilization_115200_even.rpt` and a timing report named `timing_115200_even.rpt`  

<!--
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
-->

## Design Download

After successfully synthesizing your design and generating a bitfile, download your design to a Nexys4 DDR board and demonstrate it working correctly. 
Instructions for downloading your design can be found [here](../resources/download.md).

Use the "Putty" tool to send characters from your board to the computer. 
There is a tutorial on [Putty](https://byu-cpe.github.io/ecen320/tutorials/lab_computers/putty/) that can help you run this tool.
After generating a bitstream, download your bitstream and make sure your transmitter bitstream works with a terminal emulator.
You may want to view an [ASCII Table](https://commons.wikimedia.org/wiki/File:ASCII-Table-wide.svg) to test a variety of characters.

Make sure you try both bitfiles and configure putty to operate with each bitfile separately.
Your bitfiles will be downloaded and verified as part of the grading process.

<!--
(didn't work for me)
screen /dev/ttyUSB2 115200,cs8,parenb,-parodd,-cstopb
-->

## Common Problems

* Incorrectly set the terminal settings. In particularly, not setting "parity = odd". If you leave parity to none then you may get incorrect results.
* `PuTTY: unable to load font "server:fixed"`. Go into 'fonts', click 'Change', and select a font such as 'Ubuntu Mono'.

## Assignment Submission

The following assignment specific items should be included in your repository:

1. Implement all of the makefile rules described above
    <!-- * `sim_debouncer`: Simulate your debouncer
    * `sim_tx_top`:
    * `sim_tx_top_115200_even`:
    * `gen_tx_bit`: Generate a bitfile for your transmitter
    * `gen_tx_bit_115200_even`: Generate a bitfile for your transmitter with a baud rate of 115200 and even parity -->
2. You need to have at least 4 "Error" commits in your repository as described [here](../resources/assignment_mechanics.md#github-commits).
3. Assignment specific Questions: see the [report.md](./report.md) for assignment specific questions.

    <!-- 1. Determine the "Worst Negative Slack" (or WNS). This is found in the timing report and indicates how much timing you slack you have with the current clocking (we will discuss this later in the semester).
    1. Indicate how many times you had to synthesize your design
    1. Indicate how many times you had to download your bitstream before your circuit worked. Note that I want two numbers: number of synthesis attempts and number of download attempts. Do not mix these together. -->


<!--
Preparation:
- Make sure students can use putty on the lab machines. Try it out on the labs ahead of time.
Future Changes:
- Enforce certain warnings not showing up (CFG_Voltage, etc, parallel synthesis). Make it easier to earch for these warnings in grading.
- Better instructions on how to download
- Need to explain in more detail the need to carefully review the syntehsis logs. Perhaps provide a few examples of what to look for in the logs.
- We should be adding the following attribute to all synchronier flip-flops in the download labs. Add this to the tx_download and all future download labs
   (* ASYNC_REG = "TRUE" *) logic [31:0] ssd_sync;
* Suggestion 1 Make a note that the testbenches don't check for latches and that if your download fails but synthesis succeeds then this is a likely cause. 
Future Ideas:

-->