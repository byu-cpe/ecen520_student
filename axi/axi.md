# AXI Bus Interface

In this assignment you will create an AXI4-Lite subordinate interface that connects to your UART transmitter and receiver modules from previous assignments.

The AXI specification calls the two sides of a bus transaction the **manager** (the side that starts transactions, such as a processor) and the **subordinate** (the side that responds to them, such as your UART).
Older versions of the specification, and many AMD tools and documents, use the terms **master** and **slave** for the same roles.
You will see both sets of terms: for example, the AXI VIP in your testbench is configured as a "master" and its signals are named `M_AXI_*`.

## FIFO

The AXI UART interface requires a FIFO to manage the flow of data between the AXI bus and the UART modules.
Start the assignment by creating a simple FIFO module named `fifo.sv`.
Design your fifo with the following parameters and ports:

| Parameter | Default | Purpose |
| ---- | ---- | ---- |
| DATA_WIDTH | 8 | Width of the data bus |
| DEPTH | 32 | Number of entries in the FIFO (must be a power of 2) |

| Port | Direction | Width | Purpose |
| ---- | ---- | ---- | ---- |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Synchronous reset (active high): resets the pointers and the status signals |
| clr | Input | 1 | Synchronous clear (active high): same effect as `rst`, used to empty the FIFO without resetting the rest of the design |
| we | Input | 1 | Write enable: writes `din` into the FIFO on the rising clock edge |
| din | Input | DATA_WIDTH | Write data |
| re | Input | 1 | Read enable: removes the entry at the head of the FIFO on the rising clock edge |
| dout | Output | DATA_WIDTH | Read data: the entry at the head of the FIFO |
| full | Output | 1 | The FIFO is full and cannot accept more data |
| empty | Output | 1 | The FIFO is empty and there is no data to read |
| overflow | Output | 1 | A write was attempted when the FIFO was full |
| underflow | Output | 1 | A read was attempted when the FIFO was empty |

Note that `rst` and `clr` are active high, while the AXI reset (`s_axi_aresetn`) used later in this assignment is active low.
Your `uart_axi` module will need to invert the AXI reset before connecting it to the FIFO `rst` port.

Implement your FIFO as follows:
* Design your FIFO to take advantage of the "distributed RAM" feature of the FPGA (see the [Distributed RAM Examples](https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Distributed-RAM-Examples) section of the synthesis guide).
  * Allocate an array of size DATA_WIDTH x DEPTH to implement the FIFO storage.
  * Writes to the array are synchronous to the clock.
  * Reads from the array are asynchronous (combinational). This is what allows the array to be mapped to distributed RAM (`RAM32M` or similar primitives with the default `DEPTH` of 32).
* Create a 'write pointer' that addresses the write port of the array and a 'read pointer' that addresses the read port.
  * Make each pointer one bit wider than needed to address the array ($clog2(DEPTH)+1 bits). Use the lower bits to address the array; the extra upper bit distinguishes full from empty.
  * `empty` is asserted when the two pointers are equal (all bits).
  * `full` is asserted when the lower bits of the pointers are equal and the upper bits differ. Your FIFO therefore holds exactly `DEPTH` entries.
  * Because the pointers roll over naturally, `DEPTH` must be a power of 2.
* Read behavior ("first-word fall-through"): `dout` always shows the entry at the read pointer, without waiting for a clock edge.
  Asserting `re` does not change `dout` in the same cycle; it advances the read pointer at the next rising clock edge so that `dout` then shows the next entry.
  This allows a circuit that uses the FIFO to look at `dout` and assert `re` in the same cycle to consume the entry.
  The value of `dout` is undefined when the FIFO is empty.
* Ignore writes when the FIFO is full and reads when the FIFO is empty (the pointers do not move).
  These decisions are based on the `full` and `empty` values at the start of the clock cycle. If `we` and `re` are asserted in the same cycle:
  * When the FIFO is neither empty nor full, both the write and the read occur (the number of entries does not change).
  * When the FIFO is empty, only the write occurs (and `underflow` is set).
  * When the FIFO is full, only the read occurs (and `overflow` is set).
* `overflow` and `underflow` are "sticky": once set, they stay set until `rst` or `clr` is asserted.

### FIFO Testbench

Create a testbench named `fifo_tb.sv` that instantiates your fifo and simulates the fifo.
The structure of this testbench is similar to the FIFO testbench you wrote for the bram assignment, so feel free to reuse code from it.
Note, however, that the two FIFOs behave differently: the bram FIFO has a one cycle read latency and no overflow/underflow signals, while this FIFO's `dout` shows the head entry immediately.
Include the following tests in your testbench:
* Write a few bytes of data and read them back out (without overflow or underflow). Check that the bytes read from `dout` match the bytes written.
* Write enough bytes to fill up the FIFO and verify that the full signal is asserted
* Attempt to write one more byte and verify that the overflow signal is asserted
* Read one byte and verify that `full` is deasserted. Read the rest of the bytes, checking each value, and verify that `empty` is asserted after the last read.
* Issue the 'clear' signal and verify that the fifo error is cleared.
* Attempt to read from an empty fifo and verify that the underflow signal is asserted
* Issue the 'clear' signal and verify that the fifo error is cleared.
* Write and read more than `DEPTH` bytes in total (for example, keep the FIFO partially full while writing and reading 3 x `DEPTH` bytes) to verify that the pointers wrap around correctly.
* Assert `we` and `re` in the same cycle when the FIFO is empty, when it is partially full, and when it is full, and verify the behavior described above.

Your testbench should be self-checking: count the number of errors and print `Simulation done with X errors` at the end of the simulation.
Create a makefile rule `sim_fifo` that performs this simulation from the command line and generates a log file named `sim_fifo.log`.

### FIFO Synthesis

Create a makefile rule named `synth_fifo` that synthesizes your fifo module and generates a synthesis log file named `synth_fifo.log`.
Review the synthesis report and verify that your fifo was implemented using distributed RAM (it must include one or more RAM32xxx primitives).

## AXI-Lite UART Interface

Create a new module named `uart_axi.sv` that implements an AXI4-Lite subordinate interface to your UART transmitter and receiver modules.
Base your new module on the module template file named `uart_axi_template.sv`.
This file includes the port definitions and parameters for your module to help you get started.

| Parameter | Default | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY | 100_000_000 | Clock frequency in Hz (passed to your transmitter and receiver) |
| BAUD_RATE | 115_200 | Baud rate (passed to your transmitter and receiver) |
| PARITY | 1 | Parity type, 0 = even, 1 = odd (passed to your transmitter and receiver) |
| FIFO_DEPTH | 32 | Number of entries in each FIFO (passed to the `DEPTH` parameter of both FIFOs) |
| C_S_AXI_ADDR_WIDTH | 4 | Width of the AXI address bus |

A Verilog wrapper named `uart_axi_wrapper.v` is also provided.
It instances your `uart_axi` module and passes through all of its parameters and ports.
You do not need it for this assignment, but you will use it in the MicroBlaze assignment: the Vivado block diagram editor does not accept SystemVerilog modules directly, so the wrapper is the module you add to the block diagram.
Make sure your `uart_axi` module uses exactly the parameter and port names of the template so that the wrapper works without changes.

The figure below shows the structure of the `uart_axi` module.
An AXI write to the TX data register places a byte in the transmit FIFO, and the transmit logic sends bytes from this FIFO through your transmitter to `tx_out`.
Bytes arriving on `rx_in` are received by your receiver and placed in the receive FIFO, and an AXI read of the RX data register removes a byte from this FIFO.
The FIFOs separate the AXI bus from the UART: an AXI transaction completes in a few clock cycles while a byte takes many microseconds to send or receive.
The UART side of each path operates independently of the AXI side. For example, the receiver writes bytes into the receive FIFO whenever they arrive, regardless of whether any AXI reads are taking place.

![AXI UART block diagram](axi_block_diagram.png)

Follow the instructions below for building your AXI UART.

### Transmitter

Instance your transmitter module from the previous UART transmitter assignment using the parameters of this module.
Do not copy your transmitter file into this assignment directory.
Instead, reference it with a relative path to the earlier assignment directory (e.g., `../tx_sim/tx.sv`) in your makefile rules, as you did in the tx_download assignment.
If you need to fix a bug in the transmitter, make the change in the earlier directory (your original submission is preserved by its tag).
Instance your fifo module designed above for the transmit path. 
The input to the transmit FIFO comes from the AXI bus write data (discussed in more detail below).
The output of the transmit FIFO goes to your UART transmitter module.
Create a state machine that transmits data from the transmit FIFO to the UART transmitter whenever the transmit FIFO is not empty and the UART transmitter is not busy.

### Receiver

Instance your receiver module from the previous UART receiver assignment using the parameters of this module.
As with the transmitter, reference the receiver file with a relative path (e.g., `../rx_sim/rx.sv`) rather than copying it.
Instance another fifo module for the receiver path.
The input to the receiver FIFO comes from your UART receiver module.
The output of the receiver FIFO goes to the AXI bus read data (discussed in more detail below).
Create some logic/state machine that writes a byte to the receiver FIFO whenever the UART receiver indicates that a byte has been received.

### AXI4-Lite Bus Interface

Implement the AXI4-Lite subordinate interface to support reading and writing data to/from the UART transmitter and receiver.
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

**Reset**

The AXI reset `s_axi_aresetn` is active low and synchronous to `s_axi_aclk`.
While it is low, your module must reset both FIFOs, the transmitter and receiver, the transmit and receive logic, and the AXI interface state.
In particular, `s_axi_bvalid` and `s_axi_rvalid` must be low during reset and must not be asserted until a transaction is received after reset.
Remember that your FIFO, transmitter, and receiver use active high resets, so invert `s_axi_aresetn` before connecting it to them.

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
| 7 | TX FIFO empty |
| 8 | RX FIFO full |

Bits that are not listed in the table read as 0.

**Control Register**
| Bit | Purpose |
| ---- | ---- |
| 0 | Clear TX FIFO |
| 1 | Clear RX FIFO |

<!-- 
### Synthesis

After creating your AXI UART module, create a makefile rule named `synth_axi` that synthesizes your `uart_axi.sv` module and generates a synthesis log file named `synth_axi.log`.
Don't worry whether the implementation works at this point - the purpose of the synthesis is to verify that your design can be synthesized without errors. 
-->

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

A script named `create_vip_files.tcl` is provided in this assignment directory that will generate the AXI VIP files for you.
This script creates a new Vivado IP project and generates the VIP files you need to include in your simulation.
Create a makefile rule named `build_vip` that executes the following command to generate the VIP files and a log file named `build_vip.log`:
```
vivado -mode batch -source create_vip_files.tcl -log build_vip.log
```
This command will generate a directory named `ip` that contains the following AXI VIP source files you need for simulation:
  * `./ip/axi_vip_0/sim/axi_vip_0_pkg.sv`
  * `./ip/axi_vip_0/sim/axi_vip_0.sv`
Add this directory to your `.gitignore` file.
Your `clean` makefile rule should remove the `ip` directory along with the other generated files: the Questa `work` library, the `.Xil` directory, `*.jou` and `*.log` files, and any checkpoint (`.dcp`) files.


### Testbench

Copy the axi testbench template file `uart_axi_tb_template.sv` to `uart_axi_tb.sv` and create a testbench with the following steps:
* Instance a transmitter module into your testbench and attach its output to the input of your AXI UART module (`rx_in`). This transmitter is used in the testbench to send data to your AXI UART.
* Instance a receiver module into your testbench and attach its input to the output of your AXI UART module (`tx_out`). This receiver is used in the testbench to receive data from your AXI UART.
* Create a SystemVerilog 'queue' object that represents a queue of bytes that need to be transmitted by your testbench tx module to the receiver of your uart_axi module. Create logic within your testbench that will send a byte from this queue whenever the queue is not empty and the testbench transmitter is not busy. Print a message every time a new byte is sent.
* Add logic into your testbench that prints a message every time a new byte is received by your testbench rx module (i.e., sent by your uart_axi module).
* Add the following to your 'initial' block testbench procedure:
    * Create a clock running at 100 MHz
    * Issue the axi reset signal
    * Perform a read over the axi bus to read the status register (verify that the value is correct)
    * Send a few bytes to the uart_axi module over the axi bus to be transmitted by your module
    * Read the status register to make sure the tx FIFO is not empty
    * Add a few bytes to the transmit queue to be sent by the transmitter module
    * Wait for these bytes to be transferred to your module
    * Read the status register to make sure the rx FIFO is not empty
    * Perform a few reads over the axi bus to read the received bytes from the receiver fifo.
    * Perform a write to the control register to reset the internal FIFOs.

Simulating the VIP requires two precompiled libraries that are provided with Vivado:
* `xilinx_vip` contains the `axi_vip_pkg` package (imported at the top of the testbench template) that defines the VIP agent classes and the transaction functions such as `AXI4LITE_WRITE_BURST`.
* `axi_vip_v1_1_17` contains the VIP module itself, which is instanced by the generated `axi_vip_0.sv` wrapper. The version number in this name changes with the Vivado version, so check the `data/questa` directory of your Vivado installation if this library is not found.

To simulate your testbench and the VIP files, you will need to compile the files in modelsim as follows:
  * Compile the `axi_vip_0_pkg.sv` file generated by the `build_vip` rule using the `-L xilinx_vip` flag: `vlog -sv -L xilinx_vip ./ip/axi_vip_0/sim/axi_vip_0_pkg.sv`
  * Compile the `axi_vip_0.sv` file generated by the `build_vip` rule using the `-L xilinx_vip` flag: `vlog -sv -L xilinx_vip ./ip/axi_vip_0/sim/axi_vip_0.sv`
  * Add the `-L xilinx_vip` flag when running `vlog` on your testbench
  * Add the following libraries when you run the `vsim` commnad: `-L xilinx_vip` and `-L axi_vip_v1_1_17`
  * Add the following lines to your modelsim.ini

```
axi_vip_v1_1_17 = /tools/Xilinx/Vivado/2024.1/data/questa/axi_vip_v1_1_17
xilinx_vip = /tools/Xilinx/Vivado/2024.1/data/questa/xilinx_vip
```

Create a makefile rule `sim_uart_axi` that performs this simulation from the command line and generates a log file named `sim_uart_axi.log`.
Make sure you have messages in your simulation output that indicate each of the steps described above.

The AXI VIP includes a protocol checker that monitors every transaction and reports violations of the AXI rules (for example, a `VALID` signal that is deasserted before its handshake completes).
These violations are printed as errors or warnings in the simulation log, with a message identifying the rule that was broken.
Search `sim_uart_axi.log` for VIP errors and warnings after every simulation and fix all of them: this is the fastest way to find handshake bugs in your design.

Take a screenshot of the simulation waveform that shows one AXI write and one AXI read to your `uart_axi` module.
Include the `VALID`, `READY`, address, and data signals of each channel used by the transaction, and zoom in so that the individual handshakes are visible.
Save the screenshot as `uart_axi_sim.png` and commit it to your repository.

## AXI UART Synthesis

Once your AXI UART IP is simulating properly, synthesize the module to resolve any synthesis errors.
It is important to make sure that it is synthesizable before trying to integrate it in a future project.

Create a makefile rule named `synth_uart_axi` that synthesizes your module and generates a synthesis log file named `synth_uart_axi.log`.
Review the synthesis report to identify any potential problems.

## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment.

You must follow the [Level 3](../resources/coding_standard.md#level-3) coding standards for your SystemVerilog files.

<!--
- A diagram or something to refer to in the instructions. The one in class helped to grasp it better.  (the diagram could show the axi bus interface, the FIOs and the Rx/RX like I did in class.)
- Make the report more interesting and involved
- Clarify the process for simulating
- A step-by-step description of one of the AXI-UART transactions would have helped me get started much more easily. I understand we talked about it the structure and broadly described what we wanted in class, and I took notes on what was discussed. However, without a resource I could trust to be accurate I spent a lot of time writing something that was incorrect. For example, it was unclear that writing to the RX FIFO over UART and reading from AXI were meant to operate independently, so I assumed that it was one transaction. A detailed explanation of the process would have helped me avoid that pitfall.
-->