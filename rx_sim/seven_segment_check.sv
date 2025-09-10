//////////////////////////////////////////////////////////////////////////////////
// seven_segment_check.sv
//
// This simulation model is used to check the behavior of the seven segment display
//////////////////////////////////////////////////////////////////////////////////
//`timescale 1ns / 1ps

module seven_segment_check(clk, rst, segments, dp, anode,
    new_value, output_display_val);

    input clk, rst;
    input logic [6:0] segments;
    input logic dp;
    input logic [7:0] anode;
    output logic new_value;
    output logic [31:0] output_display_val;

    parameter int CLK_FREQUENCY = 100_000_000;      // 100 MHz
    parameter int MIN_SEGMENT_DISPLAY_US = 10_000;  // 10 ms
    parameter int VERBOSE = 1;
    parameter int WARN_ON_SIMULTANEOUS_ANODES = 1;
    localparam int MIN_SEGMENT_CLOCKS = CLK_FREQUENCY / 1_000_000 * MIN_SEGMENT_DISPLAY_US;

    // Convert standard segment settings to the corresonding hex values
    function automatic logic [3:0] segment_to_hex(input logic [6:0] segments);
        begin
            case(segments)

                7'b0000001: segment_to_hex = 4'b0000; // 0
                7'b1001111: segment_to_hex = 4'b0001; // 1
                7'b0010010: segment_to_hex = 4'b0010; // 2
                7'b0000110: segment_to_hex = 4'b0011; // 3
                7'b1001100: segment_to_hex = 4'b0100; // 4
                7'b0100100: segment_to_hex = 4'b0101; // 5
                7'b0100000: segment_to_hex = 4'b0110; // 6
                7'b0001111: segment_to_hex = 4'b0111; // 7
                7'b0000000: segment_to_hex = 4'b1000; // 8
                7'b0000100: segment_to_hex = 4'b1001; // 9
                7'b0001000: segment_to_hex = 4'b1010; // A
                7'b1100000: segment_to_hex = 4'b1011; // B
                7'b0110001: segment_to_hex = 4'b1100; // C
                7'b1000010: segment_to_hex = 4'b1101; // D
                7'b0110000: segment_to_hex = 4'b1110; // E
                7'b0111000: segment_to_hex = 4'b1111; // F
                default: segment_to_hex = 4'bxxxx; // 0
            endcase
        end
    endfunction

    // Check to see if more than one anode is being displayed at a time and give a warning
    logic error_last_cycle = 0;
    always_ff @(posedge clk) begin
        if (WARN_ON_SIMULTANEOUS_ANODES > 0) begin
            if (anode != 8'hff && $countones(~anode) > 1 && error_last_cycle == 0) begin
                $display("Warning: More than one anode is being displayed at a time: %b", anode);
                error_last_cycle <= 1;
            end
            else
                error_last_cycle <= 0;
        end
    end

    // Keep track of the current segment and dp values (update when corresponding anode is low)
    logic [6:0] display_segments[7:0]; // An array of 8 segments with each segment being 7 bits
    logic [7:0] display_dp; // An array of 8 dp values
    always_ff @(posedge clk) begin
        // Update those digits that are being displayed
        for (int i = 0; i < 8; i = i + 1) begin
            if (anode[i] == 0) begin
                display_segments[i] <= segments;
                display_dp[i] <= dp;
                output_display_val[4*i +: 4] <= segment_to_hex(segments);
            end
        end
    end

    // Print the current value of the segments
    function automatic void print_segments();
        // two dimensional array. First dimension indicates which digit is being displayed
        //   second dimension correspnds to the segment. The value stored is the ascii value
        //   to print for the corresponding segment in text.
        byte segment_chars[8][7];
        byte digit_point[8];
        const byte SPACE = 8'h20;
        //const byte SPACE = 8'h2E;
        const byte DASH = 8'h2D;       // -
        const byte BAR = 8'h7C;        // |
        const byte DOT = 8'h2E;        // .
        const byte UNDERSCORE = 8'h5F; // _
        // lines of character data to build display
        automatic string line1, line2,line3,line4,line5 = "";
        begin
            // Iterate over each digit to convert the segment values to its corresponding character
            for (int i = 0; i < 8; i = i + 1) begin
                // Segment 0 (A): underscore
                if (display_segments[i][0]==0)
                    segment_chars[i][0] = UNDERSCORE;
                else
                    segment_chars[i][0] = SPACE;
                // Segment 1 (B): Horizontal Bar
                if (display_segments[i][1]==0)
                    segment_chars[i][1] = BAR;
                else
                    segment_chars[i][1] = SPACE;
                // Segment 2 (C): Horizontal Bar
                if (display_segments[i][2]==0)
                    segment_chars[i][2] = BAR;
                else
                    segment_chars[i][2] = SPACE;
                // Segment 3 (D): underscore
                if (display_segments[i][3]==0)
                    segment_chars[i][3] = UNDERSCORE;
                else
                    segment_chars[i][3] = SPACE;
                // Segment 4 (E): Horizontal Bar
                if (display_segments[i][4]==0)
                    segment_chars[i][4] = BAR;
                else
                    segment_chars[i][4] = SPACE;
                // Segment 5 (F): Horizontal Bar
                if (display_segments[i][5]==0)
                    segment_chars[i][5] = BAR;
                else
                    segment_chars[i][5] = SPACE;
                // Segment 6 (G): Horizontal Bar
                if (display_segments[i][6]==0)
                    segment_chars[i][6] = UNDERSCORE;
                else
                    segment_chars[i][6] = SPACE;
                // Determine the digit point
                if (display_dp[i] == 0)  // dp is low asserted
                    digit_point[i] = DOT;
                else 
                    digit_point[i] = SPACE;
            end
            // Print the 8 segments in text format
            // Line 1 (top line) : S6SSS (underscores)
            // Line 2            : 105SS
            // Line 4            : 234DS
            for (int i = 7; i >= 0; i = i - 1)
                 line1 = {line1, SPACE,segment_chars[i][6], SPACE,SPACE,SPACE};
            for (int i = 7; i >= 0; i = i - 1)
                line2 = {line2, segment_chars[i][1], segment_chars[i][0],segment_chars[i][5],SPACE,SPACE};
            // for (int i = 0; i < 8; i = i + 1)
            //     line3 = {line3, SPACE,segment_chars[i][0], SPACE,SPACE};
            for (int i = 7; i >= 0; i = i - 1)
                line4 = {line4, segment_chars[i][2], segment_chars[i][3],segment_chars[i][4],digit_point[i],SPACE};
            // for (int i = 0; i < 8; i = i + 1)
            //     line5 = {line5, SPACE,segment_chars[i][3], SPACE,digit_point[i]};
            $display("%s", line1);
            $display("%s", line2);
            //$display("%s", line3);
            $display("%s", line4);
            //$display("%s", line5);
        end
    endfunction


    logic [7:0] anode_d; // One clock cycle delay of anode (used for detecting anode changes)
    logic [7:0] annode_collect; // Collect the anodes that are being displayed (to see if all have been displayed)
    integer anode_count = 0; // Count the number of clocks that a single anode is displayed
    integer last_anode_count = 0;
    //logic new_value;
    logic [7:0] new_digit;
    assign new_digit = (anode ^ anode_d) & anode; // combinatinoal
    always_ff @(posedge clk) begin
        anode_d <= anode;
        new_value <= 0;
        anode_count <= anode_count + 1;
        // TODO: Check for blanking
        // See if we are transitioning from invalid annode to valid anode
        if (!(^anode === 1'bX) && (^anode_d === 1'bX)) begin
            // Starting a new display cycle
            $display("[%0t] Valid Annode values", $time);
            anode_count <= 0;
            annode_collect <= 8'h00;
        end
        // See if we are transitioning from one valid anode to another valid anode
        else if(anode != anode_d) begin
            if (anode_count > MIN_SEGMENT_CLOCKS + 2 || anode_count < MIN_SEGMENT_CLOCKS - 2 ) begin
                $display("[%0t] Warning: Invalid number of segment clocks: %0d expecting %0d %h %h", $time,
                    anode_count, MIN_SEGMENT_CLOCKS,anode,anode_d);
            end
            last_anode_count <= anode_count; // Save the last anode count for reportings
            anode_count <= 0;
            annode_collect <= annode_collect | new_digit;
            if ((annode_collect | new_digit) == 8'hff) begin
                new_value <= 1;
                annode_collect <= 0;
                $display("[%0t] New value:0x%0h",$time,output_display_val);
                print_segments();
                $display("Anode assert clocks %0d:",last_anode_count+1);
            end
        end
    end


//   --  The segments are defined as follows:
//   --
//   --    ----A----
//   --    |       |
//   --    |       |
//   --    F       B
//   --    |       |
//   --    |       |
//   --    ----G----
//   --    |       |
//   --    |       |
//   --    E       C
//   --    |       |
//   --    |       |
//   --    ----D----
//   --
//   -- The seven segments are organized into a std_logic_Vector(6 downto 0)
//   -- where segments(6) corresponds to segment 'A' and segments(0) corresponds
//   -- to segment 'G'.
//   --
//   -- The segments are LOW asserted
//   --

endmodule
