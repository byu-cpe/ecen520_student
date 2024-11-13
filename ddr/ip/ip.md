# Generating and Using the DDR Memory Controller IP

A DDR controller is a very complex piece of hardware that would be very difficult to create from scratch.
Fortunately, Xilinx provides an "Intellectual Property" (IP) block called the Memory Interface Generator (MIG) that can generate a DDR controller for you.
This page describes how to use the IP tool to generate a DDR controller for the Nexys 4 DDR board and how to integrate this core into your repository.
Complete all the exercises described here in your `ip` directory and archive your IP in this directory.

There are several steps to this DDR controller generation process:
1. [Create the DDR controller using the GUI](#creating-the-ddr-memory-controller)
2. [Add the IP files to your repository](#github-repository)
3. [Create Example DDR Design]()

The user guide for this IP can be found [here](https://docs.amd.com/r/en-US/ug586_7Series_MIS).

## Creating the DDR Memory Controller

This section describes how to create the DDR IP from the Vivado GUI.
This is a one time task that you need to complete to prepare the DDR IP for use in your design.
After creating the IP files, you will commit the IP project files into your repository so that you could recreate the IP from the command line as part of the build process.
The steps for creating the IP and adding to your repository are described in this section.

### Create IP Location

The first step in the IP process is to create an IP library project.
Open Vivado in the interactive GUI mode from your `ddr/ip` assignment directory to start the process of creating the DDR memory controller.
Enter the "Manage IP" task by creating a new location for the IP.
Create a new location for the IP by going to `File -> IP -> New Location`.

In the "New IP Location" dialog box, enter the following information:
* Change the part to "xc7a100tcsg324-1"
* Leave the target language the same
* Select the "Questa Advanced Simulator" as the simulator
* Simulator language: leave as 'mixed'
* Choose your `ddr/ip` assignment directory as the location of the IP. 

Select "OK" to create the directory.
You will then enter the "Manage IP" window.
Creating this IP directory will create `managed_ip_project` subdirectory.
This directory contains the global settings for the IP management window.

You can always return to the IP management window by selecting `Tools -> Open Location` and selecting the directory you just created.
Once you create the IP you will not need to go back to the GUI.

### Create MiG DDR Controller IP

The next step is to create the DDR controller from within the "Manage IP" window.
This is all done through the GUI as described in the instructions below.
Enter the "Manage IP" window as described above.
In the "IP Catalog" tab, enter "MiG" in the search box.
Scroll through the entries and select/double click the "Memory Interface Generator (MIG 7 Series)" IP to open the Memory Interface Generator (MIG) dialog box.
This dialog box will guide you through multiple pages of options to configure the DDR controller.
Carefully follow the instructions below to properly configure the DDR controller.
You can move back and forth between these pages by pressing the "Back" and "Next" buttons.

* "Memory Interface Generator" (Initial Screen)
  * Review to make sure the part number is correct
  * You can access the "User Guide" by pressing the button in the lower left-hand corner
  * Press "Next" to continue (for all subsequent pages press "Next" to continue unless otherwise instructed)
* "MIG output Options"
  * Leave the default settings
* "Pin Compatible FPGAs"
  * When you get to this screen a navigator will show up on the left that allows you to jump to different pages without clicking through Next/Back
  * Select the "xc7a100ti-csg324" part
* "Memory Selection"
  * Select 'DDR2 SDRAM'
* "Controller Options" (Options for Controller 0 - DDR2 SDRAM)
  * Clock Period: 3333 (300 MHz)
  * Memory Part: `MT47H64M16HR-25E` (second from the bottom)
  * Width: 16
  * Leave all other settings at the default value
  <!-- * Data Mask: selected
  * Nmber of Bank Machines (leave at default 4)
  * Ordering: leave at strict -->
* "Memory Options" (Memory Options C0 - DDR2 SDRAM)
  * Input Clock Period: 5000 ps (200 MHz)
  * RTT: 50 ohms
  * Leave all other settings at the default value
* "FPGA Options"
  * System clock: No Buffer <!-- We generate the signal at the top level -->
  * Reference clock: Use System Clock  <!-- We generate the signal at the top level -->
  * Internal VREF: select enabled (change)
  * Leave all other settings at the default value
* "Extended FPGA Options"
  * Leave at default
* "I/O Planning Options"
  * Select Fixed Pin Out
* "Pin Selection"
  * Press "Read XDC/UCF" to load a UCF file
    * Select the [`nexys4_ddr.ucf`](./nexys4_ddr.ucf) file (this file is preconfigured to describe the DDR pins for the Nexys 4 DDR board)
  * Press the "Validate" button to validate the pinout
  * Press "Next" to continue
* "System Signals Selection"
  * "System Clock Pin Selection"
    * For "sys_clk_i" select 35 for "Bank Number" and E3 for "Pin Number"
* "Summary"
  * Select "Next"
* "Simulation Options"
  * Accept the terms and conditions
  * Select "Next"
* "PCB Information"
  * Select "Next"
* "Design Notes"
  * Select "Generate"

At this point the IP source files have been "generated" and you can start using the IP.
A new dialog box will open up that will allow you to synthesize the DDR controller IP.
Click "Skip" to skip this process of running the synthesis tool on this IP (synthesis will be done later as part of your top-level design).

Two additional directories are added to your directory:
* `mig_7series_0`: This is the main directory for the mig DDR contro9ller
* `ip_user_files`: This is an empty directory

There is a button in the lower left corner named "User Guide" that provides a link to the IP user guide.
This link didn't work for me.
The public link to this IP is: https://docs.amd.com/r/en-US/ug586_7Series_MIS

After completing the IP generation process, generate a Tcl script that you can use to recreate your project at a later time.
The following TCL command will generate a file named `make_ip.tcl` that you can run to recreate the IP and avoicd the GUI steps described above:
`write_project_tcl make_ip.tcl`

Exit the GUI.

## GitHub repository

After completing the previous step you will have all the IP sources needed to implement the controller in your design.
Since your project will need to be created from scratch from your repository, it is necessary that you have the ability to create the IP from scratch within your repository (managing IP in a repository is difficult and awkward).
This section will describe how you should manage and build the IP in your repository.

Commit the following files into your repository:
* `make_ip.tcl` (generated by the `write_project_tcl` command described above)
* Copy the file `mig_7series_0/mig_a.prj` into your `ip` directory (don't commit it in its original location). This file is generated in the IP creation process.
* Copy the file `mig_7series_0/mig_7series_o.xci` into your `ip` directory (don't commit it in its original location). This file is generated in the IP creation process.

Create a `.gitignore` file in your assignment directory that ignores the following directories: `mig_7series_0`, `managed_ip_project`, and `ip_user_files`.

Further, create a `makefile` that includes the following rules:
* A `ipclean` rule that deletes the `mig_7series_0`, `managed_ip_project`, and `ip_user_files` directories.
* A rule that builds the IP from the `make_ip.tcl` file
   * Create the `mig_7series_0` directory
   * Copy the files `mig_a.prj` and `mig_7series_o.xci` to the `mig_7series_0` directory
   * Run the following command in the `mig_7series_0` directory to recreate the IP from these copied files: `vivado -mode batch -source make_ip.tcl`

Experiment with your clean and build rules to make sure you can easily remove and recreate the IP from your repository.
You should make sure your IP is cleaned as part of your top-level assignment clean process.

## Example DDR Project

A sample DDR project has been created for you to demonstrate how to use the DDR controller on the Nexys4 DDR board.
You will go through the process of simulating and building a bitstream to demonstrate the DDR controller.
This section will describe how to build and simulate this example project.
You will likely refer to this design as part of your assignment.




In this section you will experiment with the example design created by the DDR controller IP.

1. Simulate the example design (become familiar with the simulation and ask questions)
2. Synthesize the design (and give extra work for targing board)
3. Download the bitstream to the board

```
open_example_project -force -dir /home/wirthlin/ee620/520-assignments-wirthlin/ddr/proj [get_ips  mig_7series_0]
source /home/wirthlin/ee620/520-assignments-wirthlin/ddr/mig_7series_0/mig_7series_0_ex.tcl -notrace
```


  * `managed_ip_projects` (a directory that contains the synthesized products. This will be relatively empty at this point.)
  * `mig_7series_0` (a directory containing the DDR controller IP. Design files and simulation files)
    * `example_design` (a directory containing the example design including a testbench and memory simulation model)


* "Generate": (synthesis)

The "Generate Output Products" dialog box will appear.
Click "Generate" to create the DDR controller IP (this will take some time).

Questions:
* How to archive this in a git repository? (tcl script?)
* How to setup a simulation?
* Do you need to run synthesis or can you just run it as part of your top level design?
