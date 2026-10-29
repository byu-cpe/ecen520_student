//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: metastability_top.sv
//
//  Author: Mike Wirthlin
//
//  Class: ECEN 520
//
//  Description:
//    Top-level design for the metastability experiment on the Nexys4 DDR board.
//
//    The experiment samples an asynchronous toggling signal and checks whether
//    the sampling flip-flop has settled a short, adjustable time (delta) after
//    the clock edge:
//      * data_tog (CFGMCLK) toggles every CFGMCLK cycle. CFGMCLK is the internal
//        configuration oscillator of the FPGA (nominally 65 MHz) and is
//        unrelated to the board clock.
//      * ff_a   (clk_a): samples data_tog (this flip-flop can go metastable)
//      * ff_b   (clk_b): early sample of ff_a, delta after the clk_a edge
//      * ff_c   (clk_a): late sample of ff_a, one full clk_a period later (settled value)
//      * ff_b2  (clk_a): moves the early sample into the clk_a domain, aligned with ff_c
//      * err   = ff_b2 ^ ff_c : ff_a had not settled within delta
//      * trans = ff_c changed : ff_a changed value
//
//    An MMCM generates clk_a and clk_b (200 MHz). clk_b is delayed by delta
//    using the MMCM fine dynamic phase shift (one step = 1/56 of the VCO
//    period, about 17.9 ps with the 1000 MHz VCO used here). err and trans are
//    counted for one second and displayed on the seven segment display.
//
//    Sweep delta and plot err_count / trans_count against delta:
//      * small delta: every transition is an error (normal clock-to-Q + route delay)
//      * larger delta: the error ratio drops sharply (blurred by clock jitter)
//      * beyond the drop: a small exponential tail caused by metastability
//
//  Controls:
//    * BTNU / BTND: increase / decrease delta by one step (about 17.9 ps)
//    * BTNL / BTNR: increase / decrease delta by COARSE_STEPS steps (about 143 ps)
//      (delta is limited to the range 0 to MAX_PHASE_STEPS steps)
//    * CPU_RESETN: reset (delta returns to zero)
//    * SW[1:0]: display select
//        00: err_count   (errors in the last one second measurement)
//        01: trans_count (transitions in the last measurement; this is also
//                         the CFGMCLK frequency in Hz)
//        10: delta       (steps in the left four digits, ps in the right four digits)
//        11: number of measurements since reset
//    * SW[2]: 0 = decimal display, 1 = hexadecimal display. In decimal mode,
//      the leftmost digit point indicates that the value is larger than 99,999,999.
//
//  LEDs:
//    * LED[0]: detector MMCM locked
//    * LED[1]: measurement valid (a full measurement has completed since delta
//              last changed). Wait for this LED before recording err_count and
//              trans_count.
//    * LED[2]: toggles each time a new measurement is available (once per second)
//    * LED[3]: delta is at its minimum or maximum value
//
//  Dependencies:
//    * seven_segment8 (rx_sim assignment)
//    * debounce (tx_download assignment)
//
//////////////////////////////////////////////////////////////////////////////////

module metastability_top #(
    parameter integer CLK_FREQUENCY = 100_000_000, // Board clock frequency (the MMCM settings below require 100 MHz)
    parameter integer REFRESH_RATE = 200,          // Seven segment display refresh rate (Hz)
    parameter integer DEBOUNCE_TIME_US = 10_000,   // Button debounce time (us)
    parameter integer GATE_CYCLES = 200_000_000,   // clk_a cycles per measurement (one second at 200 MHz)
    parameter integer COARSE_STEPS = 8,            // Phase shift steps per coarse button press (about 143 ps)
    parameter integer MAX_PHASE_STEPS = 140        // Maximum delta in steps (2.5 ns)
    ) (
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic BTNU,
    input logic BTND,
    input logic BTNL,
    input logic BTNR,
    input logic [2:0] SW,
    output logic [3:0] LED,
    output logic [7:0] AN,
    output logic CA,
    output logic CB,
    output logic CC,
    output logic CD,
    output logic CE,
    output logic CF,
    output logic CG,
    output logic DP
    );

    // Detector MMCM settings: VCO = 100 MHz * 10 / 1 = 1000 MHz; clk_a = clk_b = 1000 MHz / 5 = 200 MHz
    localparam real CLK_PERIOD_NS = 1_000_000_000.0 / CLK_FREQUENCY;
    localparam real VCO_MULTIPLY = 10.0;
    localparam integer VCO_DIVIDE = 1;
    localparam integer DETECT_CLK_DIVIDE = 5;

    // Delta display: ps = steps * 17.857 ps (computed as steps * 18286 / 1024)
    localparam integer PS_PER_STEP_X1024 = 18286;
    localparam integer PS_SHIFT = 10;
    localparam integer PHASE_DISPLAY_SCALE = 10_000;  // Places steps in the left four decimal digits

    localparam integer RESET_FFS = 4;
    localparam integer NUM_BUTTONS = 4;
    localparam integer GATE_WIDTH = $clog2(GATE_CYCLES);
    localparam integer STEPS_WIDTH = $clog2(COARSE_STEPS + 1);
    localparam integer PHASE_WIDTH = $clog2(MAX_PHASE_STEPS + 1);
    localparam integer BIN_WIDTH = 32;
    localparam integer BCD_DIGITS = 10;      // Number of decimal digits in a 32-bit value
    localparam integer DISPLAY_DIGITS = 8;
    localparam integer BCD_COUNT_WIDTH = $clog2(BIN_WIDTH + 1);
    localparam integer VALID_MEASUREMENTS = 2;  // Measurements after a delta change before the result is valid

    // Display select values (SW[1:0])
    localparam logic [1:0] DISPLAY_ERR = 2'b00;
    localparam logic [1:0] DISPLAY_TRANS = 2'b01;
    localparam logic [1:0] DISPLAY_PHASE = 2'b10;
    localparam logic [1:0] DISPLAY_MEASUREMENTS = 2'b11;
    localparam logic [7:0] PHASE_DP = 8'b0001_0000;    // Digit point between steps and ps
    localparam logic [7:0] OVERFLOW_DP = 8'b1000_0000; // Leftmost digit point

    // Phase shift state machine states
    typedef enum logic [1:0] {PS_IDLE, PS_SHIFT_STATE, PS_WAIT} ps_state_t;

    // Board clock, reset, and inputs
    logic clk, rst;
    (* ASYNC_REG = "TRUE" *) logic [1:0] rst_sync;
    (* ASYNC_REG = "TRUE" *) logic [2:0] sw_d, sw_dd;
    (* ASYNC_REG = "TRUE" *) logic [NUM_BUTTONS-1:0] btn_d, btn_dd;
    logic [NUM_BUTTONS-1:0] btn_debounced, btn_debounced_d, btn_pulse;
    genvar i;

    // Asynchronous data clock (CFGMCLK)
    logic cfgmclk, clk_cfg;

    // Detector clocking
    logic mmcm_clkfb, mmcm_locked;
    logic clk_a_int, clk_b_int, clk_a, clk_b;
    logic ps_en, ps_incdec, ps_done;
    (* ASYNC_REG = "TRUE" *) logic [1:0] locked_sync;
    logic locked;

    // Phase shift control
    ps_state_t ps_state;
    logic phase_inc_fine, phase_dec_fine, phase_inc_coarse, phase_dec_coarse;
    logic [NUM_BUTTONS-1:0] ps_requests;
    logic ps_request_valid, ps_request_inc, ps_request_coarse, ps_request_in_range, ps_request_accept;
    logic [STEPS_WIDTH-1:0] ps_request_steps, steps_left;
    logic [PHASE_WIDTH-1:0] phase_step;

    // clk_a domain reset
    logic [RESET_FFS-1:0] rst_a_sr;
    logic rst_a;

    // Asynchronous data source (initial value loaded at configuration)
    logic data_tog = 1'b0;

    // Detector flip-flops (DONT_TOUCH prevents synthesis from merging or optimizing them)
    (* DONT_TOUCH = "TRUE" *) logic ff_a, ff_b, ff_c, ff_b2;
    logic ff_c_d, err, trans;

    // Measurement counters (clk_a domain)
    logic [GATE_WIDTH-1:0] gate_cnt;
    logic gate_done;
    logic [31:0] err_cnt, trans_cnt, err_hold, trans_hold;
    logic snap_tog;

    // Measurement results (clk domain)
    (* ASYNC_REG = "TRUE" *) logic [1:0] snap_sync;
    logic snap_sync_d, snap_new;
    logic [31:0] err_count, trans_count, measurement_count;
    logic count_update, update_toggle;
    logic [1:0] measurements_since_step;
    logic measurement_valid;

    // Display
    logic [31:0] phase_ps, phase_display, display_value;
    logic [BIN_WIDTH-1:0] bcd_bin;
    logic [4*BCD_DIGITS-1:0] bcd_work;
    logic [4*BCD_DIGITS+BIN_WIDTH-1:0] bcd_shifted;
    logic [BCD_COUNT_WIDTH-1:0] bcd_count;
    logic [4*DISPLAY_DIGITS-1:0] decimal_digits;
    logic decimal_overflow;
    logic [31:0] ssd_data;
    logic [7:0] ssd_dp;

    ////////////////////////////////////////////////////////////////////
    // Board clock, reset, and inputs
    ////////////////////////////////////////////////////////////////////

    // The board clock drives the control logic and the detector MMCM
    // (Vivado inserts the IBUF and BUFG).
    assign clk = CLK100MHZ;

    // Reset synchronizer. No reset: this is the reset synchronizer.
    always_ff @(posedge clk)
        rst_sync <= {rst_sync[0], ~CPU_RESETN};
    assign rst = rst_sync[1];

    // Switch synchronizer. No reset: synchronizer only.
    always_ff @(posedge clk) begin
        sw_d <= SW;
        sw_dd <= sw_d;
    end

    // Button synchronizer. No reset: synchronizer only.
    always_ff @(posedge clk) begin
        btn_d <= {BTNU, BTND, BTNL, BTNR };
        btn_dd <= btn_d;
    end

    // Button debouncers (one for each phase control button)
    generate
        for (i = 0; i < NUM_BUTTONS; i++) begin : button_debounce
            debounce #(.CLK_FREQUENCY(CLK_FREQUENCY), .WAIT_TIME_US(DEBOUNCE_TIME_US))
            debounce_inst (.clk(clk), .rst(rst), .noisy(btn_dd[i]), .debounced(btn_debounced[i]));
        end
    endgenerate

    // One-shot: a single-cycle pulse for each button press
    always_ff @(posedge clk) begin
        if (rst)
            btn_debounced_d <= '0;
        else
            btn_debounced_d <= btn_debounced;
    end
    assign btn_pulse = btn_debounced & ~btn_debounced_d;
    assign {phase_inc_fine, phase_dec_fine, phase_inc_coarse, phase_dec_coarse} = btn_pulse;

    ////////////////////////////////////////////////////////////////////
    // Clocking
    ////////////////////////////////////////////////////////////////////

    // STARTUPE2: provides the internal configuration oscillator (CFGMCLK).
    // All other functions of this primitive are unused.
    STARTUPE2 #(
        .PROG_USR("FALSE"),
        .SIM_CCLK_FREQ(0.0)
    )
    startup_inst (
        .CFGCLK(),
        .CFGMCLK(cfgmclk),
        .EOS(),
        .PREQ(),
        .CLK(1'b0),
        .GSR(1'b0),
        .GTS(1'b0),
        .KEYCLEARB(1'b1),
        .PACK(1'b0),
        .USRCCLKO(1'b0),
        .USRCCLKTS(1'b1),     // Do not drive the configuration clock pin
        .USRDONEO(1'b1),
        .USRDONETS(1'b1)      // Do not drive the DONE pin
    );

    // Global clock buffer for CFGMCLK
    BUFG cfgmclk_bufg(.I(cfgmclk), .O(clk_cfg));

    // Detector MMCM: clk_a (CLKOUT0) and clk_b (CLKOUT1, fine dynamic phase shift).
    // Internal feedback is used since clk_a and clk_b only need a known phase
    // relationship with each other (not with the board clock).
    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(VCO_MULTIPLY),
        .CLKFBOUT_PHASE(0.000),
        .CLKIN1_PERIOD(CLK_PERIOD_NS),
        .DIVCLK_DIVIDE(VCO_DIVIDE),
        // clk_a: 200 MHz, 50% duty cycle, no phase shift
        .CLKOUT0_DIVIDE_F(DETECT_CLK_DIVIDE),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_PHASE(0.000),
        // clk_b: 200 MHz, 50% duty cycle, phase adjusted with the dynamic phase shift
        .CLKOUT1_DIVIDE(DETECT_CLK_DIVIDE),
        .CLKOUT1_DUTY_CYCLE(0.500),
        .CLKOUT1_PHASE(0.000),
        .CLKOUT1_USE_FINE_PS("TRUE")
    )
    detector_mmcm (
        .CLKFBOUT(mmcm_clkfb),
        .CLKFBOUTB(),
        .CLKOUT0(clk_a_int),
        .CLKOUT0B(),
        .CLKOUT1(clk_b_int),
        .CLKOUT1B(),
        .CLKOUT2(),
        .CLKOUT2B(),
        .CLKOUT3(),
        .CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKOUT6(),
        .DO(),
        .DRDY(),
        .PSDONE(ps_done),
        .CLKINSTOPPED(),
        .CLKFBSTOPPED(),
        .LOCKED(mmcm_locked),
        .CLKIN1(clk),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),            // Select CLKIN1
        .CLKFBIN(mmcm_clkfb),
        .DADDR(7'h00),              // Dynamic reconfiguration port not used
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI(16'h0000),
        .DWE(1'b0),
        .PSCLK(clk),
        .PSEN(ps_en),
        .PSINCDEC(ps_incdec),
        .PWRDWN(1'b0),
        .RST(rst)
    );

    // Global clock buffers for the two detector clocks
    BUFG clk_a_bufg(.I(clk_a_int), .O(clk_a));
    BUFG clk_b_bufg(.I(clk_b_int), .O(clk_b));

    ////////////////////////////////////////////////////////////////////
    // Phase shift control (clk domain)
    ////////////////////////////////////////////////////////////////////

    // Synchronize the MMCM locked signal into the clk domain.
    // No reset: this is a synchronizer and LOCKED is low while the MMCM is in reset.
    always_ff @(posedge clk)
        locked_sync <= {locked_sync[0], mmcm_locked};
    assign locked = locked_sync[1];

    // Phase requests: accept a request only when exactly one button is pressed
    // and the resulting delta stays within 0 to MAX_PHASE_STEPS
    assign ps_requests = btn_pulse;
    assign ps_request_valid = (ps_requests != '0) && ((ps_requests & (ps_requests - 1)) == '0);
    assign ps_request_inc = phase_inc_fine | phase_inc_coarse;
    assign ps_request_coarse = phase_inc_coarse | phase_dec_coarse;
    assign ps_request_steps = ps_request_coarse ? STEPS_WIDTH'(COARSE_STEPS) : STEPS_WIDTH'(1);
    assign ps_request_in_range = ps_request_inc ? (phase_step + ps_request_steps <= MAX_PHASE_STEPS) :
                                                  (phase_step >= ps_request_steps);
    assign ps_request_accept = (ps_state == PS_IDLE) && locked && ps_request_valid && ps_request_in_range;

    // Phase shift state machine: issues one PSEN pulse per phase shift step
    // (one step for a fine request, COARSE_STEPS steps for a coarse request)
    // and waits for PSDONE after each step.
    always_ff @(posedge clk) begin
        if (rst) begin
            ps_state <= PS_IDLE;
            ps_en <= 1'b0;
            ps_incdec <= 1'b0;
            steps_left <= '0;
            phase_step <= '0;
        end
        else begin
            ps_en <= 1'b0;  // PSEN is a single-cycle pulse
            case (ps_state)
                // Idle: accept a request and determine the number of steps
                PS_IDLE:
                    if (ps_request_accept) begin
                        ps_incdec <= ps_request_inc;
                        steps_left <= ps_request_steps;
                        ps_state <= PS_SHIFT_STATE;
                    end
                // Shift: issue a PSEN pulse for one phase shift step
                PS_SHIFT_STATE: begin
                    ps_en <= 1'b1;
                    phase_step <= ps_incdec ? phase_step + 1 : phase_step - 1;
                    steps_left <= steps_left - 1;
                    ps_state <= PS_WAIT;
                end
                // Wait: the MMCM asserts PSDONE when the step has completed
                PS_WAIT:
                    if (ps_done) begin
                        if (steps_left == 0)
                            ps_state <= PS_IDLE;
                        else
                            ps_state <= PS_SHIFT_STATE;
                    end
                default:
                    ps_state <= PS_IDLE;
            endcase
        end
    end

    ////////////////////////////////////////////////////////////////////
    // Detector
    ////////////////////////////////////////////////////////////////////

    // Asynchronous data source: toggles every CFGMCLK cycle.
    // No reset: there is no reset in the CFGMCLK domain (the initial value is
    // loaded at configuration) and the value of the toggle does not matter.
    always_ff @(posedge clk_cfg)
        data_tog <= ~data_tog;

    // Sampling flip-flop (can go metastable) and late sample.
    // No reset: these flip-flops continuously sample and flush any startup value
    // within two cycles (the counters that use them are reset).
    always_ff @(posedge clk_a) begin
        ff_a <= data_tog;
        ff_c <= ff_a;
        ff_c_d <= ff_c;
    end

    // Early sample of ff_a, delta after the clk_a edge.
    // No reset: same reason as the sampling flip-flops.
    always_ff @(posedge clk_b)
        ff_b <= ff_a;

    // Bring the early sample into the clk_a domain and compare it with the late sample.
    // No reset: same reason as the sampling flip-flops.
    always_ff @(posedge clk_a) begin
        ff_b2 <= ff_b;
        err <= ff_b2 ^ ff_c;
        trans <= ff_c ^ ff_c_d;
    end

    ////////////////////////////////////////////////////////////////////
    // Measurement (clk_a domain)
    ////////////////////////////////////////////////////////////////////

    // clk_a domain reset: preset when the MMCM is not locked, released
    // synchronously to clk_a.
    always_ff @(posedge clk_a or negedge mmcm_locked) begin
        if (!mmcm_locked)
            rst_a_sr <= '1;
        else
            rst_a_sr <= {rst_a_sr[RESET_FFS-2:0], 1'b0};
    end
    assign rst_a = rst_a_sr[RESET_FFS-1];

    // Gate counter: defines the measurement interval
    always_ff @(posedge clk_a) begin
        if (rst_a)
            gate_cnt <= '0;
        else begin
            if (gate_done)
                gate_cnt <= '0;
            else
                gate_cnt <= gate_cnt + 1;
        end
    end
    assign gate_done = (gate_cnt == GATE_CYCLES - 1);

    // Error and transition counters: restart at the end of each interval
    always_ff @(posedge clk_a) begin
        if (rst_a) begin
            err_cnt <= '0;
            trans_cnt <= '0;
        end
        else begin
            if (gate_done) begin
                err_cnt <= '0;
                trans_cnt <= '0;
            end
            else begin
                err_cnt <= err_cnt + err;
                trans_cnt <= trans_cnt + trans;
            end
        end
    end

    // Save the counts at the end of each interval and toggle snap_tog to signal
    // the clk domain. The saved values are stable for a full interval.
    always_ff @(posedge clk_a) begin
        if (rst_a) begin
            err_hold <= '0;
            trans_hold <= '0;
            snap_tog <= 1'b0;
        end
        else begin
            if (gate_done) begin
                err_hold <= err_cnt + err;
                trans_hold <= trans_cnt + trans;
                snap_tog <= ~snap_tog;
            end
        end
    end

    ////////////////////////////////////////////////////////////////////
    // Measurement results (clk domain)
    ////////////////////////////////////////////////////////////////////

    // Toggle synchronizer: detect each change of snap_tog in the clk domain
    always_ff @(posedge clk) begin
        if (rst) begin
            snap_sync <= '0;
            snap_sync_d <= 1'b0;
        end
        else begin
            snap_sync <= {snap_sync[0], snap_tog};
            snap_sync_d <= snap_sync[1];
        end
    end
    assign snap_new = snap_sync[1] ^ snap_sync_d;

    // Result registers: capture the saved counts when a new measurement is available
    always_ff @(posedge clk) begin
        if (rst) begin
            err_count <= '0;
            trans_count <= '0;
            count_update <= 1'b0;
        end
        else begin
            count_update <= snap_new;
            if (snap_new) begin
                err_count <= err_hold;
                trans_count <= trans_hold;
            end
        end
    end

    // Measurement status: total measurements, update indicator, and the number
    // of measurements completed since delta last changed (saturates)
    always_ff @(posedge clk) begin
        if (rst) begin
            measurement_count <= '0;
            update_toggle <= 1'b0;
            measurements_since_step <= '0;
        end
        else begin
            if (count_update) begin
                measurement_count <= measurement_count + 1;
                update_toggle <= ~update_toggle;
            end
            if (ps_request_accept)
                measurements_since_step <= '0;
            else if (count_update && (measurements_since_step != VALID_MEASUREMENTS))
                measurements_since_step <= measurements_since_step + 1;
        end
    end
    assign measurement_valid = (measurements_since_step == VALID_MEASUREMENTS);

    assign LED[0] = locked;
    assign LED[1] = measurement_valid;
    assign LED[2] = update_toggle;
    assign LED[3] = (phase_step == 0) || (phase_step == MAX_PHASE_STEPS);

    ////////////////////////////////////////////////////////////////////
    // Display
    ////////////////////////////////////////////////////////////////////

    // Delta in ps, and a combined value with steps in the left four decimal
    // digits and ps in the right four decimal digits
    assign phase_ps = (32'(phase_step) * PS_PER_STEP_X1024) >> PS_SHIFT;
    assign phase_display = 32'(phase_step) * PHASE_DISPLAY_SCALE + phase_ps;

    // Display select register
    always_ff @(posedge clk) begin
        if (rst)
            display_value <= '0;
        else begin
            case (sw_dd[1:0])
                DISPLAY_ERR: display_value <= err_count;
                DISPLAY_TRANS: display_value <= trans_count;
                DISPLAY_PHASE: display_value <= sw_dd[2] ? {16'(phase_step), phase_ps[15:0]} : phase_display;
                DISPLAY_MEASUREMENTS: display_value <= measurement_count;
                default: display_value <= err_count;
            endcase
        end
    end

    // Add 3 to each BCD digit that is 5 or greater (one step of the
    // double dabble binary to BCD conversion)
    function automatic logic [4*BCD_DIGITS-1:0] bcd_adjust(input logic [4*BCD_DIGITS-1:0] bcd);
        logic [4*BCD_DIGITS-1:0] result;
        result = bcd;
        for (int d = 0; d < BCD_DIGITS; d++)
            if (result[4*d +: 4] >= 4'd5)
                result[4*d +: 4] = result[4*d +: 4] + 4'd3;
        return result;
    endfunction

    assign bcd_shifted = {bcd_adjust(bcd_work), bcd_bin} << 1;

    // Binary to decimal (BCD) converter: converts the display value one bit
    // per clock cycle (double dabble) and starts a new conversion when done.
    always_ff @(posedge clk) begin
        if (rst) begin
            bcd_bin <= '0;
            bcd_work <= '0;
            bcd_count <= '0;
            decimal_digits <= '0;
            decimal_overflow <= 1'b0;
        end
        else begin
            if (bcd_count == 0) begin
                bcd_bin <= display_value;
                bcd_work <= '0;
                bcd_count <= BCD_COUNT_WIDTH'(BIN_WIDTH);
            end
            else begin
                {bcd_work, bcd_bin} <= bcd_shifted;
                bcd_count <= bcd_count - 1;
                if (bcd_count == 1) begin
                    decimal_digits <= bcd_shifted[BIN_WIDTH +: 4*DISPLAY_DIGITS];
                    decimal_overflow <= |bcd_shifted[BIN_WIDTH + 4*DISPLAY_DIGITS +: 4*(BCD_DIGITS-DISPLAY_DIGITS)];
                end
            end
        end
    end

    // Seven segment display data and digit points
    assign ssd_data = sw_dd[2] ? display_value : decimal_digits;
    assign ssd_dp = (!sw_dd[2] && decimal_overflow) ? OVERFLOW_DP :
                    (sw_dd[1:0] == DISPLAY_PHASE) ? PHASE_DP : 8'h00;

    // Seven segment display controller
    seven_segment8 #(.CLK_FREQUENCY(CLK_FREQUENCY), .REFRESH_RATE(REFRESH_RATE))
    ssd_inst (
        .clk(clk),
        .rst(1'b0),
        .data_in(ssd_data),
        .dp_in(ssd_dp),
        .blank(8'h00),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),
        .anode(AN)
    );

endmodule
