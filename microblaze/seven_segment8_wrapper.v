//////////////////////////////////////////////////////////////////////////////////
// seven_segment8_wrapper.v
//
// Verilog wrapper for the seven_segment8 module. The Vivado block diagram editor
// does not accept SystemVerilog modules, so this wrapper is added to the block
// diagram instead.
//
// control[7:0]  : digit points (dp_in)
// control[15:8] : blank signals (blank)
// segment       : {DP, CA, CB, CC, CD, CE, CF, CG}
//////////////////////////////////////////////////////////////////////////////////

module seven_segment8_wrapper(
    input wire clk,
    input wire rst_n,
    input wire [31:0] data_in,
    input wire [15:0] control,
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
            .blank(control[15:8]),
            .CA(segment[6]),
            .CB(segment[5]),
            .CC(segment[4]),
            .CD(segment[3]),
            .CE(segment[2]),
            .CF(segment[1]),
            .CG(segment[0]),
            .DP(segment[7]),
            .anode(anode)
    );

endmodule
