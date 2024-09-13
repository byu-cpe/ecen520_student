# Vivado Messages

Vivado generates many different types of messages through the simulation, synthesis, and implementation processes.
There are so many messages that it is often difficult to separate the trivial ones from the important ones.
Vivado messages are categorized by a severity level, and ideally you would be able to gauge the importance of the message based on this severity level.
The severity level of these messages are as follows:

| Severity Level   | Description                                                                                                                                                                                         |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ERROR            | An ERROR condition implies an issue has been encountered which will render design results unusable and cannot be resolved without user intervention.                                                |
| CRITICAL WARNING | A CRITICAL WARNING message indicates that certain input/constraints will either not be applied or are outside the best practices for an FPGA family. User action is strongly recommended.           |
| WARNING          | A WARNING message indicates that design results may be suboptimal because constraints or specifications may not be applied as intended. User action may be taken or may be reserved.                |
| INFO             | An INFO message is the same as a STATUS message, but includes a severity and message ID tag. An INFO message includes a message ID to allow further investigation through answer records if needed. |
| STATUS           | A STATUS message communicates general status of the process and feedback to the user regarding design processing. A STATUS message does not include a message ID.                                   |

Sometimes the severity level for a message is too high or too low for our needs.
This document describes how to change the severity level of a message and suggests some changes in the severity levels that may be useful for this class.

## Changing the Severity Level of a Message

The tcl `set_msg_config` command can be used to change the severity level of a message.
This command has the following options:

* `-i`: The ID of the message to change. This is a string that contains the ID of the message you want to change (such as `-id "Synth 8-327"`)
* `-new_severity`: The new severity level of the message. This should be one of the severity levels listed above.
  You can create a `.tcl` file that contains a list of `set_msg_config` commands to change the severity level of a message.
  You can then execute this .tcl file before you run the simulation, synthesis, or implementation processes.

## Messages that can be downgraded to the "INFO" severity level

```
set_msg_config -new_severity "INFO" -id "Constraints 18-5210"
set_msg_config -new_severity "INFO" -id "DRC RTSTAT-10"
set_msg_config -new_severity "INFO" -id "Synth 8-3331"
```

## Messages that should be upgraded to the "ERROR" severity level

```
set_msg_config -new_severity "ERROR" -id "Synth 8-87"
set_msg_config -new_severity "ERROR" -id "Synth 8-155"
set_msg_config -new_severity "ERROR" -id "Synth 8-327"
set_msg_config -new_severity "ERROR" -id "Synth 8-3352"
set_msg_config -new_severity "ERROR" -id "Synth 8-5559"
set_msg_config -new_severity "ERROR" -id "Synth 8-5972"
set_msg_config -new_severity "ERROR" -id "Synth 8-6090"
set_msg_config -new_severity "ERROR" -id "Synth 8-6858"
set_msg_config -new_severity "ERROR" -id "Synth 8-6859"
set_msg_config -new_severity "ERROR" -id "Timing 38-282"
set_msg_config -new_severity "ERROR" -id "VRFC 10-3091"
set_msg_config -new_severity "WARNING" -id "Timing 38-313"
```

## ECEN 323 New Project Settings

```
# This file contains several TCL commands for changing the default settings of your projects.
# These settings change the severity level of certain messages to make the messages
# more meaningful. Some settings will be upgraded and cause an error while others
# will be downgraded to avoid unnecessary warnings.

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
# Downgrade the 'There are no user specified timing constraints' to WARNING
set_msg_config -new_severity "WARNING" -id "Timing 38-313"
# Downgrade the 'no constraints selected for write' from a warning to INFO
set_msg_config -new_severity "INFO" -id "Constraints 18-5210"
# Downgrade the 'WARNING: [DRC RTSTAT-10] No routable loads: 35 net(s) have no routable loads.' to INFO
set_msg_config -new_severity "INFO" -id "DRC RTSTAT-10"
# Downgrade the warning 'WARNING: [Synth 8-3331] design riscv_simple_datapath has unconnected port instruction[14]' to INFO
#  These start in lab 5
set_msg_config -new_severity "INFO" -id "Synth 8-3331"
# Other possible downgrade options: (lab 9 warnings in synthesis)
# WARNING: [Synth 8-6014] Unused sequential element mem_ALUSrc_reg was removed.  [/tmp/ecen323_wirthlin/lab09/riscv_forwarding_pipeline.sv:320]
# WARNING: [Synth 8-7023] instance 'my_alu' of module 'alu' has 5 connections declared, but only 4 given [/tmp/ecen323_wirthlin/lab09/riscv_forwarding_pipeline.sv:303]

# Set incremental simulation to False (force all files to be re-analyzed)
set_property INCREMENTAL false [get_filesets sim_1]
# Set the initial simulation runtime when you open the simulator to zero
set_property -name {xsim.simulate.runtime} -value 0ns -objects [get_filesets sim_1]
```

<!--
INFO: [Synth 8-155] case statement is not full and has no default [/home/wirthlin/ee620/ECEN_620_wirthlin/grading/fall2023/ECEN_620_Hesl
ington/uart_receiver/tx.sv:88]
-->
