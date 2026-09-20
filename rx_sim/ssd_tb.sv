//////////////////////////////////////////////////////////////////////////////////
// Seven Segment Display testbench
//////////////////////////////////////////////////////////////////////////////////

module ssd_tb ();

    parameter int CLK_FREQUENCY = 100_000_000;   // 100 MHz
    parameter int REFRESH_RATE = 100_000; // 500 times the refresh rate of 200 Hz
    parameter int NUMBER_OF_VALUES = 6;
    localparam real CLK_HALF_PERIOD_NS = 1.0e9 / (2.0 * CLK_FREQUENCY);

    logic clk, rst;
    logic [7:0] blank;
    logic [31:0] data_in;
    logic [7:0] dp_in;
    // logic [7:0] segments;
    logic CA,CB,CC,CD,CE,CF,CG,DP;
    logic [7:0] anode;
    logic [7:0] blanked_segments;
    logic new_value;
    logic print_value = 0;
    logic [31:0] display_val;          // the value the testbench is trying to display
    logic [31:0] output_data_in;
    logic [31:0] check_display_val;    // the value the checker thinks is being displayed on the SSD

    // Instance seven_segment module
    seven_segment8 #(.CLK_FREQUENCY(CLK_FREQUENCY), .REFRESH_RATE(REFRESH_RATE))
    ssd(.clk(clk), .rst(rst), .data_in(display_val), .dp_in(dp_in), .blank(blank),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .DP(DP), .anode(anode));

    // Instance seven_segment_check module
    seven_segment_check #(.CLK_FREQUENCY(CLK_FREQUENCY), .REFRESH_RATE(REFRESH_RATE))
    ssd_check(.clk(clk), .rst(rst),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .anode(anode), .new_value(new_value),
        .print(print_value), .blanked(blanked_segments), .output_display_val(check_display_val));

    // Clock Generator
    always
    begin
        #(CLK_HALF_PERIOD_NS) clk <=1;
        #(CLK_HALF_PERIOD_NS) clk <=0;
    end

    task automatic set_ssd_value(logic [31:0] value_to_display, logic [7:0] dp_value_to_display, logic[7:0] blank_value = 8'b00000000);
        @(negedge clk)
        $display("[%0tns] Setting SSD value to 0x%h with dp %b and blank %b", $time/1000.0, value_to_display, dp_value_to_display, blank_value);
        // Set a full value to display
        display_val = value_to_display;
        dp_in = dp_value_to_display;
        blank = blank_value;
        @(negedge clk);
        wait(new_value == 1'b1);
        @(negedge clk);
        if (check_display_val != value_to_display) begin
            $display("Error: Display value mismatch: %h != %h", check_display_val, value_to_display);
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
        data_in = 0;
        dp_in = 0;
        #100ns

        //Test Reset
        @(negedge clk);
        $display("[%0tns] Reset", $time/1000.0);
        rst = 1;
        repeat(5) @(negedge clk)
        // Un reset on negative edge
        rst = 0;

        // Test a few basic values
        set_ssd_value(32'hfedcba98,8'b11111111);
        set_ssd_value(32'h76543210,8'b00000000);
        set_ssd_value(32'ha5a5a5a5,8'b10101010);
        set_ssd_value(32'h5a5a5a5a,8'b01010101);
        set_ssd_value(32'hdeadbeef,8'b11110000);

        // Test Blanking
        // can't test full blanking becuase the checker needs each anode to be on at least once to determine the value being displayed
        // set_ssd_value(32'hffffffff,8'b00001111, 8'b11111111);
        // for(int i=0; i < 8; i++) begin
        //     set_ssd_value(32'hffffffff,8'b00001111, 8'b00000001 << i);
        // end

        // Test Random Values
        for(int i=0; i <NUMBER_OF_VALUES; i++) begin
            // Set a full value to display
            set_ssd_value($urandom_range(0, 32'hffffffff),$urandom_range(0, 8'hff));
            // data_in = $urandom_range(0, 32'hffffffff);
            // dp = $urandom_range(0, 8'hff);
            // @(negedge clk);
            // wait(new_value == 1'b1);
            // @(negedge clk);
        end
        $stop;
    end

endmodule
