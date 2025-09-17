// ddr_top example design that implements the DDR memory controller to the buttons and
// switches on the Nexys4 DDR board.

module ddr_top (
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic [15:0] SW,
    input logic BTNC,
    input logic BTNU,
    input logic BTNR,
    input logic BTNL,
    output logic [7:0] LED,
    output logic LED16_B,
    // DDR signals
    // Inouts
    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,
    // Outputs
    output [12:0]  ddr2_addr,
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

    // Constanst for DDR commands
    localparam logic [2:0] CMD_WRITE = 3'b000;
    localparam logic [2:0] CMD_READ = 3'b001;

    // CLK10MHZ reset signals
    logic clk100_rst_d, clk100_rst_dd; 
    // MMCM signals
    logic clk200, clk200_i, mmcm_locked, mmcm_clkfb;
    localparam RESET_FFS = 4;
    logic [RESET_FFS-1:0] clk200_reset_reg;
    logic clk200_reset;
    // I/O synchronizer signals
    logic [15:0] sw_d;
    logic btnc_d, btnc_dd, btnl_d, btnl_dd, btnr_d, btnr_dd, btnu_d, btnu_dd;
    logic btnc_os, btnl_os, btnr_os, btnu_os;
    // Internal signals
    logic [26:0] sw_addr;
    // State machine
    typedef enum { INIT, IDLE, WRITE_DATA_FIFO, ISSUE_WRITE_CMD, ISSUE_READ_CM, WAIT_FOR_DATA, ISSUE_READ_CMD } state_type;
    state_type cs, ns;

    // DDR interface signals
    logic clk_ui, clk_ui_rst;
    logic [26:0] app_addr, app_addr_next, sw_app_addr;
    logic [127:0] app_wdf_data, app_wdf_data_next, app_rd_data, sw_app_wdf_data;
    logic [15:0] app_wdf_mask, app_wdf_mask_next, sw_addr_wdf_mask;
    logic [7:0] sw_mem_read_data, led_mem_read_data, led_mem_read_data_next;
    logic app_wdf_wren, app_wdf_end, app_wdf_rdy, app_rdy, app_en, app_rd_data_end, app_rd_data_valid;
    logic init_calib_complete;
    logic [2:0] app_cmd, app_cmd_next;

    // Create reset synchronized to input clock
    always_ff @(posedge CLK100MHZ or negedge CPU_RESETN)
    begin
        if (~CPU_RESETN) begin
            // Asynchronous "preset"
            clk100_rst_d <= 1;
            clk100_rst_dd <= 1;
        end else begin
            // Shift register to shift out the preset reset value
            clk100_rst_d <= 0;
            clk100_rst_dd <= clk100_rst_d;
        end
    end

    // MMCM for 200 MHz clock (DDR needs 200 MHz)
    MMCME2_BASE #(
        .CLKIN1_PERIOD(10.0),       // 100 MHz input clock (needed!)
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
        .RST(clk100_rst_dd),
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
    BUFG clk200_buf(.I(clk200_i),.O(clk200));

    // clk200 domain reset
    always_ff @(posedge clk200 or negedge mmcm_locked)
        if (!mmcm_locked)
            clk200_reset_reg <= {RESET_FFS{1'b1}};   // initialize to all ones
        else
            clk200_reset_reg <= { clk200_reset_reg[RESET_FFS-2:0], 1'b0 };
    assign clk200_reset = clk200_reset_reg[RESET_FFS-1];

    // Register switches
    always_ff @(posedge clk_ui)
        sw_d <= SW;

    // Synchronizers for buttons
    always_ff @(posedge clk_ui) begin
        btnc_d <= BTNC;
        btnl_d <= BTNL;
        btnr_d <= BTNR;
        btnu_d <= BTNU;
        btnc_dd <= btnc_d;
        btnl_dd <= btnl_d;
        btnr_dd <= btnr_d;
        btnu_dd <= btnu_d;
    end
    // One shot signals (NOTE: I SHOULD USE DEBOUNCERS but am skipping this for brevity.
    // Each button press will likely result in multiple read/writes but this is ok for this
    // simple exmample)
    assign btnc_os = btnc_d & ~btnc_dd;
    assign btnl_os = btnl_d & ~btnl_dd;
    assign btnr_os = btnr_d & ~btnr_dd;
    assign btnu_os = btnu_d & ~btnu_dd;

    // Address register (lower 16 bits from BTNC, upper 11 bits from BTNU)
    always_ff @(posedge clk_ui) begin
        if (btnc_os)
            sw_addr[15:0] <= sw_d;
        if (btnu_os)
            sw_addr[26:16] <= sw_d[10:0];
    end

    /** DDR Controller instantiation
    * This memory controller provides an interface to a 128 MB DDR2 SDRAM.
    * The data bus width is 128 bits (16 bytes) and the controller provides a 27-bit 
    * "byte addressable" address. The bottom four bits of the address should
    * always be zero so that each access is aligned to a 128 bit/16-byte boundary.
    *
    *  The controller provides a 128-bit wide data interface. As such the address
    *  bus should have zeros in the lower 4 bits.
    **/
    mig_7series_0 #()
        u_mig_7series_0 (
            // Memory interface ports
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
        .init_calib_complete            (init_calib_complete),
        .ddr2_cs_n                      (ddr2_cs_n),
        .ddr2_dm                        (ddr2_dm),
        .ddr2_odt                       (ddr2_odt),
        // Application interface ports
        .app_addr                       (app_addr),             // Memory address (27 bits)
        .app_cmd                        (app_cmd),              // Command for transation
        .app_en                         (app_en),               // 
        .app_wdf_data                   (app_wdf_data),         // Memory data to be written (128 bits)
        .app_wdf_end                    (app_wdf_end),          // End of write fifo data
        .app_wdf_wren                   (app_wdf_wren),         // Write FIFO enable
        .app_rd_data                    (app_rd_data),          // Memory data read (128 bits)
        .app_rd_data_end                (app_rd_data_end),
        .app_rd_data_valid              (app_rd_data_valid),
        .app_rdy                        (app_rdy),              // Output indicating ready to accept commands
        .app_wdf_rdy                    (app_wdf_rdy),          // Output that indicates write fifo is ready
        .app_sr_req                     (1'b0),                 // Not used
        .app_ref_req                    (1'b0),                 // Not used
        .app_zq_req                     (1'b0),                 // Not used
        .app_sr_active                  (),                     // open
        .app_ref_ack                    (),                     // open
        .app_zq_ack                     (),                     // open
        .ui_clk                         (clk_ui),               // ui clk (generated by core)
        .ui_clk_sync_rst                (clk_ui_rst),               // ui sync reset
        .app_wdf_mask                   (app_wdf_mask),         // write data mask
        // System Clock Ports
        .sys_clk_i                      (clk200),               // input clock
        .sys_rst                        (~clk200_reset)         // reset from initial MMCM
        );
    // End of DDR core instantiation

    assign LED16_B = init_calib_complete;  // DDR initialized and calibrated

    // State machine registers
    always_ff @(posedge clk_ui or posedge clk_ui_rst)
        if (clk_ui_rst) begin
            cs <= INIT;
            app_addr <= 27'h0;
            app_wdf_mask <= 16'h0;
            app_wdf_data <= 128'h0;
            app_cmd <= CMD_READ;
            led_mem_read_data <= 16'h0;
        end
        else begin
            cs <= ns;
            app_addr <= app_addr_next;
            app_wdf_mask <= app_wdf_mask_next;
            app_wdf_data <= app_wdf_data_next;
            app_cmd <= app_cmd_next;
            led_mem_read_data <= led_mem_read_data_next;
        end 

    // Next state logic
    always_comb begin
        ns = cs;
        app_addr_next = app_addr;
        app_wdf_mask_next = app_wdf_mask;
        app_wdf_data_next = app_wdf_data;
        app_wdf_wren = 1'b0;
        app_wdf_end = 1'b0;
        app_en = 1'b0;
        app_cmd_next = app_cmd;
        led_mem_read_data_next = led_mem_read_data;
        case(cs)
            INIT: // wait until the core is initialized
                if (init_calib_complete)
                    ns = IDLE;
            IDLE: begin
                // Wait until the core is initialized and we have a read or write request
                if (btnl_os) begin // write sequence
                    ns = WRITE_DATA_FIFO;
                    // Set the address, write mask, and write data
                    app_addr_next = sw_app_addr;
                    app_wdf_mask_next = sw_addr_wdf_mask;
                    app_wdf_data_next = sw_app_wdf_data;
                    app_cmd_next = CMD_WRITE;
                end
                else if (btnr_os) begin // read sequence
                    ns = ISSUE_READ_CMD;
                    app_addr_next = sw_app_addr;
                    app_cmd_next = CMD_READ;
                end
            end
            // See https://docs.amd.com/r/en-US/ug586_7Series_MIS/Write-Path for summary of writing path
            WRITE_DATA_FIFO: begin
                // Issue a write into the FIFO and indicate it is the last one (i.e., no burst, single transfer)
                // app_wdf_wren qualifies the "data" going into the fifo (not the command or address)
                app_wdf_wren = 1'b1;
                app_wdf_end = 1'b1;
                if (app_wdf_rdy)    // This phase ends when app_wdf_rdy is asserted and app_wdr_wren is asserted
                    ns = ISSUE_WRITE_CMD;
            end
            ISSUE_WRITE_CMD: begin
                // Issue the write command (needs command and address). The address and command have already
                // been latched. Assert app_en and wait for app_rdy to go high to validate the transaction
                // The data has been sent in the previous state.
                app_en = 1'b1;
                if (app_rdy)
                    // Transaction has been validated. Done with the write (although the write may not have completed)
                    ns = IDLE;
            end
            ISSUE_READ_CMD: begin
                // Issue the read command (needs command and address). The address and command have already
                // been latched. Assert app_en and wait for app_rdy to go high to validate the transaction
                app_en = 1'b1;
                if (app_rdy)
                    // Transaction has been validated.
                    ns = WAIT_FOR_DATA;
            end
            WAIT_FOR_DATA: begin
                if (app_rd_data_valid) begin
                    // Data is valid. Latch it and go back to idle
                    ns = IDLE;
                    // check for app_rd_data_end ? (Digilent core uses it but docs don't mention it)
                    led_mem_read_data_next = sw_mem_read_data;
                end 
            end

        endcase
    end

    // Generates the mask for the write data based on the switch address
    // (we are only writing 16 bits but we have a 128 bit bus)
    always_comb begin
        case(sw_addr[3:0])  // The switch address points to a byte
            4'b0000: sw_addr_wdf_mask = 16'b1111111111111110; // byte 0
            4'b0001: sw_addr_wdf_mask = 16'b1111111111111101; // byte 1
            4'b0010: sw_addr_wdf_mask = 16'b1111111111111011; // byte 2
            4'b0011: sw_addr_wdf_mask = 16'b1111111111110111; // byte 3
            4'b0100: sw_addr_wdf_mask = 16'b1111111111101111; // byte 4
            4'b0101: sw_addr_wdf_mask = 16'b1111111111011111; // byte 5
            4'b0110: sw_addr_wdf_mask = 16'b1111111110111111; // byte 6
            4'b0111: sw_addr_wdf_mask = 16'b1111111101111111; // byte 7
            4'b1000: sw_addr_wdf_mask = 16'b1111111011111111; // byte 8
            4'b1001: sw_addr_wdf_mask = 16'b1111110111111111; // byte 9
            4'b1010: sw_addr_wdf_mask = 16'b1111101111111111; // byte 10
            4'b1011: sw_addr_wdf_mask = 16'b1111011111111111; // byte 11
            4'b1100: sw_addr_wdf_mask = 16'b1110111111111111; // byte 12
            4'b1101: sw_addr_wdf_mask = 16'b1101111111111111; // byte 13
            4'b1110: sw_addr_wdf_mask = 16'b1011111111111111; // byte 14
            4'b1111: sw_addr_wdf_mask = 16'b0111111111111111; // byte 15
        endcase
    end

    // Determines the 8 bit data from the 128-bit controller data bus that we
    // will load into the LED display memory.
    always_comb begin
        case(sw_addr[3:0])
            4'b0000: sw_mem_read_data = app_rd_data[7:0];    
            4'b0001: sw_mem_read_data = app_rd_data[15:8];  
            4'b0010: sw_mem_read_data = app_rd_data[23:16];  
            4'b0011: sw_mem_read_data = app_rd_data[31:24];  
            4'b0100: sw_mem_read_data = app_rd_data[39:32];  
            4'b0101: sw_mem_read_data = app_rd_data[47:40];  
            4'b0110: sw_mem_read_data = app_rd_data[55:48]; 
            4'b0111: sw_mem_read_data = app_rd_data[63:56];
            4'b1000: sw_mem_read_data = app_rd_data[71:64];   
            4'b1001: sw_mem_read_data = app_rd_data[79:72];  
            4'b1010: sw_mem_read_data = app_rd_data[87:80];  
            4'b1011: sw_mem_read_data = app_rd_data[95:88];  
            4'b1100: sw_mem_read_data = app_rd_data[103:96];  
            4'b1101: sw_mem_read_data = app_rd_data[111:104];  
            4'b1110: sw_mem_read_data = app_rd_data[119:112]; 
            4'b1111: sw_mem_read_data = app_rd_data[127:120];
        endcase
    end

    // The 128 bit data that is written. We are just going to copy the 8 bit value
    // of the switches 16 times to fill the 128 bit bus (we are only writing 16 bits
    // based on the mask but don't want to waste logic figuring out which 16
    // bits are actually being written).
    assign sw_app_wdf_data = {16{sw_d[7:0]}};

    // The 27 bit address to use for the transaction based on the switch address.
    // Mask the lower 4 bits to ensure the address is aligned to a 128 bit boundary
    assign sw_app_addr = {sw_addr[26:4], 4'b0};

    // LED data to display
    assign LED = led_mem_read_data;

endmodule
