
# Xilinx Clock Resources

In this lecture we will discuss the clock resources available on Xilinx 7-series FPGAs.
We will learn about the global clock routing and how to use the MMCM and PLL primitives.

## Reading

* [Xilinx Clock Resources](https://docs.amd.com/v/u/en-US/ug472_7Series_Clocking)
  * Chapter 1 (pages 13-15)
  * Chapter 2 (pages 29-31,36-41,50-51)
  * Chapter 3 (pages 66-86)
    * Figure 3-2
## Key Concepts

  * Understand the key constraints on the clocking network (what must it accomplish)
  * Global clock network (Clock tree, clock drivers: bufg, clock I/O inputs)
  * Big picture understanding of the MMCM module (what it does and how it is organized)
  * Understand how to configure an MMCM to generate clocking signals (given a block diagram of the MMCM, decide what the values of D, M, and O should be)
  * BUFGCTRL, BUFG, BUFIO primitives
  * Understand the major components of the MMCM
    * MMCM Use Models (Figures 3-11,3-13,3-14,3-15,3-16)
  * Know how to use the MMCM in a variety of situations: clock dejitter/synthesizer, clock network deskew, zero delay buffer, etc.
  * Understand how to use multiple cascading MMCMs and how to use the locked signal for resets

**Reference**
  * [Artix 7 Data Sheet (timing)](./docs/reference/ds181_Artix_7_Data_Sheet.pdf) (See table 37 for MMCM timing)
  * [Spartan 3 DCM App Note](./docs/reference/xapp462.pdf)
