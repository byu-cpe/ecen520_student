
module uart_axi #(
    parameter integer CLK_FREQUENCY = 100_000_000,
    parameter logic PARITY = 1'd1,
    parameter integer BAUD_RATE = 115_200,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // Globals
    input wire logic                            s_axi_aclk,
    input wire logic                            s_axi_aresetn,
    // AW
    input wire logic                            s_axi_awvalid,
    output logic                                s_axi_awready,
    input wire logic [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
    input wire logic [2:0]                      s_axi_awprot,
    // W
    input wire logic                            s_axi_wvalid,
    output logic                                s_axi_wready,
    input wire logic [31:0]                     s_axi_wdata,
    input wire logic [3:0]                      s_axi_wstrb,
    // B
    output logic                                s_axi_bvalid,
    input wire  logic                           s_axi_bready,
    output logic [1:0]                          s_axi_bresp,
    // AR
    input wire logic                            s_axi_arvalid,
    output logic                                s_axi_arready,
    input wire logic [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
    input wire logic [2:0]                      s_axi_arprot,
    // R
    output logic [31:0]                         s_axi_rdata,
    output logic [1:0]                          s_axi_rresp,
    output logic                                s_axi_rvalid,
    input wire logic                            s_axi_rready,
    // UART signals
    output logic                                tx_out,
    input wire logic                            rx_in

);

// Add your module here


endmodule
