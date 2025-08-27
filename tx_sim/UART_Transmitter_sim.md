# UART Transmitter Simulation

For this first assignment, you will be designing and simulating a UART transmitter.
Hopefully this assignment will be more of a review as the design of a UART transmitter is a common exercise in many introductory digital design courses.
The purpose of this assignment is to help you review your digital design skills and help you become familiar with the simulation tool.
You will not be synthesizing and downloading your design in this lab as you will focus primarily on design and simulation. 
You will synthesize and download the design in the next lab.

## Assignment Mechanics

Assignments play an important part of this class and much of your learning and skill development will occur while you complete assignments.
To complete and submit your assignments, you will need to follow the [assignment mechanics](../resources/assignment_mechanics.md) for the class.
Carefully review these guidelines before proceeding with this assignment.

### Create a GitHub Repository

As described in the [assignment mechanics](../resources/assignment_mechanics.md#github) page, you will need to submit your laboratory assignments using GitHub. 
When you have created your repository, add me as a collaborator as instructed in the mechanics web page.

You must place your assignment code within a specific assignment directory as described in the [assignments overview](../Readme.md) page.
Make sure your add this directory to your repository and place all assignment specific code in this directory.
You will also need to tag your repository when you are ready to submit.

### Perform Regular GitHub commits

As described in the [assignment mechanics](../resources/assignment_mechanics.md#github-commits) page, you will need to make regular commits to your repository as you complete your assignment.
Assignments submitted with only a single commit and no error examples will be penalized.

## Tools for this Assignment

Throughout this class you will learn to use a variety of tools to complete the assignments.
In this assignment you will need to use the following tools: [VSCode](https://code.visualstudio.com/) for text entry and QuestaSim for simulation.
You will learn about other tools (including the FPGA tools) in future assignments.

### VSCode

We will be using a number of different tools throughout the semester and many of these tools have an integrated text editor.
It is strongly recommended that you use [VSCode](https://code.visualstudio.com/) for all your text editing needs.
We will use the command line version of most of these tools and thus will rely on VSCode for all text editing.
VSCode is a free, open-source text editor that is available for Windows, Linux, and MacOS.
In addition to editing your files, you can also use VSCode to manage the GitHub repository for your assignments (commit, pull, push, etc.).
You will be much more productive in this class if you learn how to use VSCode proficiently.

I recommend that you install the [Verilog-HDL/SystemVerilog/Bluespec SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) extension for VSCode to assist with syntax highlighting and other features.

### QuestaSim

For this assignment you will be using QuestaSim as a simulator to simulate your design.
QuestaSim is a commercial HDL simulator that is used in the design of large, complex ASICs and will be the simulator we use for this course.
QuestaSim has been installed on the computers in the digital lab and the embedded systems lab (see this link for [setting up your environment](../resources/tools.md#questasim-setup) to use these tools).

Go through the [QuestaSim Tutorial](../resources/questa_tutorial.md) to learn how to use QuestaSim in both GUI and command line mode.
You will need to use the command line mode for submitting this assignment.

## UART Transceiver Design

The primary goal of this assignment is to design a UART transmitter for transmitting data over a conventional serial connection.
You will need to create this design in *SystemVerilog* and simulate it using QuestaSim.
There is a ECEN 320 lab description for a [UART Transceiver](https://byu-cpe.github.io/ecen320/labs/lab-09/) that you can use as a reference.

Create your transmitter with the filename `tx.sv` with the following ports and parameters (you must name the ports and parameters as indicated for the testbenches to operate correctly):

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ---- |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| send | Input | 1 | Control signal to start a transmit operation |
| din | Input | 8 | 8 data bits to send |
| busy | Output | 1 | Indicates that the transmitter is in the middle of a transmission |
| tx_out | Output | 1 | Transmitter output signal |

| Parameter Name | Type | Default | Purpose |
| ---- | ---- | ---- | ---- |
| CLK_FREQUENCY | integer | 100_000_000 | Clock frequency of the design |
| BAUD_RATE | integer | 19_200 | Baud rate of the design |
| PARITY | integer | 1 | Parity type (0 = Even, 1 = Odd) |

Design your transmitter to operate as follows:
* Determine the baud period based on the clock frequency and baud rate parameters
* Generate your UART transmission signal as follows:
  * Send a start bit (low)
  * Send 8 data bits
  * Send a parity bit (Based on the parity parameter)
  * Send 1 stop bit
* The 'tx' signal starts out high on reset (not low!). This is to prevent any inadvertent characters from being sent when your module is reset
* The 'busy' signal is asserted whenever you are in the middle of a transmission (i.e., not in an idle state)
  * Ignore the 'send' signal if you are in the middle of a transmission
* Reset the internal state machines/counters when the 'rst' signal is asserted
  * Use asynchronous resets for the synchronous elements of your design
* Add a synchronizing flip-flop on the output of the TX signal so there are no glitches on your output tx signal
* You do not need to implement handshaking as described by the 320 lab assignment.
* Make sure you have a reset clause on all of your 'always_ff' blocks.
Note that you must follow the [Level 1](../resources/coding_standard.md#level_1) coding standards for your Verilog files.

## Simulating Transmitter

Simulate the transmitter in Modelsim with the GUI to see if your module operates properly.
Simulation `.do` files can be used to interactively simulate your file.
The [sim_tx.do](sim_tx.do) file can be used to simulate a simple transmission.
Use this simulation file to make sure your module properly simulates a full byte.
After properly simulating your module, take a screen shot of your modelsim waveform and make sure your state machine variables are included in the waveform.
Name your simluation file `tx_sim.png` and include it in your repository.

After verifying that your module can properly simulate a single byte, create a new simulation file named `long_sim.do` that simulates the transfer of four bytes.
Make sure there is at least 50 us of delay between the transmissions. 
Transmit two bytes that have an odd number of bits and two bytes with an even number of bits to verify the operation of your parity generation circuit.

## Transmitter Testbench

An essential part of digital design is properly _verifying_ your design.
For this design and all designs you create in this class you will be carefully verifying with a design testbench.
<!--
TCL command tutorial?

You may want to simulate your design using a `.tcl` file during the early stages of your design process.
There are tutorials for using TCL on the 320 page [here](https://byu-cpe.github.io/ecen320/tutorials/lab_03/04_tcl_tutorial/) and [here](https://byu-cpe.github.io/ecen320/tutorials/lab_04/00_tcl_tutorial_2/).
Note that you are not required to simulate with `.tcl` files and such files will not be graded as part of this assignment.
-->
We will be using and writing testbenches through the semester to help aid in your verification efforts.
A testbench, [tx_tb.sv](./tx_tb.sv), has been created for you to test your transmitter.
This testbench also includes a behavioral model of a simple UART "receiver", [rx_model.sv](./rx_modelsv).
You will need to test your transmitter with this testbench (and associated model) and make sure it operates without any warnings or errors.

Although you are free to use the GUI version of the ModelSim tools during the development process, you will be required to build your project using the command line.
All grading of your assignment will be done by building your project using the command line. 
This will involve creating a `makefile` with a number of rules for simulating and synthesizing your project.
<!--
A resource page with instructions for using the Vivado [command line](../resources/vivado_command_line.md) is available for you.
-->
When your transmitter operates correctly with the testbench, create a makefile with the `sim_tx` rule that will simulate your transmitter with the testbench from the command line.
Here is a sample makefile rule that will run the testbench simulation from the command line (you may need to adapt this to the names used by your design files):
```
sim_tx: tx.sv
    vlog tx.sv tx_tb.sv rx_model.sv
    vsim -c work.tx_tb -do "run -all; quit"
```
**Note** the use of the `quit` command in the `vsim` command.
This is necessary to exit the simulation after the simulation is complete so you can go on to the next makefile rule.

You will need to verify that your transmitter works correctly with multiple baud rates and clock frequencies.
Further, you need to verify that your transmitter works with both even and odd parity.
You will need to create a makefile rule named `sim_tx_115200_even` that command line simulation of tx testbench with a baud rate of 115200 and even parity.
The following makefile rule demonstrates how to elaborate the simulation model with different top-level parameters:

```
sim_tx_115200_even: tx.sv
    vlog -sv tx.sv tx_tb.sv rx_model.sv
    vsim -c work.tx_tb -gBAUD_RATE=115200 -gPARITY=0 -do "run -all; quit"
```
**Note**: You can't use an underscore in the parameters on the command line (i.e., -gBAUD_RATE=115_200 will not work).

After your module passes both testbenches you are ready to submit your assignment.

## Assignment Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
    * `sim_tx`: performs command line simulation of tx testbench using the default parameters
    * `sim_tx_115200_even`: performs command line simulation of tx testbench with a baud rate of 115200 and even parity
1. Make sure you have committed your `tx_sim.png` waveform simulation file. Also, make sure you have committed the `long_sim.do` simulation file.
1. You need to have at least 3 "Error" commits in your repository as described [here](../resources/assignment_mechanics.md#github-commits).
2. Complete the [report.md](report.md) file in your assignment directory.

<!-- Notes:
- Need to help people learn how to use the GUI simulator. They just tried using the command line only. (Maybe a tutorial on how to use the GUI simulator?)
- Need to have a way for the testbench to generate an error when there is a problem so the python file catches the error.
-->