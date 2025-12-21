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
    tester = test_suite_520.build_test_suite_520("spi_download", start_date="10/10/2025", max_repo_files = 30)
    tester.add_required_tracked_files(["clock_pin.png", "bufg.png", "btnr_sync.png"])
    tester.add_Makefile_rule("sim_adxl362_top", ["adxl362_top.sv","adxl362_top_tb.sv"], ["sim_adxl362_top.log"])
    tester.add_Makefile_rule("synth_adxl362_top", [], ["synth_adxl362_top.log", "adxl362_top_synth.dcp"])
    tester.add_Makefile_rule("implement_adxl362_top", ["adxl362_top_synth.dcp"], ["implement_adxl362_top.log", 
                            "adxl362_top.dcp", "adxl362_top.dcp","adxl362_top.bit",
                            "timing_adxl362_top.rpt", "utilization_adxl362_top.rpt", "drc_adxl362_top.rpt"])
    tester.run_tests()

if __name__ == "__main__":
    main()

