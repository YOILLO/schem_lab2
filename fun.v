`timescale 1ns / 1ps

module fun(
        input clk_i,
        input rst_i,
        input [7:0] a_bi,
        input [7:0] b_bi,
        input start_i,
        output busy_o,
        output reg [7:0] y_bo
    );
    
    reg [7:0] b;
    reg start_sq;
    wire busy_sq;
    wire [7:0] sq_res;
    sqrt sq(.clk_i(clk_i),
            .rst_i(rst_i),
            .x_bi(b),
            .start_i(start_sq),
            .busy_o(busy_sq),
            .y_bo(sq_res));
        
    reg [7:0] a;
    reg start_cu;
    wire busy_cu;
    wire [7:0] cu_res;
    curt cu(.clk_i(clk_i),
            .rst_i(rst_i),
            .x_bi(a),
            .start_i(start_cu),
            .busy_o(busy_cu),
            .y_bo(cu_res));
    
    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    reg state;
    
     assign busy_o = state != IDLE;
     
     always @(posedge clk_i)
        if (rst_i) begin
            y_bo <= 0;
            state <= IDLE;
            a <= 0;
            b <= 0;
            start_sq <= 0;
            start_cu <= 0;
        end else begin
            case (state)
            IDLE:
                if (start_i) begin
                    state <= WORK;
                    y_bo <= 0;
                    a <= a_bi;
                    b <= b_bi;
                    start_cu <= 1;
                    start_sq <= 1;
                end
            WORK:
                begin
                    if ((~busy_sq) & (~busy_cu) & (~start_cu) & (~start_sq)) begin
                        state <= IDLE;
                        y_bo <= cu_res + sq_res;
                        a <= 0;
                        b <= 0;
                    end else begin
                        start_sq <= 0;
                        start_cu <= 0;
                    end
                end
            endcase
        end
    
endmodule