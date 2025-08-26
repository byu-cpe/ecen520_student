//////////////////////////////////////////////////////////////////////////////////
// TX testbench
//////////////////////////////////////////////////////////////////////////////////

module tx_tb ();

    parameter NUMBER_OF_CHARS = 20;
    parameter BAUD_RATE = 19_200;
    parameter CLK_FREQUENCY = 100_000_000;
    parameter PARITY = 0;
    localparam BAUD_CLOCKS = CLK_FREQUENCY / BAUD_RATE;

    logic clk, rst, tb_send, tb_tx_out, tx_busy;
    logic [7:0] tb_din;
    logic [7:0] char_to_send = 0;
    logic [7:0] rx_data;
    logic odd_parity_calc = 1'b0;
    logic rx_busy, rx_model_err;
    int errors = 0;

    typedef enum { UNINIT, IDLE, BUSY } receive_state_type;
    receive_state_type r_state = UNINIT;

    //////////////////////////////////////////////////////////////////////////////////
    // Instantiate Desgin Under Test (DUT)
    //////////////////////////////////////////////////////////////////////////////////

    tx #(.CLK_FREQUENCY(CLK_FREQUENCY),.BAUD_RATE(BAUD_RATE),.PARITY(PARITY))
    tx(
        .clk(clk),
        .rst(rst),
        .send(tb_send),
        .din(tb_din),
        .tx_out(tb_tx_out),
        .busy(tx_busy)
    );

    //////////////////////////////////////////////////////////////////////////////////
    // Instantiate RX simulation model
    //////////////////////////////////////////////////////////////////////////////////

    rx_model #(.CLK_FREQUENCY(CLK_FREQUENCY),.BAUD_RATE(BAUD_RATE),.PARITY(PARITY))
    rx_model(
        .clk(clk),
        .rst(rst),
        .rx_in(tb_tx_out),
        .busy(rx_busy),
        .dout(rx_data),
        .err(rx_model_err)
    );

    //////////////////////////////////////////////////////////////////////////////////
    // Clock Generator
    //////////////////////////////////////////////////////////////////////////////////
    always
    begin
        #5ns clk <=1;
        #5ns clk <=0;
    end

    // Task for initiating a transfer
    task initiate_tx( input [7:0] char_value );

        // Initiate transfer on negative clock edge
        @(negedge clk)
        $display("[%0t] Transmitting 0x%h", $time, char_to_send);

        // set inputs
        tb_send = 1;
        tb_din = char_value;

        // Wait a clock
        @(negedge clk)

        // Wait until busy goes high or reset is asserted
        wait (tx_busy == 1'b1 || rst == 1'b1);

        // Deassert send
        @(negedge clk)
        tb_send = 0;
    endtask

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        int clocks_to_delay;
        $display("===== TX TB =====");

        // Simulate some time with no stimulus/reset
        #100ns

        // Set some defaults
        rst = 0;
        tb_send = 0;
        tb_din = 8'hff;
        #100ns

        //Test Reset
        $display("[%0t] Testing Reset", $time);
        rst = 1;
        #80ns;
        // Un reset on negative edge
        @(negedge clk)
        rst = 0;

        // Make sure tx is high
        @(negedge clk)
        if (tb_tx_out != 1'b1) begin
            $display("[%0t] Warning: TX out not high after reset", $time);
            errors = errors + 1;
        end

        //////////////////////////////////
        // Transmit a few characters to design
        //////////////////////////////////
        #10us;
        for(int i = 0; i < NUMBER_OF_CHARS; i++) begin
            char_to_send = $urandom_range(0,255);
            initiate_tx(char_to_send);
            // Wait until transmission is over
            wait (tx_busy == 1'b0);
            // check to see that character received is the one that was sent
            if (rx_data != char_to_send) begin
                $display("\[%0t] WARNING: Received 0x%h instead of 0x%h", $time/1000,rx_data,char_to_send);
                errors = errors + 1;
            end
            // Delay a random amount of time
            clocks_to_delay = $urandom_range(1000,30000);
            repeat(clocks_to_delay)
                @(negedge clk);
        end

        // Issue a reset in the middle of a transmission
        initiate_tx(8'ha5);
        // Wait 4 baud periods
        repeat(BAUD_CLOCKS * 4)
            @(negedge clk);
        // Issue reset
        $display("[%0t] Testing reset of TX in middle of transaction", $time);
        rst = 1;
        #20ns;
        // Un reset on negative edge
        @(negedge clk)
        rst = 0;
        // Make sure tx is high and no longer busy
        repeat(2)
            @(negedge clk);
        if (tb_tx_out != 1'b1) begin
            $display("[%0t] Warning: TX out not high after reset", $time);
            errors = errors + 1;
        end
        if (tx_busy != 1'b0) begin
            $display("[%0t] Warning: busy is high after reset", $time);
            errors = errors + 1;
        end
        // Wait 4 baud periods
        repeat(BAUD_CLOCKS * 4)
            @(negedge clk);

        if (errors == 0 && rx_model_err == 0)
            $display("[%0t] Test Passed", $time);
        else
            $error("[%0t] Test Failed with %0d errors", $time, errors);
        $stop;
    end

endmodule
