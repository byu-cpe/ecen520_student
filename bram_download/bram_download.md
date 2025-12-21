# BRAM Download

In this assignment you will create a top-level design that instances your BRAM modules and interfaces them to your UART transmitter and receiver.

## Top-Level Design

Create a top-level design named `bram_top.sv` that instantiates both the FIFO and the ROM modules from the previous assignment.
Design your top-level design to operate as follows:
* Create a parameter named `FILENAME` that indicates the .mem file to use for the initial contents of the ROM.
* Instance your UART transmitter and receiver and connect them to the top-level UART ports
* When the **left** button is pressed, the _entire_ ROM contents are sent over the UART transmitter one character at a time. Ignore any button presses that may occur until the entire ROM has been sent. You will need to implement flow control so that you don't send another character until the previous character has been sent.
* When characters are received by the UART receiver, they are placed in the BRAM FIFO.
* When the **right** button is pressed, your circuit should send each character received in the BRAM over the UART back to the host until the BRAM FIFO is empty. Ignore any button presses that may occur until the entire FIFO has been sent. Once you have sent the data from the FIFO the data is gone and any new data that you send to the FIFO will be sent over the UART on the next button pressing.
* Use `LED16_B` for the TX busy signal, `LED17_R` for the RX busy signal, and `LED17_G` for the RX error signal.
* Attach the FIFO empty signal to LED[0] and the FIFO full signal to LED[1].
* Create a signal that indicates when the `bram_rom` module is busy sending data and attach this signal to LED[2].

### Testbench

Create a top-level testbench named `bram_top_tb.sv` that instantiates your design and simulates the behavior of the top-level design.
* Instance your top-level design
* Add your UART transmitter to the testbench and connect it to the RX input of your top-level design. You will send characters to your top-level design with your transmitter module
* Add your UART receiver to the testbench and connect it to the TX output of your top-level design. You will use your receiver module to receive and check characters from your top-level design. Print a message when a new character is received.
* Perform the following functions in your testbench:
  * Initialize and reset your design
  * Have your testbench transmitter send the characters "Hello World" to your top-level design
  * Press the left button to send the fight song over the transmitter
  * Press the right button to send the buffered data over the transmitter
  * Press the left button again to see the fight song a second time

Create a makefile rule `sim_bram_top` that performs this simulation from the command line and generates a log file named `sim_bram_top.log`.
Feel free to change the generics to use a much faster baud rate for your UART to speed up the simulation time (same with a smaller debounce delay).

## Implementation

### Synthesis

Create a constraints file with all the necessary constraints for your design.
Make sure you add the timing false path timing constraints like you did for the spi_download assignment.
Create a makefile rule named `synth_bram_top` that synthesizes your top-level design using the default parameters.
This makefile rule should generate a log file named `synth_bram_top.log` and a .dcp file named `bram_top_synth.dcp`.
Make sure all synthesis warnings and errors are resolved before proceeding with the implementation of your design.
Carefully track the number of times you synthesize your design to complete this assignment as this number will be required in the report section of this assignment.

Set the generics for the design as follows:
* `BAUD_RATE` = 115200
* `PARITY` = 0
* `FILENAME` = "fight_song.mem"

**Make sure** the synthesis log shows that two RAMB36E1 primitives were allocated for your module.
If you do not have 2 BRAMs then your design will not work, and you should not proceed with the further steps.

### Placement, Routing, and Bitstream Generation

Create makefile rule named `implement_bram_top` that performs the placement, routing, report, bitstream, and dcp file generation.
It should use the `bram_top_synth.dcp` file as input.
This makefile rule should generate a log file named `implement_bram_top.log`, a .dcp file named `bram_top.dcp`, and a bitfile named `bram_top.bit`.
Generate a timing report file named `timing_bram_top.rpt` and a utilization report file named `utilization_bram_top.rpt`.

After successfully implementing your design, open your design in the Vivado GUI to see the layout of your design on the FPGA device.
Locate the two different BRAMs used by your design and determine the "Site" of each of the BRAMs (this will be something like BRAM36_XxYx where 'a' is a letter and 'x' is a number). 
You will need to indicate the location in your report.


 <!-- To open the tool, run these steps:
* Open the Vivado GUI
* Load your design by running the command: `open_checkpoint bram_top.dcp`
* The FPGA editor tool should be open 

### FPGA Layout Tool
-->

## Download

After generating a bitstream, download your design and make sure it works.
Run the putty program (or other terminal emulator) to verify it is working correctly (make sure to set the baud rate and parity correctly).
Here are some ideas for verifying your design is working:
* Type a few characters into the terminal and verify that the busy LED is on
  * Make sure the empty signal goes low when you type
  * Type a lot of characters to make sure the full signal goes high
* Press the right button to see if the characters you typed show up on the terminal
* Press the left button to see if the fight song is sent to the terminal
* Consider typing these characters in the terminal:
  * Ctrl-J is the ASCII code for the newline character. You can use this to send a newline character to your design.
  * Ctrl-G is the ASCII code for the bell character. You can use this to send a bell character to your design.

## Submission

## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

<!--
- A short rom for testing transmit could be helpful, since the fight song took a long time to transmit in the simulation.
- I think it would've been much easier to implement some parts of this lab (or help in writing testbenches) if there were more status signals coming up out of the top module. For example, 'rom_end' would be useful. These signals can also just be tied to LEDs.
- Writing the testbench is a good excersize, but it would help to have some sort of working testbench available to help us debug our design before writing our own testbench.
-->