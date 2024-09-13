# SystemVerilog Test-benches

Test-benches are an essential part of validating digital design systems.
In this lecture we will discuss the purpose of test-benches and the general structure of a simple testbench.

**Reading**

* Chapter 1 of [System Verilog for Verification](https://search.lib.byu.edu/byu/record/cram.101.978-0-387-76530-3.1?holding=150kxz8ppcvbzc2x). Download this pdf from the library as we will use it later in the semester.
* [Stephen Edwards Verilog Slides (48-56)](http://www.cs.columbia.edu/~sedwards/classes/2005/languages-summer/verilog.pdf)

**Key Concepts**

* Difference between tcl scripts and Verilog behavioral test-benches
* Discrete time simulation model in Verilog (use of `#` operator)
* Essential components of a testbench
* initial block and how it differs from always block
* How to use basic system functions: `$display`, `$time`, `$random`, `$timeformat`, etc.
* How to create a basic testbench

**Resources**

* [ECEN 220 Testbench Review](http://ecen220wiki.groups.et.byu.net/resources/tool_resources/testbenches/)
* ChipVerify summary of [display](https://www.chipverify.com/verilog/verilog-display-tasks),
* [Verilog 95 Testbench Lecture Slides](https://github.com/byu-cpe/ECEN_620/blob/main/docs/lecture_slides/verilog95_testbench.pdf)
