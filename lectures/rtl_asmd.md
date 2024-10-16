# RTL Design using ASM Diagrams and Finite State Machine-Datapath (FSM-D)

In this lecture we will introduce you to the ASM Diagrams (ASMD) which provide a graphical way of representing complex RTL designs.
We will describe how the diagrams can be used to define an RTL design and how you can convert the diagram to RTL.
<!--
Designing a digital system with a FSM is often not enough and the digital system requires other syncronous logic with it (such as counters, and registers).
A new formalism called a Finite State Machine-Datapath (FSMD) is used to describe a digital system that includes both a FSM and a datapath.
FSMDs are defined using "Algorithmic State Machine" or ASM diagrams.
You will learn about the ASM diagram and how to convert ASM diagrams to FSMDs.
-->

## Reading
  * Chapter 11 sections 1-4 [RTL Hardware Design Using VHDL](http://search.lib.byu.edu/byu/record/sfx.3578786?holding=i9vahb2m4z7qvbf3). 
    * 11.1 - scan
    * 11.2 - Read carefully (this is the meat of the concept)
    * 11.3 - scan briefly through the examples (ignore the VHDL)
    * 11.4 - Pay attention to the Mealy controlled RT operation

## Key Concepts
  * Understand what a "RT" operation is
    * How to write it using the arrow syntax
    * What does it mean when implemented in a circuit
  * Understand the difference between a FSM and a ASMD
  * Understand the meaning of the left arrow operator and its difference with the <= operator 
  * How a set of RT operations can be translated into a digital circuit
  * Two parts of a FSM-D (data path and control path)
  * Understand what a ASMD chart is and how to convert it to RTL
  * Performing multiple RT operations for a variable
  * Adding RT operations within ASM diagrams
  * Converting ASMD diagrams into RTL
  

