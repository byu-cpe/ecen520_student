# Notes for IP Integrator assignment

This page provides the instructions for completing the MicroBlaze IP Integrator assignment.

## Demo1

This demo involves the creation of a basic MicroBlaze system with a UART.

### Vivado Project

The first step is to create a hardware design of the microblaze system.
This project will be created in the `demo1` directory.
This is done exclusively in the Vivado tool and the result is a bitstream and a .xsa hardware platform project.
You will use the IP Integrator block diagram tool to create this system.
When you are done you will also create .tcl files that will allow you to recreate your system with much less effort.

* Create Project
    * Source Vitis settings.sh
    * vivado &
    * Create new project in sub directory
    * xc7a100tcsg324-1
    * The following command can be used to do this without the GUI: 
        * `create_project demo1 ./demo1 -part xc7a100tcsg324-1`
    * Copy default NEXYS DDR .xdc file to `demo1.xdc` and add to project
* Block Diagram Creation
    * Create new block diagram (`demo1_bd`) (click on IP Integrator->Create Block Design)
    * Add microblaze block
    * Run Block Automation
        * Change size to 32 KB ram
        * Make sure AXI interface is enabled
        * Make sure debug module is enabled (Debug Only)
        * Make sure clock connection is set to New clocking wizard
    * Configure Clock Module (clock pin and reset polarity)
        * Double click clock wizard block and make the following changes:
            * change input clock from differential to single ended
            * Go to the next "output clocks" page, change reset to "active Low"
    * Hook up Clock and Reset
        * Run connection automation
        * select clk_in1 and ok
        * Select reset and ext_reset_in and select reset source (new external port active low)
        * Modify the XDC file to include the clock and rename the clock to match the name given in the block design (`clk_100MHz`)
        * Modify the .xdc file to match the port name (`reset_rtl_0`)
    * Make sure there are no errors (click check box to check)
    * Add UART
        * Add IP and select UARTLite
        * Run connection automation to hook it up
        * Default baud rate is 9600
    * Make sure there are no errors
    * Save block diagram (you can close it if you like)
        * This will create a file `./demo1.srcs/sources_1/bd/demo1_bd/demo1_bd.bd` in the project and is currently the only source of the project
        * Create tcl file for recreating the block diagram in the future: 
            * select `demo1_bd.bd` from the sources and right click 
            * File->Export->Export Block Diagram. Save the file: `.demo1/demo1_bd.tcl` (you may want to move this to a higher level directory outside the project)
    * Generate the IP output products for the block diagram
        * This step runs synthesis on all the blocks in the system to generate the hdl sources needed for the IP
        * It creates a verilog file for the block diagram (that instances all the IP)
        * Right click over the block diagram in the sources view and select "Generate Output Products". Defaults are sufficient
        * This only needs to be done once
* Finalize Project
    * Generate the top-level wrapper for the block diagram (right click and select "generate HDL wrapper").
        * This is a top-level verilog file that can be edited and instances the block diagram. This is different from the block diagram verilog file.
        * Note that this should become the "black" top-level design (instead of the block diagram)
    * Update the .xdc file to include the UART signals
        * `uart_rtl_0_rxd` (in place of the `UART_TXD_IN` pin)
        * `uart_rtl_0_txd` (in place of the `UART_RXD_OUT` pin)
    * Run synthesis on the design to make sure everything is hooked up correctly and named properly in the xdc file
        * Most problems involve incorrect pin names or not providing pin constraints
    * Run Implementation and bitstream generation once all the issues have been resolved.
        * The bitfile will be located at `./demo1/demo1.runs/impl_1/demo1_bd_wrapper.bit`
    * Generate hardware platform for Vitis
        * After generating the bitstream you need to generate an .xsa platform project for use by vitis. This tells vitis what type of platform you are programming for. 
        * File->Export, Export Hardware, include bitstream, select directory (default is ok). 
        * Change the name to `demo1`. This will create the file `./demo1/demo1.xsa` that you will use for the Vitis programming step


### Rebuilding Vivado Project from Tcl

The purpose of this step is to demonstrate how to recreate the Vivado project using the project build tcl script.
This step is optional and can be skipped if you want to go straight to the Vitis programming.

* Close the project in vivado if you are in it
* Clean the old project: 
    * `rm -rf ./demo1`
* Open vivado and create a new project:
    * `create_project demo1 ./demo1 -part xc7a100tcsg324-1`
* Create the block diagram: 
    * `source demo1_bd.tcl` (`source demo1_bd_2022_2.tcl`)
* Add the constraints file: 
    * `add_files -fileset constrs_1 -norecurse demo1.xdc`
* Generate the output products:
    * `generate_target all [get_files  demo1/demo1.srcs/sources_1/bd/demo_bd/demo_bd.bd]` (not sure if this command works)
* Create the top-level HDL wrapper:
    * `make_wrapper -files [get_files ./demo1/demo1.srcs/sources_1/bd/demo_bd/demo_bd.bd] -top`
    * `add_files -norecurse ./demo1/demo1.gen/sources_1/bd/demo_bd/hdl/demo_bd_wrapper.v`
* Generate the bitfile
* Create the hardware platform file
    * `write_hw_platform -fixed -include_bit -force -file ./demo1/demo1.xsa`

### Vitis Software Project

In this phase of the demo you will run the Vitis tools and create a software program that runs on the microblaze system.
You will run a program template and not do any code editing for this particular demo.

* Open Vitis
    * Open from Vivado (Tools->Launch Vitis IDE)
    * Open from command line
* Select workspace
    * Vitis uses the Eclipse IDE and operates in the context of a workspace. For this set of demonstrations we will use a single workspace. I selected `vitis` directory in my `ip_integrator` assignment directory for the workspace.
* Create Application Project
    * The workspace will be empty so you need to populate it with something. Select 'Create Application Project' from the initial Vitis menu
    * You need to have a platform for your project. Your platform will be based on the .xsa file you created in the Vivado step
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
        * Everytime you generate a bitstream the bitstream will be patched with your source code.

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

# To Do

* Figure out how to create the full project from a script (not just the block diagram)
    * Including custom IP from HDL
* What is the best way to organize Vitis workspaces? Are they in parallel with the project directory? Should they be inside of the proejct directory?
* What is the difference between a system project and an application project?
