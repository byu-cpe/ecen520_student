## AMD Clock Domain Crossing (CDC) IP

Because proper clock domain crossing is so important and yet can be challenging to implement correctly, AMD provides specialized IP cores to assist with this task.
AMD provides a set of IP cores named "CDC" (Clock Domain Crossing) to help designers manage signals that cross between different clock domains.
Using these cores takes out much of the complexity and risk associated with implementing clock domain crossings manually.
This lecture will review the AMD Clock Domain Crossing (CDC) IP and its usage.

## Reading

  * [Clock Domain Crossing](https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Clock-Domain-Crossing) Section of the AMD [UltraFast Design Methodology Guide for FPGAs and SoCs (UG949)](https://docs.amd.com/r/en-US/ug949-vivado-design-methodology) guide.
  * [XPM CDC Generator IP](https://docs.amd.com/r/en-US/pg382-xpm-cdc-generator)

## Key Concepts

  * Understand the different types of CDC circuits and when to use each type
  * Understand the difference between multi-bit and single-bit CDC circuits
  * Be able to instance a XPM_CDC circuit into your design
  * Understand the purpose of the `DEST_SYNC_FF` parameter

