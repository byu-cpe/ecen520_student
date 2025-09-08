//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb_debounce.sv
//
//////////////////////////////////////////////////////////////////////////////////

module tb_debounce #(
    parameter CLK_FREQUENCY     = 100_000_000,
    parameter WAIT_TIME_US      = 50,  // default is short for simulation
    parameter NUMBER_OF_PULSES  = 3
) ();

    localparam WAIT_CLOCKS = CLK_FREQUENCY / 1_000_000 * WAIT_TIME_US;
    localparam MAX_WAIT_CLOCKS = WAIT_CLOCKS + 1;
    localparam MIN_WAIT_CLOCKS = WAIT_CLOCKS - 1;
    localparam MIN_BOUNCE_CLOCKS = WAIT_CLOCKS / 50 + 1;
    localparam MAX_BOUNCE_CLOCKS = WAIT_CLOCKS / 2 + 2;
    localparam MIN_WAIT_NS = (WAIT_TIME_US - 1) * 1000;
    localparam MAX_WAIT_NS = (WAIT_TIME_US + 1) * 1000;
    localparam real CLK_HALF_PERIOD_NS = 1.0e9 / (2.0 * CLK_FREQUENCY);
    localparam MIN_CLOCKS_TO_WAIT_BEFORE_TRANSITION = 1000;
    localparam MAX_CLOCKS_TO_WAIT_BEFORE_TRANSITION = 10000;

    logic clk, sig_in, tb_noisy, tb_noisy_d, tb_debounced, tb_debounced_d, reset;

    integer i, j, errors, max_error, clk_count;
    time noisy_tt = 0; // noisy transition time
    time noisy_delay;

    // Instance the bounce generator
    gen_bounce #(.CLK_FREQUENCY(CLK_FREQUENCY), .WAIT_TIME_US(WAIT_TIME_US))
    gen_bounce (.clk(clk), .sig_in(sig_in), .bounce_out(tb_noisy));

    // Instance the debounce DUT
    debounce #(.CLK_FREQUENCY(CLK_FREQUENCY),.WAIT_TIME_US(WAIT_TIME_US))
    debounce (.clk(clk), .noisy(tb_noisy), .debounced(tb_debounced), .rst(reset));

    // Oscilating clock
    initial begin
        #105;
        clk = 0;
        forever begin
            #(CLK_HALF_PERIOD_NS) clk = ~clk;
        end
    end

    initial begin

        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);
        $display("** Start of Simulation: simulate %0d transitions, debouncer requires %0d clocks",
            NUMBER_OF_PULSES, WAIT_CLOCKS);

        // Initialize testbench inputs and parameters
        sig_in = 0;
        errors = 0;
        max_error = 0;
        reset = 0;

        // Run clock without a reset
        repeat(3) @(negedge clk);
        // Issue a reset
        reset = 1;
        repeat(3) @(negedge clk);
        // Release the reset
        reset = 0;
        @(negedge clk);
        repeat(100) @(negedge clk);

        // Generate pulses.
        for (int i=0; i<NUMBER_OF_PULSES; i=i+1) begin
            sig_in = 1;
            // wait until the signal has propagated to the debounce output
            wait (tb_debounced === 1'b1);
            // Wait a random amount of time before changing input to 0
            repeat ($urandom_range(MAX_CLOCKS_TO_WAIT_BEFORE_TRANSITION, 
                MIN_CLOCKS_TO_WAIT_BEFORE_TRANSITION)) @ (negedge clk);
            sig_in = 0;
            // wait until the signal has propagated to the debounce output
            wait (tb_debounced === 1'b0);
            // Wait a random amount of time before changing input to 0
            repeat ($urandom_range(MAX_CLOCKS_TO_WAIT_BEFORE_TRANSITION, 
                MIN_CLOCKS_TO_WAIT_BEFORE_TRANSITION)) @ (negedge clk);
        end
        $display("*** Simulation done, WAIT_TIME_US=%0d with %0d errors at time %0t ***",
            WAIT_TIME_US, errors, $time);
        $finish;

    end  // end initial begin

    // "Too early"/"Too late" checks
    // Identify the last time that the noisy has transitioned
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tb_noisy_d <= tb_noisy;
            tb_debounced_d <= tb_debounced;
            clk_count <= 0;
        end else begin
            tb_noisy_d <= tb_noisy;
            tb_debounced_d <= tb_debounced;

            if (tb_noisy_d != tb_noisy) begin
                // First positive edge in which noisy and noisy_d are different (start of first clock)
                clk_count <= 0;
                noisy_tt = $time;
                $display("[%0t] Noisy input changes to %0b", $time, tb_noisy);
            end else begin
                clk_count <= clk_count + 1;
            end

            if (tb_debounced_d != tb_debounced) begin
                $display("[%0t] Debounce change to %0b after %0d clocks", $time, tb_debounced, clk_count);
                if (clk_count < MIN_WAIT_CLOCKS) begin
                    $display("[%0t] *** Error: Debounce signal changed too soon after %0d clocks ***", $time, clk_count);
                    errors = errors + 1;
                end
                if (clk_count > MAX_WAIT_CLOCKS) begin
                    $display("[%0t] *** Error: Debounce signal changed too late after %0d clocks ***", $time, clk_count);
                    errors = errors + 1;
                end
            end
        end
    end

endmodule
