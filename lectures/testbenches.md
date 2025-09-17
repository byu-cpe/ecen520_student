# SystemVerilog Testbenches

Testbenches are an essential part of validating digital design systems.
In this lecture we will discuss the purpose of testbenches and the general structure of a simple testbench.

**Reading**
  * Chapter 1 of [System Verilog for Verification](https://lib.byu.edu/search/byu/record/cat.3659047.item.31197227929699?holding=9mng3ggqdhk9ykw0). Download this pdf from the library as we will use it later in the semester. Note that you have to authenticate to the BYU library, look to the left for "Holdings", click on one of the springer.com E-book links, then click on the springer.com link to take you to the springer.com website for the download. 
  * [Stephen Edwards Verilog Slides (48-56)](http://www.cs.columbia.edu/~sedwards/classes/2005/languages-summer/verilog.pdf)
  <!-- * Chapter 27 from Bren'ts new book -->

**Key Concepts**
  * Difference between tcl scripts and Verilog behavioral testbenches
  * Discrete time simulation model in Verilog (use of `#` operator)
  * Essential components of a testbench
  * initial block and how it differs from always block
  * How to use basic system functions: `$display`, `$time`, `$random`, `$timeformat`, etc.
  * How to create a basic testbench 

**Resources**
  * [ECEN 220 Testbench Review](http://ecen220wiki.groups.et.byu.net/resources/tool_resources/testbenches/)
  * ChipVerify summary of [display](https://www.chipverify.com/verilog/verilog-display-tasks), 
  * [Verilog 95 Testbench Lecture Slides](https://github.com/byu-cpe/ECEN_620/blob/main/docs/lecture_slides/verilog95_testbench.pdf)
 