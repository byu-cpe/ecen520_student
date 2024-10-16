## Clock domain crossing

Digital systems typically have multiple groups of circuits that operate at different clock frequencies.
These groups of circuits must often communicate with each other and special techniques are required to do so.
This lecture will discuss the handshaking and clock domain crossing approaches.

## Reading

  * 16.6-16.9 from [RTL Hardware Design Using VHDL](http://search.lib.byu.edu/byu/record/sfx.3578786?holding=i9vahb2m4z7qvbf3) (ignore the VHDL code)

## Key Concepts

  * Techniques for synchronizing a single-bit signal across different clock domains (fast to slow and slow to fast)
  * Understand rules for synchronizing properly across clock domains (see slide 47)
  * Understand the need for handshaking
  * Four phase protocol approach
  * Two phase protocol approach
  * Single phase protocl approach (and its limitations)
  * FIFos and their purpose

