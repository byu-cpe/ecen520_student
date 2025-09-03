# QuestaSim Tutorial

This brief tutorial will help you get started using QuestaSim in both GUI mode and command line mode.
GUI mode should only be used when debugging interactively. 
The command line mode will be used for grading.
Copy the following files to complete the tutorials: [counter.sv](./counter.sv) and [counter_tb.sv](./counter_tb.sv).
You are encouraged to access the help documentation within QuestaSim to get more details about the tool.

## QuestaSim GUI Tutorial

1. Starting vsim in GUI mode: `vsim`
2. Create a new project: `File > New > Project...`
    * Give it a name (e.g., `counter`)
    * Choose a location for the project and click `OK`
    * This will create a directory for your project and create a ".mpf" file for the project settings and a directory called "work" where your compiled files will be stored. It will also create a new "project" tab in the main window.
3. Add files to the project: `Project > Add to Project > Existing File ...`
    * Add the files `counter.sv` and `counter_tb.sv`
4. Compile the files by selecting "Compile > Compile All" 
5. Start simulation by selecting "Simulate > Start Simulation"
    * This will open the simulation window
    * Expand "Work" in the "Design tab" and select "counter_test"
    * Select "Optimization Options ..."
    * Select "Apply full visibility to all modules (full debug mode)"
    * Click "OK" to start
    * This will change the window configuration for simulation view (waveforms, object view, etc.)
6. In the "Objects" tab select a few signals to add to the waveform view
    * Right-click on the signal and select "Add to Wave > Wave"
7. Run the simulation by selecting "Simulate > Run > Run -All"
8. View the simulation waveform


## QuestaSim Command Line Tutorial

1. Starting vsim in command line mode: `vsim -c`
    * the `-logfile <logfile path>` option can be used to save all stdout output to a file for review
2. Compile the example files: `vlog counter.sv counter_tb.sv`. This will create a directory `work` with the compiled files.
3. Start simulation: `vsim -c work.counter_tb -voptargs=+acc`
4. Run the simulation to the end: `run -all`


## QuestaSim Waveform Helps

Waveform editing quick key commands:
* `F`: Full waveform zoom
* `I`: Zoom in
* `O`: Zoom Out

You can create a `.do` file that helps setup your waveforms when you run vsim.
This file can include dividers and waveforms before you start:


```
add wave -divider "Top"
add wave -position insertpoint  \
    sim:/tx_top_tb/tx_top/CLK100MHZ \
    sim:/tx_top_tb/tx_top/BTNC
add wave -divider "tx"
add wave -position insertpoint  \
    sim:/tx_top_tb/tx_top/tx_data \
    sim:/tx_top_tb/tx_top/tx_out \
    sim:/tx_top_tb/tx_top/tx_out_d
add wave -divider "debouncer"
add wave -position insertpoint  \
    sim:/tx_top_tb/tx_top/db/debounce_out \
    sim:/tx_top_tb/tx_top/db/debounce_counter
```

## QuestaSim Commands

### vlog

### vlog

### vcom

### vlib

<!--
Ideas:
- force command
- logging command (log)
-->

Commands:
* `exit`:
* `examine`: 

References:
* [Brief Tutorial](https://vhdlwhiz.com/the-modelsim-commands-you-need-to-know/)
* [ModelSim user manual](https://faculty-web.msoe.edu/johnsontimoj/Common/FILES/modelsim_user.pdf)
* [Command reference](https://web.eecs.utk.edu/~dbouldin/protected/modelsim_se_ref.pdf)

Example
```
vlib work
vlog tx.sv
vlog -quiet tx_tb.sv
vlog rx_model.sv
vsim -c work.tx_tb -do "run -all"
```

Libraries for primitives
```
vmap unisims_ver /tools/Xilinx/Vivado/2024.1/data/questa/unisims_ver
vcom ../vhdl/seven_segment_display.vhd
vlog mmcm_top.sv
vlog /tools/Xilinx/Vivado/2024.1/data/verilog/src/glbl.v
vsim mmcm_top glbl -L unisims_ver
```


```
add wave -position insertpoint  \
sim:/counter_tb/clk \
sim:/counter_tb/rst \
sim:/counter_tb/inc \
sim:/counter_tb/load \
sim:/counter_tb/din \
sim:/counter_tb/cnt
```
<!--

Running firefox over X11 on mac

export XAUTHORITY=$HOME/.Xauthority

https://support.xilinx.com/s/article/64052?language=en_US

using GUI: Simulate > Start Simulation > Libraries > Add > altera_mf_ver
using console: add -L altera_mf_ver to your command.


# NUMBER_OF_CHARS
# BAUD_RATE
# CLOCK_FREQUENCY
# PARITY
vsim -c work.tx_tb -gNUMBER_OF_CHARS=6 -gPARITY=0 -do "run -all"


Inside vsim
```
vsim work.tx_tb
```

vsim -voptargs=+acc work.tx_tb

add wave -position insertpoint  \
sim:/tx_tb/clk \
sim:/tx_tb/rst \
sim:/tx_tb/tb_send \
sim:/tx_tb/tb_tx_out \
sim:/tx_tb/tx_busy


```
source /tools/Xilinx/Vivado/2024.1/settings64.sh
export LM_LICENSE_FILE=1717@ece-modelsim.byu.edu
export PATH=$PATH:/usr/local/questasim/bin
```


https://stackoverflow.com/questions/59137306/how-to-pass-multiple-generics-to-vsim-using-g-switch-in-modelsim

-->