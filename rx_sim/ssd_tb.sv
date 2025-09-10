`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TX top-level testbench
//////////////////////////////////////////////////////////////////////////////////

module ssd_tb ();

    parameter int CLK_FREQUENCY = 100_000_000;   // 100 MHz
    parameter int MIN_SEGMENT_DISPLAY_US = 10;
    parameter int NUMBER_OF_VALUES = 6;

    logic clk, rst, blank;
    logic [31:0] display_val;
    logic [7:0] dp;
    logic [6:0] segments;
    logic dp_out;
    logic [7:0] an_out;
    logic new_value;
    logic [31:0] output_display_val;

    // Instance seven_segment module
    seven_segment #(.CLK_FREQUENCY(CLK_FREQUENCY), .MIN_SEGMENT_DISPLAY_US(MIN_SEGMENT_DISPLAY_US))
    ssd(.clk(clk), .rst(rst), .display_val(display_val), .dp(dp), .blank(blank),
        .segments(segments), .dp_out(dp_out), .an_out(an_out));

    // Instance seven_segment_check module
    seven_segment_check #(.CLK_FREQUENCY(CLK_FREQUENCY), .MIN_SEGMENT_DISPLAY_US(MIN_SEGMENT_DISPLAY_US))
    ssd_check(.clk(clk), .rst(rst), .dp(dp_out),
        .segments(segments), .anode(an_out), .new_value(new_value),
        .output_display_val(output_display_val));

    // Clock Generator
    always
    begin
        #5ns clk <=1;
        #5ns clk <=0;
    end

    task automatic set_ssd_value(logic [31:0] value_to_display, logic [7:0] dp_value_to_display);
        @(negedge clk)
        // Set a full value to display
        display_val = value_to_display;
        dp = dp_value_to_display;
        @(negedge clk);
        wait(new_value == 1'b1);
        @(negedge clk);
        if (output_display_val != value_to_display) begin
            $display("Error: Display value mismatch: %h != %h", output_display_val, value_to_display);
        end
    endtask //automatic

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        int clocks_to_delay;
        $display("===== Seven Segment Display TB =====");

        // Simulate some time with no stimulus/reset
        #100ns

        // Set some defaults
        rst = 0;
        blank = 0;
        display_val = 0;
        dp = 0;
        #100ns

        //Test Reset
        @(negedge clk);
        $display("[%0tns] Reset", $time/1000.0);
        rst = 1;
        repeat(5) @(negedge clk)
        // Un reset on negative edge
        rst = 0;


        set_ssd_value(32'hfedcba98,8'b11111111);
        set_ssd_value(32'h76543210,8'b00000000);
        set_ssd_value(32'ha5a5a5a5,8'b10101010);
        set_ssd_value(32'h5a5a5a5a,8'b01010101);
        set_ssd_value(32'hdeadbeef,8'b11110000);

        for(int i=0; i <NUMBER_OF_VALUES; i++) begin
            // Set a full value to display
            set_ssd_value($urandom_range(0, 32'hffffffff),$urandom_range(0, 8'hff));
            // display_val = $urandom_range(0, 32'hffffffff);
            // dp = $urandom_range(0, 8'hff);
            // @(negedge clk);
            // wait(new_value == 1'b1);
            // @(negedge clk);
        end
        $stop;
    end

endmodule
