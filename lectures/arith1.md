## Digital Arithmetic #1

Binary arithmetic is an essential component of almost every digital system.
Performing binary arithmetic in HDL involves a number of subtleties that must be addressed to operate correctly.
This lecture summarizes the basics of creating proper digital arithmetic HDL using Verilog 2001 (and thus SystemVerilog).

## Reading

* [Signed Arithmetic in Verilog 2001 - Opportunities and Hazards](http://www.tumbush.com/published_papers/Tumbush%20DVCon%2005.pdf)

## Key Concepts

  * Binary representations: ones complement, unsigned, twos-complement
  * Addition/Subtraction with unsigned and twos complement (overflow and overflow detection)
  * Hardware implementations of addition/subtraction
  * Mathematics and hardware implementation of binary Multiplication
    * unsigned/unsigned
    * signed/unsigned and signed/unsigned
    * signed/signed
  * Verilog 95 artihmetic rules
  * Signed artihmetic in Verilog 2001
  * Rules for arithmetic: mismatched types, incomplete size, etc.
