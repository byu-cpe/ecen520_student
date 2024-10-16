
# Clock Skew

One of the most common sources of timing problems is the introduction of clock skew.
Clock skew occurs when the clocks that arrive at different flip flops are not in phase with each other.
Clock skew introduces subtle timing problems that must be understood and addressed in digital systems.

## Reading

* Dr. Nelson's chapter on clock skew (see Learning Suite)
* Section 16.1-16.3 from [RTL Hardware Design Using VHDL](http://search.lib.byu.edu/byu/record/sfx.3578786?holding=i9vahb2m4z7qvbf3)

## Key Concepts

  * Definition of clock skew and the source of clock skew
  * Implications on both setup time violations and hold time violations when clock skew is present
    * forward and backward clock skew
    * Ability to analyze simple circuits with clock skew (understanding and using equations)
  * Methods for addressing clock skew timing problems
  * Interpret Vivado timing reports for clock skew

## Reference
  * [Clock skew paper](https://github.com/byu-cpe/ECEN_620/blob/main/docs/reference/clockskew_hatamiancash.pdf)

