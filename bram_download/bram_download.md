# BRAM Download

In this assignment you will create a top-level design that instances your BRAM modules and interfaces them to your UART transmitter and receiver.

## Top-Level Design

Create a top-level design named `bram_top.sv` that instantiates both the FIFO and the ROM modules from the previous assignment.
Your top-level design should have the following parameters.
Use the values listed below as the **default values** of these parameters: synthesis and implementation must use these values, so do not override them in your synthesis script.

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY | 100_000_000 | Specify the clock frequency |
| BAUD_RATE | 115_200 | Specify the UART baud rate |
| PARITY | 0 | Specify the UART parity bit (0 = even, 1 = odd) |
| DEBOUNCE_TIME_US | 10_000 | Specifies the minimum debounce delay in micro seconds (10 ms) |
| FILENAME | "fight_song.mem" | The .mem file used for the initial contents of the ROM |

Note that the `BAUD_RATE` and `PARITY` defaults are different from those of the rx_download assignment.

The `fight_song.mem` file must be present in this directory (`bram_download`) for both simulation and synthesis, since `$readmemh` looks for the file in the directory where the tools are run.
As in the bram assignment, the `.mem` file is a generated file: do not commit it, and add it to your `.gitignore` file.
Instead, add a makefile rule that generates it from the text file in the bram assignment directory:

```
fight_song.mem: ../bram/fight_song.txt
	python3 ../bram/gen_readmem.py ../bram/fight_song.txt fight_song.mem -l 4096 -r
```

Make both the `sim_bram_top` and `synth_bram_top` rules depend on `fight_song.mem` so it is generated automatically on a clean checkout (the passoff script checks that these rules create it), and have your `clean` rule delete it.

Design your top-level design to operate as follows:
* Attach the `CPU_RESETN` signal to two flip-flops to synchronize it to the clock, and use this synchronized signal as the reset for your design (note that `CPU_RESETN` is low asserted).
* Instance your UART transmitter and receiver and connect them to the top-level UART ports, using the same synchronizer on the RX input and output flip-flop on the TX output as in the rx_download assignment.
* For each of the two buttons (`BTNL` and `BTNR`):
  * Add a two flip-flop synchronizer. Give the first flip-flop the `(* ASYNC_REG = "TRUE" *)` attribute, as in the spi_download assignment.
  * Debounce the synchronized signal with your debouncer, passing in the `DEBOUNCE_TIME_US` parameter.
  * Create one-shot logic from the debouncer output so that each button press starts at most one send, no matter how long the button is held.
* When the **left** button is pressed, the _entire_ ROM contents are sent over the UART transmitter one character at a time. You will need to wait until the transmitter is no longer busy before sending the next character.
* When characters are received by the UART receiver, they are placed in the BRAM FIFO. Characters received while the FIFO is full are dropped (the FIFO ignores writes when it is full).
* When the **right** button is pressed, your circuit should send each character in the BRAM FIFO over the UART back to the host until the FIFO is empty. Once you have sent the data from the FIFO the data is gone and any new data that you send to the FIFO will be sent over the UART on the next button press.
* Both sends share the single UART transmitter, so only one send can be in progress at a time. While either send (ROM or FIFO) is in progress, ignore presses of **both** buttons.
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
  * Press the left button so that your design sends the fight song (the ROM contents) over its UART transmitter to the testbench receiver
  * Press the right button so that your design sends the buffered FIFO data ("Hello World") back over its UART transmitter to the testbench receiver
  * Press the left button again to see the fight song a second time

Create a makefile rule `sim_bram_top` that performs this simulation from the command line and generates a log file named `sim_bram_top.log`.
Your testbench may override the top-level parameters to speed up the simulation (e.g., a much faster `BAUD_RATE` and a smaller `DEBOUNCE_TIME_US`).
These overrides apply only to simulation; synthesis must use the default values.

## Implementation

### Synthesis

Create a constraints file with all the necessary constraints for your design.
Make sure you add the false path timing constraints like you did for the spi_download assignment.
Create a makefile rule named `synth_bram_top` that synthesizes your top-level design with the parameter values listed in the [parameter table](#top-level-design) above.
This makefile rule should generate a log file named `synth_bram_top.log` and a .dcp file named `bram_top_synth.dcp`.
Make sure all synthesis warnings and errors are resolved before proceeding with the implementation of your design.
Carefully track the number of times you synthesize your design to complete this assignment as this number will be required in the report section of this assignment.

**Make sure** the synthesis log shows that two RAMB36E1 primitives were allocated for your module.
If you do not have 2 BRAMs then your design will not work, and you should not proceed with the further steps.
Your FIFO instances its `RAMB36E1` directly, so a missing BRAM is almost always the ROM.
If the synthesis log shows the ROM implemented with LUTs instead of a second `RAMB36E1`, check that the read of your ROM memory is registered (i.e., `dout` is assigned inside an `always_ff` block). Vivado can only map a memory with a synchronous read to a BRAM.

### Placement, Routing, and Bitstream Generation

Create a makefile rule named `implement_bram_top` that performs the placement, routing, report, bitstream, and dcp file generation.
It should use the `bram_top_synth.dcp` file as input.
This makefile rule should generate a log file named `implement_bram_top.log`, a .dcp file named `bram_top.dcp`, and a bitfile named `bram_top.bit`.
Generate a timing report file named `timing_bram_top.rpt` and a utilization report file named `utilization_bram_top.rpt`.

After successfully implementing your design, open your design in the Vivado GUI to see the layout of your design on the FPGA device.
Locate the two different BRAMs used by your design and determine the "Site" of each of the BRAMs (this will be something like `RAMB36_X#Y#`, where each `#` is a number, e.g., `RAMB36_X0Y10`). 
You will need to indicate the location in your report.


 <!-- To open the tool, run these steps:
* Open the Vivado GUI
* Load your design by running the command: `open_checkpoint bram_top.dcp`
* The FPGA editor tool should be open 

### FPGA Layout Tool
-->

## Download

After generating a bitstream, download your design and make sure it works.
Run the putty program (or other terminal emulator) to verify it is working correctly.
Configure the serial port to match the parameters of your design: **115200 baud, 8 data bits, even parity, 1 stop bit, and no flow control**.
Note that even parity is not the default in most terminal programs; if the parity is set incorrectly, your receiver will report errors (`LED17_G`) even though your design is working.
Here are some ideas for verifying your design is working:
* Type a few characters into the terminal and verify that the RX busy LED (`LED17_R`) flickers as each character is received
  * Make sure the empty signal goes low when you type
  * Type a lot of characters to make sure the full signal goes high
* Press the right button to see if the characters you typed show up on the terminal
* Press the left button to see if the fight song is sent to the terminal
* Consider typing these characters in the terminal:
  * Ctrl-J is the ASCII code for the newline (line feed) character. When this character is echoed back from the FIFO, the terminal cursor should move down one line (depending on your terminal settings, it may not return to the left column).
  * Ctrl-G is the ASCII code for the bell character. When this character is echoed back from the FIFO, the terminal should beep (or flash, depending on your terminal settings).

## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

<!--
- A short rom for testing transmit could be helpful, since the fight song took a long time to transmit in the simulation.
- I think it would've been much easier to implement some parts of this lab (or help in writing testbenches) if there were more status signals coming up out of the top module. For example, 'rom_end' would be useful. These signals can also just be tied to LEDs.
- Writing the testbench is a good excersize, but it would help to have some sort of working testbench available to help us debug our design before writing our own testbench.
-->