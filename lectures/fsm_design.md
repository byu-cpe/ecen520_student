# Finite State Machine (FSM) Design

In this lecture we will discuss proper approaches for designing Finite State Machines (FSMs) in SystemVerilog.
We will discuss several styles of FSM coding and discuss their relatively advantages and disadvantages.

## Reading

* Chapter 10 sections 1-5 from [RTL Hardware Design Using VHDL](http://search.lib.byu.edu/byu/record/sfx.3578786?holding=i9vahb2m4z7qvbf3) book (ignore the VHDL code examples for now).
    * Read 10.1 carefully
    * 10.2.1 should be review - just scan through this and make sure you understand the key concepts
    * 10.2.2 introduces a new way of representing FSMs. Read this carefully (there are a lot of figures so the pages go quickly)
    * Don't worry about 10.3. We will discuss timing in greater detail in another unit.
    * 10.4: Make sure you understand the difference between Mealy and Moore machines
    * 10.5: There is a lot of VHDL in this section that you can ignore. The key point to understand is what a "segment" is how to code a four segment FSM, a two segment FSM (10.5.2), and a one segment FSM (10.5.4). Understand the problems with a one segment FSM. Ignore 10.5.5.
* Review chapters 21-23 from [Dr. Nelson's](https://www.amazon.com/Designing-Digital-Systems-SystemVerilog-v2-1-ebook/dp/B091BBVG4C/ref=sr_1_1?crid=3TUDSUSI1BURK&keywords=Designing+Digital+Systems+With+SystemVerilog+%28v2.1%29&qid=1662573889&s=digital-text&sprefix=designing+digital+systems+with+systemverilog+v2.1+%2Cdigital-text%2C89&sr=1-1) ECEN 220 textbook (this is not required but will help review how to code an FSM in Verilog)

## Key Concepts

* Three different components of an FSM (IFL, OFL, Current State)
* Moore and Mealy state machines
* What does the term "component" mean in terms of RTL design
* The difference between "Moore" and "Mealy" outputs
* The key components of an FSM: State register, next state logic, Moore output logic, Mealy output logic
* The different styles of FSM design
    * 1,2,3 and 4 segment style
    * Mapping of FSM components to different segments (pros and cons of different styles)
    * Pros and cons of various FSM segment coding style
* Implications of defining FSM outputs in a registered HDL block

## Resources


