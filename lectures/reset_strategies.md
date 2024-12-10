
# Reset Strategies


Like clocking, reset signals are a global signal that go to many flip-flops.
The timing of resets is as important as clocking and must be considered as part of the timing closure process.
This lecture will review reset strategies and their timing implications.

## Reading

   * Cummings, SNUG 2002 (cummingssnug2002sj_resets.pdf in Learning Suite)
      * Section 1.0
      * Section 2.0: review Verilog codings styles
      * Section 3.0: Synchronous resets (review verilog styles)
      * Section 4.0: Asynchronous resets (review verilog styles)
      * Section 6.0: Review the reset synchornization techniques
   * Cummings, SNUG 2003 (cummingssnug2003boston_resets.pdf in Learning Suite)
      * Section 1: Read the intro to see comments on previous paper and what is new
      * Section 4.2/4.3: Advantages/disadvantages of synchronous reset
      * Section 5.3/5.4: Advantages/disadvantages of asynchronous reset

## Key Concepts

  * Purpose of a reset signal
  * Use of resets in FPGAs (different ways to reset, preferred reset strategy)
  * RTL implications of resets (not mixing asynchronous/synchronous, proper reset RTL coding)
  * Synchronous vs asynchronous resets (pros and cons of each)
  * Timing implications of reset strategies

## Resources

  * https://www.eetimes.com/how-do-i-reset-my-fpga/