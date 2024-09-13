# Vivado Command Line Tools

Although the Vivado GUI can be used to help you manage projects, perform simulation, and implement your design, you will need to run the Vivado tools in command line mode.
This page provides instructions for running these tools in command line mode.
Instructions for using these tools in the GUI mode are provided on the ECEN 220 class web pages.

## Simulation

Although the Vivado simulation tools are often run in the GUI mode, it is often more productive to run them in a commandline mode.
There are three command line tools that are needed to simulate on the command line: `xvlog`, `xvhdl`, `xelab`, and `xsim`.
Details on these commands can be found in the [Vivado Simulation Reference Manual](https://docs.xilinx.com/r/en-US/ug900-vivado-logic-simulation/Overview).

Note that all of these simulation tools generate a lot of logs, directories, and miscellaneous files that you will need to ignore within your GitHub repository and properly clean in your makefile.

### xvlog

`xvlog` is a tool that parses individual verilog/vhdl files and performs the HDL 'analyze' step.
This is similar to the 'compilation' step of a traditional software such as compiling `.c` files using the `-o` option.
You must analyze each HDL file that you write before you can elaborate or simulate it.
During the early design phase, you will likely run into a number of syntax errors that these tools will catch.

Relevant arguments:

* `-sv`: use this argument for SystemVerilog files (and omit this argument for Verilog files)
* `--nolog`: This avoids generated a log for each call of this command

_Example_:

```
xvlog -sv --nolog tx.v
```

### xvhdl

`xvhdl` is similar to `xvlog` and performs the HDL 'analyze' step for the VHDL language.
Like Verilog files, all VHDL files must be analyzed before they can be elaborated or simulated.

Relevant arguments:

* `--nolog`: This avoids generated a log for each call of this command

_Example_:

```
xhvdl --nolog tx.vhd
```

### xelab

**xelab** is the tool used to _elaborate_ a top-level design. Static elaboration involves setting parameters and generics, integrating submodules of the hierarchy into the design, evaluating generate statements, and other steps to create an implemented instance of a module.
Elaboration is similar to the static linking stage in software.
The **xelab** tool also generates executable code for a simulation and links this executable code with the simulation kernel library.
Note that all modules/files involved in the elaboration must first be analyzed as described above using `xvlog` and `xvhdl`.

Relevant arguments:

* The first set of arguments are the _module names_ (not the file names) that are to be analyzed. It is possible to analyze more than one module, although you will usually only analyze a single top-level module at a time.
* `-s <snapshot_name>`: this specifies the "snapshot" or location where the elaborated design will go. A new directory will be created that has the same name as the snapshot. Although this argument is not required, it is helpful when managing more than one elaborated design.
* `--nolog`: This avoids generated a log for each call of this command
* `-debug typical`: This debug option will include information about your internal signals so you can create waveforms of internal signals
* `-relax`: This option will downgrade some errors to warnings (such as when some files have timescale and others do not)
* `-L <library>`: This option specifies a library to be used during elaboration. This is often used to specify the `unisims_ver` library that contains the Xilinx primitives.
* `--generic_top`: This option is used to change the top-level parameters of your design. The value is a string with a parameter name, followed by '=', and then the value. For example, `--generic_top "BAUD_RATE=115200"`. Multiple `--generic_top` options can be used to set multiple parameters.
* `glbl`: This option specifies the `glbl` library that includes the compiled xilinx primitive libraries.

_Example_:

```
xelab --nolog rx_tb -s rx_tb
```

#### Setting Parameters for Simulation

You may want to change the parameters of a module that you are simulating from the default module parameters.
This is done by using the `-generic_top` option during elaboration with the **xelab* command (a 'generic' is a VHDL term that we will discuss in the VHDL section).
Note that you can't set the parameters of a module further down in the hierarchy - you can only set the parameters of the top-level module you are elaborating.
The value you give to this parameter is a quoted string that provides both the parameter name and the value that you will change to.
The following example shows how to use this option to set a `BAUD_RATE` parameter to a value of 9600:

```
xelab --nolog tx_tb -s tx_tb -generic_top "BAUD_RATE=9600"
```

### xsim

**xsim** is the actual simulation tool that you will run to perform a simulation.
Any module that is to be simulated with this tool must have been elaborated as described in the previous step.
The **xsim** tool can be run in 'gui' mode to provide a graphical user interface (i.e., waveform window) or on the command line.
The 'gui' mode is useful in early debugging when errors need to be identified but takes longer to load and run.
The command line mode is used for running test-benches and other validation runs for modules that have been validated previously.

Relevant arguments:

* The first argument is the 'snapshot' name that you want to simulate. This is the same name given with the `-s` option in the **xelab** tool
* `--gui`: Indicates that the simulation should be run in the 'gui' mode (the default is in command line mode)
* `--onfinish quit`: Exit the simulator when the simulation ends (i.e., when `$finish` is reached)
* `-runall`: Executes a `run all` command when the simulator first starts

_Example 1_: Run simulator in gui mode

```xsim -gui tx_tb```

_Example 2_: Run simulator interactively from a tcl command line

```xsim tx_tb```

_Example 3_: Run simulator until `$finish` is reached and exit

```xsim tx_tb --onfinish quit -runall```

	$(XSIM) tb_sim -onfinish quit -runall

### Simulating Xilinx Primitives

To simulate primitives within the Xilinx unisims library from the simulation command line you will need to complete the following steps:

1. You will need to compile the `glbl` verilog library that contains the simulation model for the mmcm module (you will need to change the location of the glbl file to match your installation):

```
xvlog --nolog -sv /tools/Xilinx/Vivado/2021.2/data/verilog/src/glbl.v
```

1. When you elaborate your final simulation model you will need to include the following options:

* `-L unisims_ver` : This will include the unisims library that contains the mmcm primitive
* `glbl` : This will include the glbl library that contains the simulation model for the mmcm primitive
* `-relax` : This will downgrade warnings such as the following: `Module glbl has a timescale but at least one module in design doesn't have timescale.`

_Example_:

```
xelab --nolog -debug typical mmcm_top -debug typical -relax -s mmcm_top_elab -L unisims_ver glbl
```
