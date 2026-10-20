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

Your FIFO should be created as follows:
* Create a 12-bit "write address" counter and a 12-bit "read address" counter that indicate which address to write to and read from, respectively (12 bits address the 4096 bytes of the BRAM).
  * Every time a byte is written to the FIFO (i.e., when `we` is asserted), the write address should increment by one. The address naturally rolls over from 4095 to 0.
  * Every time a byte is read from the FIFO (i.e., when `re` is asserted), the read address should increment by one (also rolling over).
* Perform a write to the memory when a valid write occurs.
* Perform a read from the memory only when a valid read occurs (i.e., enable the BRAM read port with `re` asserted and the FIFO not empty).
* Create an `empty` signal that is asserted when the read address is equal to the write address.
* Create a `full` signal that is asserted when the write address is one less than the read address, with wrap-around (i.e., `wr_addr + 1 == rd_addr` using 12-bit arithmetic).
  Because one location is always left unused to distinguish full from empty, the FIFO holds at most 4095 bytes.
* Ignore reads when the FIFO is empty and ignore writes when the FIFO is full.
  These decisions are based on the `empty` and `full` values at the start of the clock cycle. If `we` and `re` are asserted in the same cycle:
  * When the FIFO is neither empty nor full, both the write and the read occur (the number of bytes in the FIFO does not change).
  * When the FIFO is empty, only the write occurs.
  * When the FIFO is full, only the read occurs (the write is ignored even though the read frees a location).
* Read timing: the FIFO has a one clock cycle read latency.
  When `re` is asserted (and the FIFO is not empty), the byte at the head of the FIFO appears on `dout` on the next clock cycle and remains on `dout` until the next valid read.
  The value of `dout` is undefined before the first read.
* Instance a `RAMB36E1` primitive into your design using an 8-bit data bus. You will need to carefully read the details about this primitive in the [7 Series Memory Resources (UG473)](https://docs.amd.com/v/u/en-US/ug473_7Series_Memory_Resources) (see page 25).
  * Make sure all inputs are wired up. Many inputs are not needed but every input should have a constant if it is not used.
  * Use the 'A' port for writing to the BRAM and the 'B' port for reading from the BRAM. 
  * To configure each of the ports to 8 bits, set the `READ_WIDTH_B` parameter to 9  and the `WRITE_WIDTH_A` to 9.
  * Set the `WRITE_MODE_A` parameter to "READ_FIRST"
  * Connect the following ports appropriately. Make sure you connect all the bits of each of the port (see the datasheet for details):
    * `DIADI` and `DOBDO` (32-bit data ports)
    * `ADDRARDADDR` and `ADDRBWRADDR` (16 bits) It is tricky to hook up the address ports appropriately. Read the data sheet carefully to understand how to connect this port.
    * `WEA` (4 bit write enable).
    * `ENARDEN` (port A enable)
    * `ENBWREN` (port B enable): drive this with your valid read signal (`re` and not empty) to get the read timing described above.
  * Do not include the parameters for initializing the memory. In fact, use only those parameters that you plan to override.

### BRAM FIFO Testbench 

Create a simple testbench named `bram_fifo_tb.sv` that demonstrates writing a few bytes, reading/writing a few bytes, and the full/empty signals working properly.
Use a SystemVerilog 'queue' to store the values of the FIFO so you can check that the order you write is the order that you read.
Remember the one-cycle read latency: compare `dout` against the expected value on the clock cycle *after* you assert `re`.
Print a message each time an element is written to or read from the FIFO.

To simulate the `RAMB36E1` primitive you will need to include the 'unisim' library in your simulation.
This precompiled library contains all the simulation models of the Xilinx primitives.
Follow these steps to include this library in your simulation environment:
* Add the following line to your `modelsim.ini` file: `unisim = /tools/Xilinx/Vivado/2024.1/data/questa/unisim`. Note that the path for this library is based on the computers in the digital lab. You may need to adjust this path if you are using a different computer. Commit this file to your repository.
* Add the flag `-L unisim` to your `vsim` command in your simulation script.
Create a makefile rule named `sim_bram_fifo` that runs this simulation from the command line and generates a log file named `sim_bram_fifo.log`.

<!--
* `vlib unisim`
* `vmap unisim <Simulation library path>`. For the computers in the digital lab, the simulation path is: 
-->
### BRAM FIFO Synthesis

After verifying that your FIFO works properly, create a makefile rule named `synth_bram_fifo` that synthesizes your FIFO design in the out of context synthesis mode.
This synthesis step should create a .dcp file named `synth_bram_fifo.dcp` and a log file named `synth_bram_fifo.log`
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
* Use the `FILENAME` parameter in an initial block that loads the ROM contents with `$readmemh`.
* Create a read pointer that indicates which address to read from
* Increment this pointer every time `re` is asserted
* Reset the pointer when `init` is asserted
* Assert the 'rom_end' signal when the value of the memory output is zero

### BRAM ROM Testbench 

Create a testbench in a file named `bram_rom_tb.sv` that demonstrates the ability to read all the contents of the ROM until the `rom_end` signal is asserted.
Provide a couple of clock cycles between each read.

You will need to populate your ROM with a text message.
Two text messages have been provided for you: [fight_song.txt](fight_song.txt) and [moroni_10.txt](moroni_10.txt).
<!-- [declaration_of_independence.txt](declaration_of_independence.txt). -->
These text files cannot be directly loaded into the memory using the `readmemh` command because they are ASCII files.
I have created a python script, [gen_readmem.py](gen_readmem.py), that will convert these files into a format that can be read by the `readmemh` command.
The following example demonstrates how to create a memory file that is readable by the `readmemh` command:

`python3 gen_readmem.py fight_song.txt fight_song.mem -l 4096 -r`

The `-l 4096` option specifies the length of the memory (in bytes) and will zero fill the memory if the file is shorter than this length.
The `-r` option indicates that a carriage return should be added to the end of each line.

The `.mem` files are *generated* files: do not commit them to your repository, and add them to your `.gitignore` file.
Instead, create makefile rules that generate them from the `.txt` files using `gen_readmem.py`, for example:

```
fight_song.mem: fight_song.txt
	python3 gen_readmem.py fight_song.txt fight_song.mem -l 4096 -r
```

Make every simulation and synthesis rule that uses a `.mem` file depend on it, so the `.mem` file is regenerated automatically on a clean checkout (the passoff script checks that these rules create the `.mem` files they need).
Your `clean` rule should also delete the `.mem` files.

Create a memory file for both text files and add a parameter to your testbench to specify the default ROM contents.
Configure your testbench to use the `fight_song.mem` file by default.
Create a makefile rule named `sim_bram_rom` that runs your testbench with the `fight_song.mem` from the command line and generates a log file named `sim_bram_rom.log`.
Also, create a makefile rule named `sim_bram_rom_moroni_10` that runs your testbench with the `moroni_10.mem` file and generates a file named `sim_bram_rom_moroni_10.log`.

### BRAM ROM Synthesis 

After verifying that your ROM works properly, create a makefile rule for synthesizing your BRAM ROM in the out of context synthesis mode.
The makefile rule should be named: `synth_bram_rom` and should synthesize the ROM with the `fight_song.mem` file contents (this rule must also depend on `fight_song.mem` so that it is generated before synthesis).
This synthesis step should create a .dcp file named `synth_bram_rom.dcp` and a log file named `synth_bram_rom.log`

Resolve any synthesis errors or warnings before submitting your assignment.
Review your synthesis log to **make sure** the synthesis log shows that one RAMB36E1 was allocated for your module.
If you made any changes to your modules to resolve synthesis errors, rerun the testbench to make sure the module operates correctly.

  
## Submission and Grading

1. Implement all the required makefile rules and make sure your `passoff.py` script runs without errors.
2. Complete and commit the [report.md](report.md) file for this assignment. The assignment specific questions in the report ask you to:
    * Fill in a resource utilization table for each design (FIFO and ROM) from its synthesis log.
    * Open `synth_bram_rom.dcp` in Vivado, find the ROM's BRAM in the schematic, and copy its `INIT_00` property from the "Cell Properties" window. This shows how the fight song contents were loaded into the BRAM.


<!--
- Easy lab. COuld be combined with download if the instantiation insturciotns are provided (a waste of time to look it up)
- Add a little more help on how to use the bram primitives and where in the docs to look.
  Add an instruction in GitHub to add the modelsim.ini to the bram directory, and to run vsim from the terminal as <vsim -L unisim &>.
- Need to have check script copy the modelsim.ini file to the student's directory for grading outside of the repo OR have them commit the modelsim.ini file (done)
- Use the description from Chu section 9.3.2 for creating a FIFO (have them read this and implement this)

They use glbl.v file for simulation. Need to include in their repository.
Don't hard code any paths in makefile! (perhaps have an environment variable that is set so I can reuse their makefiles)
-->
