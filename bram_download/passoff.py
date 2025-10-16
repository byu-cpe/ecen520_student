#!/usr/bin/python3

import pathlib
import sys

sys.dont_write_bytecode = True # Prevent the bytecodes for the resources directory from being cached
# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent  / 'resources'
sys.path.append( str(resources_path) )

import test_suite_520
import repo_test

def main():
    tester = test_suite_520.build_test_suite_520("bram_download", start_date="10/24/2025", max_repo_files = 30)
    tester.add_Makefile_rule("sim_bram_top", ["bram_top.sv","bram_top_tb.sv"], ["sim_bram_top.log"])
    tester.add_Makefile_rule("synth_bram_top", [], ["synth_bram_top.log", "bram_top_synth.dcp"])
    tester.add_Makefile_rule("implement_bram_top", ["bram_top_synth.dcp"], ["implement_bram_top.log", 
                                                                            "bram_top.dcp", "bram_top.dcp",
                            "timing_bram_top.rpt", "utilization_bram_top.rpt"])
    tester.run_tests()

if __name__ == "__main__":
    main()

