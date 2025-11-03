# AXI Bus Interface

In this assignment you will create an AXI4-Lite subordinate/slave interface that connects to your UART transmitter and receiver modules from previous assignments.

## FIFO

The AXI UART interface requires a FIFO to manage the flow of data between the AXI bus and the UART modules.
Start the assignment by creating a simple FIFO module named `fifo.sv`.
Design your fifo with the following specifications:
* Create the following parameters:
  * DATA_WIDTH: Width of the data bus (default 8)
  * DEPTH: Depth of the FIFO in number of entries (default 32)
* Create a 'write pointer' used to control the address of the write/in port and a 'read pointer' that controls the address of the read/out port.
* Design your FIFO to take advantage of the "distributed RAM" feature of the FPGA (see the synthesis guide).
  * Allocate an array of data of size DATA_WIDTH x DEPTH to implement the fifo storage.
  * The writes should be synchronous to the clock
  * Reads should be asynchronous to the clock
* Create a data in port of width DATA_WIDTH
  * Create a 'write enable' signal that writes data into the fifo in the data in port based on the write pointer
  * Writes should be synchronous to the clock
* Create a data out port of width DATA_WIDTH
  * Create a 'read enable' signal that reads data from the fifo based on the read pointer
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

Create a new module named `uart_axi.sv` that implements an AXI4-Lite subordinate/slave interface to your UART transmitter and receiver modules.
Base your new module on the module template file named `uart_axi_template.sv`.
This file includes the port definitions and parameters for your module.

**Transmitter**

Instance your transmitter module from the previous UART transmitter assignment using the parameters of this module.
Instance your fifo module designed above for the transmit path. 
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
* Reads to address offset 0x04 return the value of status register (described below)
* Writes to address offset 0x04 write the value of the control register (described below)

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

## AXI UART Simulation

The next step in this assignment is to simulate the AXI UART interface.
You will need to create a testbench named `uart_axi_tb.sv` that instantiates your `uart_axi.sv` module and the AXI VIP.
To save you time, a template file that includes these instantiations is provided in a file named `uart_axi_tb_template.sv`.
<!-- We will be using the Xilinx AXI Bus Functional Model (BFM) called the "VIP" to simulate the AXI bus transactions. -->
The sections below will describe (1) how to generate/access the AXI VIP and (2) how to hook it up and use it in your testbench.

### AXI VIP

The Xilinx/AMD tools include a pre-built AXI4-Lite Bus Functional Model (BFM) called the "AXI VIP".
This VIP can be used to simulate AXI bus transactions in your testbench to make sure your AXI interface works correctly.
You will need to 'generate' this IP from the Vivado IP tool in order to access the source files for simulation.

A scripted named `create_vip_files.tcl` is provided in this assignment directory that will generate the AXI VIP files for you.
This script when run within the Vivado Tcl console will create a new Vivado IP project and generate the VIP files you need to include in your simulation.
Create a makefile rule that executes the following command `vivado -mode batch -source create_vip_files.tcl` to generate the VIP files.
This command will generate a directory named `ip` that contains the AXI VIP source files you need for simulation.
Add this directory to your `.gitignore` file and clean this directory as part of your assignment clean makefile rule.

### Testbench

Rename the axi testbench template file to `uart_axi_tb.sv` and complete the testbench.
* Instance a transmitter module into your testbench and attach it to the output of your AXI UART module (so your testbench can send data to your AXI UART)
* Instance a receiver module into your and attach it to the output of your AXI UART module (so your testbench can receive data from your AXI UART)
* Create a 'queue' object in SystemVerilog that represents a queue of bytes that need to be transmitted from your testbench tx module and to the receiver of your uart_axi module. Create logic within your testbench that will send a byte from this queue whenever the queue is not empty and the transmitter is not busy. Print a message every time a new byte is sent.
* Add logic into your testbench that prints a message every time a new byte is received by your testbench rx module (i.e., sent by your uart_axi module).
* Add the following to your 'initial' block testbench procedure
    * Create a clock running at 100 MHz
    * Issue the axi reset signal
    * Perform a read over the axi bus to read the status register
    * Send a few bytes to the uart_axi module over the axi bus
    * Add a few bytes to the transmit queue to be sent by the transmitter module
    * Wait for these bytes to be transferred
    * Perform a read over the axi bus to read the status register (it should be different with the internal fifo state changed)
    * Perform a few reads over the axi bus to read the received bytes from the receiver fifo.
    * Perform a write to the control register to reset the internal FIFOs.
    
## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

