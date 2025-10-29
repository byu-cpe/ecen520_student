# ECEN 520 - Advanced Digital Design

This repository contains the lecture schedule (including links to lecture summaries), descriptions of the assignments, and code necessary for completing the assignments for ECEN 520.
* [Lecture Schedule](#lecture-schedule)
* [Assignments](#assignments)

## Lecture Schedule

<!-- See notes for future changes below. --> 

| Date | Lecture |
| --- | --- |
| **Week 1** | |
| 9/3/2025   | [Class Overview](./lectures/class_overview.md) |
| 9/5/2025   | [SystemVerilog Review](./lectures/system_verilog_overview.md) |
| **Week 2** | |
| 9/8/2025   | [Behavioral SystemVerilog](./lectures/system_verilog_sequential.md) |
| 9/10/2025  | [FSM Design #1](./lectures/fsm_design.md) |
| 9/12/2025  | [FSM Output Glitches and State Encoding](./lectures/glitches.md) |
| **Week 3** | |
| 9/15/2025  | [RTL Design using ASM Diagrams](./lectures/rtl_asmd.md)|
| 9/17/2025  | [SystemVerilog Testbenches](./lectures/testbenches.md)|
| 9/19/2025  | [Functions, Tasks, Threads, generate](./lectures/functions_tasks.md) |
| **Week 4** | |
| 9/22/2025  | [SystemVerilog Types](./lectures/systemverilog_types.md) |
| 9/24/2025  | [SystemVerilog Types continued](./lectures/systemverilog_types.md) |
| 9/26/2025  | [HDL Synthesis](./lectures/hd_synthesis.md) |
| **Week 5** | |
| 9/29/2025  | [Memories](./lectures/memories.md) |
| 10/1/2025  | [SPI Controller](./lectures/spi.md) |
| 10/3/2025  | [Verification with UVM](./lectures/uvm.md) |
| **Week 6** | |
| 10/6/2025  | **Exam #1** |
| 10/8/2025  | [Timing overview and review](./lectures/timing_overview.md) |
| 10/10/2025 | [Clock Skew](./lectures/clock_skew.md) |
| **Week 7** | |
| 10/13/2025 | [Xilinx Clock Timing reports](./lectures/xilinx_timing.md) |
| 10/15/2025 | [Xilinx Clock Resources (MMCM)](./lectures/xilinx_clocking.md) |
| 10/17/2025 | [Reset timing and strategies](./lectures/reset_strategies.md) |
| **Week 8** | |
| 10/20/2025 | [Metastability & Synchronizer design](./lectures/metastability.md) |
| 10/22/2025 | [Clock domain crossing](./lectures/clock_crossing.md) |
| 10/24/2025 | [Handshaking and Data Transfer](./lectures/handshaking.md) |
| **Week 9** |  |
| 10/27/2025 | ASIC Design (Tomoo)(./lectures/asic-design.md)  |
| 10/29/2025 | [Pipelining and Retiming](./lectures/pipelining.md) |
| 10/31/2025 | [AXI Bus](./lectures/axi.md) |
| **Week 10**| |
| 11/3/2025  | [AXI Bus part 2](./lectures/axi.md)|
| 11/5/2025  | [IP Integration](./lectures/ip_integration.md) |
| 11/7/2025  | **Exam #2** |
| **Week 11**|  |
| 11/10/2025 |  |
| 11/12/2025 | [Digital Arithmetic #1](./lectures/arith1.md) |
| 11/14/2025 | [Digital Arithmetic #2](./lectures/arith2.md)  |
| **Week 12**| |
| 11/17/2025 | [DSP Blocks](./lectures/dsp.md) |
| 11/19/2025 | [DDR](./lectures/ddr.md) |
| 11/21/2025 | [IO Resources](./lectures/io.md) |
| **Week 13**| |
| 11/24/2025 | **No Class** |
| 11/26/2025 | No Class - Thanksgiving Break |
| 11/28/2025 | No Class - Thanksgiving Break |
| **Week 14**| |
| 12/1/2025  | [CLB Blocks](./lectures/clb.md) |
| 12/3/2025  | TBD |
| 12/5/2025  | TBD  |
| **Week 15**|  |
| 12/8/2025  | TBD |
| 12/10/2025  | Review for Exam |
| 12/12/2025  | No Class - Final's Week |
| **Week 16**|  |
| 12/16/2025 | Final Exam in class |

<!--
* Move synthesis lecture before testbench/types lectures
* Dedicated lecture on implementation, constraints, and timing analysis
* Dedicated lecture on Verilog vs. SystemVerilog (how to code in Verilog)
  (this seemed to be weak and skipped this time)

Other Lectures: 
* ILA (Integrated Logic Analyzer)
* Simulation Coverage
* Assertions
* [Alternative HDLs](./lectures/alt_hdl.md)
* [Wishbone Bus](./lectures/wishbone.md)

[VHDL Part 1](./lectures/vhdl1.md)
[VHDL Part 2](./lectures/vhdl2.md)
[Poor Design Practice](./lectures/poor_practice.md)

-->

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
| 11 | [DDR](./ddr/ddr.md) | `ddr` |
| 12 |  |  |

<!--
[VGA Controller (VHDL)](./vga/vga.md) `vga`
[Project](./project/project.md) `project`
-->