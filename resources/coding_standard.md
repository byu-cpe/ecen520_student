# ECEN 520 Coding Standard

Like software, coding your RTL with an appropriate style will make it easier for you to maintain your code, for others to understand your code, and for grading of your code.
You will be required to follow these standards for all assignments submitted for this class. 
This page summarizes the coding requirements for all HDL code generated for this class.
The coding standard is progressive meaning that additional levels of coding standard will be required as we progress through the class.
Each assignment will indicate which level of the coding standard is required.
These standards are based loosely on the [ECEN 320](https://ecen220wiki.groups.et.byu.net/03-coding-standard/) coding standards but are adapted for this class.

## Level 1

These standards are required for **all** assignments.

  * **Module File**
    * Create one file for each module you are creating. Do not put two or more modules in a single file (no matter which language you are coding in)
    * The name of the file must match the name of the module/entity you are creating (i.e., use a file named tx.sv for a module named tx)
  * **Declarations**
    * All signals, variables, and parameters should be declared at the beginning of the module or block.
    * Use meaningful names for all declarations to improve code readability.x
  * **Comments**
    * File header: Every HDL file should have a file header as a comment at the top of the file that includes *each* the following:
      * Name of module
      * Your name
      * Class
      * Date 
      * Brief description (at least one sentence)
    * A short comment is required for every `always` block (or process in VHDL) as well as `initial` blocks
    * A short comment is required for every module instantiated in your design
    * A short comment is required for every generate statement in your design
  * **Magic Numbers**
    * Do not use "Magic Numbers" embedded in your code. Instead, define a constant with a meaningful name and use the constant. Exceptions to this include the following:
       * Using the constant '1' or '0'.
       * Using constants with a delay value (i.e., #10)
  * **Formatting**
    * Indentation. Your module should be properly formatted such that the indentation matches the proper scope. 
    * Sometimes editors will insert a mix of tabs/spaces. Make sure that your code is properly indented when viewed within GitHub

## Level 2

Implement the standards for Level 1 and the following additional standards:

  * Synchronous Blocks (always/process blocks that generate synchronous circuits)
    * Reset clause: by default, all synchronous blocks should have a reset clause. If a reset is not needed, provide a comment indicating why a reset is not needed.
      * The reset clause must be the first clause in the block.
      * All other logic should be in the 'else' portion of the first, initial reset clause. This 'else' clause should not have any logic in it (i.e., reset logic in first clause, all other logic in else clause)
      * There should be only one reset clause in the block (if a reset is used). 
      * All signals that use a reset in a synchronous block must use the same style of reset (i.e., all use synchronous or all use asynchronous - no mixing of the two in the same block)
    * Synchronous always blocks should be limited to related signals. Do not create one big synchronous block with all synchronous signals of the module.
    * Use non-blocking assignment statements in synchronous blocks
    * Sensitivity Lists:
      * The only signals in the sensitivity list should be clocks and rests (and no resets for synchronous resets)
 * Combinational process blocks (VHDL): only place the sensitive signals in the sensitivity list
  * Combinational always_comb: Use blocking statements in always_ff
  * Case statements: cover all cases in a case statement
* State machines:
  * Provide a comment at the start of the state machine clearly indicating the code below is a state machine.
  * Group all blocks associated with a state machine adjacent to each other (i.e., state registers, outputs, input forming logic, etc.). 
  * Provide a short comment for *every* state where the logic for the state is described (i.e., for each case in a case statement)
 
## Level 3 

Implement the standards for Level 2 and the following additional standards:

  * Functions and tasks:
    * Provide a comment for every function and task
    
## Git Repository Standards

In addition to coding standards, you will be required to follow several simple standards for managing your assignment repositories.
The repository organization for all assignments must conform to the following:

* Create a `.gitignore` for your assignment (see [here](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files) for a tutorial on `.gitignore` files)
   * You should ignore all temporary files created as part of your build/simulation process
   * You may create a higher level `.gitignore` to include common ignore rules (no assignment-level `.gitignore` is needed if your higher level ignore file covers all the cases of the assignment)
* You should not include any temporary build or project files (assignments submitted with large intermediate project files will receive a significant assignment penalty). Be carefull when using the `git add` command to avoid adding unnecessary files (i.e., do not just add full directories. Add individual files as needed).
* You should include a makefile that has a `make clean` rule. Executing this rule should clean the assignment directory of all intermediate, ignored files.
   * Make sure you use the `-f` flag in your `rm` command for `make clean` to allow the command to run if the files do not exist. This will allow running the command if the files do not exist.
