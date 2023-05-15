`timescale 1ns / 1ps


module tests(

    );
    
    reg [7:0] a [9:0];
    reg [7:0] b [9:0];
    integer res [9:0];
    
    reg clc;
    reg rst;
    reg [7:0] a_bi;
    reg [7:0] b_bi;
    reg start_i;
    wire busy_o;
    wire [7:0] y_bo;
    
    fun f(.clk_i(clc),
           .rst_i(rst),
           .a_bi(a_bi),
           .b_bi(b_bi),
           .start_i(start_i),
           .busy_o(busy_o),
           .y_bo(y_bo));
   
   integer i;
   integer c;
   initial begin
        // 1
        a[0] = 15;
        b[0] = 28;
        res[0] = 7;
        // 2
        a[1] = 255;
        b[1] = 255;
        res[1] = 21;
        // 3
        a[2] = 145;
        b[2] = 1;
        res[2] = 6;
        // 4
        a[3] = 45;
        b[3] = 76;
        res[3] = 11;
        // 5
        a[4] = 234;
        b[4] = 34;
        res[4] = 11;
        // 6
        a[5] = 0;
        b[5] = 0;
        res[5] = 0;
        // 7
        a[6] = 1;
        b[6] = 1;
        res[6] = 2;
        // 8
        a[7] = 27;
        b[7] = 0;
        res[7] = 3;
        // 9
        a[8] = 0;
        b[8] = 9;
        res[8] = 3;
        // 10
        a[9] = 0;
        b[9] = 1;
        res[9] = 1;
   
        rst <= 1;
        clc <= 0;
        #1
        clc <= 1;
        #1
        clc <= 0;
        rst <= 0;
        for (i = 0; i < 10; i = i + 1) begin
            #1
            a_bi <= a[i];
            b_bi <= b[i];
            clc <= 1;
            start_i <= 1;
            #1
            clc <= 0;
            #1
            c = 0;
            while (busy_o) begin
                clc <= 1;
                #1
                clc <= 0;
                #1;
                c = c + 1;
            end
            if (y_bo != res[i]) begin
                $display("Error on test %d, result %d, should be %d", i, y_bo, res[i]);
            end else begin
                $display("Correct, test %d, result %d, in %d ticks", i, y_bo, c);
            end
        end
        $stop;
   end
endmodule
