`timescale 1ns / 1ps

module curt(
        input clk_i,
        input rst_i,
        input [7:0] x_bi,
        input start_i,
        output busy_o,
        output reg [7:0] y_bo
    );
    
    localparam IDLE = 3'b000;
    localparam WORK = 3'b001;
    localparam WAIT_MUL_1 = 3'b010;
    localparam WAIT_MUL_2 = 3'b011;
    localparam END = 3'b111;
    reg [2:0]state;
    
    reg [7:0]a_mul;
    reg [7:0]b_mul;
    reg start_mul;
    wire busy_mul;
    wire [15:0]output_mul;

    mult m(.clk_i(clk_i),
           .rst_i(rst_i),
           .a_bi(a_mul),
           .b_bi(b_mul),
           .start_i(start_mul),
           .busy_o(busy_mul),
           .y_bo(output_mul));
   
    reg [7:0]y;
    reg [7:0]x;
    reg [7:0]s;
    wire [8:0]y_shifted;
    wire [8:0]y_inc;
    
    assign y_shifted = y << 1;
    assign y_inc = y + 1;
    assign busy_o = state != IDLE;
    
    always @(posedge clk_i)
        if (rst_i) begin
            y <= 0;
            y_bo <= 0;
            state <= IDLE;
            a_mul <= 0;
            b_mul <= 0;
            start_mul <= 0;
            x <= 0;
        end else begin
            case (state)
            IDLE:
            begin
                if (start_i) begin
                    state <= WORK;
                    s <= 6;
                    y <= 0;
                    x <= x_bi;
                end
            end
            WORK:
            begin
                if (s[7]) begin
                    state <= END;
                end else begin
                    y <= y_shifted;
                    a_mul <= y_shifted;
                    b_mul <= 3;
                    start_mul <= 1;
                    state <= WAIT_MUL_1;
                end
            end
            WAIT_MUL_1:
            begin    
                if (~busy_mul & ~start_mul) begin
                    a_mul <= output_mul;
                    b_mul <= y_inc;
                    start_mul <= 1;
                    state <= WAIT_MUL_2;
                end else begin
                    start_mul <= 0;
                end
            end
            WAIT_MUL_2:
            begin    
                if (~busy_mul & ~start_mul) begin
                    if (x >= (output_mul + 1) << s) begin
                        x <= x - ((output_mul + 1) << s);
                        y <= y + 1;
                    end
                    s <= s - 3;
                    state <= WORK;
                end else begin
                    start_mul <= 0;
                end
            end
            END:
            begin
                y_bo <= y;
                state <= IDLE;
            end
            endcase
        end
endmodule
