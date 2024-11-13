
vlib work

#Map the required libraries here#
vmap unisim /mnt/toolsdisk/Xilinx/Vivado/2024.1/data/questa/unisim
vmap secureip /mnt/toolsdisk/Xilinx/Vivado/2024.1/data/questa/secureip
vmap unisims_ver /mnt/toolsdisk/Xilinx/Vivado/2024.1/data/questa/unisims_ver
#vmap unisim <unisim lib path>
#vmap secureip <secureip lib path>

#Compile all modules#
#vlog  -incr mig_7series*.v
vlog  ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0.v
vlog  ./mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0_mig_sim.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/clocking/*.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/controller/*.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/ecc/*.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/ip_top/*.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/phy/*.v
vlog  -incr ./mig_7series_0/mig_7series_0/user_design/rtl/ui/*.v

vlog  ddr_top.sv

#Compile files in sim folder (excluding model parameter file)#
#$XILINX variable must be set
#vlog -incr $env(XILINX_VIVADO)/data/verilog/src/glbl.v
vlog -incr glbl.v
vlog wiredly.v
vlog ddr_top_tb.v

#Pass the parameters for memory model parameter file#
vlog -incr +define+x1Gb +define+sg25E +define+x16 ddr2_model.v

#Load the design. Use required libraries.#
vsim -t fs +notimingchecks -voptargs=+acc -L unisims_ver -L secureip work.ddr_top_tb glbl -do 'ddr_top_tb_wave.do'


