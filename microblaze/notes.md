# Notes for IP Integrator assignment
<!-- This file is modified from the ECEN_620 repository, assignments/ip_integrator/notes.md file
-->


This page provides the instructions for completing the simple demonstrations using the MicroBlaze and the IP Integrator.
You will be required to include several of the resulting files into your assignment submission including makefile rules to build these demonstrations.
The demonstrations include the following:
* [Demo 1](./notes.md#demo-1): Basic MicroBlaze system with UART

## Demo 1

This first demo involves the creation of a basic MicroBlaze system with a UART.
You will be using the GUI to create the Vivado project and the Vitis tool to create the software application.
You will also learn how to recreate the Vivado project using Tcl scripts.

### Vivado Project

The first step is to create a hardware design of the MicroBlaze system using the Vivado GUI using the IP Integrator block diagram tool.
This project will be created in the `demo1` directory of your assignment.
This is done exclusively in the Vivado tool and the result is a bitstream and a .xsa hardware platform project.
These instructions assume you are using Vivado 2024.1 but other versions should be similar.

* Start the Vivado GUI:
    * source the vitis settings: `source /toolchain/Xilinx/Vitis/2024.1/settings.sh`
        * Note that we are sourcing the Vitis settings instead of the vivado settings since Vivado is included in the Vitis toolchain and we need additional tools for the Vitis step later.
    * Start Vivado in your assignment directory: `vivado &`
        * Running the vivado tool from the command line will generate a number of temporary files. You will need to 'ignore' these files in your git repository and clean them as part of your clean process.
* Create the `demo1` project
    * Create new project from GUI: File->Project->New
        * Project name: `demo1`
        * Make sure the directory created is in your `microblaze` assignment directory
        * RTL project (default)
        * Click "Next" for the "Add Sources" and "Add Constraints" pages
        * Select the target part: `xc7a100tcsg324-1`
        * Click Finish
    * Copy default NEXYS DDR .xdc file to `demo1.xdc`
        * `cp ../resources/Nexys-4-DDR-Master.xdc ./demo1.xdc`
    * Add the .xdc file to the project
        * Click on "add Sources" in the Flow Navigator
        * Select "Add or create constraints", press Next
        * Select "Add Files", navigate to the `demo1.xdc` file that you copied and select it. Click Finish
* Block Diagram Creation
    * Create new block diagram
        * Click "Create Block Diagram" under "IP Integrator" in the Flow Navigator 
        * Type `demo1_bd` for the block diagram name and click OK
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
    * Hook up external Clock and Reset
        * Click on the "Run Connection Automation" link in the 'Designer Assistance' box that appears. A new dialog box will open up.
            * Click the box next to "clk_in1" and press "ok"
            * This should hook up a port to the clock with the name `clk_100MHz`
        * Click on the "Run Connection Automation" link again.
            * Check the box next to `resetn` and `ext_reset_in` and press "ok"
            * This should hook up a reset port with the name `reset_rtl_0`
    * Finalize the MicroBlaze configuration
        * Click on the "Run Block Automation" link in the 'Designer Assistance' box that appears.
        * Select "Keep Classic MicroBlaze" in the new dialog box.
    * Add a UART
        * Add another IP named "AXI UARTLite" (Click plus button, type "AXI UARTLite", select it). The uart will be added but not connected.
        * Select "Run connection automation" to hook it up. Select "All Automation"
            * This will add a AXI interconnect module between the MicroBlaze and the Uart. It will also add a port named `uart_rtl_0` for the top-level uart signals.
        * Default baud rate is 9600
    * Check for errors
        * Click the icon that looks like a check in a box to perform a validationcheck.
    * Save block diagram
        * Close the block diagram editor and save the block diagram when prompted.
        * This will create a file `./demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd` in the project and is currently the only source of the project
        * At this point you have a block diagram that describes a basic MicroBlaze system with a UART.
    * Create tcl file for recreating the block diagram in the future: 
        * select `demo1_bd.bd` from the sources and right click 
        * File->Export->Export Block Diagram. Save the file: `./demo1/demo1_bd.tcl` (you may want to move this to a higher level directory outside the project)
* Modify the `demo1.xdc` file to match the block diagram
    * Set the clock constraint
        * Uncomment the two clock lines in the original xdc file
        * Rename the clock to match the name given in the block design (`clk_100MHz`)
    * Set the reset constraint
        * Uncomment the line for the reset pin and rename it to match the name given in the block design (`reset_rtl_0`)
    * Set the UART constraints
        * Uncomment the two UART lines in the original xdc file and rename them as follows:
        * `uart_rtl_0_rxd` (in place of the `UART_TXD_IN` pin). Note that the naming swap is counter-intuitive here.
        * `uart_rtl_0_txd` (in place of the `UART_RXD_OUT` pin)
* Generate IP output products
    * At this point you have a "block diagram" which is just a graphical representation of your system. You need to generate a variety of files including Verilog files before synthesizing your design
    * Generate the IP output products for the block diagram
        * This step generates the HDL on all the blocks in the system to generate the HDL sources needed for the IP. It also generates the simulation, synthesis, and implementation files needed to use the IP in your design.
        * Right click over the block diagram in the sources view and select "Generate Output Products". The defaults are sufficient. Click "Generate". The tool will generate all the IP files including a Verilog file that describes the block diagram. This may take a few minutes to complete.
        * Review the files **TODO** to see what was generated.
    * Generate the top-level wrapper for the block diagram (right click and select "generate HDL wrapper").
        * This is a top-level Verilog file that can be edited and instances the block diagram. This is different from the block diagram Verilog file.
        * Note that this should become the "black" top-level design (instead of the block diagram)
    * Create HDL wrapper
        * Create a top-level HDL wrapper for the block diagram
        * Select the block diagram and right click and select "Create HDL Wrapper". Leave the option "Let Vivado Manage wrapper and auto-update" selected and click OK.
    * Generate hardware platform for Vitis
        * You need to generate an .xsa platform project for use by Vitis. This tells vitis what type of platform you are programming for. 
        * File->Export, Export Hardware, keep "pre-synthesis" selected.
        * Change the .xsa name to `demo1`. This will create the file `./demo1/demo1.xsa` that you will use for the Vitis programming step
    * Run implementation to generate the bitstream
        * Run synthesis on the design to make sure everything is hooked up correctly and named properly in the xdc file. Most problems involve incorrect pin names or not providing pin constraints        
        * Clock "Run Implementation" on the Flow Navigator. This will run the implementation tools and generate a bitstream for your design. Click OK as needed to get the process started.
        * Click "Generate Bitstream" when implementation is complete to generate the bitstream.
        * The bitfile will be located at `./demo1/demo1.runs/impl_1/demo1_bd_wrapper.bit`


### Rebuilding Vivado Project from Tcl

The purpose of this step is to demonstrate how to recreate the Vivado project using the project build Tcl script.
You will need to build this project from a makefile and cannot do it without a Tcl script.

* Close the project in vivado if you are in it
* Clean the old project: `rm -rf ./demo1`
* Open Vivado and execute the following commands (you can use these commands as part of a build script within a Makefile):
```
create_project demo1 ./demo1 -part xc7a100tcsg324-1
add_files -fileset constrs_1 -norecurse demo1.xdc
source demo1_bd.tcl
#close_bd_design [get_bd_designs demo1_bd]
make_wrapper -files [get_files ./demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd] -top
add_files -norecurse ./demo1/demo1.gen/sources_1/bd/demo1_bd/hdl/demo1_bd_wrapper.v
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file ./demo1/demo1.xsa
```

### Vitis Software Project

In this phase of the demo you will run the Vitis tools and create a software program that runs on the Microblaze system.
You will run a program template and not do any code editing for this particular demo.

* Open Vitis
    * Vitis is the software development environment for Xilinx embedded processors including the MicroBlaze. Vitis operates within a 'workspace' and you will need to specify the workspace for your vitis project. For this demo, we will create the workspace within the `demo1\vitis` directory within your microblaze assignment.
    * Open from command line (in `microblaze` directory): `vitis -w ./demo1/vitis`
* Select workspace
    * Vitis uses the VSCode IDE and operates in the context of a workspace. For this set of demonstrations we will use a single workspace. Select 'Open Workspace' and navigate to your `microblaze/demo1` directory. Create a new directory named `vitis` and select this as your workspace.
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
```
Hello World
Successfully ran Hello World application
```
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

To Do:
* Add instructions for using `xil_printf()`

## Demo2

This demo adds the GPIO for the switches and the LEDs.
It also demonstrates how to use the low-level driver code to talk to the GPIO.

### Vivado Project

* Open vivado and create a new project:
    * `create_project demo1 ./demo2 -part xc7a100tcsg324-1`
* Create the block diagram based on demo1 (to save time) 
    * `source demo1_bd.tcl` (`source demo1_bd_2022_2.tcl`)
* Add the AXI GPIO module for the LEDs (use auto connect) and Edit it
    * Rename module to "axi_gpio_LED"
    * Rename output pins to "gpio_LED"
    * Select "All Outputs"
    * Set width to 16
* Add the AXI GPIO module for the switches (use auto connect) and Edit it
    * Rename module to "axi_gpio_SW"
    * Rename output pins to "gpio_SW"
    * Select "All Outputs"
    * Set width to 16
* Generate top-level HDL
* Generate a tcl file for creating this block diagram (`demo2_bd_2022_2.tcl`)
* Update .xdc file
    * Uncomment lines for switches and LEDs
    * Rename the pins in the xdc file (Look at top-level HDL for the names of the switches and LED ports.)
        * `gpio_LED_tri_o` for LEDs
        * `gpio_SW_tri_i` for switches
    * Add the .xdc file to the project: `add_files -fileset constrs_1 -norecurse demo2.xdc`
* Generate the output products:
* Generate the bitfile
* Create the hardware platform file
    * `write_hw_platform -fixed -include_bit -force -file ./demo1/demo1.xsa`

### Vitis Project

The next step is to create a Vitis project and source code that will talk to the switches and LEDs.

* Launch Vitis from the VIvado IDE
* Create new application project:
    * "File->New->Application Project"
    * Choose "Create a new platform from hardware (xsa)" and select demo2.xsa
    * Note: don't give the application project the same name as the platform (i.e., demo2)
* Build the default project just to make sure everything is ok
* You can create an "example" application project that uses the Hardware blocks and drivers for those blocks from within Vitis to learn more about how the blocks are controlled in software.
    * Select the "platform.spr" red vitis icon under the green platform icon
    * Click on the "Board Support Package"item (under microblaze_0 -> stadnalone_microblaze_0 -> Board Support Package). You should see a page to the right titled "Board Support Package".
    * At the bottom of this page is a table that lists "Drivers". Click on the "Import Examples" link to generate a new software example that uses the IP core.
* You can also look at the raw drivers for the gpio IP
    * demo2 -> microbalaze_0 -> standalone_microblaze_0 -> bsp -> microblaze_0 -> libsrc -> gpio_v4_9 -> src
    * The files of most interest are:
        * "xgpio.h"
        * "xgpio.src"

Modify your code as follows:

Include the "xgpio.h" header:
`
#include "xgpio.h"
`

To use the GPIO you need to create a data structure named `XGpio` for each GPIO module that stores information about the GPIO (such as the base address).
Declare two such structures:
`
    XGpio gpio_led;
    XGpio gpio_sw;
`

Initialize each of the structures using the `XGpio_Initialize` function:
`
    XGpio_Initialize(&gpio_led, XPAR_AXI_GPIO_LED_DEVICE_ID);
    XGpio_Initialize(&gpio_sw, XPAR_AXI_GPIO_SW_DEVICE_ID);
`
Note that you need a dedicated DEVICE_ID for each of these calls.
These constants are defined in the `xparameters.h` file (see demo2 -> microbalaze_0 -> standalone_microblaze_0 -> bsp -> microblaze_0 -> include -> xparameters.h ).

Set the direction of the GPIO ports (in software):
`
    const int CHANNEL_NUM = 1;
    XGpio_SetDataDirection(&gpio_led, CHANNEL_NUM, 0x0 ); // set LED output direction
    XGpio_SetDataDirection(&gpio_sw, CHANNEL_NUM, 0xffff ); // set Switches input direction
`
The `1` constant is used to indicate that we are using channel 1 in both cases.

Read the switches and print value to screen:
`
    u32 sw;
    sw = XGpio_DiscreteRead(&gpio_sw, CHANNEL_NUM);
    xil_printf("switches %x\r\n",sw);
`

Write the value to the LEDs:
`
    XGpio_DiscreteWrite(&gpio_led,CHANNEL_NUM, sw);
`

At this point, rebuild your application program to make sure there are no errors.
Download the application to the board and make sure it works.
Create a standalone bitstream for this.



## IPDemo1

In this demo we will create a new IP block talking to the LEDs using the IP wizard.
This demo will create the IP and the AXI bus interface logic.
The IP created will be placed in the `ip_repo` directory.

### Create Block Diagram with new IP

### Vivado Project

* Open vivado and create a new project: `create_project ipdemo1 ./ipdemo1 -part xc7a100tcsg324-1`
* Create the block diagram: `source demo1_bd.tcl` (`source demo1_bd_2022_2.tcl`)
* Create a new empty IP: "Tools->Create and package IP". This will create all the HDL and other files needed for a basic IP
    * Box 1: choose "Create new AXI4 Peripheral" (creates all the logic and wrappers for an AXI IP)
    * Box 2: Specify name (I will leave as "myip"), Select IP location. Leave default `./ip_repo` in the ip_integrator assignment directory. This way it is available for all projects associated with the demos.
    * Box 3: Registers and width (leave the same)
    * Box 4: Different options (Just click on "Add repository" for now)
        * Add to repository will add the empty IP to the repository (Use this option for now)
            * Only creates a new IP in the `ip_repo` directory
        * Edit IP will open a new project for the IP
            * It also adds the IP to the repository (`myip_1_0` in the `myip_1_0`)
            * Creates a new .xpr project in the `ip_repo` directory that you can use to edit the IP. You can go back and edit the IP using this project.
            * It creates `edit_myip_...` directories for editing the IP (not sure what these are for )
        * Verify IP using AXI4 VIP
            * Creates the IP
            * Creates a block diagram within the existing project that is just the VIP and the new IP
            * Creates a simulation testbench for simulating the IP and a simulation set
* Look at the HDL created by the IP (top-level instantiation and a auto generated bus interface)
* Add the new IP to your design and hook it up to the AXI bus
* Go through the process of generating a bitstream/hardware
    * Generate output products
    * Create HDL wrapper
    * Add the xdc file (`demo1.xdc`)
    * Implementation
    * Generate hardware platform (`ipdemo1.xsa`)

### Vitis

* Create new application project:
    * "File->New->Application Project"
    * Choose "Create a new platform from hardware (xsa)" and select ipdemo1.xsa
    * Note: don't give the application project the same name as the platform (i.e., ipdemo1)
* Build the project just to make sure
* Look at the drivers for the IP
    * ipdemo1->microbalaze_0->standalone_microblaze_0->bsp->microblaze_0->libsrc->myip_v1_0->src

When writing software to communicate with your IP you will basically need to write data to or read data from the address space of your IP.
You are most likely not doing anything fancy like interrupts, DMA, etc. so simple I/O reads and writes are all you need.
The main thing you need to know is the address space of your I/O device.
This is found in the address editor in the Vivado project (you will also see the base address in your xparameters.h).
You can use the functions `Xil_In32` and `Xil_Out32` defined in the [`xil_io.h`](https://github.com/Xilinx/embeddedsw/blob/master/lib/bsp/standalone/src/common/xil_io.h) file to read and write to the address space of your IP as demonstrated in the following examples:

```
// Read the register that is at offset 8 from the base address of the IP
u32 result = Xil_In32(MYIP_BASEADDR+8);

// Write the register that is at offset 12 from the base address of the IP
u32 value_to_write = 0xaaaa5555;
Xil_Out32(MYIP_BASEADDR+12, value_to_write);
```


### Simulating IP

In this example we will simulate the IP.
Note that you can create a simulation project for a VIP by selecting the "Verify IP using AXI4 VIP" when creating the IP but we won't do this.
We will create a project from scratch.
The [427 website](https://byu-cpe.github.io/ecen427/documentation/vivado-axi-simulation/) provides a nice tutorial on creating a simulation.

* Create a new block diagram within the project (or create a new project). Named `sim_ip`
    * Add AXI Verification IP block
        * Set  INTERFACE MODE = MASTER and PROTOCOL = AXI4LITE in the VIP core
    * Add you IP block
        * Set the address of the IP: Click on Address Editor, Select the IP "S00_AXI", right click and select "Assign", take note of the chosen address 
    * Hook up: 
        * add AXI bus connection
        * Create an input port for the clock. Hook up to both cores
        * Create an input port for the reset. Hook up both cores
* Create a new testbench file for your simulation
    * See [427 website](https://github.com/byu-cpe/ecen427_student/tree/main/hw/ip_repo/pit) for starter file
    * Make sure ports match up
    * Change name of include and objects within the simulation
    * Add testbench to project as a simuation file
* Simulate basic reads and writes

### Updating the IP and RePackaging IP

In this step we will change the IP and repackage the IP for use in our system.
Open the file `myip_v1_S00_AXI.v` and make some changes.
Possible changes include:
* load different values into the registers (inverted, or'd, etc)
* Create a different read register (like a counter, bus counter, etc)

Once you have made the changes you need to repackage the IP and upgrade the IP.
* Select the IP block in the block diagram editor that was changed. Right click to "Edit in IP Packager"
* Click on "Review and Package"
    * Clock on "Repackage IP" at bottom
* Upgrade the ip in your block diagram with the following TCL command: `upgrade_ip [get_ips *]`
    * How to do this in GUI?

After changing the code, run the simulation and make sure it is still working (i.e., compiling).
Simulate to make sure it works as expected.

Questions:
 * Does the IP have to be installed before building the block diagram that uses it? (i.e., revision control)
 * How do you archive your new IP? Can you have just the rtl source and run tcl commands to create the new module?

## IPDemo2

This demo will create a new IP block from HDL source.
It is based on the 427 template and demo.

* Download the two files from: https://github.com/byu-cpe/ecen427_student/tree/main/hw/ip_repo/pit
* Open vivado and create a new project: `create_project ipdemo2 ./ipdemo2 -part xc7a100tcsg324-1`
* Create the block diagram: `source demo1_bd.tcl`  (`source demo1_bd_2022_2.tcl`)
* Add the xdc file: `add_files -fileset constrs_1 -norecurse demo1.xdc`
* Add the two files to the project (pit.v, and pit.sv): `add_files -norecurse {./pit.sv ./pit.v}`
* Right click in block diagram and select "add module" (not add IP): `create_bd_cell -type module -reference pit pit_0`
* Can now add it to the system


* After changing your IP, go to Edit Packed IP and "Re Package IP"


# Reference

* Reference
    * [Xilinx Embedded code repository](https://github.com/Xilinx/embeddedsw/blob/master/XilinxProcessorIPLib/drivers/uartlite/examples/xuartlite_polled_example.c)
* https://digilent.com/reference/vivado/getting-started-with-ipi/2018.2

## TCL Commands

### demo1 tutorial

```
# Create project. Key file created is the demo1 projeject file: ./demo1/demo1.xpr
create_project demo1 ./demo1 -part xc7a100tcsg324-1
# Add constraints file to the project (modifies project file)
add_files -fileset constrs_1 -norecurse ./demo1.xdc
# Create block diagram. Creates .bd file: .demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd
create_bd_design "demo1_bd"
# Add microblaze IP
#  (When IP is added to the block diagram, new directories with the IP XML are stored
#  in the project directory: ./demo1/demo1.srcs/sources_1/bd/demo1_bd/ip/)
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
# Results from Run Block Automation
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { all {1} axi_intc {0} axi_periph {Enabled} cache {None} clk {New Clocking Wizard} compress {1} cores {1} debug_module {Debug Only} disable {0} ecc {None} local_mem {32KB} preset {None}}  [get_bd_cells microblaze_0]
# Configure clock wizard
set_property -dict [list \
  CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
  CONFIG.RESET_PORT {resetn} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz_1]
# Automate clock and reset connection
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Clk {New External Port} Manual_Source {Auto}}  [get_bd_pins clk_wiz_1/clk_in1]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
# finalize microblaze configuration
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { all {1} axi_intc {0} axi_periph {Disabled} cache {None} clk {/clk_wiz_1/clk_out1 (100 MHz)} compress {1} cores {1} debug_module {Debug Only} disable {1} ecc {None} local_mem {32KB} preset {None}}  [get_bd_cells microblaze_0]
# Add UART
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_1/clk_out1 (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins axi_uartlite_0/UART]
# validate
validate_bd_design
save_bd_design
close_bd_design [get_bd_designs demo1_bd]
generate_target all [get_files  ./demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd]
export_ip_user_files -of_objects [get_files /home/wirthlin/ee620/vivado/demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/wirthlin/ee620/vivado/demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd]
launch_runs demo1_bd_axi_uartlite_0_0_synth_1 demo1_bd_clk_wiz_1_0_synth_1 demo1_bd_dlmb_bram_if_cntlr_0_synth_1 demo1_bd_dlmb_v10_0_synth_1 demo1_bd_ilmb_bram_if_cntlr_0_synth_1 demo1_bd_ilmb_v10_0_synth_1 demo1_bd_lmb_bram_0_synth_1 demo1_bd_mdm_1_0_synth_1 demo1_bd_microblaze_0_0_synth_1 demo1_bd_rst_clk_wiz_1_100M_0_synth_1 -jobs 4
export_simulation -of_objects [get_files /home/wirthlin/ee620/vivado/demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd] -directory /home/wirthlin/ee620/vivado/demo1/demo1.ip_user_files/sim_scripts -ip_user_files_dir /home/wirthlin/ee620/vivado/demo1/demo1.ip_user_files -ipstatic_source_dir /home/wirthlin/ee620/vivado/demo1/demo1.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/wirthlin/ee620/vivado/demo1/demo1.cache/compile_simlib/modelsim} {questa=/home/wirthlin/ee620/vivado/demo1/demo1.cache/compile_simlib/questa} {xcelium=/home/wirthlin/ee620/vivado/demo1/demo1.cache/compile_simlib/xcelium} {vcs=/home/wirthlin/ee620/vivado/demo1/demo1.cache/compile_simlib/vcs} {riviera=/home/wirthlin/ee620/vivado/demo1/demo1.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
# Wrapper
make_wrapper -files [get_files .demo1/demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd] -top
add_files -norecurse ./demo1/demo1.gen/sources_1/bd/demo1_bd/hdl/demo1_bd_wrapper.v
# Generate .xsa file
write_hw_platform -fixed -force -file /home/wirthlin/ee620/vivado/demo1/demo1.xsa
# Export block diagram tcl
write_bd_tcl -force ./demo1/demo1_bd.tcl
# Launch implementation
launch_runs impl_1 -jobs 4
```