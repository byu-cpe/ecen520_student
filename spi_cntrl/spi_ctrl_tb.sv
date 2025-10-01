//////////////////////////////////////////////////////////////////////////////////
// spi_ctrl_tb.sv
//
//  Testbench for the spi_ctrl.sv file
//////////////////////////////////////////////////////////////////////////////////

module spi_ctrl_tb ();

    parameter CLK_FREQUENCY = 100000000;
    parameter SCLK_FREQUENCY = 1000000;
    parameter SHIFT_REG_WIDTH = 8;

    // Ports and parameters
    logic clk, rst;
    logic [7:0] spi_cntrl_data_to_send;
    logic start;
    logic [7:0] spi_cntrl_data_received;
    logic busy;
    logic sample;
    logic SPI_MISO;
    logic SPI_SCLK;
    logic SPI_MOSI;
    logic SPI_CS;
    logic load;


    localparam real CLK_HALF_PERIOD_NS = 1.0e9 / (2.0 * CLK_FREQUENCY);

    //////////////////////////////////////////////////////////////////////////////////
    //  Instantiate Desgin Under Test (DUT)
    //////////////////////////////////////////////////////////////////////////////////

    spi_ctrl #(.CLK_FREQUENCY(CLK_FREQUENCY), .SCLK_FREQUENCY(SCLK_FREQUENCY),
        .SHIFT_REG_WIDTH(SHIFT_REG_WIDTH),.MSB_FIRST(1))
    dut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .load(load),
        .data_to_send(spi_cntrl_data_to_send),
        .data_received(spi_cntrl_data_received),
        .busy(busy),
        .sample(sample),
        .spi_miso(SPI_MISO),
        .spi_sclk(SPI_SCLK),
        .spi_mosi(SPI_MOSI),
        .spi_cs(SPI_CS)
    );

    logic su_new_value;
    logic [7:0] su_send_value, su_received_value;

    spi_subunit
     #(.SHIFT_REG_WIDTH(SHIFT_REG_WIDTH)) 
     subunit(.sclk(SPI_SCLK), .mosi(SPI_MOSI), .miso(SPI_MISO), .cs(SPI_CS),
        .send_value(su_send_value), .received_value(su_received_value),
        .new_value(su_new_value) );

    //////////////////////////////////////////////////////////////////////////////////
    // Testbench variables
    //////////////////////////////////////////////////////////////////////////////////
    logic [7:0] tb_main_char_to_send;
    logic [7:0] tb_su_char_to_send;
    int clocks_to_delay;
    integer bits = 0;


    //////////////////////////////////////////////////////////////////////////////////
    // Clock Generator
    //////////////////////////////////////////////////////////////////////////////////
    // Oscilating clock
    initial begin
        #105;
        clk = 0;
        forever begin
            #(CLK_HALF_PERIOD_NS) clk = ~clk;
        end
    end

    task transfer_8bits( input [7:0] main_byte_to_send, input [7:0] subunit_byte_to_send);
        // wait for clock edge
        @(negedge clk)
        $display("\[%0t] Main transfering byte 0x%h, subunit transfering byte 0x%h", $time,
            main_byte_to_send, subunit_byte_to_send);
        @(negedge clk)
        spi_cntrl_data_to_send <= main_byte_to_send;
        su_send_value <= subunit_byte_to_send;
        repeat(10) @(negedge clk)
        start <= 1'b1; // keep start high
        wait (busy == 1'b1);
        for (bits = 0; bits < 8; bits = bits + 1) begin
            @(negedge clk iff sample == 1'b1);
            // wait for clock edge
            // wait (sample == 1'b0);
            // @(negedge clk);  // wait for falling c   lock edge to change inputs
        end
        start <= 1'b0;
        wait (busy == 1'b0);
        if (su_received_value == main_byte_to_send)
            $display("\[%0t]  Sub unit correctly received byte 0x%h", $time, su_received_value);
        else
            $display("\[%0t]  Error:<spi_ctrl_tb> Sub unit Received byte 0x%h, expected 0x%h", $time,
            su_received_value, main_byte_to_send);
        // Wait until the transaction is done
        wait (busy == 1'b0);
        if (spi_cntrl_data_received == subunit_byte_to_send)
            $display("\[%0t]  Main unit correctly received byte 0x%h", $time, subunit_byte_to_send);
        else
            $display("\[%0t]  Error:<spi_ctrl_tb> Main unit Received byte 0x%h, expected 0x%h", $time,
            spi_cntrl_data_received, subunit_byte_to_send);
    endtask

    task issue_consecutive_transfer(int num_transfers);
        $display("[%0t] Issuing consecutive transfer of %0d bytes", $time, num_transfers);
        // wait for clock edge
        @(negedge clk);
        su_send_value = $urandom_range(0,255);
        spi_cntrl_data_to_send = $urandom_range(0,255);
        for(int i = 0; i < num_transfers; i=i+1) begin
            $display("\[%0t]  Main transfering byte 0x%h, sub unit transfering byte 0x%h", $time,
                spi_cntrl_data_to_send, su_send_value);
            // Initial start
            if (i == 0) begin
                start <= 1'b1; // keep start high
                wait (busy == 1'b1);
            end
            // Send 8 bitis
            for (bits = 0; bits < 8; bits = bits + 1) begin
                @(negedge clk iff sample == 1'b1);
            end
            // check values
            if (su_received_value == spi_cntrl_data_to_send)
                $display("\[%0t]  Sub unit correctly received byte 0x%h", $time, su_received_value);
            else
                $display("\[%0t]  Error:<spi_ctrl_tb> Sub unit Received byte 0x%h, expected 0x%h", $time,
                su_received_value, spi_cntrl_data_to_send);
            if (spi_cntrl_data_received == su_send_value)
                $display("\[%0t]  Main unit correctly received byte 0x%h", $time, su_send_value);
            else
                $display("\[%0t]  Error:<spi_ctrl_tb> Main unit Received byte 0x%h, expected 0x%h", $time,
                spi_cntrl_data_received, su_send_value);
            // Provide control signals for next byte or end
            if (i < num_transfers - 1) begin
                // su_send_value = $urandom_range(0,255);
                spi_cntrl_data_to_send = $urandom_range(0,255);
                load = 1'b1;
                @(negedge clk);
                load = 1'b0;
            end
            else begin
                start <= 1'b0;
            end
        end
        wait (busy == 1'b0);

    endtask

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        int clocks_to_delay;
        $display("===== SPI Controller TB =====");

        // Run without reset for a bit
        repeat(10) @(negedge clk);

        // Set default inputs
        rst <= 0;
        spi_cntrl_data_to_send <= 0;
        start <= 0;
        load <= 0;
        //SPI_MISO <= 1'bz;
        repeat(10)@(posedge clk);

        // Issue reset
        $display("[%0t] Testing Reset", $time);
        rst <= 1;
        repeat(2)@(negedge clk);
        rst <= 0;
        repeat(10)@(negedge clk);

        // Issue a few transactions
        for(int i = 0; i < 6; i++) begin
            tb_main_char_to_send = $urandom_range(0,255);
            tb_su_char_to_send = $urandom_range(0,255);
            $display("[%0t] Issuing Transfer of 0x%h (#%0d)", $time, tb_main_char_to_send,i+1);
            transfer_8bits(tb_main_char_to_send, tb_su_char_to_send);
            clocks_to_delay = $urandom_range(1000,3000);
            repeat(clocks_to_delay) @(negedge clk);
        end

        $display();
        repeat(5000)@(negedge clk);

        // Issue a few burst transactions
        for(int i = 0; i < 3; i++) begin
            issue_consecutive_transfer(i+2);
            repeat($urandom_range(1000,3000)) @(negedge clk);
        end

        $stop;

    end

endmodule
