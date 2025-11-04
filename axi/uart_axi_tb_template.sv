`timescale 1ps/1ps
import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module uart_axi_tb #(
    parameter integer CLK_FREQUENCY = 100_000_000,
    parameter logic PARITY = 1'd1,
    parameter integer BAUD_RATE = 115_200)
  ();

  // Internal AXI signal declarations
  logic [31:0]axi_vip_0_M_AXI_ARADDR;
  logic [2:0]axi_vip_0_M_AXI_ARPROT;
  logic axi_vip_0_M_AXI_ARREADY;
  logic axi_vip_0_M_AXI_ARVALID;
  logic [31:0]axi_vip_0_M_AXI_AWADDR;
  logic [2:0]axi_vip_0_M_AXI_AWPROT;
  logic axi_vip_0_M_AXI_AWREADY;
  logic axi_vip_0_M_AXI_AWVALID;
  logic axi_vip_0_M_AXI_BREADY;
  logic [1:0]axi_vip_0_M_AXI_BRESP;
  logic axi_vip_0_M_AXI_BVALID;
  logic [31:0]axi_vip_0_M_AXI_RDATA;
  logic axi_vip_0_M_AXI_RREADY;
  logic [1:0]axi_vip_0_M_AXI_RRESP;
  logic axi_vip_0_M_AXI_RVALID;
  logic [31:0]axi_vip_0_M_AXI_WDATA;
  logic axi_vip_0_M_AXI_WREADY;
  logic [3:0]axi_vip_0_M_AXI_WSTRB;
  logic axi_vip_0_M_AXI_WVALID;
  logic clk_wiz_clk_out1;
  logic rst_clk_wiz_100M_peripheral_aresetn;
  // RX/TX signals
  logic rx_in;
  logic tx_out;

  // axi_mst_agent master_agent. declared in axi_vip_0_pkg.sv
  axi_vip_0_mst_t  axi_vip_0_mst;

  // Instance the AXI VIP
  axi_vip_0 axi_vip_0_inst
       (.aclk(clk_wiz_clk_out1),
        .aresetn(rst_clk_wiz_100M_peripheral_aresetn),
        .m_axi_awaddr(axi_vip_0_M_AXI_AWADDR),
        .m_axi_awprot(axi_vip_0_M_AXI_AWPROT),
        .m_axi_awvalid(axi_vip_0_M_AXI_AWVALID),
        .m_axi_awready(axi_vip_0_M_AXI_AWREADY),
        .m_axi_wdata(axi_vip_0_M_AXI_WDATA),
        .m_axi_wstrb(axi_vip_0_M_AXI_WSTRB),
        .m_axi_wvalid(axi_vip_0_M_AXI_WVALID),
        .m_axi_wready(axi_vip_0_M_AXI_WREADY),
        .m_axi_bresp(axi_vip_0_M_AXI_BRESP),
        .m_axi_bvalid(axi_vip_0_M_AXI_BVALID),
        .m_axi_bready(axi_vip_0_M_AXI_BREADY),
        .m_axi_araddr(axi_vip_0_M_AXI_ARADDR),
        .m_axi_arprot(axi_vip_0_M_AXI_ARPROT),
        .m_axi_arvalid(axi_vip_0_M_AXI_ARVALID),
        .m_axi_arready(axi_vip_0_M_AXI_ARREADY),
        .m_axi_rdata(axi_vip_0_M_AXI_RDATA),
        .m_axi_rresp(axi_vip_0_M_AXI_RRESP),
        .m_axi_rvalid(axi_vip_0_M_AXI_RVALID),
        .m_axi_rready(axi_vip_0_M_AXI_RREADY)
    );

  // Instance the UART AXI module
  uart_axi #(.CLK_FREQUENCY(CLK_FREQUENCY), .PARITY(PARITY), .BAUD_RATE(BAUD_RATE))
      design_1_uart_axi_0_0
      (.rx_in(rx_in),
        .s_axi_aclk(clk_wiz_clk_out1),
        .s_axi_araddr(axi_vip_0_M_AXI_ARADDR[3:0]),
        .s_axi_aresetn(rst_clk_wiz_100M_peripheral_aresetn),
        .s_axi_arprot(axi_vip_0_M_AXI_ARPROT),
        .s_axi_arready(axi_vip_0_M_AXI_ARREADY),
        .s_axi_arvalid(axi_vip_0_M_AXI_ARVALID),
        .s_axi_awaddr(axi_vip_0_M_AXI_AWADDR[3:0]),
        .s_axi_awprot(axi_vip_0_M_AXI_AWPROT),
        .s_axi_awready(axi_vip_0_M_AXI_AWREADY),
        .s_axi_awvalid(axi_vip_0_M_AXI_AWVALID),
        .s_axi_bready(axi_vip_0_M_AXI_BREADY),
        .s_axi_bresp(axi_vip_0_M_AXI_BRESP),
        .s_axi_bvalid(axi_vip_0_M_AXI_BVALID),
        .s_axi_rdata(axi_vip_0_M_AXI_RDATA),
        .s_axi_rready(axi_vip_0_M_AXI_RREADY),
        .s_axi_rresp(axi_vip_0_M_AXI_RRESP),
        .s_axi_rvalid(axi_vip_0_M_AXI_RVALID),
        .s_axi_wdata(axi_vip_0_M_AXI_WDATA),
        .s_axi_wready(axi_vip_0_M_AXI_WREADY),
        .s_axi_wstrb(axi_vip_0_M_AXI_WSTRB),
        .s_axi_wvalid(axi_vip_0_M_AXI_WVALID),
        .tx_out(tx_out));

  // Variables for use in the AXI transactions
  xil_axi_prot_t prot = 0;
  xil_axi_resp_t resp;
  bit[31:0] data;

  initial begin
    axi_vip_0_mst = new("axi_vip_0_mst", axi_vip_0_inst.inst.IF);
    axi_vip_0_mst.start_master();
    $display("===== AXI UART TB =====");

    // Testbench logic
    // Example of an AXI read
    // axi_vip_0_mst.AXI4LITE_READ_BURST(32'h44A0_0004, prot, data, resp);
    // axi_vip_0_mst.AXI4LITE_WRITE_BURST(32'h44A0_0000, prot, data, resp);

    // Put your testbench code here

 end

endmodule
