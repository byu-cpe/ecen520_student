# Generating and Using the DDR Memory Controller IP

A DDR controller is a very complex piece of hardware that would be very difficult to create from scratch.
Fortunately, Xilinx provides an "Intellectual Property" (IP) block called the Memory Interface Generator (MIG) that can generate a DDR controller for you.
This page describes how to use the IP tool to generate a DDR controller for the Nexys 4 DDR board and how to integrate this core into your repository.
Complete all the exercises described here in your `ip` directory and archive your IP in this directory.

There are several steps to this DDR controller generation process:
1. [Create the DDR controller using the GUI](#creating-the-ddr-memory-controller)
2. [Add the IP files to your repository](#github-repository)
3. [Create Example DDR Design]()
4. [Simulate the Example Design]()
5. [Synthesize & Implement the Example Design]()

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
* "Create a New Customized IP Location" page. Click Next
* "Manage IP Settings" page
  * Change the part to "xc7a100tcsg324-1"
  * Leave the target language the same
  * Select the "Questa Advanced Simulator" as the simulator
  * Simulator language: leave as 'mixed'
  * Choose your `ddr/ip` assignment directory as the location of the IP. 
  * Click Finish
Creating this IP directory will create the `managed_ip_project` and `ip_user_files` subdirectory.
This directory contains the global settings for the IP management window.

You will then enter the "Manage IP" window.
You can always return to the IP management window by selecting `Tools -> Open Location` and selecting the directory you just created.
Once you create the IP you will not need to go back to the GUI.

### Create MiG DDR Controller IP

The next step is to create the DDR controller from within the "Manage IP" window.
This is all done through the GUI as described in the instructions below.
Enter the "Manage IP" window as described above.
In the "IP Catalog" tab, enter "MiG" in the search box.
Scroll through the entries and select/double-click the "Memory Interface Generator (MIG 7 Series)" IP to open the Memory Interface Generator (MIG) dialog box.
This dialog box will guide you through multiple pages of options to configure the DDR controller.
Carefully follow the instructions below to properly configure the DDR controller.
You can move back and forth between these pages by pressing the "Back" and "Next" buttons.

* "Memory Interface Generator" (Initial Screen)
  * Review to make sure the part number is correct
  * You can access the "User Guide" by pressing the button in the lower left-hand corner
  * Press "Next" to continue (for all subsequent pages press "Next" to continue unless otherwise instructed)
* "MIG Output Options"
  * Select the 'AXI4' interface <!-- Remove this option if you are not using AXI -->
* "Pin Compatible FPGAs"
  * When you get to this screen a navigator will show up on the left that allows you to jump to different pages without clicking through Next/Back
  * Select the "xc7a100ti-csg324" part
* "Memory Selection"
  * Select 'DDR2 SDRAM'
* "Controller Options" (Options for Controller 0 - DDR2 SDRAM)
  * Clock Period: 3333 (300 MHz)
  * Memory Part: `MT47H64M16HR-25E` (second from the bottom)
  * Width: 16
  * Number of Bank Machines: 2 <!-- Change from default of 4 to 2. We don't need a complicated core. -->
  * Leave all other settings at the default value
  <!-- * Data Mask: selected
  * Nmber of Bank Machines (leave at default 4)
  * Ordering: leave at strict -->
* "AXI Parameter" 
  * Leave all default settings <!-- Keep the data width at 128 for consistency with previous assignment -->
* "Memory Options" (Memory Options C0 - DDR2 SDRAM)
  * Input Clock Period: 5000 ps (200 MHz)
  * RTT: 50 ohms
  * Leave all other settings at the default value
* "FPGA Options"
  * System clock: No Buffer <!-- We generate the signal at the top level -->
  * Reference clock: Use System Clock  <!-- We generate the signal at the top level -->
  * Internal VREF: select enabled (change)
  * Leave all other settings at the default value
* "Extended FPGA Options" (Internal Termination for High Range Banks)
  * Leave at default
* "I/O Planning Options"
  * Select Fixed Pin Out
* "Pin Selection"
  * Press "Read XDC/UCF" to load a UCF file
    * Select the [`nexys4_ddr.ucf`](./nexys4_ddr.ucf) file (this file is preconfigured to describe the DDR pins for the Nexys 4 DDR board)
  * Press the "Validate" button to validate the pinout
* "System Signals Selection"
  * Leave everything the same (no changes)
* "Summary"
  * Select "Next"
* "Simulation Options"
  * Accept the terms and conditions
  * Select "Next"
* "PCB Information"
  * Select "Next"
* "Design Notes"
  * Select "Generate". This will perform the generation process.

A new dialog box will open up that will allow you to synthesize the DDR controller IP.
Click "Skip" to skip this process of running the synthesis tool on this IP (synthesis will be done later as part of your top-level design).
There is a button in the lower left corner named "User Guide" that provides a link to the IP user guide (this link didn't work for me).
The public link to this IP is: https://docs.amd.com/r/en-US/ug586_7Series_MIS

Two additional directories are created:
* `mig_7series_0`: This is the main directory for the mig DDR contro9ller
* `ip_user_files`: This is an empty directory

After completing the IP generation process, generate a Tcl script that you can use to recreate your project at a later time.
This will allow you skip the GUI steps described above when you recreate the IP.
The following TCL command will generate a file named `make_ip.tcl` that you can run to recreate the IP and avoid the GUI steps described above:
`write_project_tcl make_ip.tcl`

Exit the GUI.

### GitHub repository

After completing the previous step you will have all the IP sources needed to implement the controller in your design.
Since your project will need to be created from scratch from your repository, it is necessary that you have the ability to create the IP from scratch within your repository (managing IP in a repository is difficult and awkward).
This section will describe how you should manage and build the IP in your repository.

Commit the following files into your repository:
* `make_ip.tcl` (generated by the `write_project_tcl` command described above)
* Copy the file `mig_7series_0/mig_a.prj` into your `ip` directory (don't commit it in its original location). This file is generated in the IP creation process.
* Copy the file `mig_7series_0/mig_7series_0.xci` into your `ip` directory (don't commit it in its original location). This file is generated in the IP creation process.

Create a `.gitignore` file in your assignment directory that ignores the following directories: `mig_7series_0`, `managed_ip_project`, and `ip_user_files`.

Further, create a `makefile` in the `ip` directory that includes the following rules:
* A `clean_ip` rule that deletes the `mig_7series_0`, `managed_ip_project`, and `ip_user_files` directories.
* A `make_ip` rule that builds the IP from the `make_ip.tcl` file
   * Create the `mig_7series_0` directory
   * Copy the files `mig_a.prj` and `mig_7series_0.xci` to the `mig_7series_0` directory
   * Run the following command in the `mig_7series_0` directory to recreate the IP from these copied files: `vivado -mode batch -source make_ip.tcl`

Experiment with your clean and build rules to make sure you can easily remove and recreate the IP from your repository.
You should make sure your IP directory is cleaned as part of your top-level assignment clean process described later.

## Example DDR Project

The DDR controller IP comes with an example project that demonstrates how to use the DDR controller.
This example project includes the source files and testbench to demonstrate how to use the DDR controller.
This particular project is not designed for the Nexys4 DDR board we are using but it provides a useful reference.

The generic example design has been adaptd for the Nexys4 DDR board.
Several files are provided for you so you can run this customized version of the example design on your Nexys4 DDR board.
This section will describe how to build and simulate this example project.
You may need to refer to this design as part of your assignment.

### Generate the Example Design project

A TCL script, [create_example_project](./create_example_project.tcl), has been created to generate the generic example project in a directory named `example_design`.
Run the following command to generate the example project using this TCL script:
```
vivado -mode batch -source create_example_project.tcl -nojournal -notrace
```
This command generates a directory `example_design` that contains all the example project files.
You will need these example files to simulate and synthesize the example design.
The top-level file is located at `./example_design/mig_7series_0_ex/imports/example_top.v`.

Add the following rules in the `ip/makefile`:
* A `clean_example` rule that deletes the `example_design` directory.
* A `make_example` rule that creates the example design (i.e., runs the command listed above).

The generic example design located at `./example_design/mig_7series_0_ex/imports/example_top.v` has been adapted to operate on the Nexys4 DDR board.

The file is named [`example_nexys4_top.v`](./example_nexys4_top.v) is the top-level design file for the Nexys4 DDR board.
This design adds an MMCM to provide a 200 MHz clock and routes the top-level output signals to two LEDs.
You will be simulating this design, synthesizing it, and running it on your Nexys4 DDR board as part of this exercise.

### Simulating the Design

You will need to simulate the design in questasim to learn about how the design operates, observe how the DDR controller operates, as well as to see how the simulation environment is setup.
You will need to create your own custom simulation environment for your DDR design and can use this design example as a reference for completing the main assignment design.

The generic example design includes the testbench file `./example_design/mig_7series_0_ex/imports/sim_tb_top.v`.
This testbench has been adapted for the Nexys4 DDR board and is provided as the file [`example_nexys4_top_tb.v`](./example_nexys4_top_tb.v).
This testbench is written in verilog so it has less features than a systemverilog testbench.
The testbench includes the following features:
* It generates the top-level 100 MHz clock
* It generates a reset signal
* It instances the top-level design
* It instances a DDR2 memory model to simulate the DDR memory

Before running the simulation, you will need to modify your `modelsim.ini` file to include three libraries that are needed to simulate the DDR controller.
These libraries include the `unisim`, `secureip`, and `unisims_ver` libraries.
The following lines can be added to your `modelsim.ini` file:
 ```unisim = /tools/Xilinx/Vivado/2024.1/data/questa/unisim
secureip = /tools/Xilinx/Vivado/2024.1/data/questa/secureip
unisims_ver = /tools/Xilinx/Vivado/2024.1/data/questa/unisims_ver
```
Alternatively, you can execute the following commands to update your `modelsim.ini` file:
```
vmap unisim /tools/Xilinx/Vivado/2024.1/data/questa/unisim
vmap secureip /tools/Xilinx/Vivado/2024.1/data/questa/secureip
vmap unisims_ver /tools/Xilinx/Vivado/2024.1/data/questa/unisims_ver
```

You can run the simulation in GUI mode by executing the following command: `source example_nexys4_top_sim.do`
You will manually need to execute `run` to run the simulation.
Run the simulation to answer the following questions.
Put your answers under the heading: "DDR Controller Simulation". **TODO:check questions**
* What time does the `init_calib_complete` signal go high?
* What are the values of the `ddr2_dq` signals during the first write caused by the `BTNL` button press?
* What is the clock period of the `ddr2_ck_p` clock signal?
* What is the clock period of the `clk_ui` clock signal?

No makefile rules are required to simluate this design.

### Synthesizing the Design

Included with the top-level design is the file `example_nexys4_top.xdc` that describes the pinout for the top-level design _excluding_ the pins for the DDR controller.

A synthesis build script [`example_nexys4_top_synth.tcl`](./example_nexys4_top_synth.tcl) has been created to generate a bitfile for the design.
This synthesis script will read in the top-level design file as well as the files associated with the DDR controller.
Familiarize yourself with script as you will need to make a similar script for your assignment design.
Run the script as follows:
```
	vivado -mode batch -source ddr_top_synth.tcl -log ./logs/ddr_top_implement.log -nojournal -notrace
```

Add the following rules in the `ip/makefile`:
* A `make_example_bit` rule that creates a bitfile for the example design.
* A `clean` rule that cleans all the generated files for the example design (including the `example_design` directory and IP files).

### Running the Design

After generating the bitfile, program the Nexys4 DDR board with the bitfile.
Run the design and make sure the calibration LED lights up indicating that the DDR controller has been properly calibrated.

At this point you have all the files you need to generate your own custom DDR design.
