
# Personal Project

In this assignment you are to create your own personal project that demonstrates the integration of the DDR.
The intent of this assignment is for you to be creative and demonstrate your ability to integrate existing HDL cores.
The only requirements you for this assignment are:
* You must use the DDR controller in your design
* You must include at least two of the modules you created in this class (VGA, UART, SPI, BRAM, etc.)
* You must use at least one module that you get form somewhere else (e.g. [opencores](https://opencores.org/), [fpga4fun](http://www.fpga4fun.com/), etc.)

## Project Ideas

The hardest part of this assignment is coming up with a project idea that is reasonable to complete in the limited time given to you. 
The intent is not to make this too time consuming but rather to make it fun and a good way to demonstrate your skills.
Feel free to contact me if you have any questions about the difficulty and feasibility of your project idea.
Here are a few project ideas that you might consider (it is fine if more than one student does any of these):

* Accelerometer logger: Use the accelerometer and log the accelerometer data into the DRAM. Transfer the data over the UART and save to a file (you can transmit binary data rather than ascii). 
* Display controller: Use the DDR to hold the contents of an image. Synchronize the access of data from the DDR and display the image on the VGA display. You will need a way to load the image data into the DDR
* Play sounds or record sound: there is hardware on the board to support recording and playback of sound. Consider using the OOB design described below to find cores for playing or recording sound.

The sources for the default design that is configured on your board can be found at the digilent github for the [Nexys4 DDR board](https://github.com/Digilent/Nexys-4-DDR-OOB).
Consider browsing through this design to find interesting cores or ideas you may integrate. 
You are free to use anything in this repository.
You may want to browse through their [repositories](https://github.com/orgs/Digilent/repositories?type=all) to find other design examples or cores.


## Project Simulation

Create a top-level simulation testbench that demonstrates the primary functions of your design.
Create a makefile rule named `sim_top` that performs this simulation.

## Bitfile Generation

Create a synthesis script that will synthesis your design and generate a bitfile named `project.bit`.
Create a makefile rule `gen_bit` that performs this task.
Make sure your bitstream operates correctly on the board.

## Submission

The following assignment specific items should be included in your repository:

1. Required Makefile rules:
  * `sim_top`
  * `gen_bit`
2. You need to have at least 4 "Error" commits in your repository
3. Assignment specific Questions:
  * **Project Summary**: Provide a brief paragraph summary of what your project does and how it operates on the board. If the design requires any external files or software, describe it (i.e., if you have a simple python script that interacts with your design include it in your repository and explain how it works).
  * **3rd Party Module**: Describe where you obtained your external core. Provide a link to the resources of this core.
  * **Improvements**: Describe a few improvements you could make to the design should you have more time.
  * **File List**: List all the system verilog files you created to build your design. Clearly indicate which one is the top design.

<!--
- Be more specific on the file names. 
- REquire them to be very specific about how to run the design (buttons, baud rate, etc.) Many students didn't cinldue this information.
- Require some minimum complexity of IP (the tri-color LED core isn't really enough)
- Require them to put their non-ip file in the top level (not a sub directory) to simplify grading.
- Students struggled to find an IP. Need to find some good IP ideas to make it easier.
- It looks like a few students didn't put the IP generation process in the makefile. Need to add a rule that explicilty does this (add it to the passoff script)
-->