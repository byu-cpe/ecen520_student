# DDR Memory Interfacing

DRAM is used in most digital systems today.
This lecture reviews how a DRAM functions and the key concepts needed to interface a DRAM device to a digital system.

**Reading**

  * [Micron Data Sheet](https://media.digikey.com/pdf/Data%20Sheets/Micron%20Technology%20Inc%20PDFs/MT47H256M4,128M8,64M16.pdf)
    * Functional Description: Page 10-11
    * Review block diagram: Figure 5
    * Pin assignments: pages 17-18
    * Commands: pages 74-81
  * [XAPP 858](https://docs.amd.com/v/u/en-US/xapp858)
    * Overview: pages 1-9
    * User interface implementation: pages 35-47

**Reference**

* [Introduction to DRAM](https://www.allaboutcircuits.com/technical-articles/introduction-to-dram-dynamic-random-access-memory/)
* [DRAM Command Overview](https://www.allaboutcircuits.com/technical-articles/executing-commands-memory-dram-commands/)
* https://www.techtarget.com/whatis/definition/SRAM-static-random-access-memory#:~:text=SRAM%20(static%20RAM)%20is%20a,performance%20and%20lower%20power%20usage
* http://www.graphics.stanford.edu/courses/cs448a-01-fall/lectures/dram/dram.2up.pdf
* https://www.youtube.com/watch?v=I-9XWtdW_Co (part 1 of DRAM video – nicely done)
* https://www.es.ele.tue.nl/premadona/files/akesson01.pdf
* https://www.systemverilog.io/ddr4-basics
* https://www.electronics-notes.com/articles/electronic_components/semiconductor-ic-memory/dynamic-ram-how-does-dram-work-operation.php
* https://www.techtarget.com/whatis/definition/SRAM-static-random-access-memory#:~:text=SRAM%20(static%20RAM)%20is%20a,performance%20and%20lower%20power%20usage

**Key Concepts**

  * Be able to interpret Figure 5 of the data sheet (i.e., how a dram is organized)
  * Difference between banks, rows, and columns
  * Purpose of all signals on the device
  * DRAM commands: Activate, precharge, refresh, read, write (when and how each command is needed)
  * How to perform single reads or burst reads with the dram
  * How to perform single writes or bursts of writes with the dram

