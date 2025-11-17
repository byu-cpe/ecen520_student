# MicroBlaze IO Demonstration
<!-- This file is modified from the ECEN_620 repository, assignments/ip_integrator/notes.md file
-->

This demo involves the creation of a basic MicroBlaze system with a UART.
You will be using the GUI to create the Vivado project and the Vitis tool to create the software application.
You will also learn how to recreate the Vivado project using Tcl scripts.

## Vivado Project

The first step is to create a hardware design of the MicroBlaze system using the Vivado GUI using the IP Integrator block diagram tool.
This project will be created in the `demo_io` directory of your assignment.
This is done exclusively in the Vivado tool and the result is a bitstream and a .xsa hardware platform project.
These instructions assume you are using Vivado 2024.1 but other versions should be similar.

* Start the Vivado GUI:
    * source the vitis settings: `source /tools/Xilinx/Vitis/2024.1/settings.sh` (or wherever the tools are located)
        * Note that we are sourcing the Vitis settings instead of the vivado settings since Vivado is included in the Vitis toolchain and we need additional tools for the Vitis step later.
    * Start Vivado in your assignment directory: `vivado &`
        * Running the vivado tool from the command line will generate a number of temporary files. You will need to 'ignore' these files in your git repository and clean them as part of your clean process.
* Create the `demo_io` project
    * Create new project from GUI: File->Project->New
        * Project name: `demo_io`
        * Make sure the directory created is in your `microblaze` assignment directory
        * RTL project (default)
        * Click "Next" for the "Add Sources" and "Add Constraints" pages
        * Select the target part: `xc7a100tcsg324-1`
        * Click Finish
    * Copy default NEXYS DDR .xdc file to your assignment directory and name it `demo_io.xdc`
        * `cp ../resources/Nexys-4-DDR-Master.xdc ./demo_io.xdc`
    * Add the .xdc file to the project
        * Click on "add Sources" in the Flow Navigator
        * Select "Add or create constraints", press Next
        * Select "Add Files", navigate to the `demo_io.xdc` file that you copied and select it. Click Finish
* Block Diagram Creation
    * Create new block diagram
        * Click "Create Block Diagram" under "IP Integrator" in the Flow Navigator 
        * Type `demo_io_bd` for the block diagram name and click OK
        * The block diagram editor should be open
    * Add MicroBlaze block
        * Click the "+" button to open the IP dialog box
        * Type "MicroBlaze" in the box and select the "MicroBlaze" IP (not any of the other MicroBlaze options).
        * The block should appear in the block diagram
    * Run Block Automation
        * Click on the "Run Block Automation" link in the 'Designer Assistance' box that appears. A new dialog box will open up.
        * Change "Local Memory" to 32 KB ram
        * Make sure AXI interface is enabled
        * Make sure debug module is enabled (Debug Only)
        * Make sure clock connection is set to New clocking wizard
        * Click "OK" 
        * A bunch of new blocks will be added to the canvas and connections will be made
    * Configure Clock Module
        * Double click 'clocking wizard' block and make the following changes:
            * At the bottom of the page in the "Input Clock Information" table, change input clock from differential to single ended
            * Go to the next "output clocks" page, change 'reset type' to "active Low" (to reflect the fact that our reset is active low)
        * Click ok to finalize the changes
    * Hook up the external Clock and Reset
        * Click on the "Run Connection Automation" link in the 'Designer Assistance' box that appears. A new dialog box ### Rebuilding Vitis Project from the command line

will open up.
            * Click the box next to "clk_in1" and press "ok"
            * This should hook up a port to the clock with the name `clk_100MHz`
        * Click on the "Run Connection Automation" link again.
            * Check the box next to `resetn` and `ext_reset_in` and press "ok"
            * This should hook up a reset port with the name `reset_rtl_0`
    * Finalize the MicroBlaze configuration
        * Click on the "Run Block Automation" link in the 'Designer Assistance' box that appears.
        * Select "Keep Classic MicroBlaze" in the new dialog box.
    * Add the AXI GPIO module for the LEDs
        * Click the "+" button to add a new IP. Type "gpio" in the box and select AXI GPIO
        * Select the module on the canvas and change its name in the "Block Properties" box to "axi_gpio_LED"
        * Click "Connection Automation", select "All Automation" and click OK. 
            * This will hook up the block to the AXI bus and generate new output ports for the module
        * Configure the block to match the LED ports
            * Double click the box to open the "re-customize IP" box### Rebuilding Vitis Project from the command line


            * Select "All Outputs" 
            * Change GPIO Width from 32 to 16
        * Select the gpio_rtl_0 output port, right click "External Interface Properties"
            * Change the name of the output port to "gpio_LED" in the "External Interface Properties" box.
    * Add the AXI GPIO module for the switches
        * Follow the same procedure as above with the following changes### Rebuilding Vitis Project from the command line


            * Rename the module "axi_gpio_SW"
            * Rename the ouptput pins to "gpio_SW"
            * Select "All Inputs"
            * Sete width to 16
    * Check for errors
        * Click the icon that looks like a check in a box to perform a validationcheck.### Rebuilding Vitis Project from the command line


    * Create tcl file for recreating the block diagram in the future: 
        * File->Export->Export Block Diagram. Save the file in your assignment directory: `./demo_io_bd.tcl`
    * Save block diagram
        * Close the block diagram editor and save the block diagram when prompted.
        * This will create a file `./demo_io/demo_io.srcs/sources_1/bd/demo_io_bd/demo_io_bd.bd` in the project and is currently the only source of the project
        * At this point you have a block diagram that describes a basic MicroBlaze system with the Switches and LEDs.
* Modify the `demo_io.xdc` file to match the block diagram
    * Set the clock constraint
        * Uncomment the two clock lines in the original xdc file
        * Rename the clock to match the name given in the block design (`clk_100MHz`)
    * Set the reset constraint
        * Uncomment the line for the reset pin and rename it to match the name given in the block design (`reset_rtl_0`)
    * Set the LED constraints
        * Uncomment the lines for the LEDs and rename them to match the name given in the block design (`gpio_LED_tri_o`)
    * Set the SW constraints
        * Uncomment the lines for the LEDs and rename them to match the name given in the block design (`gpio_SW_tri_i`)
* Generate IP output products
    * At this point you have a "block diagram" which is just a graphical representation of your system. You need to generate a variety of files including Verilog files before synthesizing your design
    * Generate the IP output products for the block diagram
        * This step generates the HDL on all the blocks in the system for the IP. It also generates the simulation, synthesis, and implementation files needed to use the IP in your design.
        * Right click over the block diagram in the sources view and select "Generate Output Products". The defaults are sufficient. Click "Generate". The tool will generate all the IP files including a Verilog file that describes the block diagram. This may take a few minutes to complete.
        * Review the files **TODO** to see what was generated.
    * Generate the top-level wrapper for the block diagram (right click and select "Create HDL wrapper").
        * This is a top-level Verilog file that can be edited and instances the block diagram. This is different from the block diagram Verilog file.
        * Note that this should become the "black" top-level design (instead of the block diagram)
    * Create HDL wrapper
        * Create a top-level HDL wrapper for the block diagram
        * Select the block diagram and right click and select "Create HDL Wrapper". Leave the option "Let Vivado Manage wrapper and auto-update" selected and click OK.
    * Generate hardware platform for Vitis
        * You need to generate an .xsa platform project for use by Vitis. This tells vitis what type of platform you are programming for. 
        * File->Export, Export Hardware, keep "pre-synthesis" selected.
        * Change the .xsa name to `demo_io`. This will create the file `./demo_io/demo_io.xsa` that you will use for the Vitis programming step
    * Run implementation to generate the bitstream
        * Run synthesis on the design to make sure everything is hooked up correctly and named properly in the xdc file. Most problems involve incorrect pin names or not providing pin constraints        
        * Clock "Run Implementation" on the Flow Navigator. This will run the implementation tools and generate a bitstream for your design. Click OK as needed to get the process started.
        * Click "Generate Bitstream" when implementation is complete to generate the bitstream.
        * The bitfile will be located at `./demo_io/demo_io.runs/impl_1/demo_io.bit`

### Rebuilding Vivado Project from Tcl

The purpose of this step is to demonstrate how to recreate the Vivado project using the project build Tcl script.
You will need to build this project from a makefile and cannot do it without a Tcl script.

* Exit the Vivado GUI and return to the command line
* Clean the old project: `rm -rf ./demo_io`
* Open Vivado in tcl mode (`vivado -mode tcl`) and execute the following commands (you can use these commands as part of a build script within a Makefile):
```
create_project demo_io ./demo_io -part xc7a100tcsg324-1
add_files -fileset constrs_1 -norecurse demo_io.xdc
source demo_io_bd.tcl
make_wrapper -files [get_files ./demo_io/demo_io.srcs/sources_1/bd/demo_io_bd/demo_io_bd.bd] -top
add_files -norecurse ./demo_io/demo_io.gen/sources_1/bd/demo_io_bd/hdl/demo_io_bd_wrapper.v
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1### Rebuilding Vivado Project from Tcl

write_hw_platform -fixed -include_bit -force -file ./demo_io/demo_io.xsa
```

Create a makefile step named `build_demo_io` that will create the demo_io project and generate a bitstream and a the `./demo_io/demo_io.xsa` file.
Also, make sure your 'clean' rule will clean up the project completely.

## Vitis Software Project

In this phase of the demo you will run the Vitis tools and create a software program that runs on the Microblaze system.
You will run a program template and not do any code editing for this particular demo.
**Note**: These instructions are  for the 2024 version of Vitis.
Older versions of vitis are much different.

* Open Vitis
    * Vitis is the software development environment for Xilinx embedded processors including the MicroBlaze. Vitis operates within a 'workspace' and you will need to specify the workspace for your vitis project. For this demo, we will create the workspace within the `demo_io\vitis` directory within your microblaze assignment.### Rebuilding Vivado Project from Tcl

    * Make sure the vitis environment is setup: `source /tools/Xilinx/Vitis/2024.1/settings.sh` 
    * Open from command line (in `microblaze` assignment directory): `vitis -w ./demo_io/vitis`
* Create Platform Component
    * Vitis needs the libraries associated with the processor you are running on. You need to create a "platform component" that has these libraries.
    * Click on "Create Platform Component". Enter "microblaze_io_platform" for the platform name. Leave the path as given. Click Next.
    * Make sure 'Hardware Design' is selected. Click on Browse to find the .xsa file you created in the previous Vivado step. `./demo_io/demo_io.xsa`. Click Next and wait while vitis interrogates your platform. 
    * Click Next again. and finish to complete the platform.
    * When you are done you should have a component with a green diamond named "microblaze_io_platfor" in the components pane.
* Create Example Application Project
    * With a platform component for the board, you can create an application project. This is the code that will run on the microblaze. For this example, we will modify a hello world application to a simple LED example.
    * Click on the "Examples" icon on the left (an icon that looks like three boxes, one behind the other). Expand "Embedded Software Examples" and select "Empty Application".
    * Click on the button "Create Application Component from Template" (ID should say "empty_application"). 
        * **Name and Location**: Entery the name `demo_io` in the "component name" box. Leave the component path as the default. Click Next.
        * **Hardware**: Select "microblaze_io_platform" and click next. 
        * **Domain**: Click next.
        * **Summary**: Click finish.
    * When this is done you should have a component named "demo_io" in your components pane
    * Expand the "demo_io" component and you will see four sub folders that can be expanded: 'Settings', 'Includes', 'Sources', and 'Output'
        * Expand the 'Sources' folder. This is the folder that contains the source code. 
        * Copy the file [`demo_io.c`](./demo_io.c) to the directory `demo_io/vitis/demo_io/src/demo_io.c`. This file is the code that will run on your MicroBlaze. This file should show up under the 'Sources' folder. Review the code to familiarize yourself on what it does.
    * Modify the `CMakeLists.txt` file in the 'Settings' Folder to include the new `demo_io.c` file. Add the two lines to specify the project sources as shown in the example below.
```
collect(PROJECT_LIB_DEPS xil)
collect(PROJECT_LIB_DEPS gcc)
collect(PROJECT_LIB_DEPS c)

# Add files for your project here
collect (PROJECT_LIB_SOURCES demo_io.c)
collector_list (_sources PROJECT_LIB_SOURCES)
# End add
```
        * Save a copy of your modified `CMakeLists.txt` file in your assignment directory (i.e., something like CMakeLists.txt.demo_io). You will need to save this file and copy it over to the Vitis project as part of your automated project building step described below.
    * Build the application project
        * Click on the 'demo_io' component to make it active and clilck on the hammer in the bottom pain to build the application
        * The build window will show the compile process. Note if there are any errors.
        * The executable should be located at : `./demo_io/vitis/demo_io/build/demo_io.elf` (you will need this for a later step)
* Download the project to the board
    * Make sure your board is hooked into your computer
    * Click the 'Run' button. 
    * You can rerun the program by pressing the "CPU Reset" button

### Rebuilding Vitis Project from the command line

Creating a Vitis project by hand is cumbersome in a source control system.
You can perform these steps manually using a custom Python script run within vitis.
The script [`demo_io_vitis.py`](./demo_io_vitis.py) is an example can be run to create the Vitis project and build the platform and executable.
Carefully review this script and its contents.
This script may need to be edited to match the filenames you have chosen for your `CMakeLists.txt` file.
This script will copy the files from your project directory and place them in the vitis workspace.
Note that this script assumes that the hardware project has already been created.

You can run this script in vitis interactively as follows: `vitis -s demo_io_vitis.py`

After verifying that you can create a vitis project and the corresponding .elf file, create a makefile step named `build_demo_io_vitis` that will create the vitis project and build the following file:  `./demo_io/vitis/demo_io/build/demo_io.elf`
Also, make sure your 'clean' rule will clean up the vitis project completely.

### Running from the command line

You can also download your bitfile and the elf file to your board interactively outside of the vitis gui using the `xsdb` debugger tool.
Run the debugger in interactive mode by executing the following command:

`xsdb`

Once in the interactive tool, execute the following commands to download the bitfile and elf file.

```
# Connect to local xsdb server
connect
# Connect to NEXYS board
targets -filter {name =~ "xc7a100t"} -set
# Download fpga
fpga ./demo_io/vitis/microblaze_io/export/microblaze_io/hw/sdt/demo_io.bit
# Select microblaze
targets -filter {name =~ "MicroBlaze #0"} -set 
# Download elf file
dow ./demo_io/vitis/demo_io/build/demo_io.elf
# Start execute ("con"tinue)
con
```

<!-- 
## Generate bitstream with the program inserted. 

The bitstream generated by Vivado does not have the compiled .elf file inserted into the BRAMs. 
If you want a bitstream with the memory loaded then you need to complete an additional step to patch the bitstream. 
Note that the .elf file needs to be compiled before completing this step.

    * Open up Vivado and select the `demo_io` project
        * Select: Tools->Associate ELF Files
        * Click on the three dots by the "mb_bootloop_le.elf under the "Design sources". Navigate to the .elf file and select it.
        * Every time you generate a bitstream the bitstream will be patched with your source code.
    <!-- * Vitis
        * Select the system program associated with your project. Right click and select "Program Device". 
        * In the "Software Configuration" box, select "bootloop" (i.e. ,you need to change the program to insert from the bootloop to something else)
        * Select down arrow and "browse", navigate to "hello->Debug->hello.elf"
        * Click "Generate" (you can click on "Program" but we don't need to program but only generate the bitfile)
        * This should generate a new file `vitis/hello/_ide/bitstream/download.bit`. Program this using the hardware manager or something other than vitis to make sure it works. -->


 -->
