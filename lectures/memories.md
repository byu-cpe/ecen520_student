# Memories

In this lecture we will discuss the memory architecture on the Xilinx 7-series FPGAs.
We will discuss different ways of insantiating memories within HDL code and how to infer memories from HDL code.

## Reading
  * [Xilinx Synthesis Guide (UG901)](https://docs.amd.com/r/en-US/ug901-vivado-synthesis). "RAM HDL Coding Guidelines" in Chapter 5 (120-170)x`
  * [7 Series Memory Resources (UG473)](https://docs.amd.com/v/u/en-US/ug473_7Series_Memory_Resources). Pages 11-25
  * [Xilinx Libraries Guide (UG953)](https://docs.amd.com/r/en-US/ug953-vivado-7series-libraries). Read the summary of the FIFO36E1, FIFO18E1, RAMB36E1, and RAMB18E1 primitives.
  <!-- * [](). Chapter 19 from Brent's book -->>

## Key Concepts

  * Understand how a memory array differs from a register file
  * What are block memories used for
  * Understand the various modes of operation: WRITE_FIRST, READ_FIRST, and NO_CHANGE_MODE
  * Use the BRAM in different address/data width configurations
  * Understand the write and read timing of a BRAM
  * Timing parameters of a BRAM
  * How to instance a BRAM as a module
  * How to infer BRAMs from HDL
  * What is a FIFO and why is it used

<!-- Future: (probably two lectures in the future)
- Examples of dual port block ram inference
- Discuss LUT RAMs
- discuss CAM memories
-->