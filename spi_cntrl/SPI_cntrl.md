# SPI
 
In this assignment, you will create a [SPI](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) controller for communicating with a SPI device.

The SPI protocol is used extensively in embedded systems as a way to control external devices using a simple serial protocol. 
There are two devices on the Nexys 4 board that use the SPI protocol (each on a different SPI bus): an accelerometer and a QSPI flash memory. 
We will use the controller in the next assignment to communicate with the accelerometer.
The SPI protocol is similar to the UART in that it transfers data serially between two devices. 
The primary difference between SPI and the UART is that SPI includes a clock to synchronize the transfer of data bits and provides simultaneous transmit and receive.
This allows devices to communicate without agreeing ahead of time on the baud rate.

**Note on Terminology**

Many technical protocols including SPI were originally defined using the terms "master" and "slave" to represent the relationship between different devices in the protocol.
"Master" devices are usually in control of an operation or communication protocol and "slave" devices are designed to respond to the master.
There is a growing effort to replace this master/slave terminology due to its reference to human slavery
(see [here](https://www.allaboutcircuits.com/news/how-master-slave-terminology-reexamined-in-electrical-engineering/), [here](https://www.sparkfun.com/spi_signal_names), and [here](https://en.wikipedia.org/wiki/Master/slave_(technology))).
Several proposed alternatives have been made for these terms in the context of SPI.
For the purposes of this assignment, the term "Main" will be used for the term "Master" and the term "Subnode" will be used for the term "Slave" as described by the [Analog Devices](https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html) SPI overview (since we will be talking to an Analog Devices device).
While these terms are not perfect, they retain the "M" letter and the "S" letter from the original terms and thus are consistent with the pin names of the SPI protocol.
Other terminology has been proposed, and it can sometimes be difficult to reconcile the terminology from different devices and data sheets.

## SPI Controller

The first task for this assignment is to create an SPI controller (or SPI "Main").
The SPI controller is responsible for communicating with SPI "Subnode" sharing the SPI bus.
Review online resources to become intimately familiar with the SPI protocol ([wikipedia](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface),
[Analog Devices](https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html), and
[circuit basics](https://www.circuitbasics.com/basics-of-the-spi-communication-protocol/)).
The SPI protocol is a serial protocol that involves the following four signals: a clock (`SCLK`), a chip select (`/CS`), data out or `MOSI` (Main out, subnode in), and data in or `MISO` (Main in, subnode out).
Only one main controller may exist on the SPI bus but multiple sub-nodes may share the bus.
The controller drives the `SCLK`, `/CS`, and `MOSI` signals.
The sub-nodes drive the `MISO` signal.
As a serial protocol, data is shifted one bit per clock cycle.
Unlike the UART, data is being written and read at the same time.
The use of two data signals, `MISO` and `MOSI` allow this full duplex communication to occur.

<!-- SCLK -->
The controller you design will need to generate the `SPI_SCLK` signal used by the subunits.
This clock is not continuous as with a conventional clock and will only toggle during a transaction.
When there is no transaction, the signal should be low.
There is a control bit `CPOL` that determines the polarity of the idle `SPI_SCLK`.
We will assume `CPOL` = 0 meaning that SCLK is low when no transactions are in process.
The `SPI_SCLK` signal will toggle at a much slower rate than our input 100 MHz clock.
For the [accelerometer](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL362.pdf) we are using, the maximum frequency of the `SPI_SCLK` is 10 MHz (the clock low and clock high phases must be 50 ns or longer for a minimum clock period of 100 ns).  
Your controller will need to generate the desired `SPI_SCLK` frequency based on a parameter, `SCLK_FREQUENCY`.
Like the UART, you will need to have a state that is multiple clock cycles long for each phase of the `SPI_SCLK` signal.
You will determine the number of clock cycles for each phase of `SPI_SCLK` by the `SCLOCK_FREQUENCY` and `CLK_FREQUENCY` module parameters.

Your controller should generate the `/CS`, `SCLK`, and `MOSI` signals as shown in the following SPI transaction diagram:

![SPI Transaction](./spi_transaction.jpg)

The reading/writing of a byte will require multiple phases as follows:
  1. `/CS` is driven low and valid data (MSB) is driven by the Main on to `MOSI`. If the subunit is sending data, it will drive the MSB of its data.
  2. `CLK` is driven high. The subunit will sample `MOSI` on this low to high transition and the controller will sample the `MISO` signal. 
  3. `CLK` is driven low. Both the controller and the subunit change the values on the `MOSI` and `MISO` signals to make sure that the setup and hold times are met for the next transition of `CLK`.
  4. The controller performs steps 2 and 3 for the remaining 7 bits of the byte.
  5. In the final phase, drives `/CS` high to end the transaction. 

When the transaction is over, the controller will have received an 8-bit value that it received from the subunit.
Note that this description assumes the control signal `CPHA` = 0 meaning that data is sampled by the subunit on the rising edge and sampled by the Main controller on the falling edge.

<!--
Two control bits determine the operating mode of the procotol: `CPOL` and `CPHA`.
The `CPOL` determines the polarity of the clock during the IDLE phase and the `CPHA` determines the clock phase for data transfers.
Design your controller to operate with `CPOL` = 0 and 
-->

<!-- back to back transactions -->
Your controller should also support multi-byte transfers by initiating a new transaction immediately after the previous transaction.
An input signal named `hold_cs` will be used to determine whether you should continue the transaction with another byte or end the transaction and return `/CS` to high.
Multi-byte transfers within a single transaction will be required for the accelerometer as shown in the figure below.
In this figure three single byte transfers are performed with `/CS` held low for the entire transaction.

![Multi Byte Transaction](./adxl362_spi_read.jpg)

Create a controller the name `spi_cntrl.sv` that has following top-level ports and parameters:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| start| Input | 1 | start a transfer |
| data_to_send | Input | 8 | Data to send to subunit |
| hold_cs | Input | 1 | Hold CS signal for multi-byte transfers |
| SPI_MISO | Input | 1 | SPI MISO signal |
| data_received | Output | 8 | Data received on the last transfer |
| busy | Output | 1 | Controller is busy |
| done | Output | 1 | One clock cycle signal indicating that the transfer is done and the received data is valid |
| SPI_SCLK | Output | 1 | SCLK output signal |
| SPI_MOSI | Output | 1 | MOSI output signal |
| SPI_CS | Output | 1 | CS output signal |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY | 100_000_000 | Specify the clock frequency of the board |
| SCLK_FREQUENCY  | 500_000 | Specify the frequency of the SCLK |

When building your controller make sure you put flip-flops on the output signals `SPI_SCLK`, `SPI_MOSI`, and `SPI_CS` to remove any glitches from the signal.

<!--
**Note:** We have not talked about ASMD diagrams yet so you can ignore the instructions for creating ASMD diagrams.

Begin by creating an ASMD diagram of your SPI controller. 
Carefully review your ASMD diagram to make sure that your FSM and datapath are clearly defined.
You will need to include a copy of your ASMD diagram in your final submission.
Once you are satisfied with your ASMD diagram, create the HDL for your controller.

When designing yoru controller, use the following Verilog 2001/SystemVerilog constructs when you create your controller:
* Use the 'logic' data type
* Use the C-like port specification syntax
* Verilog 2001 parameter declaration and specification
* An enumerated type for your state values  
-->

## SPI Testbench

Once you have created your SPI controller, create a testbench named `spi_cntrl_tb.sv` to simulate transactions with your controller.
I have provided a [simulation model](./spi_subunit.sv) for you that simulates a SPI subnode.
Instance your SPI controller and the provided simulation model and connect the two together.
Design your testbench to do the following:
  * Make the top-level testbench parameterizable with the two top-level parameters.
  * Generate a free oscillating clock and run the clock for several cycles before setting any inputs to your receiver.
  * Provide initial values for the inputs to your receiver (without starting a transaction)
  * Issue a reset by waiting a few clock cycles, issuing the reset for a few clock cycles, and then deasserting the reset
  * Send at least 10 bytes over SPI as single byte transfers. You should create a task to perform this transer.
    * Transmit a random 8-bit value for each transaction and print the value you are transmitting
    * Print the value of the data received from the transaction from the subnode
    * Check to make sure the character you sent is the character you received. Print a message that you correctly received the character you sent or print that an error occurred.
  * Send at least 5 transactions that are multi-byte transfers
    * Make sure that the data you send is the data that is received
  * End your simulation with `$stop`

Create a makefile rule named `sim_spi_cntrl` that will run your testbench with the default parameters.
In addition, create a makefile named `sim_spi_cntrl_100` that runs the same testbench but using 100_000 as the `SCLK_FREQUENCY` parameter.

## ADXL362 Controller

You will create another module that instances your SPI controller and controls the accelerometer on the Nexys4 board. 
Links to the accelerometer are listed below for your convenience. 

The ADXL362 accelerometer uses a three byte transfer to perform a read or a write to/from its registers (see figures 36 and 37 of the [data sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL362.pdf)). 
You will need to support both the write and read register operation as described below.
Create your controller module in a file named `adxl362_cntrl.sv` and create the following top-level ports:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| start| Input | 1 | start a transfer |
| write | Input | 1 | Indicates that a write operation occurs |
| data_to_send | Input | 8 | Data to send to subunit |
| address | Input | 8 | Address for data transfer |
| SPI_MISO | Input | 1 | SPI MISO signal |
| busy | Output | 1 | Controller is busy |
| done | Output | 1 | One clock cycle signal indicating that the transfer is done and the received data is valid |
| SPI_SCLK | Output | 1 | SCLK output signal |
| SPI_MOSI | Output | 1 | MOSI output signal |
| SPI_CS | Output | 1 | CS output signal |
| data_received | Output | 8 | Data received on the last transfer |

| Parameter Name | Default Value | Purpose |
| ---- | ---- | ---- |
| CLK_FREQUENCY | 100_000_000 | Specify the clock frequency of the board |
| SCLK_FREQUENCY  | 500_000 | Specify the frequency of the SCLK |

You will need to create a state machine in your top-level design to implement the three byte transfer using the SPI controller (i.e., send one byte, issue hold_cs and issue second byte, and so on for three bytes). 
When the `start` signal is asserted read the `write` signal to determine what type of operation to perform.
If `write` is asserted, perform a write sequence.
If `read` is asserted, perform a read sequence. 
These sequences are as follows:

  * Write register (when `write` is asserted)
    * Byte 0: write register (0x0a) command that tells the adxl362 that you will be preforming a WRITE
    * Byte 1: 8-bit address (taken from the `address` input)
    * Byte 2: Data to write (taken from `data_to_send`)
  * Read register (when `write` is de-asserted)
    * Byte 0: read register (0x0b) command that tells the adxl362 that you will be preforming a READ
    * Byte 1: 8-bit address (taken from the `address` input)
    * Byte 2: Don't care (capture the byte received on this operation)

## ADXL362 Testbench

Create a testbench of your controller named `adxl362_tb.sv` that tests the operation of your AXDL362L controller.
This testbench should be designed as follows:+
* Make the top-level testbench parameterizable with the two top-level parameters.
* Create a free-running clock
* Instance your top-level design
* Instance the [ADXL362 simulation](./adxl362_model.sv) model
  * attach the SPI signals from the design to the SPI signals of the simulation
* Perform the following sequence of events for your testbench:
  * Execute the simulation for a few clock cycles without setting any of the inputs
  * Set default values for the inputs (reset, buttons, and switchces)
  * Wait for a few clock cycle, assert the reset for a few clock cycles, deassert the reset (don't forget that the reset signal for the board is low asserted)
  * Perform the following operations within your testbench by setting the address and data_to_send:
    * Read the DEVICEID register (0x0). Should get 0xad
    * Read the PARTID (0x02) to make sure you are getting consistent correct data (0xF2)
    * Read the status register (0x0b): should get 0x41 on power up (0xC0?)
    * Write the value 0x52 to register 0x1F for a soft reset

Make sure your design successfully passes this testbench.
Add the makefile rules named `sim_adxl362` and `sim_adxl362_100` that will perform this simulation from the command line (the `sim_adxl362_100` rule should be used to set the `SCLK_FREQUENCY` parameter to 100_000).

## Synthesis of SPI Controller Modules

Before proceeding with the top-level SPI design, it is important to make sure that your SPI controller and adxl362 controller from the previous assignment are properly synthesizable.
Create a makefile rule named `synth_adxl362_cntrl` that performs "out of context" synthesis of the adxl362 controller module from the preivous assignment (see the [instructions](../rx_sim/UART_Receiver_sim.md#receiver-synthesis) on how to do this).
Make sure all synthesis warnings and errors are resolved before proceeding with the top-level design.
If you made any changes to your modules to resolve synthesis errors, rerun the testbenches from the previous assignment to make sure they operate correctly.


<!--
## Preliminary Synthesis

Although we will not be downloading this design in this assignment, it is important to perform a preliminary synthesis step on these modules to identify any synthesis problems.
Create a makefile rule named `synth_adxl362_cntrl` that performs "out of context" synthesis on this module (see the [instructions](../rx_sim/UART_Receiver_sim.md#receiver-synthesis) on how to do this).
Make sure all synthesis warnings and errors are resolved before submitting your assignment.
-->
                                      
**Resources:**
  * [Nexys DDR user guide](https://digilent.com/reference/_media/reference/programmable-logic/nexys-4-ddr/nexys4ddr_rm.pdf)
  * [ADXL362 Product Page](https://www.analog.com/en/products/adxl362.html)
  * [ADXL362 Data Sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL362.pdf)

## Submission and Grading

1. Required Makefile rules:
    * `sim_spi_cntrl`
    * `sim_spi_cntrl_100`
    * `sim_adxl362`
    * `sim_adxl362_100`
1. You need to have at least 4 "Error" commits in your repository
2. No assignment specific questions for this assignment


<!--
- Come up with some "discussion" or exploration exercise as part of the readme.md
- It is hard to follow their testbenches. Need to provide more constraints so that I can follow and see that what was recieved is what was sent
  (prehaps have them provide such a statement in the testbench output)
- Perhaps I provide a detailed module test bench and they create the top-level testbench
  (trade off between learning testenches and testing their circuits properly)

- Does it make sense to break this up into two pieces: one 8-bit controller and one 3-byte controller? Perhaps make a single controller for the ADXL that is general.  FOrcing a 8-bit repreaed controller isn't that general.
  - Probably have them just create a design that does the full 24-bit transfer as one step. Perhaps make the number of bits for a transfer a parameter.
- Move the synthesis step from the next assignment back to this assignment (the out of context synthesis step)
-->
