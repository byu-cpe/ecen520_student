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
    tester = test_suite_520.build_test_suite_520("microblaze", start_date="11/21/2025", max_repo_files = 50)
    tester.add_Makefile_rule("build_demo_io", [], ["./demo_io/demo_io.xsa"])
    tester.add_Makefile_rule("build_demo_io_vitis", [], ["./demo_io/vitis/demo_io/build/demo_io.elf"])
    tester.add_Makefile_rule("build_mb_uart", [], ["./mb_uart/mb_uart.xsa"])
    tester.add_Makefile_rule("build_mb_uart_vitis", [], ["./mb_uart/vitis/mb_uart/build/mb_uart.elf"])
    tester.add_Makefile_rule("build_custom_vitis", [], ["./mb_uart/vitis/custom/build/custom.elf"])
    tester.run_tests()

if __name__ == "__main__":
    main()

