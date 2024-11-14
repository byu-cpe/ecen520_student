
# DDR

In this assignment you will generate a DDR controller from the IP generator tool and use this controller to read and write data from a DDR memory.

## DDR Controller IP

The first part of this assignment is to generate a DDR controller using the IP generator tool in Vivado and simulate/build the DDR demo design for the Nexys4 DDR board.
Instructions for completing this portion of the assignment can be found in the [IP](ip/ip.md) section of the assignment.
All the files needed for this part of the assignment can be found in the [ip](ip) directory.
You should create the DDR IP in this directory and then use this generated IP for your assignment submission.

Note that you do not need to complete any new makefile rules for this portion of the assignment but there are a number of questions that you need to complete as part of the report for this part of the assignment.
Make sure you go through this exercise carefully as the understanding you develop during this exercise will be important for the second part of the assignment.

## DDR UART FIFO

For the second part of the assignment you will create a new design that uses the DDR controller to implement a FIFO in the DDR much like you did with the BRAM assignment.
This design will be similar to the example design created in the previous exercise of this assignment but will need to be modified to implement the functionality described below.
Create a top-level design named `ddr_uart_fifo.sv` that does the following:
* Instance your UART receiver and transmitter. Set the values of the BAUD rate and parity as specified in the parameters described below.
* Create the FIFO functionality for the DDR as follows (you do not necessarily need to create a new module for this):
  * Create a write address register that is one bit larger than the address width of the DDR controller. Use this address to write data to the DDR controller (except for the most significant bit).
  * Create a read counter that is one bit larger than the address width of the DDR controller. Use this address to write data to the DDR controller (except for the most significant bit).
  * Create an empty flag that is asserted when the write address is equal to the read address (including the most significant bit).
  * Create an full flag that is asserted when the write address is equal to the read address and the most significant bit is different.
* Create a state machine that implements the following:
  * Do not proceed in your state machine until the `init_calib_complete` signal is asserted
  * When a character is received from the UART receiver, write the character to the DDR at the address specific by the write address register. Increment this address.
  * When BTNC is pressed, read the full DDR FIFO and send each character one at a time to the UART transmitter.
* Instance your seven segment display controller and display the number of characters received from the UART receiver.
* If BTNU is pressed, reset the DDR FIFO counters
* Display the `init_calib_complete` signal on `LED16_B`

Include the following parameters and associated default values in your design:
| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY  | 100_000_000 | Specify the clock frequency |
| BAUD_RATE | 115_200 | Specify the receiver baud rate |
| PARITY | 0 | Specify the parity bit (0 = even, 1 = odd) |
| MIN_SEGMENT_DISPLAY_US | 1_000 | The amount of time in microseconds to display each digit (1 ms) |
| DEBOUNCE_TIME_US | integer | 1_000 | Specifies the minimum debounce delay in micro seconds (1 ms) |

## DDR UART FIFO Simulation

Create a top-level testbench that simulates the design in command line mode.
Instance your top-level design, the DDR memory controller, and the UART receiver and transmitter.
Design your testbench to do the following;
* Wait until the `init_calib_complete` signal is asserted
* Write several characters to the design by sending data over your transmitter. Print a message to the console when each character is sent.
* Press BTNC to read the data back from the DDR FIFO. Print a message to the console when each character is receivfed

Create a makefile rule `sim_ddr_fifo` that performs this simulation.

## DDR UART FIFO Bitfile Generation

Create a syntehsis script that will synthezie your design and generate a bitfile.
Create a makefile rule `gen_bit` that performs this task.

Make sure your bitstream operates corretly on the board.

## Submission

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
  * `sim_ddr_uart_top`
  * `gen_bit`
2. You need to have at least 4 "Error" commits in your repository
3. Assignment specific Questions:
  * "DDR Controller IP" Questions

