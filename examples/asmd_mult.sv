// Example SV ASMD multiplier with FSM

module asmd_mult (clk,rst,start,a_in,b_in,ready,r);
    input clk,rst,start;
    input [7:0] a_in,b_in;
    output ready;
    output [15:0] r;

    typedef enum { IDLE, AB0, LOAD, OP } state_type_t;
    state_type_t cur_state, next_state;
    logic count_0;
    logic [7:0] a_reg, n_reg, r_reg, a_next, n_next, r_next;

    // FSM state register
    always @(posedge clk) begin
        if (rst == 1'b1)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic and outputs
    always_comb begin
        // Default values
        next_state = state;
        case (state)
            IDLE:
                if (start == 1'b1) begin
                    if (a_in == 0 || b_in == 0)
                        next_state = AB0;
                    else
                        next_state = LOAD;
                end
            AB0: next_state = IDLE;
            LOAD: next_state = OP;
            OP:
                if (count_0)
                    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Control Path Outputs
    assign ready = (state == IDLE);
    // Data path registers
    always_ff @(posedge clk) begin
        if (rst == 1'b1) begin
            a_reg <= 0;
            n_reg <= 0;
            r_reg <= 0;
        end 
        else begin
            a_reg <= a_next;
            n_reg <= n_next;
            r_reg <= r_next;
        end
    end

    // Next state logic for datapath
    always_comb begin
        a_next = a_reg;
        n_next = n_reg;
        r_next = r_reg;
        case (state)
            IDLE:
            AB0: begin
                a_next = a_in;
                n_next = b_in;
                r_next = 0;
            end
            LOAD: begin
                a_next = a_in;
                n_next = b_in;
                r_next = 0;
            end
            OP: begin
                a_next = a_reg;
                n_next = n_reg - 1;
                r_next = a_reg + r_reg;
            end
        endcase
    end

    // Outputs
    assign count_0 = (n_next == 0);
    assign r = r_reg;

endmodule
