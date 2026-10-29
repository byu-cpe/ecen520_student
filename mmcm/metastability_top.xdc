##################################################################################
#
#  Filename: metastability_top.xdc
#
#  Author: Mike Wirthlin
#
#  Class: ECEN 520
#
#  Description:
#    Constraints for the metastability_top design (Nexys4 DDR board).
#
##################################################################################

# Configuration settings
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

##################################################################################
# Pins
##################################################################################

# Clock
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK100MHZ}];

# Reset and buttons
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { CPU_RESETN }];
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }];
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }];
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }];

# Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { SW[0] }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { SW[1] }];
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { SW[2] }];

# LEDs
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }];

# Seven segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { CA }];
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { CB }];
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { CC }];
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { CD }];
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { CE }];
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { CF }];
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { CG }];
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { DP }];
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];

# Asynchronous inputs and outputs are not timed
set_false_path -from [get_ports { CPU_RESETN BTNU BTND BTNL BTNR SW[*] }]
set_false_path -to [get_ports { LED[*] AN[*] CA CB CC CD CE CF CG DP }]

##################################################################################
# Metastability detector
##################################################################################

# Asynchronous data clock: the STARTUPE2 internal configuration oscillator
# (CFGMCLK, nominally 65 MHz). This clock is unrelated to all other clocks.
create_clock -name clk_cfg -period 15.385 [get_pins startup_inst/CFGMCLK]

# CFGMCLK toggle -> sampling flip-flop A (intentionally asynchronous)
set_max_delay -datapath_only 2.0 -from [get_cells data_tog_reg] -to [get_cells ff_a_reg]

# A (clk_a) -> B (clk_b): intentionally violates timing; keep the route short
set_max_delay -datapath_only 1.0 -from [get_cells ff_a_reg] -to [get_cells ff_b_reg]

# B (clk_b) -> B2 (clk_a): Vivado does not know about the dynamic phase shift
set_max_delay -datapath_only 2.0 -from [get_cells ff_b_reg] -to [get_cells ff_b2_reg]

# Measurement results (clk_a) -> result registers (clk): toggle handshake
set_max_delay -datapath_only 5.0 -from [get_cells snap_tog_reg] -to [get_cells {snap_sync_reg[0]}]
set_max_delay -datapath_only 10.0 \
  -from [get_cells {err_hold_reg[*] trans_hold_reg[*]}] \
  -to   [get_cells {err_count_reg[*] trans_count_reg[*]}]

# CDC waiver for the intentionally unsynchronized detector crossings
create_waiver -type CDC -id {CDC-1} -user "ecen520" \
  -to [get_pins {ff_a_reg/D ff_b_reg/D ff_b2_reg/D}] \
  -description "Metastability detector: intentionally unsynchronized crossings"

# Keep the detector flip-flops close together so the results are repeatable
# between builds
create_pblock pblock_meta
add_cells_to_pblock pblock_meta [get_cells {ff_a_reg ff_b_reg ff_c_reg ff_b2_reg}]
resize_pblock pblock_meta -add {SLICE_X50Y50:SLICE_X51Y51}
