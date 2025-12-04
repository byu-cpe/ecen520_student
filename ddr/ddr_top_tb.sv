// adapted from ./example_design/mig_7series_0_ex/imports/sim_tb_top.v
// search for Nexys4 to find changes made for Nexys4 board

`timescale 1ps/100fs

module ddr_top_tb;


   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter SIMULATION            = "TRUE";
   parameter BEGIN_ADDRESS         = 32'h00000000;
   parameter END_ADDRESS           = 32'h00000fff;
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000;


   parameter WAIT_TIME_US = 2;    // default is 10_000. Speed up for faster sim
   parameter logic PARITY = 1'd1;
   parameter integer BAUD_RATE = 1_000_000; // default is 19_200. Speed up for faster simulation
   localparam CLK_FREQUENCY = 100_000_000;

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   parameter BANK_WIDTH            = 3;
                                     // # of memory Bank Address bits.
   parameter CK_WIDTH              = 1;
                                     // # of CK/CK# outputs to memory.
   parameter COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
   parameter nCS_PER_RANK          = 1;
                                     // # of unique CS outputs per rank for phy
   parameter CKE_WIDTH             = 1;
                                     // # of CKE outputs to memory.
   parameter DM_WIDTH              = 2;
                                     // # of DM (data mask)
   parameter DQ_WIDTH              = 16;
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 2;
   parameter DQS_CNT_WIDTH         = 1;
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter ECC                   = "OFF";
   parameter RANKS                 = 1;
                                     // # of Ranks.
   parameter ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter ROW_WIDTH             = 13;
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 27;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
  //  parameter CLKIN_PERIOD          = 4999;
   parameter CLKIN_PERIOD          = 10000; // Nexys4 has a 100 MHz input clock
                                     // Input Clock Period

   //***************************************************************************
   // Simulation parameters
   //***********example_****************************************************************
   parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter TCQ                   = 100;
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***********example_****************************************************************
   parameter RST_ACT_LOW           = 1;
                                     // =1 for active low reset,
                                     // =0 for active high.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0;
                                     // IODELAYCTRL reference clock frequency
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter tCK                   = 3333;
                                     // memory tCK paramter.
                     // # = Clock Period in pS.

   
   //***************************************************************************
   // AXI4 Shim parameters
   //***************************************************************************
   parameter C_S_AXI_ID_WIDTH              = 4;
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 32;
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 128;
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1

   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DRAM_TYPE             = "DDR2";

    

  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//

  localparam real TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam MEMORY_WIDTH            = 16;
  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;
  localparam ECC_TEST 		   	= "OFF" ;
  localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;

  localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));
  localparam RESET_PERIOD = 200000; //in pSec  
  localparam real SYSCLK_PERIOD = tCK;
    
    

  //**************************************************************************//
  // Wire Declarations
  //**************************************************************************//
  reg                                sys_rst_n;
  wire                               sys_rst;


  reg                     sys_clk_i;

  reg clk_ref_i;

  
  wire                               ddr2_reset_n;
  wire [DQ_WIDTH-1:0]                ddr2_dq_fpga;
  wire [DQS_WIDTH-1:0]               ddr2_dqs_p_fpga;
  wire [DQS_WIDTH-1:0]               ddr2_dqs_n_fpga;
  wire [ROW_WIDTH-1:0]               ddr2_addr_fpga;
  wire [BANK_WIDTH-1:0]              ddr2_ba_fpga;
  wire                               ddr2_ras_n_fpga;
  wire                               ddr2_cas_n_fpga;
  wire                               ddr2_we_n_fpga;
  wire [CKE_WIDTH-1:0]               ddr2_cke_fpga;
  wire [CK_WIDTH-1:0]                ddr2_ck_p_fpga;
  wire [CK_WIDTH-1:0]                ddr2_ck_n_fpga;
    
  
  wire                               init_calib_complete;
  wire                               tg_compare_error;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr2_cs_n_fpga;
    
  wire [DM_WIDTH-1:0]                ddr2_dm_fpga;
    
  wire [ODT_WIDTH-1:0]               ddr2_odt_fpga;
    
  
  reg [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr2_cs_n_sdram_tmp;
    
  reg [DM_WIDTH-1:0]                 ddr2_dm_sdram_tmp;
    
  reg [ODT_WIDTH-1:0]                ddr2_odt_sdram_tmp;
    

  
  wire [DQ_WIDTH-1:0]                ddr2_dq_sdram;
  reg [ROW_WIDTH-1:0]                ddr2_addr_sdram;
  reg [BANK_WIDTH-1:0]               ddr2_ba_sdram;
  reg                                ddr2_ras_n_sdram;
  reg                                ddr2_cas_n_sdram;
  reg                                ddr2_we_n_sdram;
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr2_cs_n_sdram;
  wire [ODT_WIDTH-1:0]               ddr2_odt_sdram;
  reg [CKE_WIDTH-1:0]                ddr2_cke_sdram;
  wire [DM_WIDTH-1:0]                ddr2_dm_sdram;
  wire [DQS_WIDTH-1:0]               ddr2_dqs_p_sdram;
  wire [DQS_WIDTH-1:0]               ddr2_dqs_n_sdram;
  reg [CK_WIDTH-1:0]                 ddr2_ck_p_sdram;
  reg [CK_WIDTH-1:0]                 ddr2_ck_n_sdram;
  
  logic tb_tx_to_top, btnc, btnu;

//**************************************************************************//

  //**************************************************************************//
  // Reset Generation
  //**************************************************************************//
  initial begin
    sys_rst_n = 1'b0;
    #RESET_PERIOD
      sys_rst_n = 1'b1;
   end

   assign sys_rst = RST_ACT_LOW ? sys_rst_n : ~sys_rst_n;

  //**************************************************************************//
  // Clock Generation
  //**************************************************************************//

  initial
    sys_clk_i = 1'b0;
  always
    sys_clk_i = #(CLKIN_PERIOD/2.0) ~sys_clk_i;


  initial
    clk_ref_i = 1'b0;
  always
    clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;




  always @( * ) begin
    ddr2_ck_p_sdram   <=  #(TPROP_PCB_CTRL) ddr2_ck_p_fpga;
    ddr2_ck_n_sdram   <=  #(TPROP_PCB_CTRL) ddr2_ck_n_fpga;
    ddr2_addr_sdram   <=  #(TPROP_PCB_CTRL) ddr2_addr_fpga;
    ddr2_ba_sdram     <=  #(TPROP_PCB_CTRL) ddr2_ba_fpga;
    ddr2_ras_n_sdram  <=  #(TPROP_PCB_CTRL) ddr2_ras_n_fpga;
    ddr2_cas_n_sdram  <=  #(TPROP_PCB_CTRL) ddr2_cas_n_fpga;
    ddr2_we_n_sdram   <=  #(TPROP_PCB_CTRL) ddr2_we_n_fpga;
    ddr2_cke_sdram    <=  #(TPROP_PCB_CTRL) ddr2_cke_fpga;
  end
    

  always @( * )
    ddr2_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr2_cs_n_fpga;
  assign ddr2_cs_n_sdram =  ddr2_cs_n_sdram_tmp;
    

  always @( * )
    ddr2_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr2_dm_fpga;//DM signal generation
  assign ddr2_dm_sdram = ddr2_dm_sdram_tmp;
    

  always @( * )
    ddr2_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr2_odt_fpga;
  assign ddr2_odt_sdram =  ddr2_odt_sdram_tmp;
    

// Controlling the bi-directional BUS

  genvar dqwd;
  generate
    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq
       (
        .A             (ddr2_dq_fpga[dqwd]),
        .B             (ddr2_dq_sdram[dqwd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
    // For ECC ON case error is inserted on LSB bit from DRAM to FPGA
          WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq_0
       (
        .A             (ddr2_dq_fpga[0]),
        .B             (ddr2_dq_sdram[0]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_p
       (
        .A             (ddr2_dqs_p_fpga[dqswd]),
        .B             (ddr2_dqs_p_sdram[dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );

      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_n
       (
        .A             (ddr2_dqs_n_fpga[dqswd]),
        .B             (ddr2_dqs_n_sdram[dqswd]),
        .reset         (sys_rst_n),
        .phy_init_done (init_calib_complete)
       );
    end
  endgenerate
    

    

  //===========================================================================
  //                         FPGA Memory Controller
  //===========================================================================
  ddr_top # // changed for nexys4
    (
    .WAIT_TIME_US(WAIT_TIME_US),
    .PARITY(PARITY),
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD_RATE(BAUD_RATE)
    )
   u_ip_top
     (

      .CLK100MHZ(sys_clk_i),
      .CPU_RESETN(sys_rst),
      .BTNC(btnc),
      .BTNU(btnu),
      .LED(),
      .LED16_B(calibration_done),
      .UART_TXD_IN(tb_tx_to_top),
      .UART_RXD_OUT(tb_rx_from_top),

     .ddr2_dq              (ddr2_dq_fpga),
     .ddr2_dqs_n           (ddr2_dqs_n_fpga),
     .ddr2_dqs_p           (ddr2_dqs_p_fpga),

     .ddr2_addr            (ddr2_addr_fpga),
     .ddr2_ba              (ddr2_ba_fpga),
     .ddr2_ras_n           (ddr2_ras_n_fpga),
     .ddr2_cas_n           (ddr2_cas_n_fpga),
     .ddr2_we_n            (ddr2_we_n_fpga),
     .ddr2_ck_p            (ddr2_ck_p_fpga),
     .ddr2_ck_n            (ddr2_ck_n_fpga),
     .ddr2_cke             (ddr2_cke_fpga),
     .ddr2_cs_n            (ddr2_cs_n_fpga),
    
     .ddr2_dm              (ddr2_dm_fpga),
    
     .ddr2_odt             (ddr2_odt_fpga)
    
     );

  //**************************************************************************//
  // Memory Models instantiations
  //**************************************************************************//

  genvar r,i;
  generate
    for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
      if(DQ_WIDTH/16) begin: mem
        for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
          ddr2_model u_comp_ddr2
            (
             .ck      (ddr2_ck_p_sdram[0+(NUM_COMP*r)]),
             .ck_n    (ddr2_ck_n_sdram[0+(NUM_COMP*r)]),
             .cke     (ddr2_cke_sdram[0+(NUM_COMP*r)]),
             .cs_n    (ddr2_cs_n_sdram[0+(NUM_COMP*r)]),
             .ras_n   (ddr2_ras_n_sdram),
             .cas_n   (ddr2_cas_n_sdram),
             .we_n    (ddr2_we_n_sdram),
             .dm_rdqs (ddr2_dm_sdram[(2*(i+1)-1):(2*i)]),
             .ba      (ddr2_ba_sdram),
             .addr    (ddr2_addr_sdram),
             .dq      (ddr2_dq_sdram[16*(i+1)-1:16*(i)]),
             .dqs     (ddr2_dqs_p_sdram[(2*(i+1)-1):(2*i)]),
             .dqs_n   (ddr2_dqs_n_sdram[(2*(i+1)-1):(2*i)]),
             .rdqs_n  (),
             .odt     (ddr2_odt_sdram[0+(NUM_COMP*r)])
             );
        end
      end
      if (DQ_WIDTH%16) begin: gen_mem_extrabits
        ddr2_model u_comp_ddr2
          (
           .ck      (ddr2_ck_p_sdram[0+(NUM_COMP*r)]),
           .ck_n    (ddr2_ck_n_sdram[0+(NUM_COMP*r)]),
           .cke     (ddr2_cke_sdram[0+(NUM_COMP*r)]),
           .cs_n    (ddr2_cs_n_sdram[0+(NUM_COMP*r)]),
           .ras_n   (ddr2_ras_n_sdram),
           .cas_n   (ddr2_cas_n_sdram),
           .we_n    (ddr2_we_n_sdram),
           .dm_rdqs ({ddr2_dm_sdram[DM_WIDTH-1],ddr2_dm_sdram[DM_WIDTH-1]}),
           .ba      (ddr2_ba_sdram),
           .addr    (ddr2_addr_sdram),
           .dq      ({ddr2_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)],
                      ddr2_dq_sdram[DQ_WIDTH-1:(DQ_WIDTH-8)]}),
           .dqs     ({ddr2_dqs_p_sdram[DQS_WIDTH-1],
                      ddr2_dqs_p_sdram[DQS_WIDTH-1]}),
           .dqs_n   ({ddr2_dqs_n_sdram[DQS_WIDTH-1],
                      ddr2_dqs_n_sdram[DQS_WIDTH-1]}),
           .rdqs_n  (),
           .odt     (ddr2_odt_sdram[0+(NUM_COMP*r)])
           );
      end
    end
  endgenerate
    
    


  //***************************************************************************
  // Reporting the test case statusclear_fifo
  // Status reporting logic exists both in simulation test bench (sim_tb_top)
  // and sim.do file for ModelSim. Any update in simulation run time or time out
  // in this file need to be updated in sim.do file as well.
  //***************************************************************************
  initial
  begin : Logging
     fork
        begin : calibration_done
           wait (init_calib_complete);
           $display("Calibration Done");
           #50000000.0;
           if (!tg_compare_error) begin
              $display("TEST PASSED");
           end
           else begin
              $display("TEST FAILED: DATA ERROR");
           end
           disable calib_not_done;
            $finish;
        end

        begin : calib_not_done
           if (SIM_BYPASS_INIT_CAL == "SIM_INIT_CAL_FULL")
             #2500000000.0;
           else
             #1000000000.0;
           if (!init_calib_complete) begin
              $display("TEST FAILED: INITIALIZATION DID NOT COMPLETE");
           end
           disable calibration_done;
            $finish;
        end
     join
  end

  // UART stuff
  logic tb_tx_busy, tb_tx_send, new_data_from_tx, tb_rx_busy;
  logic [7:0] tb_rx_data, tb_tx_data;

  tx #(.PARITY(PARITY), .CLK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE))
  tx(.clk(sys_clk_i), .rst(~sys_rst),
    .send(tb_tx_send), .din(tb_rx_data), .busy(tb_tx_busy), .tx_out(tb_tx_to_top));

  // Testbench receiver
  rx #(.CLK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE), .PARITY(PARITY))
  rx(.clk(sys_clk_i), .rst(~sys_rst),
    .Sin(tb_rx_from_top), .Dout(tb_tx_data), .busy(tb_rx_busy),
      .ReceiveAck(new_data_from_tx), .Receive(new_data_from_tx), .parityErr());
  always_ff @(posedge sys_clk_i) begin
    if (new_data_from_tx) begin
      $display("[%0t] TB Received Data from TX FIFO: 0x%0h ('%c')", $time, tb_tx_data, tb_tx_data);
    end
  end

  // Create a queue of bytes to send
  logic [7:0] tx_data_queue[$];
  // Always block to send data from the queue
  always @(negedge sys_clk_i) begin
    if (~tb_tx_busy && (tx_data_queue.sisim:/ddr_top_tb/u_ip_top/rx_fifo_out_data
ze() > 0)) begin
      // Blocking used because I need to assign it immediately
      repeat(200) @(negedge sys_clk_i);
      tb_rx_data = tx_data_queue.pop_front();
      tb_tx_send <= 1;
      $display("[%0t] TB Sending Data to RX FIFO: 0x%0h ('%c')", $time, tb_rx_data, tb_rx_data);
    end else  begin
      tb_tx_send <= 0;
    end
  end

  string test_string = "Hello, ECEN 520 World!";
  initial begin
    btnc = 0;
    btnu = 0;
    // Wait for calibration to complete
    wait (calibration_done);
    $display("[%0t] Calibration Done", $time);

    repeat(1000) @(negedge sys_clk_i);
    // Send test data
    foreach (test_string[i]) begin
      tx_data_queue.push_back(test_string[i]);
    end
    // Wait until the queue is empty and the transmitter is not busy
    wait ((tx_data_queue.size() == 0) && ~tb_tx_busy);
    repeat(1000) @(negedge sys_clk_i);
    $display("[%0t] Data transferred", $time);
    // Press button
    wait (~tb_tx_busy)
    repeat(1000) @(negedge sys_clk_i);
    btnc = 1;
    // wait until all bytes have transmitted
    for (int i=0; i<test_string.len(); i=i+1) begin
      wait (new_data_from_tx == 1);
      wait (new_data_from_tx == 0);
    end
    btnc = 0;

    repeat(10000) @(negedge sys_clk_i);
    $stop;
  end

endmodule

