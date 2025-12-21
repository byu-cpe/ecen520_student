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
    tester = test_suite_520.build_test_suite_520("rx_download", start_date="09/25/2025", max_repo_files = 30)
    tester.add_Makefile_rule("sim_rxtx_top", ["rxtx_top_tb.sv"], ["sim_rxtx_top.log"])
    tester.add_Makefile_rule("sim_rxtx_top_115200_even", ["rxtx_top_tb.sv"], ["sim_rxtx_top_115200_even.log"])
    tester.add_Makefile_rule("synth_rxtx_top", ["rxtx_top.sv"], ["synth_rxtx_top.log", "rxtx_top_synth.dcp"])
    tester.add_Makefile_rule("synth_rxtx_top_115200_even", ["rxtx_top.sv"], ["synth_rxtx_top_115200_even.log",
                                                                            "rxtx_top_115200_even_synth.dcp"])
    tester.add_Makefile_rule("implement_rxtx_top", ["rxtx_top_synth.dcp"], ["synth_rxtx_top.log", "rxtx_top.dcp", "rxtx_top.bit"])
    tester.add_Makefile_rule("implement_rxtx_top_115200_even", ["rxtx_top_115200_even_synth.dcp"], 
                             ["synth_rxtx_top_115200_even.log", "rxtx_top_115200_even.dcp", "rxtx_top_115200_even.bit"])
    tester.run_tests()


if __name__ == "__main__":
    main()

