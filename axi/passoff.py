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
    tester = test_suite_520.build_test_suite_520("axi", start_date="11/6/2025", max_repo_files = 30)
    tester.add_Makefile_rule("sim_fifo", ["fifo.sv", "fifo_tb.sv"], ["sim_fifo.log"])
    tester.add_Makefile_rule("synth_fifo", ["fifo.sv"], ["synth_fifo.log",])
    tester.add_Makefile_rule("build_vip", [], ["build_ip.log",
                                               "./ip/axi_vip_0/sim/axi_vip_0_pkg.sv",
                                               "./ip/axi_vip_0/sim/axi_vip_0.sv"])
    tester.add_Makefile_rule("sim_axi_uart", ["axi_uart.sv", "axi_uart_tb.sv"], ["sim_axi_uart.log"])
    tester.run_tests()

if __name__ == "__main__":
    main()

