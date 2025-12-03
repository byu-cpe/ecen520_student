// ddr_top.sv
//
// This is the top-level module for the DDR assignment. It instantiates the memory controller and other components.
module ddr_top #(
    parameter int WAIT_TIME_US = 10_000,
    parameter logic PARITY = 1'd1,
    parameter int CLK_FREQUENCY = 100_000_000,
    parameter int BAUD_RATE = 19_200
    ) (

    // NEXYS4 board signals
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic [15:0] SW,
    input logic BTNC,
    input logic BTNU,
    input logic BTNR,
    input logic BTNL,
    output logic [7:0] LED,
    output logic LED16_B,
    input wire UART_TXD_IN,
    output UART_RXD_OUT,

    // DDR top-level signals
    // Inouts
    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,
    // Outputs
    output [12:0] ddr2_addr,
    output [2:0] ddr2_ba,
    output ddr2_ras_n,
    output ddr2_cas_n,
    output ddr2_we_n,
    output [0:0] ddr2_ck_p,
    output [0:0] ddr2_ck_n,
    output [0:0] ddr2_cke,
    output [0:0] ddr2_cs_n,
    output [1:0] ddr2_dm,
    output [0:0] ddr2_odt
);

    // clk100 MHz reset signals
    logic clk100_rst_d, clk100_rst;
     // MMCM signals
    logic clk200, clk200_i, mmcm_locked, mmcm_clkfb;
    localparam RESET_FFS = 4;
    logic [RESET_FFS-1:0] clk200_reset_reg;
    logic clk200_reset;
    // DDR interface signals
    logic init_calib_complete, ddr_mmcm_locked, ddr_mmcm_reset_n;
    logic app_sr_active, app_ref_ack, app_zq_ack;
    // AXI signals
    logic axi_clk, axi_rst;
    logic [26:0] s_axi_awaddr, s_axi_araddr;
    logic s_axi_awvalid, s_axi_awready;
    logic [127:0] s_axi_wdata;
    logic [15:0] s_axi_wstrb;
    logic s_axi_wvalid, s_axi_wready;
    logic [3:0] s_axi_bresp;
    logic s_axi_bvalid, s_axi_bready;
    logic s_axi_arvalid, s_axi_arready;
    logic s_axi_rready, s_axi_rvalid;
    logic [127:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;

    // Reset synchronizer for CLK100MHZ domain
    always_ff @(posedge CLK100MHZ or negedge CPU_RESETN)
    begin
        if (~CPU_RESETN) begin
            // Asynchronous "preset"
            clk100_rst_d <= 1;
            clk100_rst <= 1;
        end else begin
            // Shift register to shift out the preset reset value
            clk100_rst_d <= 0;
            clk100_rst <= clk100_rst_d;
        end
    end

    // MMCM for 200 MHz clock (DDR needs 200 MHz)
    MMCME2_BASE #(
        .CLKIN1_PERIOD(10.0),             // 100 MHz input clock (needed!)
        .CLKFBOUT_MULT_F(10.000),         // 1000 MHz (M=10,D=1)
        .CLKFBOUT_PHASE(0.000),           // In PHase
        .DIVCLK_DIVIDE(1),                // 1000 MHz (M=10,D=1)
        // Clock 0: 200 MHz, 50% duty cycle, in phase with input clock
        .CLKOUT0_DIVIDE_F(5),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_PHASE(0.000)
    )
    mmcm(
        .CLKFBOUT(mmcm_clkfb),
        .CLKOUT0(clk200_i),
        .LOCKED(mmcm_locked),
        .CLKFBIN(mmcm_clkfb),
        .CLKIN1(CLK100MHZ),
        .PWRDWN(1'b0),
        .RST(clk100_rst),// DDR initialized and calibrated
        .CLKFBOUTB(),
        .CLKOUT0B(),
        .CLKOUT1(),
        .CLKOUT1B(),
        .CLKOUT2(),
        .CLKOUT2B(),
        .CLKOUT3(),
        .CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKOUT6()
    );
    // No BUFG for feedback (no need to synchronize input clock with internal clock
    //BUFG mmcm_clkfb_buf(.I(mmcm_clkfb_i),.O(mmcm_clkfb));
    BUFG clk200_buf(.I(clk200_i),.O(clk200));// DDR initialized and calibrated

    // clk200 domain reset
    always_ff @(posedge clk200 or negedge mmcm_locked)
        if (!mmcm_locked)
            clk200_reset_reg <= {RESET_FFS{1'b1}};   // initialize to all ones
        else
            clk200_reset_reg <= { clk200_reset_reg[RESET_FFS-2:0], 1'b0 };
    assign clk200_reset = clk200_reset_reg[RESET_FFS-1];

    // DDR Memory controller
    mig_7series_0 #(
        //     .RST_ACT_LOW                      (RST_ACT_LOW)
    )
    u_mig_7series_0 (
        // DDR memory interface ports (top-level signals)
        .ddr2_addr                      (ddr2_addr),
        .ddr2_ba                        (ddr2_ba),
        .ddr2_cas_n                     (ddr2_cas_n),
        .ddr2_ck_n                      (ddr2_ck_n),
        .ddr2_ck_p                      (ddr2_ck_p),
        .ddr2_cke                       (ddr2_cke),
        .ddr2_ras_n                     (ddr2_ras_n),
        .ddr2_we_n                      (ddr2_we_n),
        .ddr2_dq                        (ddr2_dq),
        .ddr2_dqs_n                     (ddr2_dqs_n),
        .ddr2_dqs_p                     (ddr2_dqs_p),
        .ddr2_cs_n                      (ddr2_cs_n),
        .ddr2_dm                        (ddr2_dm),
        .ddr2_odt                       (ddr2_odt),
        // Application interface ports
        .init_calib_complete            (init_calib_complete),   // Indicates ddr initialization done
        .ui_clk                         (axi_clk),                // ui clock generated by the core (use this for your logic)
        .ui_clk_sync_rst                (axi_rst),            // ui clock domain reset generated by the core (use this for your logic reset)
        .mmcm_locked                    (ddr_mmcm_locked),       // mmcm_locked signal for the internal MMCM (used if you want to cascade)
        .aresetn                        (ddr_mmcm_reset_n),      // Input reset for the module
        .app_sr_req                     (1'b0),                  // Reserved: tied to 0
        .app_ref_req                    (1'b0),                  // Refresh request (not used)
        .app_zq_req                     (1'b0),                  // ZQ calibration request (not used)  
        .app_sr_active                  (app_sr_active),         // Reserved output: open
        .app_ref_ack                    (app_ref_ack),           // Refresh acknowledge: open
        .app_zq_ack                     (app_zq_ack),            // ZQ calibration acknowledge: open

        // AXI Slave Interface Write Address Ports
        .s_axi_awid                     (4'd0),                  // Hard code the ID to 0
        .s_axi_awaddr                   (s_axi_awaddr),          // Byte addresses (2^27 = 128 MB DRAM)
        .s_axi_awlen                    (8'd0),                  // Single beat transfers (hard code to 0)
        .s_axi_awsize                   (3'b000),                // 8 bit transfers
        .s_axi_awburst                  (2'b01),                 // INCR mode (but doesn't matter since we are only doing single beat transfers)
        .s_axi_awlock                   (1'b0),                  // No exclusive or locked transfer
        .s_axi_awcache                  (4'b0011),               // Normal, non-cacheable, bufferable
        .s_axi_awprot                   (3'b000),                // unprivileged, secure, data access — default
        .s_axi_awqos                    (4'h0),                  // Lowest QoS
        .s_axi_awvalid                  (s_axi_awvalid),
        .s_axi_awready                  (s_axi_awready),
        // AXI Slave Interface Write Data Ports
        .s_axi_wdata                    (s_axi_wdata),
        .s_axi_wstrb                    (s_axi_wstrb),
        .s_axi_wlast                    (1'b1),                  // Last transfer is first transfer (always)
        .s_axi_wvalid                   (s_axi_wvalid),
        .s_axi_wready                   (s_axi_wready),
        // AXI Slave Interface Write Response Ports
        .s_axi_bid                      (),                      // Leave open (we are not overlapping transactions)
        .s_axi_bresp                    (s_axi_bresp),
        .s_axi_bvalid                   (s_axi_bvalid),
        .s_axi_bready                   (s_axi_bready),
        // AXI Slave Interface Read Address Ports
        .s_axi_arid                     (4'd0),                  // Hard code to 0
        .s_axi_araddr                   (s_axi_araddr),          // Addresses are *byte* addresses
        .s_axi_arlen                    (8'd0),                  // Single beat transfers (hard code to 0)
        .s_axi_arsize                   (3'b000),                // 8 bit transfers
        .s_axi_arburst                  (2'b01),                 // INCR mode (but doesn't matter since we are only doing single beat transfers)
        .s_axi_arlock                   (1'b0),                  // No exclusive or locked transfer  
        .s_axi_arcache                  (4'b0011),               // Normal, non-cacheable, bufferable
        .s_axi_arprot                   (3'b000),                // unprivileged, secure, data access — default
        .s_axi_arqos                    (4'h0),                  // Lowest QoS   
        .s_axi_arvalid                  (s_axi_arvalid),
        .s_axi_arready                  (s_axi_arready),
        // AXI Slave Interface Read Data Ports
        .s_axi_rid                      (4'd0),                  // Hard code to 0
        .s_axi_rdata                    (s_axi_rdata),
        .s_axi_rresp                    (s_axi_rresp),           // Leave open - we are ignoring the response
        .s_axi_rlast                    (1'b1),                  // Always the last transfer (single beat transfers)
        .s_axi_rvalid                   (s_axi_rvalid),
        .s_axi_rready                   (s_axi_rready),
        // System Clock Ports
        .sys_clk_i                      (clk200),               // clock from top-level MMCM
        .sys_rst                        (~clk200_reset)         // reset from top-level MMCM
    );

    // DDR initialized and calibrated
    assign LED16_B = init_calib_complete;
    assign ddr_mmcm_reset_n = mmcm_locked; // when not locked, issue reset to core

    ///////////////////////////////////
    // Put your logic here
    ///////////////////////////////////

endmodule
