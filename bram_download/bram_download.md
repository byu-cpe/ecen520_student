# BRAM Download

In this assignment you will create a top-level design that instances your BRAM modules and interfaces them to your UART transmitter and receiver.

## Top-Level Design

Create a top-level design that instantiates both the FIFO and the ROM modules from the previous assignment.
Design your top-level design to operate as follows:
* Instance your UART transmitter and receiver and connect them to the top-level UART ports
* When the **left** button is pressed, the _entire_ ROM contents are sent over the UART transmitter one character at a time. Ignore any button presses that may occur until the entire ROM has been sent. You will need to implement flow control so that you don't send another character until the previous character has been sent.
* When characters are received by the UART receiver, they are placed in the BRAM FIFO.
* When the **right** button is pressed, your circuit should send each character received in the BRAM over the UART back to the host until the BRAM FIFO is empty. Ignore any button presses that may occur until the entire FIFO has been sent. After sending the full contents of the FIFO, reset your counters so that you only send the new data received after the button has been pressed (you don't want to send the data received more than once).
* Use `LED16_B` for the TX busy signal, `LED17_R` for the RX busy signal, and `LED17_G` for the RX error signal.

## Testbench

Create a top-level testbench that instantiates your design and simulates the behavior of the top-level design.
* Instance your top-level design
* Add your UART transmitter to the testbench and connect it to the RX input of your top-level design. You will send characters to your top-level design with your transmitter module
* Add your UART receiver to the testbench and connect it to the TX output of your top-level design. You will use your receiver module to receive and check chacters from your top-level design. Print a message when a new character is received.
* Perform the following functions in your testbench:
  * Initialize and reset your design
  * Have your testbench transmitter send the characters "Hello World" to your top-level design
  * Press the left button to send the fight song over the transmitter
  * Press the right button to send the buffered data over the transmitter
  * Press the left button again to see the fight song a second time

Create a makefile rule `sim_bram_top` that performs this simulation from the command line.
Feel free to change the generics to use a much faster baud rate for your UART to speed up the simulation time (same with a smaller debounce delay).

## Synthesis, Implementation, and Bitstream Generation

Create a makefile rule `gen_bit` that generates a bitstream for your top-level design.
During the synthesis process, create a design checkpoint file (`.dcp`) for your top-level design as you will need to use it as described below.
Set the generics for the generated bitfile as follows:
* `BAUD_RATE` = 115200
* `PARITY` = 0
* `FILENAME` = "fight_song.mem"

**Make sure** the synthesis log shows that two RAMB36E1 primitives were allocated for your module.
If you do not have 2 BRAMs then your design will not work and you should not proceed with the further steps.

## Design Evaluation

After successfully implementing your design, open your design in the Vivado GUI fpga_editor tool.
To open the tool, run these steps:
* Open the Vivado GUI
* Load your design by running the command: `open_checkpoint bram_top.dcp`
* The FPGA editor tool should be open

### FPGA Layout Tool

Once you have opened the FPGA editor tool, perform the following steps.
The results of these steps need to be included in your assignment report.
* Take a screen shot of the laytout of the design on the device (centered on where your logic is) 
* Locate the two BRAMs used by your design and determine the location site of each of the BRAMs and report (RAMB36_XxYx)

### Design Timing Analysis

Carefully review the timing analysis file for your design.
From this file, answer the following questions in your report:
* Determine the worst case negative slack
  * What clock rate could you safely run your design?
* How many design endpoints are there in your design?
* Max Delay Paths
  * Determine the source and destination of your maximum delay path
  * How much clock skew is there between the source and destination of the maximum delay path?
* Min Delay Paths
  * Determine the source and destination of your maximum delay path
  * How much clock skew is there between the source and destination of the minimum delay path?

## Download

After generating a bitstream, download your design and make sure it works.
Run the putty program (or other terminal emulator) to verify it is working correctly (make sure to set the baud rate and parity correctly).
Here are some ideas for verifying your design is working:
* Type a few characters into the terminal and verify that the busy LED is on
* Press the right button to see if the characters you typed show up on the terminal
* Press the left button to see if the fight song is sent to the terminal
* Consider typing these characters in the terminal:
  * Ctrl-J is the ASCII code for the newline character. You can use this to send a newline character to your design.
  * Ctrl-G is the ASCII code for the bell character. You can use this to send a bell character to your design.

## Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
  * `sim_bram_top`
  * `gen_bit`
2. You need to have at least 3 "Error" commits in your repository
3. Assignment specific Questions:
  * Include a link to your top-level design layout in the FPGA layout tool
  * List the location site of each of the BRAMs in your design
  * Add the timing analysis results to your report file

