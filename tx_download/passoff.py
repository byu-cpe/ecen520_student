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
    tester = test_suite_520.build_test_suite_520("tx_download", start_date="09/10/2025", max_repo_files = 30)
    tester.add_required_tracked_files(["debounce.sv", "debounce_sim.do", "debounce_sim.png",])
    tester.add_Makefile_rule("sim_debouncer", ["debounce.sv"], ["sim_debouncer.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_debouncer.log", "WAIT_TIME_US=50 with 0 errors", 
                                                     "Debouncer Test - 50us", error_on_match = False,
                                                     error_msg = "Debouncer failed"))
    tester.add_Makefile_rule("sim_debouncer_10ms", ["debounce.sv"], ["sim_debouncer_10ms.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_debouncer_10ms.log", "WAIT_TIME_US=10000 with 0 errors", 
                                                     "Debouncer Test - 10ms", error_on_match = False,
                                                     error_msg = "Debouncer failed"))
    tester.add_Makefile_rule("sim_tx_top_tb", [], ["sim_tx_top_tb.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_tx_top_tb.log", "BAUD 19200 Simulation Complete - No Errors", 
                                                     "tx testbench Test - 19200 even", error_on_match = False,
                                                     error_msg = "top testbench failed"))
    tester.add_Makefile_rule("sim_tx_top_tb_115200_even", [], ["sim_tx_top_tb_115200_even.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_tx_top_tb_115200_even.log", "BAUD 115200 Simulation Complete - No Errors", 
                                                     "tx testbench Test - 115200 even", error_on_match = False,
                                                     error_msg = "top testbench failed"))
    tester.add_Makefile_rule("synth", ["tx_top.sv"], ["synth.log", "tx_top_synth.dcp"])
    tester.add_Makefile_rule("implement", ["tx_top_synth.dcp"], ["implement.log", "tx_top.bit", 
                                            "tx_top.dcp", "utilization.rpt", "timing.rpt"])
    tester.add_Makefile_rule("synth_115200_even", ["tx_top.sv"], ["synth_115200_even.log", "tx_top_115200_even_synth.dcp"])
    tester.add_Makefile_rule("implement_115200_even", ["tx_top_115200_even_synth.dcp"], ["implement_115200_even.log", "tx_top.bit", 
                                            "tx_top.dcp", "utilization_115200_even.rpt", "timing_115200_even.rpt"])
    tester.run_tests()


if __name__ == "__main__":
    main()

