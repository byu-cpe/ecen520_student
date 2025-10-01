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
    tester = test_suite_520.build_test_suite_520("spi_cntrl", start_date="10/03/2025", max_repo_files = 30)
    tester.add_Makefile_rule("sim_spi_cntrl", ["spi_ctrl.sv"], ["sim_spi_cntrl.log"])
    tester.add_build_test(repo_test.file_regex_check("sim_spi_cntrl.log", "Error:<spi_ctrl_tb>", 
                                                     "SPI Control Testbench", error_on_match = True,
                                                     error_msg = "spi_ctrl testbench failed"))    
    tester.add_Makefile_rule("sim_adxl362", ["adxl362_cntrl.sv", "adxl362_cntrl_tb.sv"], ["sim_adxl362.log"])
    tester.add_Makefile_rule("synth_adxl362_cntrl", [], ["synth_adxl362_cntrl.log"])
    tester.run_tests()


if __name__ == "__main__":
    main()

