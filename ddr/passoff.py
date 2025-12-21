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
    tester = test_suite_520.build_test_suite_520("ddr", start_date="12/5/2025", max_repo_files = 40)
    # IP directory rules:
    tester.add_Makefile_rule("make_ip", [], ["./ip/mig_7series_0/mig_7series_0.xci"])
    tester.add_Makefile_rule("make_example", [], ["./ip/example_design/mig_7series_0_ex/mig_7series_0_ex.xpr"])
    tester.add_Makefile_rule("make_example_bit", [], ["./ip/example_nexys4_top.bit"])
    # DDR directory rules
    tester.add_Makefile_rule("sim_ddr_uart_top", [], ["sim_ddr_uart_top.log"])
    tester.add_Makefile_rule("gen_bit", ["ddr_top.sv"], ["ddr_fifo_top.bit","ddr_fifo_top.log",
                                             "timing_ddr_fifo_top.rpt","utilization_ddr_fifo_top.rpt"])
    tester.run_tests()

if __name__ == "__main__":
    main()

