# MicroBlaze UART

Once you have created the microblaze [IO demonstration](./demo_io.md), you can create a microblaze with your custom AXI UART.
This page will describe the steps necessary to build the MicroBlaze system that includes your UART as well as the switches and your seven segment display.

This demo involves the creation of a basic MicroBlaze system with a UART.
You will be using the GUI to create the Vivado project and the Vitis tool to create the software application.
You will also learn how to recreate the Vivado project using Tcl scripts.

## Vivado Project

Follow these steps to build the MicroBlaze system:

* Open Vivado and use the GUI to create a new project

* Create the new uart microblaze project
    * Create a new project directory for your new MicroBlaze project (something like `mb_uart`).
    * Copy the `demo_io.xdc` file you created for the earlier project and rename it `mb_uart.xdc` (add this file in your microblaze project directory repository). Add it to the project. You will be editing it later on.
    * Add the following files to your project
        * Add the file `seven_segment8_wrapper.v` from this assignment. This file is a Verilog wrapper for your seven_segment8 module (the block diagram does not accept SystemVerilog files)
        * Your seven segment display module (`seven_segment8.sv`) from your 'rx_sim' assignment.
        * Your rx and tx modules from the rx_sim and tx_sim assignments
        * Your fifo, uart_axi, and uart_axi_wrapper from the axi assignment
    * Source the `demo_io_bd.tcl` file you created earlier to build the io project. Running this script will create the same block diagram and save you time building the new MicroBlaze system from scratch.
* Modify the block diagram to add a GPIO module for the buttons, the seven segment display and your UART axi module
    * Add a third GPIO module for the buttons
        * Name the module appropriately
        * Set the module as all inputs and the size as 5 bits (one for each button)
        * Use the "Connection Automation" to wire it up into your system
        * Rename the top-level ports appropriately (the default ports are named something like `gpio_rtl_0.` Rename it to something like `gpio_BTN`.)
        * Modify the xdc file to add the buttons. The buttons should be assigned the following bits:
            * 0: BTNC
            * 1: BTNU
            * 2: BTNL
            * 3: BTNR
            * 4: BTND
    * Add a fourth GPIO module for the seven segment display
        * Name the module appropriately
        * Set the module as all outputs and the size as 32 bits (for your 32-bit output register)
        * Click the 'Enable Dual Channel' button so there are two GPIO channels
        * Set the second channel as output only and use 16 bits (bits 7:0 for the digit points and bits 15:8 for the blank signals of the eight digits)
        * Use the "Connection Automation" to wire it up into your system. Only select the 'S_AXI' port to hook up (not the other ports). The output port will be hooked up to your seven segment display block.
        * Add your seven segment display logic to the block diagram
            * Right click on the canvas and select "Add Module". Select the seven_segment8_wrapper module. This will add the module to the canvas.
            * Manually wire the clock input and reset to the corresponding inputs of your module (note that the wrapper to the seven segment display controller uses an inverted reset so you can hook up the system reset directly to the module)
            * Click the "+" on the GPIO output of the GPIO module for the seven segment display. The gpio_io_o output is shown. Wire this output to the data_in intput of your seven segment display module.
            * Click the "+" on the GPI2 output of the GPIO for the seven segment display. Wire this output to the control input of your seven segment display module.
            * Right click on the canvas and select "Create Port". Name the port "AN", indicate it is an output, and leave the type as "Other" (you do not need to set its size).
                * Wire the anode output of your seven segment display module to this port.
            * Create a port for the cathodes named 'C' and wire it to the Cathode outputs of your module.
        * Update the xdc file to match the names of the top-level ports
            * The Anode signals (`AN`) should not require any changes.
            * The cathode signals (`Cx`) are all single bit named ports. You will need to change the name of each signal to be part of a vector. Assign your signals as follows:
                * CA = C[6]
                * CB = C[5]
                * CC = C[4]
                * CD = C[3]
                * CE = C[2]
                * CF = C[1]
                * CG = C[0]
                * DP = C[7]
    * Add your UART axi module
        * Right click on the canvas and select "Add Module". Select your uart_axi.
        * Rename your module `uart_axi` (From the default uart_axi_wrapper_0)
        * Double click the module to view its parameters. The defaults are a baud rate of 115,200 (`BAUD_RATE`) and odd parity (`PARITY` = 1). You can change them here, but your terminal settings must match whatever values you choose.
        * Run the Connection Automation to wire it up
        * Create an output port for the tx output (named `UART_RXD_OUT`) and hook it up to the tx output of your module (this is the name in the .xdc file so you don't have to update the xdc)
        * Create an input port for the rx input (named `UART_TXD_IN`) and hook it up to the rx input of your module (again, this is the name in the .xdc file)
    * Validate and save your block diagram
        * Click the "validate" box to make sure everything is hooked up correctly
        * Export your block diagram file (to a file such as `mb_uart_bd.tcl` in your top-level `microblaze` directory)
    * Exit the block diagram editor and save the block diagram
* Build your project and make sure it builds without any errors
    * Generate IP products (select the block diagram icon, right click 'generate output products')
    * Create a top-level wrapper for the block diagram (select the block diagram icon, right click 'create HDL wrapper')
        * Select the top-level wrapper and right click to set it as "top"
    * Generate the hardware platform (File->Export, Export Hardware) and create a `mb_uart.xsa` file
    * Run synthesis, implementation, and a bitfile to verify that your project is ready

    <!-- * Create an inverted reset signal
        * Your circuit modules rely on a high asserted reset but the reset coming on the board is low asserted. You will need to create a high asserted reset to use for your modules.
        * Instance the IP block titled "Utility Vector Logic"
        * Double click the module and select "Not" and C_SIZE as 1
        * Wire the input reset to the input of this module.
        * You will hook up the output of this module to your seven seegment display and uart AXI -->

Once you have a platform that compiles, create a makefile step named `build_mb_uart` that will create the demo_io project and generate a bitstream and a the `./mb_uart/mb_uart.xsa` file.
Also, make sure your 'clean' rule will clean up the project completely.

## Vitis Project

Like the `demo_io` example, you need to create a vitis platform component based on your `mb_uart` design.
Follow these steps to create a working project and test it on your platform.'

* Create a vitis workspace within your `mb_uart` vivado project directory named `vitis` and create the vitis platform component.
* Create an empty application in your project.
* Add the file [`mb_uart.c`](./mb_uart.c) to your project
* Modify the the `CMakeLists.txt` file to include this new source file.
* Compile your project and make sure there are no errors
* Download the project to the board and test it as described below.

### Testing Your System

The `mb_uart.c` program does the following:

* The LEDs show the switches. While a button is pressed, BTND shows the inverted switches, BTNL and BTNR shift the switch value left and right, and BTNU shows the UART status register.
* Every character received by the UART is echoed back to the terminal.
* Pressing BTNC transmits the value of the lower 8 switches as a character (e.g., set the switches to 0x41 to send an 'A').
* The seven segment display shows four bytes: the number of characters received (upper two digits), the number of characters sent, the UART status register, and the lower 8 switches (lower two digits).

Use a terminal emulator such as PuTTY (see the [tx_download](../tx_download/tx_download.md) assignment) to communicate with your UART.
Your terminal settings must match the parameters of your `uart_axi` block. With the default parameters, use:
* Baud rate: 115,200
* Data bits: 8
* Parity: **odd** (the most common mistake is leaving the parity set to "none")
* Stop bits: 1
* Flow control: none

For example, with `screen` on Linux: `screen /dev/ttyUSB1 115200,cs8,parenb,parodd,-cstopb` (the device name depends on your computer).
Type a few characters in the terminal and make sure they are echoed back and that the received and sent counts on the seven segment display increase.

Once you have a working system, automate the process for building the elf file.
Create a python script for creating and building the project from scratch such that you have a file `./mb_uart/vitis/mb_uart/build/mb_uart.elf`
Create a makefile rule named `build_mb_uart_vitis` that will create the vitis project and build the elf file in the path described above.
As in the previous example, you will need to copy the .c file into the project and the modified `CMakeLists.txt`
Also, make sure your 'clean' rule will clean up the vitis project completely.


