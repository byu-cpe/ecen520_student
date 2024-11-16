onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Test Bench}
add wave -noupdate /ddr_top_tb/sys_rst_n
add wave -noupdate /ddr_top_tb/sys_clk_i
add wave -noupdate /ddr_top_tb/init_calib_complete
add wave -noupdate /ddr_top_tb/btnc
add wave -noupdate /ddr_top_tb/btnu
add wave -noupdate /ddr_top_tb/btnr
add wave -noupdate /ddr_top_tb/btnl
add wave -noupdate /ddr_top_tb/led
add wave -noupdate /ddr_top_tb/sw
add wave -noupdate -divider Top
add wave -noupdate /ddr_top_tb/u_ip_top/CLK100MHZ
add wave -noupdate /ddr_top_tb/u_ip_top/clk200
add wave -noupdate /ddr_top_tb/u_ip_top/clk200_reset
add wave -noupdate /ddr_top_tb/u_ip_top/clk_ui
add wave -noupdate /ddr_top_tb/u_ip_top/clk_ui_rst
add wave -noupdate /ddr_top_tb/u_ip_top/btnu_os
add wave -noupdate /ddr_top_tb/u_ip_top/btnc_os
add wave -noupdate /ddr_top_tb/u_ip_top/btnl_os
add wave -noupdate /ddr_top_tb/u_ip_top/btnr_os
add wave -noupdate /ddr_top_tb/u_ip_top/sw_addr
add wave -noupdate /ddr_top_tb/u_ip_top/app_addr
add wave -noupdate /ddr_top_tb/u_ip_top/app_cmd
add wave -noupdate /ddr_top_tb/u_ip_top/app_cmd_next
add wave -noupdate /ddr_top_tb/u_ip_top/app_en
add wave -noupdate /ddr_top_tb/u_ip_top/app_rd_data
add wave -noupdate /ddr_top_tb/u_ip_top/app_rd_data_end
add wave -noupdate /ddr_top_tb/u_ip_top/app_rd_data_valid
add wave -noupdate /ddr_top_tb/u_ip_top/app_rdy
add wave -noupdate -radix hexadecimal /ddr_top_tb/u_ip_top/app_wdf_data
add wave -noupdate -radix hexadecimal /ddr_top_tb/u_ip_top/app_wdf_data_next
add wave -noupdate /ddr_top_tb/u_ip_top/app_wdf_end
add wave -noupdate /ddr_top_tb/u_ip_top/app_wdf_mask
add wave -noupdate /ddr_top_tb/u_ip_top/app_wdf_mask_next
add wave -noupdate /ddr_top_tb/u_ip_top/app_wdf_rdy
add wave -noupdate /ddr_top_tb/u_ip_top/app_wdf_wren
add wave -noupdate /ddr_top_tb/u_ip_top/cs
add wave -noupdate -divider DDR
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_addr
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_ba
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_cas_n
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_ck_n
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_ck_p
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_cke
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_cs_n
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_dm
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_dq
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_dqs_n
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_dqs_p
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_odt
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_ras_n
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/ddr2_we_n
add wave -noupdate -divider IF
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_addr
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_cmd
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_en
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_rd_data
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_rd_data_end
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_rd_data_valid
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_rdy
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_ref_ack
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_ref_req
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_sr_active
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_sr_req
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_wdf_data
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_wdf_end
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_wdf_mask
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_wdf_rdy
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_wdf_wren
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_zq_ack
add wave -noupdate /ddr_top_tb/u_ip_top/u_mig_7series_0/app_zq_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {103604362500 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 239
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {107119527671 fs} {121771596304 fs}
