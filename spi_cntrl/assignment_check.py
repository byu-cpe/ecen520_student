#!/usr/bin/python3

# Manages file paths
import pathlib
import sys

# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent / 'resources'
sys.path.append(str(resources_path))

import test_suite_520


def main():
    tester = test_suite_520.build_test_suite_520("spi_cntrl", min_err_commits=5, max_repo_files=20)
    tester.add_make_test("sim_spi_cntrl")
    tester.add_make_test("sim_spi_cntrl_100")
    # tester.add_make_test("synth_spi_cntrl")
    tester.add_make_test("sim_adxl362")
    # tester.add_make_test("synth_adxl362_cntrl")
    tester.run_tests()


if __name__ == "__main__":
    main()
