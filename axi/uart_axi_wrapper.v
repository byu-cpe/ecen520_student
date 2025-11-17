// uart_axi.v

module uart_axi_wrapper #(
    parameter integer CLK_FREQUENCY = 100_000_000,
    parameter integer PARITY = 1'd1,
    parameter integer BAUD_RATE = 19_200,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // AXI4-Lite signals
    input wire                              s_axi_aclk,
    input wire                              s_axi_aresetn,
    // AW
    input wire                              s_axi_awvalid,
    output wire                             s_axi_awready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr,
    input wire [2:0]                        s_axi_awprot,
    // W
    input wire                              s_axi_wvalid,
    output wire                             s_axi_wready,
    input wire [31:0]                       s_axi_wdata,
    input wire [3:0]                        s_axi_wstrb,
    // B
    output wire                             s_axi_bvalid,
    input wire                              s_axi_bready,
    output wire [1:0]                       s_axi_bresp,
    // AR
    input wire                              s_axi_arvalid,
    output wire                             s_axi_arready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr,
    input wire [2:0]                        s_axi_arprot,
    // R
    output wire [31:0]                      s_axi_rdata,
    output wire [1:0]                       s_axi_rresp,
    output wire                             s_axi_rvalid,
    input wire                              s_axi_rready,
    // UART signals
    output wire                             tx_out,
    input wire                              rx_in
);


    uart_axi#(
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .PARITY(PARITY),
        .BAUD_RATE(BAUD_RATE)
    )
    uart_sv_inst (
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),

        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),

        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),

        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),

        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        .tx_out(tx_out),
        .rx_in(rx_in)
    );


endmodule
