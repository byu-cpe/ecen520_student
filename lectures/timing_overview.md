
# Timing Overview

This lecture will review the fundamental principles of digital timing that were taught in previous digital design courses.

## Reading

* Section 8.6 from [RTL Hardware Design Using VHDL](http://search.lib.byu.edu/byu/record/sfx.3578786?holding=i9vahb2m4z7qvbf3)
* Chapters 13 and 15 from [Dr. Nelson's](https://www.amazon.com/Designing-Digital-Systems-SystemVerilog-v2-1-ebook/dp/B091BBVG4C/ref=sr_1_1?crid=3TUDSUSI1BURK&keywords=Designing+Digital+Systems+With+SystemVerilog+%28v2.1%29&qid=1662573889&s=digital-text&sprefix=designing+digital+systems+with+systemverilog+v2.1+%2Cdigital-text%2C89&sr=1-1) ECEN 220 textbook
* Sequential Timing (Dr. Nelson - see Learning Suite)
* Hold Time (Dr. Nelson - see Learning Suite)

## Key Concepts

* Operation of D flip-flop and latch
  * Different clock edges, reset types
* Flip Flop Timing Parameters (including max and min)
  * t_setup, t_hold, t_clk-to-q 
* Setup time analysis (when to use max and min)
  * Setup time constraints
  * Resolving setup time violations
* Hold time analysis
  * Hold time constraint for path
  * Hold time violations
* Evaluate timing of simple sequential circuits (With and without next state logic)
* Methods for addressing setup time and hold time problems
* Clock Jitter

**Reference**

  * [Timing Lecture Slides](https://github.com/byu-cpe/ECEN_620/blob/main/docs/lecture_slides/arithmetic.pdf) (clock jitter, timing analysis using Xilinx reports)
  * [Xilinx Timing Constraints](https://docs.xilinx.com/v/u/2018.3-English/ug903-vivado-using-constraints)
  * [Xilinx Design Analysis and Closure Techniques](https://www.xilinx.com/content/dam/xilinx/support/documentation/sw_manuals/xilinx2021_1/ug906-vivado-design-analysis.pdf)
   