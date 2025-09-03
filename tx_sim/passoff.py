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
    tester = test_suite_520.build_test_suite_520("tx_sim", start_date="09/03/2025", max_repo_files = 20)
    tester.add_required_tracked_files(["tx.sv","tx_sim.png", "tx_sim_long.png"])
    tester.add_Makefile_rule("sim_tx", ["tx.sv"], ["tx_sim.log"])
    tester.add_build_test(repo_test.file_regex_check("tx_sim.log", "Test Passed", 
                                                     "tx testbench Test", error_on_match = False,
                                                     error_msg = "tx testbench failed"))
    tester.add_Makefile_rule("sim_tx_115200_even", ["tx.sv"], ["tx_sim_115200_even.log"])
    tester.add_build_test(repo_test.file_regex_check("tx_sim_115200_even.log", "Test Passed", 
                                                     "tx testbench Test - 115200 even", error_on_match = False,
                                                     error_msg = "tx testbench 115200 even failed"))
    tester.run_tests()

if __name__ == "__main__":
    main()

