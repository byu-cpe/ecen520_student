# Synthesis script

# Load top-level design and constraints
read_verilog -sv example_nexys4_top.v
read_xdc example_nexys4_top.xdc 

# read the DDR IP files
read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0.v
 read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0_mig.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v
  # added for axi memory controller
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v
          read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v
          read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v
        read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v
    read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_top.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v
      read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v
# Traffic generator files
read_verilog ./example_design/mig_7series_0_ex/imports/mig_7series_v4_2_axi4_tg.v
  read_verilog ./example_design/mig_7series_0_ex/imports/mig_7series_v4_2_axi4_wrapper.v
  read_verilog ./example_design/mig_7series_0_ex/imports/mig_7series_v4_2_tg.v
  read_verilog ./example_design/mig_7series_0_ex/imports/mig_7series_v4_2_data_gen_chk.v
  read_verilog ./example_design/mig_7series_0_ex/imports/mig_7series_v4_2_cmd_prbs_gen_axi.v
  # Not sure what is needed below:
#  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_std.v
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
  read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v
read_verilog ./mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_2_arb_select.v

read_xdc ./mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc

synth_design -top example_nexys4_top -part xc7a100tcsg324-1 -verbose -debug_log

opt_design
place_design
route_design

report_timing_summary -max_paths 10 -report_unconstrained -file example_nexys4_top_timing_summary_routed.rpt -warn_on_violation
report_utilization -file  example_nexys4_top_utilization_impl.rpt
report_drc -file example_nexys4_top_drc_routed.rpt

write_bitstream -force example_nexys4_top.bit
write_checkpoint -force example_nexys4_top.dcp
