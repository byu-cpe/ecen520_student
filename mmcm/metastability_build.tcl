##################################################################################
#
#  Filename: metastability_build.tcl
#
#  Author: Mike Wirthlin
#
#  Class: ECEN 520
#
#  Description:
#    Builds the metastability_top design (synthesis, implementation, reports,
#    and bitstream). Run from the mmcm directory:
#      vivado -mode batch -source metastability_build.tcl -log metastability_build.log
#
#    Update the paths below if your seven segment display or debouncer files
#    are in a different location.
#
##################################################################################

set seven_segment_file ../rx_sim/seven_segment8.sv
set debounce_file ../tx_download/debounce.sv

source ../resources/messages.tcl

# Synthesis
read_verilog -sv metastability_top.sv $seven_segment_file $debounce_file
read_xdc metastability_top.xdc
synth_design -top metastability_top -part xc7a100tcsg324-1
write_checkpoint -force metastability_top_synth.dcp

# Implementation
opt_design
place_design
route_design

# Reports
report_utilization -file utilization_metastability_top.rpt
report_clock_interaction -file clock_interaction_metastability_top.rpt
report_cdc -details -file cdc_metastability_top.rpt
report_timing_summary -max_paths 2 -report_unconstrained -file timing_metastability_top.rpt -warn_on_violation

# Bitstream
write_checkpoint -force metastability_top.dcp
write_bitstream -force metastability_top.bit
