<!--
- Make sure they put their images _inline_ (rather than links) so I don't have to click to grade. One separate image for each counter and an annotation of text.
- The build makefiles had hard coded paths for the glbl.v file. Need to modify the instructions so that the make will work on any computer (have them copy it to their repo?)
- Have them figure out the TCL commands for printing the simulation files to an image
- Need to have the testbench print more out with more interesting notes/comments
- Have them create a 48-bit counter instead of 32-bit counter and display the top 32 bits (so we don't get roll over so fast)
- Force them to get metastability? If so, how to force it? (more guidelines). See Baker's
- Force them to use generate statements? It is a good place to learn to use them.
-->

# Clocking and Metastability

In this assignment you will learn how to use the MMCM to create a de-skewed clock, clocks of various frequency, and phase, and to induce metastability.
You will use the switches, buttons, seven segment display, and LEDs to interact with your clocking circuit.

<!--
Fvco range is 600 MHz to 1600 Mhz

Fvco = Fin X M / D

Fin = 100 MHz thus M/D must be between 6 and 16
DIVCLK_DIVIDE = D

for 100 MHz, D=2, M=12

- Give the students help on the "stretcher" circuit. Use 'always_latch'? or instance latch primitive.
- Why can't you have a bufg on the input clock? (or ibufg?) It seems you have to hook up the signal directly.

Dallin:
set_false_path -from [get_clocks sclock0] -to [get_clocks clock4]
set_false_path -from [get_clocks clock4] -to [get_clocks clock0]
set_false_path -from [get_clocks clock3] -to [get_clocks clock0]
set_false_path -from [get_clocks {clock* sclock*}] -to [get_clocks sys_clk_pin]
-->

## Top-Level Design

Start your assignment by creating a top-level design that connects to the following pins on the FPGA:

* 100 MHz clock input
* Reset button
* Switches

| Port Name                  | Direction | Width  | Function                                     |
|----------------------------|-----------|--------|----------------------------------------------|
| CLK100MHZ                  | Input     | 1      | Clock                                        |
| CPU_RESETN                 | Input     | 1      | Reset (low asserted)                         |
| SW                         | Input     | 8      | Switches (8 data bits to send)               |
| BTNC                       | Input     | 1      | Control signal to start a transmit operation |
| LED                        | Output    | 16     | Board LEDs (used for data and busy)          |
| UART_RXD_OUT               | Output    | 1      | Transmitter output signal                    |
| UART_TXD_IN                | Input     | 1      | Receiver input signal                        |
| LED16_B                    | Output    | 1      | Used for TX busy signal                      |
| LED17_R                    | Output    | 1      | Used for RX busy signal                      |
| LED17_G                    | Output    | 1      | Used for RX error signal                     |
| AN                         | [7:0]     | Output | Anode signals for the seven segment display  |
| CA, CB, CC, CD, CE, CF, CG | [6:0]     | Output | Seven segment display cathode signals        |
| DP                         | Output    | 1      | Seven segment display digit point signal     |

| Parameter Name     | Default Value | Purpose                                                         |
|--------------------|---------------|-----------------------------------------------------------------|
| CLK_FREQUENCY      | 100_000_000   | Specify the clock frequency                                     |
| SEGMENT_DISPLAY_US | 1_000         | The amount of time in microseconds to display each digit (1 ms) |
| DEBOUNCE_DELAY_US  | integer       | 1_000                                                           | Specifies the minimum debounce delay in micro seconds (1 ms) |

## Main MMCM

The first step in this assignment is to create your "Main" MMCM that is used to deskew the input clock and generate a variety of clocks (note that this part of the design is just one part of the top-level design - you do not need to create a module for this).
Instance the "MMCME2_BASE" primitive into your design and hook it up as described below.
You can learn more about primitives that can be instantiated at the following [library guide](https://docs.xilinx.com/v/u/2012.2-English/ug953-vivado-7series-libraries).
Note that you can look at the text for the module definition of this primitive in the following file: `<Xilinx>/Vivado/<version>/data/verilog/src/unisim_comp.v`

**Tips**

To simulate primitives from the command line you will need to complete the following steps:

1. You will need to compile the `glbl` verilog library that contains the simulation model for the mmcm module (you will need to change the location of the glbl file to match your installation):

```
xvlog --nolog -sv /tools/Xilinx/Vivado/2021.2/data/verilog/src/glbl.v
```

1. When you elaborate your final simulation model you will need to include the following options:

* `-L unisims_ver` : This will include the unisims library that contains the mmcm primitive
* `glbl` : This will include the glbl library that contains the simulation model for the mmcm primitive
* `-relax` : This will downgrade warnings such as the following: `Module glbl has a timescale but at least one module in design doesn't have timescale.`

You will have unconnected ports in your MMCM.
To avoid getting unnecessary warnings, provide an empty `()` for the port as follows

```
  .CLKOUT0(mmcm1_clk0_int),     // Hook up to internal net
  .CLKOUT0B(),                  // Leave unconnected (won't generate a warning)

```

<!--
Need to describe how to use modules in your design (see note in link)
https://support.xilinx.com/s/article/64052?language=en_US
-->

* Use the board RST to reset this MMCM
    * Although the reset button signal doesn't really need to be synchronized for this situation, it is a good idea to add a synchronizer to clean up the signal a bit (avoid lots of high frequency glitches). These synchronizers should be clocked by the free running 100 MHz board clock (not any of the generated clocks from the MMCM).
* Configure the MMCM and instance BUFGs so that the MMCM performs a "deskew" function (Figure 3-11) on the input 100 MHz clock. The CLKOUT0 should be in phase with the input clock and have a 50% duty cycle
* Create additional clock outputs with the following requirements:
    * CLKOUT1: Same clock frequency as input, phase shifted 180 degrees, 25% duty cycle
    * CLKOUT2: Same clock frequency as input, phase shifted 90 degrees, 75% duty cycle
    * CLKOUT3: Lower clock frequency as input, out of phase with input. Do not use power of 2 divide and make this at least 6x lower frequency.
    * CLKOUT4: Higher clock frequency as input, out of phase with input. Do not use power of 2 multiply and make this at least 2.5x greater than input clock.
    * CLKOUT5: Lower clock frequency as input (but different from CLKOUT3), in phase with input
    * CLKOUT6: Higher clock frequency as input (but different from CLKOUT5), in phase with input

### Clock Domain Reset signals

You will need to create a reset signal for each of the clock domains you created.
This reset signal will be used by the logic in each of the clock domains.
The purpose of this reset signal is to synchronize the rest with the given clock so that the reset timing will be met.

A good example on how to do this can be found in Figure 4 of the following [URL](http://www.markharvey.info/art/7clk_19.10.2015/7clk_19.10.2015.html).
This approach involves the following principles:

* Provide several flip-flops in a chain for the reset signal (at least two as a synchronizer and a few more if you want more time for the reset)
* The last flip-flop of this chain is your clock domain reset signal, the first flip-flop should have a '0' as its input (so that the 0 can propagate through the flip-flop chain)
* These flip-flops should be asynchronously "Preset" when the MMCM `Locked` signal is low. This way, the reset signal going to the clock domain will be asserted immediately when `Locked` goes low (i.e., when you lose a good clock)
* These flip-flops should be clocked by clock signal generated by the MMCM that corresponds to the clock domain of interest.

### Clock Domain Counters

Create a 32-bit counter for each of the 7 clock domains.
Each of these counters should be reset using the appropriate reset circuit created above.
These counters will be referred to later in the description as CNT0, CNT1, ... CNT6.

## Clock Domain Crossing Signals

For this part you will create enable signals in various clock domains and "count" these enable pulses in a different clock domain.

* Create a single pulse in CLKOUT3 that occurs every 4 clock cycles (PULSE3)
* Create a single pulse in CLKOUT4 that occurs every 100 clock cycles (PULSE4)
* Create a counter in the CLKOUT0 domain that counts the PULSE3 pulses. Note that you should only count once for each unique PULSE3 signal. This counter will be referred to as PULSE3CNT.
* Create a counter in the CLKOUT0 domain that counts the PULSE4 pulses. Note that you should only count once for each unique PULSE3 signal. This counter will be referred to as PULSE4CNT.

## Secondary MMCM and Metastability Circuit

Instance a second MMCM that uses CLK0 as the input clock.
Create a new clock from this MMCM that is a fractional value of the frequency of CLK0 (using prime numbers for M and D).
Your resulting frequency should be between 50 MHz and 100 MHz.
Do **NOT** use de-skewing in this configuration (i.e., do not align the input CLK0 with this MMCM - see Figure 3-13).
The goal here is to make a second MMCM that is *not* necessarily synchronous with the input clock (in most cases you would just make them synchronous).
This MMCM should be reset when the first MMCM is not locked (i.e., the output of the first locked signal should drive the input of the second reset with an inverter so that the second MMCM doesn't start to operate until the first one has locked).
Create a counter for this new clock domain named CNTB_0.
This counter should be reset using an appropriate reset signal.

Create a signal in this clock domain that toggles every clock cycle.
This signal will be the "input" signal used for inducing metastability.
Create a metastability detection circuit (see resources below)

* [Old FPGA ap note: Figure 1](https://docs.xilinx.com/v/u/en-US/xapp094)
* [this paper](https://www.researchgate.net/publication/258377930_Metastability_Testing_at_FPGA_Circuit_Design_using_Propagation_Time_Characterization)
* (Let me know if you find some other good ones!)

<!-- as shown [here in Figure 1](http://userweb.eng.gla.ac.uk/scott.roy/DCD3/technotes.pdf).-->
The f_data signal is your toggling circuit created in the CNTB_0 clock domain.
Use CLKOUT4 as the f_clk.
Every time FF 'D' goes high, a metastability event has been detected.
Create a counter in the CLKOUT4 clock domain that counts metastability events.
This counter will be referred to as CNT_META.

## Design I/O

Instance the seven segment display in your design.
Note that you should drive the seven segment display with the top-level clock that comes into the FPGA.
If you use a clock generated by one of the MMCMs then your seven segment display will be disabled when you press the reset button.

Create a mux that selects one of the counters you generated based on the value of the switches.
Place a register after this mux to synchronize the various counters in their different clock domains to the top-level clock (i.e., the same clock used by the seven segment display).
You don't need two levels of synchronizers - just one to prepare the data for the seven segment display controller.
It is possible you will get metastability but this is not an issue for the seven segment display controller - you will never see it.

| SW[3:0] | Display   |
|---------|-----------|
| 0x0     | CNT0      |
| 0x1     | CNT1      |
| 0x2     | CNT2      |
| 0x3     | CNT3      |
| 0x4     | CNT4      |
| 0x5     | CNT5      |
| 0x6     | CNT6      |
| 0x7     | PULSE3CNT |
| 0x8     | PULSE4CNT |
| 0x9     | CNTB_0    |
| 0xA     | CNT_META  |

## Simulation and Bitfile

Create a top-level testbench that simulates your design.
This testbench should demonstrate e your clocking, counter circuits, seven segment display and mux are all working properly.
Create a makefile rule `sim_top` that performs this simulation from the commandline.

Create a makefile rule `gen_bit` that generates a bitstream for your top-level design.

## Timing Analysis

It is important that you implement the circuit with *no* timing violations.
Without any special care, you will end up with timing violations.
You will need to treat some of the timing situations in your design with special care.
Here are some guidelines for getting a successful timing analysis:

* Add the property "ASYNC_REG=true" to your clock domain crossing synchronizers (see page 40 of the [Vivado Synthesis Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug901-vivado-synthesis.pdf)). This will let the synthesis tool know that it should not optimize the flip-flops away and that you want to move the synchronizer flip-flop as close to the output of the previous flip-flop as possible.
* You need to add a constraint in your .xdc file to ignore the timing between asynchronous FFs. Details on how to ignore these timing paths are described below. This occurs in two places:
    * The synchronizer for the pulse3 and pulse4 signals that are crossing clock domains
    * The synchronizer register used to synchronize the various counters to the top-level clock domain
    * The input to the "metastability A" FF used to detect metastability.

You will use the `set_false_path` constraint directive to have the timing analysis tool ignore these paths.
The following examples demonstrate how to use this command:

```
# Sets a false path from counter0 to the ssd_sync register (all 32 bits)
# Note that Vivado adds the "_reg" name to your HDL name
set_false_path -from [ get_cells clk0_cntr_reg[*] ] -to [ get_cells ssd_sync_reg[*] ]
# Sets a false path from the pulse3_reg signal to the synchronizer signal in another clock
# domain.
set_false_path -from [ get_cells pulse3_reg ] -to [ get_cells pulse3_clk0_d_reg ]
```

## Submission

1. Prepare your repository
    * `sim_top`: performs command line simulation of the top testbench
    * `gen_bit`: Generates a bitstream for your top-level design
2. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission-process) file

* Create the template file based on the instructions linked above
* Add the following items for the assignment-specific section of the readme:
    1. **Resources**: Provide a summary of the number of resources your design uses (see the output from the utilization report). Specifically, indicate the number of `Slice LUTs`, `Slice Registers`, and `Bonded IOB` resources your design uses.
    2. **Warnings**: You should not have _any_ warnings in your project as described in the assignment instructions above. Make sure you don't have any warnings and state this in your readme. If you do have warnings, you need to provide strong justification for them.
    3. **Timing**: Determine the "Worst Negative Slack" (or WNS). This is found in the timing report and indicates how much timing you slack you have with the current clocking.
    4. **Waveforms**:  Create one or more waveforms with markers to demonstrate each of your 7 clocks operating correctly. Take a screenshot of the waveform. Make sure you demonstrate correct frequency (by measuring period), phase offset, and duty cycle.

