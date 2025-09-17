//////////////////////////////////////////////////////////////////////////////////
// gen_bounce: generate a bounce signal for testing a debouncer
//////////////////////////////////////////////////////////////////////////////////

module gen_bounce #(parameter BOUNCE_CLOCKS_LOW_RANGE=5000, BOUNCE_CLOCKS_HIGH_RANGE=150000) (clk, sig_in, bounce_out);

    input logic clk, sig_in;
    output logic bounce_out;

    parameter integer CLK_FREQUENCY     = 100_000_000;
    parameter integer WAIT_TIME_US      = 5000;
    parameter real MIN_BOUNCE_CLOCKS_FRACTION = 0.01;      // Minimum bounce as a fraction of WAIT_CLOCKS
    parameter real MAX_BOUNCE_CLOCKS_FRACTION = 0.3;       // Maximum bounce as a fraction of WAIT_CLOCKS
    parameter integer NUM_BOUNCES_LOW_RANGE = 2;            // The minimum number of bounces per transition
    parameter integer NUM_BOUNCES_HIGH_RANGE = 6;           // The maximum number of bounces per transition
    parameter integer VERBOSE = 0;                          // Set verbose to 1 to print debug messages

    localparam integer WAIT_CLOCKS = CLK_FREQUENCY / 1_000_000 * WAIT_TIME_US;


    // Random number generator for bounce clocks
    function int get_bounce_clocks;
        get_bounce_clocks = $urandom_range(BOUNCE_CLOCKS_LOW_RANGE, BOUNCE_CLOCKS_HIGH_RANGE);
    endfunction

    // Random number generator for number of bounces
    function int get_bounce_number;
        get_bounce_number = $urandom_range(NUM_BOUNCES_LOW_RANGE, NUM_BOUNCES_HIGH_RANGE);
    endfunction

    // Task for generating a bounce delay.
    task bounce_delay(input expected_sig_in);
        integer bounce_delay_clocks;
        bounce_delay_clocks = get_bounce_clocks();
        repeat(bounce_delay_clocks) begin
            @(posedge clk);
            if (sig_in != expected_sig_in)
                return;
        end
    endtask

    initial begin
        // Wait until sig_in is stable ('0' or '1') before doing anything
        repeat(5) @(posedge clk);  // Wait a clock before checking sig_in
        while( (sig_in === 1'bx) || (sig_in === 1'bz) ) begin // have to use === when looking for 'x' or 'z'
            // Continue waiting until sig_in is stable
            @(posedge clk);
        end
        // Set the stable value of sig_in after a stable value has been clocked
        bounce_out = sig_in;
        // Continuosly monitor sig_in for changes
        forever begin
            @(negedge clk)
            if (sig_in != bounce_out) begin
                bounce(sig_in);
            end
        end
    end

    // Task for generating a bouncy signal. The end result is the final value of debounce_out.
    // The sig_in input should be the 'end_result'. If it is not, then abandone the bounce.
    task bounce(input end_result);
        integer bounces;
        bounces = get_bounce_number();
        for(int i = 0; i < bounces; i++) begin
            // Set bounce_out to the opposite of the end result
            bounce_out = ~end_result;
            // Delay before edge of bounce towards end result
            bounce_delay(end_result);
            // Check to see if the signal has changed back to the original value. If so, abandon the rest of the bounce
            if (sig_in != end_result)
                return;
            // Set bounce_out to end result
            bounce_out = end_result;
            // Delay before changing back away from end result
            if (i < bounces - 1) // Do not delay if this is the last bounce
                bounce_delay(end_result);
        end
    endtask

endmodule
