//////////////////////////////////////////////////////////////////////////////////
// seven_segment8_wrapper.v
//////////////////////////////////////////////////////////////////////////////////

module seven_segment8_wrapper(
    input wire clk,
    input wire rst_n,
    input wire [31:0] data_in,
    input wire [8:0] control,
    // input wire [7:0] dp_in,
    // input wire blank,
    output wire [7:0] segment,
    output wire [7:0] anode);

    parameter integer CLK_FREQUENCY = 100_000_000;   // 100 MHz
    parameter integer REFRESH_RATE = 200;

    seven_segment8 #(.CLK_FREQUENCY(CLK_FREQUENCY),.REFRESH_RATE(REFRESH_RATE))
    ssd8 (
            .clk(clk),
            .rst(~rst_n),       // Note the active low reset
            .data_in(data_in),
            .dp_in(control[7:0]),
            .blank(control[8]),
            .segment(segment),
            .anode(anode)
    );

endmodule
