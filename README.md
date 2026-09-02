# ECEN 520 - Advanced Digital Design

This repository contains the lecture schedule (including links to lecture summaries), descriptions of the assignments, and code necessary for completing the assignments for ECEN 520.

* [Lecture Schedule](#lecture-schedule)
* [Assignments](#assignments)

## Lecture Schedule

<!--
* Lecture on double data rate and serializer/deserializer (LVDS) - see Brigham's shift register design
* Dedicated lecture on implementation, constraints, and timing analysis
* Dedicated lecture on Verilog vs. SystemVerilog (how to code in Verilog)
  (this seemed to be weak and skipped this time)

Other Lectures: 
* ILA (Integrated Logic Analyzer)
* Simulation Coverage
* Assertions
* [Alternative HDLs](./lectures/alt_hdl.md)
* [Wishbone Bus](./lectures/wishbone.md)

Other Assignments:
* Use a serializer and LVDS for (double data rate? - See Brigham's shift register design)

[VHDL Part 1](./lectures/vhdl1.md)
[VHDL Part 2](./lectures/vhdl2.md)
[Poor Design Practice](./lectures/poor_practice.md)
[Verification with UVM](./lectures/uvm.md)
Cliff Cummings, Sunburst (UVM/SV)
-->


| Week | Date | Lecture |
| --- | --- | --- |
| 1 | 9/2/2026   | [Class Overview](./lectures/class_overview.md) |
|   | 9/4/2026   | [SystemVerilog Review](./lectures/system_verilog_overview.md) |
| 2 | 9/7/2026   | Holiday - No Class |
|   | 9/9/2026   | [Behavioral SystemVerilog](./lectures/system_verilog_sequential.md) |
|   | 9/11/2026  | [FSM Design](./lectures/fsm_design.md) |
| 3 | 9/14/2026  | [FSM Output Glitches and State Encoding](./lectures/glitches.md) |
|   | 9/16/2026  | [RTL Design using ASM Diagrams](./lectures/rtl_asmd.md)|
|   | 9/18/2026  | [HDL Synthesis](./lectures/hd_synthesis.md) |
| 4 | 9/21/2026  | [SystemVerilog Testbenches](./lectures/testbenches.md)|
|   | 9/23/2026  | [Functions, Tasks, Threads, generate](./lectures/functions_tasks.md) |
|   | 9/25/2026  | [SystemVerilog Types](./lectures/systemverilog_types.md) |
| 5 | 9/28/2026  | [Memories](./lectures/memories.md) |
|   | 9/30/2026  | [SPI Controller](./lectures/spi.md) |
|   | 10/2/2026  | [Timing overview and review](./lectures/timing_overview.md) |
| 6 | 10/5/2026  | [Clock Skew](./lectures/clock_skew.md) |
|   | 10/7/2026  | [Xilinx Clock Resources (MMCM)](./lectures/xilinx_clocking.md) |
|   | 10/9/2026  | [Xilinx Clock Timing reports](./lectures/xilinx_timing.md) |
| 7 | 10/12/2026 |  **Exam #1** |
|   | 10/14/2026 | [Reset timing and strategies](./lectures/reset_strategies.md) |
|   | 10/16/2026 | [Metastability & Synchronizer design](./lectures/metastability.md)|
| 8 | 10/19/2026 | [Clock domain crossing](./lectures/clock_crossing.md) |
|   | 10/21/2026 | [Clock domain crossing (cont.)](./lectures/clock_crossing.md) | | <!-- Cover Xilinx CDC IP and CDC verification -->
|   | 10/23/2026 | [Handshaking and Data Transfer](./lectures/handshaking.md) |
| 9 | 10/26/2026 | [Pipelining and Retiming](./lectures/pipelining.md) |
|   | 10/28/2026 | [ASIC Design (Tomoo)](./lectures/asic-design.md) |
|   | 10/30/2026 | [AXI Bus](./lectures/axi.md) |
| 10 | 11/2/2026  | [AXI Bus part 2](./lectures/axi.md) |
|   | 11/4/2026  | [IP Integration](./lectures/ip_integration.md) |
|   | 11/6/2026  | [Digital Arithmetic #1](./lectures/arith1.md) |
| 11 | 11/9/2026  | **Exam #2** |
|   | 11/11/2026 | [Digital Arithmetic #2](./lectures/arith2.md) |
|   | 11/13/2026 | [DSP Blocks](./lectures/dsp.md) |
| 12 | 11/16/2026 | MicroBlaze Assignment Preparation |
|   | 11/18/2026 | [CLB Blocks](./lectures/clb.md) |
|   | 11/20/2026 | [IO Resources #1](./lectures/io.md) |
| 13 | 11/23/2026 | [IO Resources #2](./lectures/io.md) |
|   | 11/25/2026 | No Class - Thanksgiving Break |
|   | 11/27/2026 | No Class - Thanksgiving Break |
| 14 | 11/30/2026 | [DDR](./lectures/ddr.md) |
|   | 12/2/2026  | VHDL #1 |
|   | 12/4/2026  | VHDL #2 |
| 15 | 12/7/2026  | Trends in HDL design |
|   | 12/9/2026  | Review for Exam (last day of class) |
| **Week 16**|  |
| 16 | 12/16/2026 | Final Exam in class (Wed, 11:00 AM - 2:00 PM) |


## Assignments

All assignments must be submitted on a classroom GitHub repository. 
Review the [assignment mechanics](./resources/assignment_mechanics.md) page to learn how to properly submit your assignments.

| # | Name | Directory/Lab Tag | 
| ---- | ----| ----|
| 1 | [UART Transmitter-Simulation](./tx_sim/UART_Transmitter_sim.md) | `tx_sim` |
| 2 | [UART Transmitter-Synthesis and Download](./tx_download/tx_download.md) | `tx_download` |
| 3 | [UART Receiver Simulation](./rx_sim/UART_Receiver_sim.md) | `rx_sim` |
| 4 | [UART Synthesis and Download](./rx_download/UART-Receiver_synth.md) | `rx_download` |
| 5 | [SPI Controller-Simulation](./spi_cntrl/SPI_cntrl.md) | `spi_cntrl` |
| 6 | [SPI Controller-Download](./spi_download/spi_download.md) | `spi_download` |
| 7 | [BRAM](./bram/bram.md) | `bram` |
| 8 | [BRAM-Download](./bram_download/bram_download.md) | `bram_download` |
| 9 | [MMCM Clocking](./mmcm/mmcm.md) | `mmcm` |
| 10 | [AXI](./axi/axi.md) | `axi` |
| 11 | [MicroBlaze](./microblaze/microblaze.md) | `microblaze` |
| 12 | [DDR](./ddr/ddr.md) | `ddr` |

<!--
[VGA Controller (VHDL)](./vga/vga.md) `vga`
[Project](./project/project.md) `project`
-->