# Synthesis script

# Load top-level design and constraints
read_verilog -sv ddr_top.sv
read_xdc ddr_top.xdc 

# See the following for synthesis
# ddr/proj/mig_7series_0_ex/mig_7series_0_ex.runs/synth_1/example_top.tcl
# And the following for implementation
# ddr/proj/mig_7series_0_ex/mig_7series_0_ex.runs/impl_1/example_top.tcl

# read_ip -quiet mig_7series_0/mig_7series_0.xci
# set_property used_in_implementation false [get_files -all /home/wirthlin/ee620/520-assignments-wirthlin/ddr/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0_ooc.xdc]
# set_property used_in_implementation false [get_files -all /home/wirthlin/ee620/520-assignments-wirthlin/ddr/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc]


read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0.v
 read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0_mig.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_std.v
   read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_mc.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_rank_common.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_common.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_state.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_col_mach.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v
     read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v
       read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_top.v

        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v
         read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v
   read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_top.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v

read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_arb_select.v

# #read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v
# #read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v

read_xdc ./mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc

synth_design -top ddr_top -part xc7a100tcsg324-1 -verbose -debug_log

opt_design
place_design
route_design

report_timing_summary -max_paths 10 -report_unconstrained -file ddr_top_timing_summary_routed.rpt -warn_on_violation
report_utilization -file  ddr_top_utilization_impl.rpt
report_drc -file ddr_top_drc_routed.rpt

write_bitstream -force ddr_top.bit
write_checkpoint -force ddr_top.dcp
