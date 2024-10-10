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
Set the generics for the generated bitfile as follows:
* `BAUD_RATE` = 115200
* `PARITY` = 0
* `FILENAME` = "fight_song.mem"

Make sure you create a design checkpoint file (`.dcp`) for your top-level design as you will need to use it as described below.
**Make sure** the synthesis log shows that two RAMB36E1 primitives were allocated for your module.
If you do not have 2 BRAMs then your design will not work.

`open_checkpoint bram_top.dcp`
* Take a screen shot of the laytout of the device (centered on where your logic is) 
* Determine the location site of each of the BRAMs and report (RAMB36_XxYx)
* 

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


## Submission

The assignment submission steps are described in the [assignment mechanics checklist](../resources/assignment_mechanics.md#assignment-submission-checklist) page.
Carefully review these steps as you submit your assignment.

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
  * `sim_bram_fifo`
  * `sim_bram_rom`
  * `sim_bram_rom_declaration`
  * `synth_bram_fifo`
  * `synth_bram_rom`
2. You need to have at least 4 "Error" commits in your repository
3. Assignment specific Questions:
    1. Create a table in your report that indicates the total number of primitives for each design based on the synthesis reports. The table listed below is an example of what you should include in your report. You will need to include all cells used in each of the two designs.

| Cell Type | BRAM ROM | BRAM FIFO |
| ---- | ---- | ---- |
| CARRY4 | | |
| RAMB36E1 | | |


Report:
- Get something out of the syntehsis log (verigy number of BRAMs)
- Take a screen shot of the layout of the device. Point out the BRAMs.

Add detailed timing analysis to your README.md file.

<!--
They use glbl.v file for simulation. Need to include in their repository.
Don't hard code any paths in makefile! (perhaps have an environment variable that is set so I can reuse their makefiles)
- Have them simulate the full fight song

- buffer empties when right pressed.
- start fight song with new line (make it more clear how to setup putty and what to send at the end of the line)
- Have the fight song spit out the text as fast as possible (no delays).
-->
