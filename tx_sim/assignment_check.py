#!/usr/bin/python3

# Manages file paths
import pathlib
import sys

# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent / 'resources'
sys.path.append(str(resources_path))

import test_suite_520


def main():
    tester = test_suite_520.build_test_suite_520("tx_sim", min_err_commits=3, max_repo_files=20)
    tester.add_make_test("sim_tx")
    tester.add_make_test("sim_tx_115200_even")
    tester.run_tests()


if __name__ == "__main__":
    main()
