onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Test Bench}

add wave -noupdate -divider Top

add wave -position insertpoint  \
sim:/example_nexys4_top_tb/u_ip_top/CLK100MHZ \
sim:/example_nexys4_top_tb/u_ip_top/CPU_RESETN \
sim:/example_nexys4_top_tb/u_ip_top/tg_compare_error \
sim:/example_nexys4_top_tb/u_ip_top/init_calib_complete \
sim:/example_nexys4_top_tb/u_ip_top/clk100_rst_d \
sim:/example_nexys4_top_tb/u_ip_top/clk100_rst_dd \
sim:/example_nexys4_top_tb/u_ip_top/clk100_mmcm_clkfb \
sim:/example_nexys4_top_tb/u_ip_top/clk200_i \
sim:/example_nexys4_top_tb/u_ip_top/clk100_mmcm_locked \
sim:/example_nexys4_top_tb/u_ip_top/sys_clk_i \
sim:/example_nexys4_top_tb/u_ip_top/sys_rst \
sim:/example_nexys4_top_tb/u_ip_top/clk \
sim:/example_nexys4_top_tb/u_ip_top/rst \
sim:/example_nexys4_top_tb/u_ip_top/mmcm_locked \
sim:/example_nexys4_top_tb/u_ip_top/aresetn \
sim:/example_nexys4_top_tb/u_ip_top/app_sr_active \
sim:/example_nexys4_top_tb/u_ip_top/app_ref_ack \
sim:/example_nexys4_top_tb/u_ip_top/app_zq_ack \
sim:/example_nexys4_top_tb/u_ip_top/app_rd_data_valid \
sim:/example_nexys4_top_tb/u_ip_top/app_rd_data \
sim:/example_nexys4_top_tb/u_ip_top/mem_pattern_init_done \
sim:/example_nexys4_top_tb/u_ip_top/cmd_err \
sim:/example_nexys4_top_tb/u_ip_top/data_msmatch_err \
sim:/example_nexys4_top_tb/u_ip_top/write_err \
sim:/example_nexys4_top_tb/u_ip_top/read_err \
sim:/example_nexys4_top_tb/u_ip_top/test_cmptd \
sim:/example_nexys4_top_tb/u_ip_top/write_cmptd \
sim:/example_nexys4_top_tb/u_ip_top/read_cmptd \
sim:/example_nexys4_top_tb/u_ip_top/cmptd_one_wr_rd

add wave -noupdate -divider DDR

add wave -position insertpoint  \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_dq \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_dqs_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_dqs_p \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_addr \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_ba \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_ras_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_cas_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_we_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_ck_p \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_ck_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_cke \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_cs_n \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_dm \
sim:/example_nexys4_top_tb/u_ip_top/ddr2_odt

