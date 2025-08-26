# DSP blocks

The 7 Series FPGAs contain DSP blocks for performing arithmetic operations without consuming limited CLB logic.
This lecture reviews the internals of the 7 Series DSP.

## Reading

  * [DSP Guide](https://docs.amd.com/v/u/en-US/ug479_7Series_DSP48E1)
    * Chapter 1: DSP48E1 Slice Overview
    * Chapter 2: DSP48E1 Slice Architecture

## Key Concepts

  * Be able to interpret and understand the various DSP architecture diagrams
  * Understand the various operation combinations of the DSP
  * Understand what the SIMD mode is and how it is different from the conventional mode
  * How to infer a multiplier from HDL
  * The purpose of a barrel shifter
  * Understand the internal pipelining of the multiplier
  * The purpose of the pre-adder
  * The purpose of the pattern detect module
