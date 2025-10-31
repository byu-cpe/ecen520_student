# AXI Bus Interface

In this assignment you will create an AXI4-Lite subordinate/slave interface that connects to your UART transmitter and receiver modules from previous assignments.

## FIFO

The AXI UART interface requires a FIFO to manage the flow of data between the AXI bus and the UART modules.
Start the assignment by creating a simple FIFO module named `fifo.sv`.
Design your fifo with the following specifications:
* Create the following parameters:
  * DATA_WIDTH: Width of the data bus (default 8)
  * DEPTH: Depth of the FIFO in number of entries (default 32)
* Create a write pointer used to control the address of the write/in port and a and read pointer that controls the address of the read/out port.
* Design your FIFO to take advantage of the "distributed RAM" feature of the FPGA (see the synthesis guide).
  * Allocate an array of data of size DATA_WIDTH x DEPTH to implement the fifo storage.
  * The writes should be synchronous to the clock
  * Reads should be asynchronous to the clock
* Create a data in port of width DATA_WIDTH
  * Create a write enable signal that writes data into the fifo in the data in port based on the write pointer
  * Writes should be synchronous to the clock
* Create a data out port of width DATA_WIDTH
  * Create a read enable signal that reads data from the fifo based on the read pointer
  * Reads should be asynchronous to the clock
* Create the following status signals:
  * full: Indicates the fifo is full and cannot accept more data
  * empty: Indicates the fifo is empty and there is no data to read
  * overflow: Indicates a write was attempted when the fifo was full.
  * underflow: Indicates a read was attempted when the fifo was empty.
* Create a synchronous reset signal that resets the fifo pointers and status signals.
* Add a control signal that 'clears' the FIFO (resets pointers and status) without resetting the entire module.

### FIFO Testbench

Create a testbench named `fifo_tb.sv` that instantiates your fifo and simulates the fifo.
Include the following tests in your testbench:
* Write a few bytes of data and read them back out (without overflow or underflow)
* Write enough bytes to fill up the FIFO and verify that the full signal is asserted
* Attempt to write one more byte and verify that the overflow signal is asserted
* Issue the 'clear' signal and verify that the fifo error is cleared.
* Attempt to read from an empty fifo and verify that the underflow signal is asserted

Create a makefile rule `sim_fifo` that performs this simulation from the command line and generates a log file named `sim_fifo.log`.

### FIFO Synthesis

Create a makefile rule named `synth_fifo` that synthesizes your fifo module and generates a synthesis log file named `synth_fifo.log`.
Review the synthesis report and verify that your fifo was implemented using distributed RAM (it must include one or more RAM32xxx primitives).

## AXI-Lite UART Interface

A module template file named `uart_axi_template.sv` has been provided to you.
This file includes the port definitions and parameters for your module.
Copy this file to a new file named `uart_axi.sv` and complete the implementation.

**Transmitter**

Instance your transmitter module from the previous UART transmitter assignment using the parameters of this module.
Instance your fifo module for the transmit path. 
The input to the transmit FIFO comes from the AXI bus write data (discussed in more detail below).
The output of the transmit FIFO goes to your UART transmitter module.
Create a state machine that transmits data from the transmit FIFO to the UART transmitter whenever the transmit FIFO is not empty and the UART transmitter is not busy.

**Receiver**

Instance your receiver module from the previous UART receiver assignment using the parameters of this module.
Instance another fifo module for the receiver path.
The input to the receiver FIFO comes from your UART receiver module.
The output of the receiver FIFO goes to the AXI bus read data (discussed in more detail below).
Create some logic/state machine that writes a byte to the receiver FIFO whenever the UART receiver indicates that a byte has been received.

**AXI4-Lite Bus Interface**

Implement the AXI4-Lite subordinate/slave interface to support reading and writing data to/from the UART transmitter and receiver.
You will also need to implement a status register that indicates the status of the FIFOs and a control register that allows clearing the FIFOs.
The address map for your AXI interface is as follows:

| Address Offset | Read | Write |
| ---- | ---- | ---- |
| 0x00 | RX Data | TX Data |
| 0x04 | Status Register (read only) | Control Register (write only)

* Reads to address offset 0x00 return a byte from the receiver FIFO. 
* Writes to address offset 0x00 write a byte to the transmit FIFO.
* Reads to address offset 0x04 return the value of status register described below
* Writes to address offset 0x04 write the value of the control register described below

**Status Register**
| Bit | Purpose |
| ---- | ---- |
| 0 | TX Busy |
| 1 | RX Busy |
| 2 | RX error status |
| 3 | TX FIFO full |
| 4 | RX FIFO empty |
| 5 | TX overflow |
| 6 | RX underflow |

**Control Register**
| Bit | Purpose |
| ---- | ---- |
| 0 | Clear TX FIFO |
| 1 | Clear RX FIFO |

### Synthesis

After creating your AXI UART module, create a makefile rule named `synth_axi` that synthesizes your `uart_axi.sv` module and generates a synthesis log file named `synth_axi.log`.
Don't worry whether the implementation works at this point - the purpose of the synthesis is to verify that your design can be synthesized without errors.

## AXI Simulation

## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

