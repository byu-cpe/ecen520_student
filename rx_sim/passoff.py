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
    tester = test_suite_520.build_test_suite_520("rx_sim", start_date="09/17/2025", max_repo_files = 25)
    tester.add_required_tracked_files(["rx.sv","sim_rx.png", "sim_rx.do"])

    tester.add_Makefile_rule("sim_rx", ["rx.sv"], ["sim_rx.log", "sim_rx.png"])
    tester.add_build_test(repo_test.file_regex_check("sim_rx.log", "Simulation done with 0 errors", 
                                                     "rx testbench - default parameters", error_on_match = False,
                                                     error_msg = "rx testbench failed"))
    tester.add_Makefile_rule("sim_rx_115200_even", ["rx.sv"], ["sim_rx_115200_even.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_rx_115200_even.log", "Simulation done with 0 errors", 
                                                     "rx testbench - 115200 baud rate, even parity", error_on_match = False,
                                                     error_msg = "rx testbench failed"))
    tester.add_Makefile_rule("synth_rx", ["rx.sv"], ["rx_synth.log"])
    tester.add_Makefile_rule("synth_rx_gray", ["rx.sv"], ["rx_synth_gray.log"])
    tester.add_Makefile_rule("sim_ssd", ["seven_segment8.sv",], ["sim_ssd.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_ssd.log", "ERROR: seven_segment_check:", 
                                                     "SSD Test", error_on_match = True,
                                                     error_msg = "SSD testbench failed"))    
    tester.add_Makefile_rule("synth_ssd", ["seven_segment8.sv"], ["synth_ssd.log"])
    tester.run_tests()

if __name__ == "__main__":
    main()

