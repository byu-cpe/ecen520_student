# Debugging Ideas

When your downloaded circuit doesn't work but your simulations seem to work, consider these ideas for debugging:

1. Simulation
    * Make sure simulation is working correctly. This may seem obvious based on the assumptions above but double check that the simulation is working as you suggest.
    * It is much easier to resolve problems in the simulation than in the hardware so avoid just skimming through the simulation.
2. Synthesis
    * The synthesis step is an important place to find problems with a design.
    * Carefully review the synthesis report. Look for any warnings or errors and address/remove them. Even simple warnings may be a symptom of a larger problem and it is best to remove them all.
    * You may want to try generating a bitstream by running synthesis with optimization turned off
3. Implementation
    * The implementation step is another place where errors can creep in your design.
    * Review the "Pads report" to make sure that the pins have been assigned correctly. It is possible that you assigned the incorrect pins to the wrong signals. This check will eliminate this possibilty.
    * Check the timing report and make sure that all your timing constraints have been met
4. Download
    * Make sure that the correct bitstream is being downloaded to the FPGA. It is possible that you are downloading an old bitstream that does not match the current simulation.
    * Carefully note the behavior or your circuit and try to observe symptoms or partial symptoms that may give a clue to the cause of hte problem. "It doesn't work" is not a helpful description of the problem.
5. Internal Logic Analyzer
    * The internal logic analyzer is a powerful tool for debugging your circuit. It allows you to observe the internal signals of your circuit without having to add additional pins to the FPGA.
