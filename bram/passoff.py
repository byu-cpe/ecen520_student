#!/usr/bin/python3

# Manages file paths
import pathlib
import sys

sys.dont_write_bytecode = True # Prevent the bytecodes for the resources directory from being cached
# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent  / 'resources'
sys.path.append( str(resources_path) )

import test_suite_520
import repo_test

def main():
    tester = test_suite_520.build_test_suite_520("bram", start_date="10/17/2025", max_repo_files = 30)
    tester.add_Makefile_rule("sim_bram_fifo", ["bram_fifo.sv", "bram_fifo_tb.sv"], ["sim_bram_fifo.log"])
    tester.add_Makefile_rule("sim_bram_rom", ["bram_rom.sv", "bram_rom_tb.sv"], ["sim_bram_rom.log", "fight_song.mem"])
    tester.add_Makefile_rule("sim_bram_rom_moroni_10", ["bram_rom.sv", "bram_rom_tb.sv"], 
                            ["sim_bram_rom_moroni_10.log", "moroni_10.mem"])
    tester.add_Makefile_rule("synth_bram_fifo", ["bram_fifo.sv"], ["synth_bram_fifo.log", "synth_bram_fifo.dcp"])
    tester.add_Makefile_rule("synth_bram_rom", ["bram_rom.sv"], ["synth_bram_rom.log", "synth_bram_rom.dcp"])
    tester.run_tests()

if __name__ == "__main__":
    main()

