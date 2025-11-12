# This script will create the simulation files for the AXI VIP
set IP_DIR ./ip

# Creates an "IP" project so we can create the IP. 
create_project ip_project ${IP_DIR}/ip_project -force -part xc7a100tcsg324-1 -ip
# Creates IP files in ./ip/axi_vip_0 (xci and xml files)
create_ip -name axi_vip -vendor xilinx.com -library ip -version 1.1 -module_name axi_vip_0 -dir ${IP_DIR}
# Sets properties of IP
set_property -dict [list \
  CONFIG.INTERFACE_MODE {MASTER} \
  CONFIG.PROTOCOL {AXI4LITE} \
] [get_ips axi_vip_0]
# Generates the simulation files
generate_target all [get_files  ${IP_DIR}/axi_vip_0/axi_vip_0.xci]

# The files you will need include:
# ./ip/axi_vip_0/sim/axi_vip_0_pkg.sv
# ./ip/axi_vip_0/sim/axi_vip_0.sv
