#!/usr/bin/python3

# Start dates for each ECEN 520 assignment, keyed by assignment name (the same
# string passed to build_test_suite_520, which is also the assignment directory
# name and the git submission tag).
#
# UPDATE THESE ONCE PER SEMESTER. This is the only place assignment start dates
# are defined - the individual 'passoff.py' scripts look their date up from here.
#
# Dates are strings in "MM/DD/YYYY" format. The start date marks when an
# assignment officially opens; it is used to prevent early submissions and to
# enforce that students have updated their starter code.
#
# To add a new assignment, add a row here using the same name that the
# assignment's passoff.py passes to build_test_suite_520. An assignment with no
# entry here runs without a start date check (and prints a warning).

START_DATES = {
    "tx_sim":        "09/04/2026",
    "tx_download":   "09/10/2026",
    "rx_sim":        "09/17/2026",
    "rx_download":   "09/25/2026",
    "spi_cntrl":     "10/03/2026",
    "spi_download":  "10/10/2026",
    "bram":          "10/17/2026",
    "bram_download": "10/24/2026",
    "mmcm":          "10/31/2026",
    "axi":           "11/6/2026",
    "microblaze":    "11/21/2026",
    "ddr":           "12/5/2026",
}
