# MicroBlaze UART

Once you have created the microblaze [IO demonstration](./demo_io.md), you can create a microblaze with your custom AXI UART.
This page will describe the steps necessary to build the MicroBlaze system that includes your UART as well as the switches and your seven segment display.

This demo involves the creation of a basic MicroBlaze system with a UART.
You will be using the GUI to create the Vivado project and the Vitis tool to create the software application.
You will also learn how to recreate the Vivado project using Tcl scripts.

## Vivado Project

Follow these steps to build the MicroBlaze system:
* Create the new uart microblaze project
    * Create a new project directory for your new MicroBlaze project.
    * Copy the `demo_io.xdc` file you created earlier and rename it `mb_uart.xdc`. Add it to the project. You will be editing it later on.
    * Source the `demo_io_bd.tcl` file you created earlier to build the io project. Running this script will create the same block diagram and save you time building the new MicroBlaze system.
    * Add the following files to your project
        * Add the file `seven_segment8_wrapper.v` from this assignment. This file is a Verilog wrapper for your seven_segment8 module (the block diagram does not accept SystemVerilog files)
        * Your seven segment display module (`seven_segment8.sv`) from your 'rx_sim' assignment.
        * Your rx and tx modules from the rx_sim and tx_sim assignments
        * Your fifo, uart_axi, and uart_axi_wrapper from the axi assignment
* Modify the block diagram to add a GPIO module for the buttons, the seven segment display and your UART axi module
    * Add a third GPIO module for the buttons
        * Name the module appropriately
        * Set the module as all inputs and the size as 5 bits (one for each button)
        * Use the "Connection Automation" to wire it up into your system
        * Rename the top-level ports appropriately
        * The buttons should be assigned the following bits (in the xdc file)
            * 0: BTNC
            * 1: BTNU
            * 2: BTNL
            * 3: BTNR
            * 4: BTND
    * Add a fourth GPIO module for the seven segment display
        * Name the module appropriately
        * Set the module as all outputs and the size as 32 bits (for your 32-bit output register)
        * Click the 'Enable Dual Channel' button so there are two GPIO channels
        * Set the second channel as output only and use 9 bits (8 bits for the digit points and 1 bit for the blank signal)
        * Use the "Connection Automation" to wire it up into your system. Only select the 'S_AXI' port to hook up. The output port will be hooked up to your seven segment display block.
        * Add your seven segment display logic to the block diagram
            * Right click on the canvas and select "Add Module". Select the seven_segment8_wrapper module. This will add the module to the canvas.
            * Manually wire the clock input and reset to the corresponding inputs of your module
            * Click the "+" on the GPIO output of the GPIO module for the seven segment display. The gpio_io_o output is shown. Wire this output to the data_in intput of your seven segment display module.
            * Click the "+" on the GPI2 output of the GPIO for the seven segment display. Wire this output to the control input of your seven segment display module.
            * Right clilck on the canvas and select "Create Port". Name the port "AN", indicate it is an output, and leave the type as "Other".
                * Wire the anode output of your seven segment display module to this port.
            * Create a port for the cathodes named 'C' and wire it to the Cathode outputs of your module.
    * Add your UART axi module
        * Right click on the canvas and select "Add Module". Select your uart_axi.
        * Run the Connection Automation to wire it up
        * Create a port for the tx output (named `UART_RXD_OUT`) and hook it up to the tx output of your module
        * Create a port for the rx input (named `UART_TXD_IN`) and hook it up to the rx input of your module
    * Validate and save your block diagram
        * Click the "validate" box to make sure everything is hooked up correctly
        * Export your block diagram file
        * Exit the block diagram editor and save the block diagram
* Update your new xdc file
    * Enable all entries in the xdc file needed to build the project
    * Rename any ports that need renaming.


Set as top


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
        * Click on the "Run Connection Automation" link in the 'Designer Assistance' box that appears. A new dialog box will open up.
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
            * Double click the box to open the "re-customize IP" box
            * Select "All Outputs" 
            * Change GPIO Width from 32 to 16
        * Select the gpio_rtl_0 output port, right click "External Interface Properties"
            * Change the name of the output port to "gpio_LED" in the "External Interface Properties" box.
    * Add the AXI GPIO module for the switches
        * Follow the same procedure as above with the following changes
            * Rename the module "axi_gpio_SW"
            * Rename the ouptput pins to "gpio_SW"
            * Select "All Inputs"
            * Sete width to 16
    * Check for errors
        * Click the icon that looks like a check in a box to perform a validationcheck.
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
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file ./demo_io/demo_io.xsa
```

## Vitis Software Project

In this phase of the demo you will run the Vitis tools and create a software program that runs on the Microblaze system.
You will run a program template and not do any code editing for this particular demo.
**Note**: These instructions are  for the 2024 version of Vitis. Older versions of vitis are much different.

* Open Vitis
    * Vitis is the software development environment for Xilinx embedded processors including the MicroBlaze. Vitis operates within a 'workspace' and you will need to specify the workspace for your vitis project. For this demo, we will create the workspace within the `demo_io\vitis` directory within your microblaze assignment.
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
        * **Name and Location**: Entery the name "io_follow" in the "component name" box. Leave the component path as the default. Click Next.
        * **Hardware**: Select "microblaze_io_platform" and click next. 
        * **Domain**: Click next.
        * **Summary**: Click finish.\
    * When this is done you should have a component named "io_follow" in your components pane

* Create Application Project
    * The workspace will be empty so you need to populate it with something. Select 'Create Application Project' from the initial Vitis menu
    * You need to have a platform for your project. Your platform will be based on the `.xsa` file you created in the Vivado step
    * Select the tab "Create a new platform from hardware (xsa)". You will need to navigate to your .xsa file (the base file it gives you is way off). The file is in your demo1 project
    * Select a name for the application ("hello"). Note that when you give the application name "hello" it is auto creating a "system project" with the name "hello_system". 
    * Select all of the defaults (including the "Hello World" template)
* Things to note:
    * You have a green box with the name "demo1". This is your platform project (i.e., the bitfile with your microblaze). This is the root for all of the platform specific information you may need.
        * All of the base libraries for the IP are in this hierarchy (see `microblaze_0 -> standalone_microblaze_0 -> bsp -> microblaze_0 -> libsrc`)
    * You have a blue box with the "system project" named "hello_system [demo1]. This is the root for all of system and application project
        * Navigate down to "hello_system" -> "hello" -> src -> helloworld.c to get to the helloworld.c file creatd for you. Double click on this to open the file.
* Build the application project
    * Click on the "hammer" icon or select the system project, right click and select "Build Project"
    * This will compile the system library files as well as your application project
* Download the project to the board
    * Make sure your board is hooked into your computer
    * Open a terminal emulator wit hthe 9600 baud rate and point to the uart device on your system
    * Select the application program and right click: Run as -> Launch Hardware
    * You should see the following text on your terminal emulator:

    * You can rerun the program by pressing the "CPU Reset" button
* Generate bitstream with the program inserted. 
    * The bitstream generated by Vivado does not have the compiled .elf file inserted into the BRAMs. If you want a bitstream with the memory loaded then you need to complete an additional step to patch the bitstream. This can be done in Vitis or Vivado. Note that the .elf file needs to be compiled before completing this step.
    * Vitis
        * Select the system program associated with your project. Right click and select "Program Device". 
        * In the "Software Configuration" box, select "bootloop" (i.e. ,you need to change the program to insert from the bootloop to something else)
        * Select down arrow and "browse", navigate to "hello->Debug->hello.elf"
        * Click "Generate" (you can click on "Program" but we don't need to program but only generate the bitfile)
        * This should generate a new file `vitis/hello/_ide/bitstream/download.bit`. Program this using the hardware manager or something other than vitis to make sure it works.
    * Vivado
        * Select: Tools->Associate ELF Files
        * Click on the three dots by the "mb_bootloop_le.elf under the "Design sources". Navigate to the .elf file and select it.
        * Every time you generate a bitstream the bitstream will be patched with your source code.

## Makefile commands

Once you have created the project and downloaded it to the board, create makefile rules and clean rules to build the project, the bitfile, the software, and the bitfile with the program.

