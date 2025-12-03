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
    localparam FIFO_WIDTH = 8;
    localparam FIFO_DEPTH = 32;

    logic tx_write, tx_busy, rx_busy, rx_ack, rx_receive;
    logic rx_empty, tx_full, tx_empty, clear_fifo, write_tx_fifo, read_rx_fifo;
    logic [7:0] tx_data, rx_data, rx_fifo_out_data;
    logic rx_in_dd, rx_in_d;
    logic [7:0] read_data_byte_next, read_data_byte;

    // Uart Transmitter
    tx #(.PARITY(PARITY), .CLK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE))
    tx(.clk(axi_clk), .rst(axi_rst), .send(tx_write), .din(tx_data),
        .busy(tx_busy),.tx_out(UART_RXD_OUT));
    fifo #(.DATA_WIDTH(FIFO_WIDTH), .DEPTH(FIFO_DEPTH))
    tx_fifo(.clk(axi_aclk), .rst(axi_reset),
        .we(write_tx_fifo), .re(tx_write), .clear(clear_fifo),
        .din(read_data_byte), .overflow(), .underflow(),
        .dout(tx_data), .full(tx_full), .empty(tx_empty)
    );
    // Signal is used to issue a new transmit as well as read from the tx_fifo
    // (when the fifo is not empty and not busy, we can read from the FIFO and start a new transaction)
    assign tx_write = ~tx_empty && ~tx_busy;

    // Receiver signal synchronizers
    always_ff@(posedge axi_clk) begin
        rx_in_d <= UART_TXD_IN;
        rx_in_dd <= rx_in_d;
    end

    // Uart Receiver
    rx #(.CLK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE), .PARITY(PARITY))
    rx(.clk(axi_clk), .rst(axi_rst), .Sin(rx_in_dd), .Dout(rx_data), .busy(rx_busy),
        .ReceiveAck(rx_ack), .Receive(rx_receive), .parityErr(rx_parity_err));
    fifo #(.DATA_WIDTH(FIFO_WIDTH), .DEPTH(FIFO_DEPTH))
    rx_fifo(.clk(axi_clk), .rst(axi_reset),
        .we(rx_receive), .re(read_rx_fifo), .clear(clear_fifo),
        .din(rx_data), .overflow(), .underflow(),
        .dout(rx_fifo_out_data), .full(), .empty(rx_empty)
    );
    assign rx_ack = rx_receive;

    assign LED17_R = rx_busy;
    //assign LED16_B = tx_busy; // TODO: find another LED
    // LED17_G

    // AXI State Machine
    localparam OKAY_RESP = 2'b00;
    localparam EXOKAY_RESP = 2'b01;
    localparam SLVERR_RESP = 2'b10;
    localparam DECERR_RESP = 2'b11;

    // AXI state machine
    typedef enum {AXI_IDLE, 
        AXI_READ_ADDRESS, AXI_READ_DATA, 
        AXI_WRITE_ADDRESS, AXI_WRITE_DATA, AXI_WRITE_DATA_RESP
    }  AXIStateType;
    AXIStateType axi_ns, axi_cs;
    logic axi_busy;

    always_ff @(posedge axi_clk) begin
        if (axi_rst) begin
            axi_cs <= AXI_IDLE;
        end else begin
            axi_cs <= axi_ns;
        end
    end

    // General interface signals
    logic issue_read_transaction, issue_write_transaction; // TODO
    logic [127:0] write_data;
    logic [7:0] write_data_byte;
    logic [26:0] read_address, write_address, write_address_next, read_address_next;
    logic [15:0] write_strobe;
    // Write address channel
    logic [26:0] s_axi_awaddr_next;
    logic s_axi_awvalid_next;
    // Write data channel
    logic [127:0] s_axi_wdata_next;
    logic [15:0] s_axi_wstrb_next;
    logic s_axi_wvalid_next;
    // Write response channel
    logic s_axi_bready_next;
    // Read address channel
    logic [26:0] s_axi_araddr_next;
    logic s_axi_arvalid_next, s_axi_rready_next;

    // registers for AXI signals
    always_ff @(posedge axi_clk) begin
        if (axi_rst) begin
            s_axi_awaddr <= 0;
            s_axi_awvalid <= 0;
            s_axi_wdata <= 0; 
            s_axi_wstrb <= 0;
            s_axi_wvalid <= 0;
            s_axi_bready <= 0;
            s_axi_araddr <= 0;
            s_axi_arvalid <= 0;
            s_axi_rready <= 0;
            read_data_byte <= 0;
        end else begin
            s_axi_awaddr <= s_axi_awaddr_next;
            s_axi_awvalid <= s_axi_awvalid_next;
            s_axi_wdata <= s_axi_wdata_next; 
            s_axi_wstrb <= s_axi_wstrb_next;
            s_axi_wvalid <= s_axi_wvalid_next;
            s_axi_bready <= s_axi_bready_next;
            s_axi_araddr <= s_axi_araddr_next;
            s_axi_arvalid <= s_axi_arvalid_next;
            s_axi_rready <= s_axi_rready_next;
            read_data_byte <= read_data_byte_next;
        end
    end

    always_comb begin
        axi_busy = 1;
        s_axi_awaddr_next = s_axi_awaddr;
        s_axi_awvalid_next = 0;
        s_axi_wdata_next = s_axi_wdata;
        s_axi_wstrb_next = s_axi_wstrb;
        s_axi_wvalid_next = 0;
        s_axi_bready_next = 0;
        s_axi_araddr_next = s_axi_araddr;
        s_axi_arvalid_next = 0;
        s_axi_rready_next = 0;
        read_data_byte_next <= read_data_byte;
        axi_ns = axi_cs;
        case (axi_cs)
            AXI_IDLE: begin
                // Idle state: waiting for a read or write transaction
                axi_busy = 0;
                // Reads have priorities over writes (unlikely they will occur simultaneously)
                if (issue_read_transaction) begin
                    axi_ns = AXI_READ_ADDRESS;
                    s_axi_araddr_next <= read_address;
                    s_axi_arvalid_next <= 1;
                end else if (issue_write_transaction) begin
                    // Issue the address and valid for the write
                    axi_ns = AXI_WRITE_ADDRESS;
                    s_axi_awaddr_next <= write_address;
                    s_axi_awvalid_next <= 1;
                    // Technically the write data and strobe should be set 
                    // during the write data channel but I am going to do it here so that
                    // the write operation is atomic.
                    s_axi_wdata_next = write_data;
                    s_axi_wstrb_next = write_strobe;

                end
            end
            AXI_READ_ADDRESS: begin
                // address and valid is setup. Now waiting for ready
                // Wait until the s_axi_awready signal is high
                if (s_axi_arready) begin
                    s_axi_arvalid_next = 0;
                    axi_ns = AXI_READ_DATA;
                    // Ready to accept data
                    s_axi_rready_next <= 1;
                end
            end
            AXI_READ_DATA: begin
                if (s_axi_rvalid) begin
                    // Capture the read byte data
                    read_data_byte_next <= s_axi_rdata[7:0];
                    axi_ns = AXI_IDLE;
                    s_axi_rready_next <= 0;
                end
            end
            AXI_WRITE_ADDRESS: begin
                // address and valid is setup. Now waiting for ready
                // Wait until the s_axi_awready signal is high
                if (s_axi_awready) begin
                    s_axi_awvalid_next = 0;
                    axi_ns = AXI_WRITE_DATA;
                    // Setup write data and valid (this is done when the write address is started)
                    // s_axi_wdata_next = write_data;
                    // s_axi_wstrb_next = write_strobe;
                    s_axi_wvalid_next = 1;
                end
            end
            AXI_WRITE_DATA: begin
                // Wait for write data ready
                if (s_axi_wready) begin
                    s_axi_wvalid_next = 0;
                    s_axi_bready_next = 1;
                    axi_ns = AXI_WRITE_DATA_RESP;
                end
            end
            AXI_WRITE_DATA_RESP: begin
                if (s_axi_bvalid) begin
                    // Look at response value?
                    axi_ns = AXI_IDLE;
                    s_axi_bready_next = 1;
                end
            end
            default:
                axi_ns = AXI_IDLE;
        endcase
    end

    // BTNC one shot

    // I/O synchronizer signals
    // logic [15:0] sw_d;
    logic btnc_d, btnc_dd, btnc_debounce, btnc_debounce_d, btnc_os;
    //, btnl_d, btnl_dd, btnr_d, btnr_dd, btnu_d, btnu_dd;
    //logic btnc_os, btnl_os, btnr_os, btnu_os;
    //logic [26:0] sw_addr;
    always_ff @(posedge axi_clk)
    begin
        if (axi_rst) begin
            btnc_d <= 0;
            btnc_dd <= 0;
            btnc_debounce_d <= 0;
        end else begin
            btnc_d <= BTNC;
            btnc_dd <= btnc_d;
            btnc_debounce_d <= btnc_debounce;
        end
    end
    debounce #(.WAIT_TIME_US(WAIT_TIME_US))
    db(.clk(axi_clk), .rst(1'b0), .noisy(btnc_dd), .debounced(btnc_debounce));
    assign btnc_os = btnc_debounce & ~btnc_debounce_d;

    // State machine
    typedef enum { INIT, IDLE, WRITE_DATA_FIFO, WAIT_DDR_READ} state_type;
    state_type cs, ns;

    always_ff @(posedge axi_clk) begin
        if (axi_rst) begin
            cs <= INIT;
        end else begin
            cs <= ns;
        end
    end

    always_comb begin
        ns = cs;
        write_address_next = write_address;
        read_address_next = read_address;
        read_rx_fifo = 0;
        write_tx_fifo = 0;
        issue_write_transaction = 0;
        case (cs)
            INIT: begin
                // Wait for init to complete
                if (init_calib_complete)
                    ns = IDLE;
            end
            IDLE: begin
                // Wait for button press to start streaming data
                if (btnc_os && (read_address != write_address) ) begin
                    ns = WRITE_DATA_FIFO;
                end 
                else if (~rx_empty && ~axi_busy) begin
                    // There is data in the RX fifo and the AXI bus is free. Write data to DDR.
                    issue_write_transaction = 1;
                    write_address_next = write_address + 1; // increment write
                    read_rx_fifo = 1;
                end
            end
            WRITE_DATA_FIFO: begin
                if (read_address == write_address) begin
                    // If we have caught up, go back to idle
                    ns = IDLE;
                end else if (~rx_empty && ~axi_busy) begin
                    // There is data in the RX fifo and the AXI bus is free. Write data to DDR.
                    // (emptying the rx fifo takes precidence over sending data out of the tx)
                    issue_write_transaction = 1;
                    write_address_next = write_address + 1; // increment write
                    read_rx_fifo = 1;
                end else if (~tx_full && ~axi_busy) begin
                    // We have room in the TX fifo and the AXI bus is free. Read data from DDR.
                    issue_read_transaction = 1;
                    read_address_next = read_address + 1; // increment read
                    ns = WAIT_DDR_READ;
                end
            end
            WAIT_DDR_READ: begin
                if (~axi_busy) begin                    
                    // Read is complete. Write data to TX fifo
                    ns = WRITE_DATA_FIFO;
                    write_tx_fifo = 1;
                end
            end
        endcase
    end



    // // Register switches
    // always_ff @(posedge axi_clk)
    //     sw_d <= SW;

    // Synchronizers for buttons
    // always_ff @(posedge axi_clk) begin
    //     btnc_d <= BTNC;
    //     btnl_d <= BTNL;
    //     btnr_d <= BTNR;
    //     btnu_d <= BTNU;
    //     btnc_dd <= btnc_d;
    //     btnl_dd <= btnl_d;
    //     btnr_dd <= btnr_d;
    //     btnu_dd <= btnu_d;
    // end
    // One shot signals (NOTE: I SHOULD USE DEBOUNCERS but am skipping this for brevity.
    // Each button press will likely result in multiple read/writes but this is ok for this
    // simple exmample)
    // assign btnc_os = btnc_d & ~btnc_dd;
    // assign btnl_os = btnl_d & ~btnl_dd;
    // assign btnr_os = btnr_d & ~btnr_dd;
    // assign btnu_os = btnu_d & ~btnu_dd;

    // // Address register (lower 16 bits from BTNC, upper 11 bits from BTNU)
    // always_ff @(posedge axi_clk) begin
    //     if (btnc_os)
    //         sw_addr[15:0] <= sw_d;
    //     if (btnu_os)
    //         sw_addr[26:16] <= sw_d[10:0];
    // end


    // Generates the write strobe to specify which byte is being written
    // (we are only writing 16 bits but we have a 128 bit bus)
    always_comb begin
        case(write_address[3:0])  // The switch address points to a byte
            4'b0000: write_strobe = 16'b0000000000000001; // byte 0
            4'b0001: write_strobe = 16'b0000000000000010; // byte 1
            4'b0010: write_strobe = 16'b0000000000000100; // byte 2
            4'b0011: write_strobe = 16'b0000000000001000; // byte 3
            4'b0100: write_strobe = 16'b0000000000010000; // byte 4
            4'b0101: write_strobe = 16'b0000000000100000; // byte 5
            4'b0110: write_strobe = 16'b0000000001000000; // byte 6
            4'b0111: write_strobe = 16'b0000000010000000; // byte 7
            4'b1000: write_strobe = 16'b0000000100000000; // byte 8
            4'b1001: write_strobe = 16'b0000001000000000; // byte 9
            4'b1010: write_strobe = 16'b0000010000000000; // byte 10
            4'b1011: write_strobe = 16'b0000100000000000; // byte 11
            4'b1100: write_strobe = 16'b0001000000000000; // byte 12
            4'b1101: write_strobe = 16'b0010000000000000; // byte 13
            4'b1110: write_strobe = 16'b0100000000000000; // byte 14
            4'b1111: write_strobe = 16'b1000000000000000; // byte 15
        endcase
    end

    // Write signal output multiplexer
    assign write_data_byte = rx_fifo_out_data;
    always_comb begin
        case(write_address[3:0])  // The switch address points to a byte
            4'b0000: write_data = {120'd0, write_data_byte}; // byte 0
            4'b0001: write_data = {112'd0, write_data_byte, 8'd0}; // byte 1
            4'b0010: write_data = {104'd0, write_data_byte, 16'd0}; // byte 2
            4'b0011: write_data = {96'd0, write_data_byte, 24'd0}; // byte 3
            4'b0100: write_data = {88'd0, write_data_byte, 32'd0}; // byte 4
            4'b0101: write_data = {80'd0, write_data_byte, 40'd0}; // byte 5
            4'b0110: write_data = {72'd0, write_data_byte, 48'd0}; // byte 6
            4'b0111: write_data = {64'd0, write_data_byte, 56'd0}; // byte 7
            4'b1000: write_data = {56'd0, write_data_byte, 64'd0}; // byte 8
            4'b1001: write_data = {48'd0, write_data_byte, 72'd0}; // byte 9
            4'b1010: write_data = {40'd0, write_data_byte, 80'd0}; // byte 10
            4'b1011: write_data = {32'd0, write_data_byte, 88'd0}; // byte 11
            4'b1100: write_data = {24'd0, write_data_byte, 96'd0}; // byte 12
            4'b1101: write_data = {16'd0, write_data_byte, 104'd0}; // byte 13
            4'b1110: write_data = {8'd0, write_data_byte, 112'd0}; // byte 14
            4'b1111: write_data = {write_data_byte, 120'd0}; // byte 15
        endcase
    end

/*
    // Determines the 8 bit data from the 128-bit controller data bus that we
    // will save
    always_comb begin
        case(sw_addr[3:0])
            4'b0000: sw_mem_read_data = s_axi_rdata[7:0];    
            4'b0001: sw_mem_read_data = s_axi_rdata[15:8];  
            4'b0010: sw_mem_read_data = s_axi_rdata[23:16];  
            4'b0011: sw_mem_read_data = s_axi_rdata[31:24];  
            4'b0100: sw_mem_read_data = s_axi_rdata[39:32];  
            4'b0101: sw_mem_read_data = s_axi_rdata[47:40];  
            4'b0110: sw_mem_read_data = s_axi_rdata[55:48]; 
            4'b0111: sw_mem_read_data = s_axi_rdata[63:56];
            4'b1000: sw_mem_read_data = s_axi_rdata[71:64];   
            4'b1001: sw_mem_read_data = s_axi_rdata[79:72];  
            4'b1010: sw_mem_read_data = s_axi_rdata[87:80];  
            4'b1011: sw_mem_read_data = s_axi_rdata[95:88];  
            4'b1100: sw_mem_read_data = s_axi_rdata[103:96];  
            4'b1101: sw_mem_read_data = s_axi_rdata[111:104];  
            4'b1110: sw_mem_read_data = s_axi_rdata[119:112]; 
            4'b1111: sw_mem_read_data = s_axi_rdata[127:120];
        endcase
    end
*/

    // The 128 bit data that is written. We are just going to copy the 8 bit value
    // of the switches 16 times to fill the 128 bit bus (we are only writing 16 bits
    // based on the mask but don't want to waste logic figuring out which 16
    // bits are actually being written).
    // assign sw_app_wdf_data = {16{sw_d[7:0]}};

    // The 27 bit address to use for the transaction based on the switch address.
    // Mask the lower 4 bits to ensure the address is aligned to a 128 bit boundary
    // assign sw_app_addr = {sw_addr[26:4], 4'b0};

    // LED data to display
    // assign LED = led_mem_read_data;

endmodule
