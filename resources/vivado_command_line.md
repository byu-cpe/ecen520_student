# Vivado Command Line Tools

Although the Vivado GUI can be used to help you manage projects, perform simulation, and implement your design, you will need to run the Vivado tools in command line mode.
This page provides instructions for running these tools in command line mode.
Instructions for using these tools in the GUI mode are provided on the ECEN 220 class web pages.

## Synthesis and Implementation

The Vivado Synthesis and Implementation tools are used to convert your HDL into a configuration bitstream that can be downloaded to your FPGA.
Like the simulation tools, the Vivado synthesis and implementation tools can also be run from the command line.
The process of performing synthesis and implementation, however, operates much differently than the simulation tools.
To implement a configuration bitstream you need to run a set of Tcl commands within the Vivado tool.
You can execute these commands in the GUI, but you can also execute the commands on the command line interactively or with a script.
Note that the instructions described below involve running the implementation in [non-project mode](https://docs.xilinx.com/r/en-US/ug892-vivado-design-flows-overview/Using-Non-Project-Mode).

<!--
Note that there is a difference between synthesis and implementation - they are considered very different steps with different manuals/reports.

Reports: (see "Report" class of TCL commands)

report_design_analysis
report_utilization
check_timing
report_timing_summary


report_drc -file tx_top_drc_routed.rpt -pb tx_top_drc_routed.pb -rpx tx_top_drc_routed.rpx
report_timing_summary -max_paths 10 -report_unconstrained -file tx_top_timing_summary_routed.rpt -pb tx_top_timing_summary_routed.pb -rpx tx_top_timing_summary_routed.rpx -warn_on_violation
report_clock_utilization -file tx_top_clock_utilization_routed.rpt

The synthesis "report" appears to be just the output of Vivado during the synthesis run.
Is there a way to steer the "synthesis" output to its own file?
Not sure what: -debug_log does

implementation.log is just the output of vivado for the implementation steps.

-->

The following example demonstrates how to execute the commands within a Tcl script from the command line.

```
vivado -mode batch -source tx_synth.tcl -log tx_implement.log
```

The options for this command are as follows:

* `-mode batch`: This option indicates that the Vivado tool should be run in batch mode. In this mode, the GUI is not opened and the runs a TCL command shell.
* `-source <tcl file>` : This option indicates that the Vivado tool should execute the commands in the given tcl file. The Vivado executable will exit after executing all of the commands in this file.
* `-log <log file<`: This option indicates that the Vivado tool should write all of the output generated from executing the given TCL script to the given log file. It is a good idea to use this option when you are generating bitstreams as all of the feedback from the synthesis tool is generated to std_out during execution, and you will often want to refer to this output when evaluating your synthesis and implementation.

A sample script that performs the full implementation is shown below:

```
# Simple script for generating a bitstream

# Load files
read_verilog tx.v
read_verilog -sv top.sv
read_xdc top.xdc

# Perform synthesis
synth_design -top top -part xc7a100tcsg324-1

# Perform Implementation
opt_design
place_design
route_design

# Generate reports
report_io -file tx_top_io.rpt
report_timing_summary -max_paths 10 -report_unconstrained -file tx_top_timing_summary_routed.rpt -warn_on_violation
report_utilization -file tx_top_utilization_impl.rpt
report_drc -file tx_top_drc_routed.rpt

# Generate bitstream
write_bitstream -force tx.bit
```

Details on all of the TCL commands used in this script can be found from the [Vivado TCL commands guide](https://docs.xilinx.com/r/en-US/ug835-vivado-tcl-commands).
Details on several of the commands used above are described below.

### read_verilog

The `read_verilog` command reads a verilog file into the Vivado tool and is similar to the `xvlog` command described in the simulation section.
You must read in all of the HDL files into the Vivado environment before performing synthesis.
Like the `xvlog`, the `-sv` flag should be used to distinguish between Verilog and SystemVerilog files.

### read_xdc

The `read_xdc` command reads a Xilinx Design Constraints (XDC) file into the Vivado tool.
You must read the XDC file into the Vivado environment before performing synthesis.

### synth_design

The `synth_design` command performs the logic synthesis.
Logic synthesis is a very complex operation that runs the Vivado synthesis tool (refer to the [Vivado Synthesis User Guide](https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis) for details on the synthesis tool).
There are numerous options available for controlling the synthesis process.
A few of these will be listed below.

* `-top`: This option specifies the top-level module that is to be synthesized. This module must be one of the modules that was read in with the `read_verilog` command.
* `-verbose`: This option enables verbose operation. It is usually a good idea to carefully review the output of your synthesis tool and enable verbosity so you can see any potential issues with your design.
* `-part`: This option specifies the FPGA part that will be used during synthesis. For this class, we will use the `xc7a100tcsg324-1` part on the Nexys DDR board.
* `-generic`: This option is used to change the parameters of the top-level module that is being synthesized. The value is a string with a parameter name, followed by '=', and then the value. For example, `-generic {BAUD_RATE=115200}`. Multiple `-generic` options can be used to set multiple parameters.

#### Setting Parameters for Synthesis

As with simulation, you may want to change the parameters of a module that you are implementing from the default module parameters.
This is done by using the `-generic` option with the `synth_design` TCL command.
The value you give to this parameter is a string within braces that provides both the parameter name and the value that you will change to.
The following example shows how to use this option to set a `BAUD_RATE` parameter to a value of 9600:

```
synth_desigh -top my_top -partxc7a100tcsg324-1 -generic {BAUD_RATE=9600}
```

### Design implementation

After synthesis, the next phase involves implementation which takes the synthesized design and maps it to the resources of the FPGA part you have selected.
There are three commands used during the implementation process.

#### opt_design

This command performs a number of design optimizations to make it lower power, improved timing, and lower resources.
This command is _optional,_ and you may not want to use it in early labs.

#### place_design

Performs placement of the top-level I/O ports and the leaf cells (primitives) of your design.
This command is _required_.

#### route_design

Performs routing of the nets between the placed primitives.
This command is _required_.

### Generate reports

Once your design has been implemented, it is essential to review the design details to learn about the performance, utilization, and potential issues with your design.
There are many commands that will generate a variety of reports to help you understand your design.
These commands are called after your design has completed the implementation process.

#### report_timing_summary

This command summarizing the timing of your design.
You must always check to make sure your design meets the timing constraint and this report provides you with this check.
There are a variety of options to this command:

```
report_timing_summary -max_paths 10 -report_unconstrained -file tx_top_timing_summary_routed.rpt -warn_on_violation
```

#### report_utilization

This command summarizes the FPGA utilization of your design.

```
report_utilization -file tx_top_utilization_impl.rpt
```

#### report_drc

This command performs a "Design Rule Check" (or DRC) to make sure your implemented design does not violate any design rules

```
report_drc -file tx_top_drc_routed.rpt
```

### Generate bitstream

When you are done with the implementation, you can generate a bitstream that can be downloaded to your FPGA.
This is done with the `write_bitstream` command.

```
write_bitstream -force tx.bit
```

* `-force`: Overwrite the bitstream if it exists

### Create Checkpoint

If you close Vivado after implementing your design and generating your bitstream, you will not be able to go back and access the design.
It is usually desirable to save the implemented design so you can go back and review the design and make implementation changes.
You can save the design by creating a checkpoint file ('dcp' file).
This is done with the `write_bitstream` command.

```
write_checkpoint -force tx.dcp
```

* `-force`: Overwrite the checkpoint if it exists

### Read Checkpoint

```

```

## Adjusting Message Severity Levels

The messages you get from the tools are very important, and it is essential that you understand and handle all warnings and errors.
Sometimes it is necessary to adjust the severity level of the messages you get from the tools as some messages are very important and not listed as a warning and others are not that important and listed as a warning.
You can adjust the severity of a message by using the tcl `set_msg_config` command in Vivado.
The following set of tcl commands adjusts the warnings appropriate for this class.
You should run these commands before performing synthesis.

```
# Change in Message severity

# Downgrades

# Downgrade the 'There are no user specified timing constraints' to WARNING
#set_msg_config -new_severity "WARNING" -id "Timing 38-313"
# Downgrade the 'no constraints slected for write' from a warning to INFO
set_msg_config -new_severity "INFO" -id "Constraints 18-5210"
# Downgrade the 'WARNING: [DRC RTSTAT-10] No routable loads: 35 net(s) have no routable loads.' to INFO
set_msg_config -new_severity "INFO" -id "DRC RTSTAT-10"
# Downgrade the waraning 'WARNING: [Synth 8-3331] design riscv_simple_datapath has unconnected port instruction[14]' to INFO
#  These start in lab 5
set_msg_config -new_severity "INFO" -id "Synth 8-3331"
# WARNING: [Synth 8-7080] Parallel synthesis criteria is not met
set_msg_config -new_severity "INFO" -id "Synth 8-7080"
# WARNING: [Synth 8-3917] design top has port DP driven by constant 1
set_msg_config -new_severity "INFO" -id "Synth 8-3917"
#  This message is given when a state is unused. This occurs because the state is unreachable or a duplicate
#  (not sure why vivado added a state and then removed it)
# WARNING: [Synth 8-3332] Sequential element (U1/FSM_onehot_state_reg[13]) is unused and will be removed from module top.
#set_msg_config -new_severity "INFO" -id "Synth 8-3332"

# Upgrades

set_msg_config -new_severity "ERROR" -id "Synth 8-87"
#INFO: [Synth 8-155] case statement is not full and has no default
set_msg_config -new_severity "ERROR" -id "Synth 8-155"
# Infer Latch
set_msg_config -new_severity "ERROR" -id "Synth 8-327"
set_msg_config -new_severity "ERROR" -id "Synth 8-3352"
# Multi-driven net
set_msg_config -new_severity "ERROR" -id "Synth 8-5559"
# [Synth 8-5972] variable 'Zero' cannot be written by both continuous and procedural assignments
set_msg_config -new_severity "ERROR" -id "Synth 8-5972"
set_msg_config -new_severity "ERROR" -id "Synth 8-6090"
# "multi-driven net" caused by continuous assign statements along with wire declaration
set_msg_config -new_severity "ERROR" -id "Synth 8-6858"
# Upgrade the 'multi-driven net on pin' message to ERROR
set_msg_config -new_severity "ERROR" -id "Synth 8-6859"
# Upgrade the 'The design failed to meet the timing requirements' message to ERROR
set_msg_config -new_severity "ERROR" -id "Timing 38-282"
# Upgrade the 'actual bit length 8 differs from formal bit length 22 for port 'o_led' message
set_msg_config -new_severity "ERROR" -id "VRFC 10-3091"
```

## Hardware Manager

You can run the hardware manager from the TCL interpreter when running vivado in TCL mode.
These instructions were summarized from this [document](https://docs.xilinx.com/r/en-US/ug835-vivado-tcl-commands/open_hw_manager).

First, enter the Vivado TCL command interpreter:

```
$ vivado -mode tcl
```

Next, open the hardware manager:

```
Vivado% open_hw_manager
```

With your board connected to your computer, connect to the hardware server and open your hardware target:

```
Vivado% connect_hw_server
Vivado% open_hw_target
```

Once you have successfully connected to your board, you can see which device you are using by executing the `current_hw_device` command.

Set the programming bit file to the bitstream:

```
Vivado% set_property PROGRAM.FILE {<path to bitfile>} [get_hw_devices xc7a100t_0]
```

Now, program the device:

```
Vivado% program_hw_device
```

Finally, close the hardware manager:

```
Vivado% close_hw_manager
```
