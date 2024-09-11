`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TX top-level testbench
//////////////////////////////////////////////////////////////////////////////////

module tx_top_tb ();

    logic clk, rst_n, rst, btnc, btnc_bouncy;
    logic [7:0] sw, sw_d, sw_dd;
    logic [7:0] led;
    logic tx_out;
    logic rx_busy;
    logic tx_busy;
    logic [7:0] rx_data;
    logic [7:0] char_to_send = 0;
    logic tx_initialized = 0;

    parameter integer DEBOUNCE_DELAY_US = 100;
    parameter logic PARITY = 1'd1;
    parameter integer BAUD_RATE = 19_200;
    parameter integer NUMBER_OF_CHARS = 5;

    localparam integer CLK_FREQUENCY = 100_000_000;
    localparam integer BOUNCE_CLOCKS = CLK_FREQUENCY / 1_000_000 * DEBOUNCE_DELAY_US;

    // Clock Generator
    always begin
        clk <=1; #5ns;
        clk <=0; #5ns;
    end

    // reset
    assign rst = ~rst_n;

    // Debounce simulation generator
    gen_bounce #(.BOUNCE_CLOCKS_LOW_RANGE(2), .BOUNCE_CLOCKS_HIGH_RANGE(20))
    bounce_btnc(
        .clk(clk),
        .sig_in(btnc),
        .bounce_out(btnc_bouncy)
    );

    // Instantiate Top-level design
    tx_top #(.DEBOUNCE_DELAY_US(DEBOUNCE_DELAY_US), .PARITY(PARITY), .BAUD_RATE(BAUD_RATE))
    tx_top(
        .CLK100MHZ(clk),
        .CPU_RESETN(rst_n),
        .SW(sw),
        .BTNC(btnc_bouncy),
        .LED(led),
        .UART_RXD_OUT(tx_out),
        .LED16_B(tx_busy)
    );

    // Instantiate RX simulation model
    rx_model #(.CLK_FREQUENCY(CLK_FREQUENCY), .PARITY(PARITY), .BAUD_RATE(BAUD_RATE))
    rx_model(
        .clk(clk),
        .rst(rst),
        .rx_in(tx_out),
        .busy(rx_busy),
        .dout(rx_data)
    );

    // Task for initiating a tx transfer
    task automatic initiate_tx( input [7:0] char_value );

        // set switches
        sw = char_value;
        repeat(100)
            @(negedge clk);

        // Press the button and wait enough clocks to get it to go through the debouncer
        $display("[%0tns] Pressing BTNC to transmit 0x%h", $time/1000.0, char_value);
        btnc = 1;
        repeat(BOUNCE_CLOCKS*1.1)
            @(negedge clk);
        // Wait until busy goes high
        wait (rx_busy == 1'b1);
        // Print a message when the character starts to transmit
        $display("[%0tns]  Transmission started", $time/1000.0);

        // Wait long enough for the zero to propagate through the debouncer
        btnc = 0;
        repeat(BOUNCE_CLOCKS*1.2)
            @(negedge clk);
        // Wait until busy goes low
        wait (rx_busy == 1'b0);

    endtask

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        int clocks_to_delay;
        $display("===== TX Top TB =====");
        $display("BAUD_RATE=%d PARITY=%d DEBOUNCE_DELAY_US %d BOUNCE_CLOCKS %d",
            BAUD_RATE, PARITY, DEBOUNCE_DELAY_US, BOUNCE_CLOCKS);

        // Simulate some time with no stimulus/reset while clock is running
        #100ns

        // Set some defaults and run some more
        rst_n = 1;
        btnc = 0;
        sw = 8'h00;
        #100ns

        // Issue the reset
        // Note that once the system has been reset testbench signals are changed on the negative edge of the clock
        $display("[%0tns] Reset", $time/1000.0);
        @(negedge clk);
        rst_n = 0;
        repeat (5) @(negedge clk);
        rst_n = 1;

        // Change the switches a bit to make sure the LEDs follow
        for(int i = 0; i < 10; i++) begin
            @(negedge clk);
            sw = $urandom_range(0,255);
            repeat(100)
                @(negedge clk);
        end
        sw = 8'h00;

        // Send a short signal that doesn't make it throught the debouncer
        $display("[%0tns] Sending some short bounces. Should not transmit", $time/1000.0);
        @(negedge clk)
        btnc = 1;
        repeat(BOUNCE_CLOCKS/2)
            @(negedge clk);
        btnc = 0;
        repeat(10)
            @(negedge clk);

        // Transmit a few characters to design
        for(int i = 0; i < NUMBER_OF_CHARS; i++) begin
            char_to_send = $urandom_range(0,255);
            initiate_tx(char_to_send);
            repeat(10000)
                @(negedge clk);
        end

        $stop;
    end

    // Signal to determine when the test bench has been initalized
    initial begin
        // Wait until the reset is asserted
        wait(rst_n == 0);
        // Wait until the reset is de-asserted
        wait(rst_n == 1);
        @(posedge clk);
        tx_initialized = 1;
    end

    // Check that the LEDs follow the switches
    always_ff @(posedge clk ) begin
        sw_d <= sw;
        sw_dd <= sw_d;
        if (tx_initialized && (sw_d == sw) && (sw_dd == sw)) begin
            // Only check leds and switches when the testbench has been initialized
            // and when there are no changes on the switches (some students may register the
            // switches and others may not)
            if (led != sw)
                $display("[%0tns] ERROR: LEDs do not follow switches LED=%h != SW=%h", $time/1000, led, sw);
        end
    end

endmodule
