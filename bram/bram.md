# BRAM

In this assignment you will practice using BRAMs by creating two different modules that instance a BRAM.

## Synchronous FIFO

Create a module in a file named `bram_fifo.sv` that implements a simple synchronous FIFO for ASCII bytes (this will be used with the UART).
The ports of this module should be as follows:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Synchronous Reset |
| we | Input | 1 | Write enable |
| re | Input | 1 | Read enable |
| din | Input | 8 | Data In |
| dout | Output | 8 | Data Out |
| full | Output | 1 | Indicates FIFO is full |
| empty | Output | 1 | Indicates FIFO is empty |

Your FIFO should be created by as follows:
* Create a "write address" counter and a "read address" counter that indicate which address to write to and read from, respectively.
  * Every time a byte is written to the FIFO (i.e., when 'we' is asserted), the write address should increment by one. The address should roll over if you reach the limit. 
  * You should read from the memory every clock cycle. Increment this address every time the `re` signal is asserted.
* Perform a write to the memory when the `we` signal is asserted.
* Create an 'empty' signal that is asserted when the read address is equal to the write address.
* Create a 'full' signal that is asserted when the write address is one less than the read address.
* You should ignore reads when the fifo is empty and you should ignore writes when the fifo is full.
* Instance a `RAMB36E1` primitive into your design using an 8-bit data bus. You will need to carefully read the details about this primitive in the [7 Series Memory Resources (UG473)](https://docs.amd.com/v/u/en-US/ug473_7Series_Memory_Resources) (see page 25).
  * Make sure all inputs are wired up. Many inputs are not needed but every input should have a constant if it is not used.
  * Use the 'A' port for writing to the BRAM and the 'B' port for reading from the BRAM. 
  * To configure each of the ports to 8 bits, set the `READ_WIDTH_B` parameter to 9  and the `WRITE_WIDTH_A` to 9.
  * Set the `WRITE_MODE_A` parameter to "READ_FIRST"
  * Connect the following ports appropriately. Make sure you connect all the bits of each of the port (see the datasheet for details):
    * `DIADI` and `DOBDO` (32-bit data ports)
    * `ADDRARDADDR` and `ADDRBWRADDR` (16 bits) It is tricky to hook up the address ports appropriately. Read the data sheet carefully to understand how to connect this port.
    * `WEA` (4 bit write enable).
    * `ENARDEN`
  * Do not include the parameters for initializing the memory. In fact, use only those parameters that you plan to override.

### BRAM FIFO Testbench 

Create a simple testbench named  `bram_fifo_tb.sv` that demonstrates writing a few bytes, reading/writing a few bytes, and the full/empty signals working properly.
Use a SystemVerilog 'queue' to store the values of the FIFO so you can check that the order you write is the order that you read.
Print a message each time an element is written to or read from the FIFO.

To simulate the `RAMB36E1` primitive you will need to include the 'unisim' library in your simulation.
This precompiled library contains all the simulation models of the Xilinx primitives.
Follow these steps to include this library in your simulation environment:
* Add the following line to your `modelsim.ini` file: `unisim = /tools/Xilinx/Vivado/2024.1/data/questa/unisim`. Note that the path for this library is based on the computers in the digital lab. You may need to adjust this path if you are using a different computer.
* Add the flag `-L unisim` to your `vsim` command in your simulation script.
Create a makefile rule named `sim_bram_fifo` that runs this simulation from the command line.

<!--
* `vlib unisim`
* `vmap unisim <Simulation library path>`. For the computers in the digital lab, the simulation path is: 
-->
### BRAM FIFO Synthesis

After verifying that your FIFO works properly, create a makefile rule named `synth_bram_fifo` that synthesizes your FIFO design in the out of context synthesis mode (see the [instructions](../rx_sim/UART_Receiver_sim.md#receiver-synthesis) on how to do this).
Resolve any synthesis errors or warnings before proceeding with the next module.
Make sure the synthesis log shows that one RAMB36E1 was allocated for your module.
If you made any changes to your modules to resolve synthesis errors, rerun the testbench to make sure the module operates correctly.

## ASCII BRAM ROM

Create a second module in a file named `bram_rom.sv` that implements a "ROM" that stores a set of ASCII characters that can be read out one character at a time.
This module will be used to store a message sent over the UART.
The ports of this module should be as follows:

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Synchronous Reset |
| init | Input | 1 | Return pointer to zero |
| re | Input | 1 | Read enable |
| dout | Output | 8 | Data Out |
| rom_end | Output | 1 | Indicates the buffer is empty  |

| Parameter | Type | Function |
| ---- | ---- | ---- |
| FILENAME | string | File name of the ASCII file to read |

Design your module to operate as follows:
* Create an "inferred" memory that is 8 bits x 4096 (i.e., don't instance the BRAM primitive but use the inferred memory in your HDL).
* Provide a parameter that contains a file name that contains the data to be stored in the ROM. Create an initial block that performs this initialization.
* Create a read pointer that indicates which address to read from
* Increment this pointer every time `re` is asserted
* Reset the pointer when `init` is asserted
* Assert the 'end' signal when the value of the memory output is zero

### BRAM ROM Testbench 

Create a testbench in a file named `bram_rom_tb.sv`that demonstrates the ability to read all the contents of the ROM until the `end` signal is asserted.
Provide a couple of clock cycles between each read.

You will need to populate your ROM with a text message.
Two text messages have been provided for you: [fight_song.txt](fight_song.txt) and [declaration_of_independence.txt](declaration_of_independence.txt).
These text files cannot be directly loaded into the memory using the `readmemh` command because they are ASCII files.
I have created a python script, [gen_readmem.py](gen_readmem.py), that will convert these files into a format that can be read by the `readmemh` command.
The following example demonstrates how to create a memory file that is readable by the `readmemh` command:

`python3 gen_readmem.py fight_song.txt fight_song.mem -l 4096 -r`

Create a memory file for both text files and add a parameter to your testbench to specify the default ROM contents.
Configure your testbench to use the `fight_song.mem` file by default.
Create a makefile rule named `sim_bram_rom` that runs your testbench with the `fight_song.mem` from the command line.
Also, create a makefile rule named `sim_bram_rom_declaration` that runs your testbench with the `declaration_of_independence.mem` file.

### BRAM ROM Synthesis 

After verifying that your FIFO works properly, create a makefile rule for synthesizing your BRAM ROM in the out of context synthesis mode.
The makefile rule should be named: `synth_bram_rom` and should synthesize the ROM with the `fight_song` file contents.
Resolve any synthesis errors or warnings before proceeding with the next module.
**Make sure** the synthesis log shows that one RAMB36E1 was allocated for your module.
If you made any changes to your modules to resolve synthesis errors, rerun the testbench to make sure the module operates correctly.

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


<!--
- Need to have check script copy the modelsim.ini file to the student's directory for grading outside of the repo OR have them commit the modelsim.ini file
- Use the description from Chu section 9.3.2 for creating a FIFO (have them read this and implement this)

They use glbl.v file for simulation. Need to include in their repository.
Don't hard code any paths in makefile! (perhaps have an environment variable that is set so I can reuse their makefiles)
-->
