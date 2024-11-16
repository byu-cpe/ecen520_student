# CLB Architecture

The configuration logic block (CLB) is the key for programmable logic within a Xilinx FPGA.
This lecture reviews the details of the 7 Series CLB and describes how a variety of logic functions can be mapped to the CLB architecture.

**Reading**

  * [CLB Guide](https://docs.amd.com/v/u/en-US/ug474_7Series_CLB)

**Reference**

**Key Concepts**

Note that you are not expected to memorize any details about the CLB architecture.
Instead, you are expected to understand the key principles of the CLB and use the CLB given the appropriate information from the data sheet.

  * Difference between a CLB tile and slice
  * How logic can be implemented in look-up tables
  * Be able to map arbitrary logic to look up tables
  * How multiple LUTs within a CLB can be combined to create wider logic functions
  * Use of multiplexers to create wide multiplexing functions
  * Purpose of a carry chain and how it speeds up carry logic
  * What is distributed RAM and how does it operate in the context of a LUT/CLB
  * What is a SRL and how does it operate in the context of a LUT/CLB
