`timescale 1ns / 1ps

module Systolic_Array_tb();
    reg clk;
    reg reset;
    reg start;
    reg [(MAT_LEN*DATA_SIZE)-1:0] Mat1_in;
    reg [(MAT_LEN*DATA_SIZE)-1:0] Mat2_in;
    wire [(MAT_LEN*ACC_SIZE)-1:0] result_tb;
    wire done;

    reg [ACC_SIZE-1:0] result_tb1, result_tb2, result_tb3, result_tb4, result_tb5, result_tb6, result_tb7, result_tb8, result_tb9;

    parameter MAT_ROWS = 3;
    parameter MAT_COLS = 3;
    parameter MAT_LEN = 9;
    parameter DATA_SIZE = 8;
    parameter ACC_SIZE = 16;
    parameter ROW_SIZE = MAT_ROWS*DATA_SIZE;


    Systolic_Array instant
    (
        .clk(clk),
        .reset(reset),
        .start(start),
        .Mat1_in(Mat1_in),
        .Mat2_in(Mat2_in),
        .result(result_tb),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        Mat1_in = 72'b00001010_00010001_00000010_00000101_00000001_00000000_00011100_00010000_00000101;  // hex: a11020501001c1005
                        // (10 17 2)
                        // (5  1  0)
                        // (28 16 5)

        Mat2_in = 72'b00000000_00010100_00001000_00010101_00000010_00100000_00000100_00000000_00000001;  // hex: 1408150220040001
                        // (0  20 8) 
                        // (21 2  32)
                        // (4  0  1) 

        #20
        reset = 0;

        #5
        start = 1;

        #5
        start = 0;
        /* result should be (365 234 626)
                            (21  102 72) 
                            (356 592 741)    
        0000000101101101_0000000100010010_0000001010000010
        0000000000010101_0000000001100110_0000000001001000
        0000000101100100_0000001001010000_0000001011100101
        hex: 16d011202820015006600480164025002e5
        */

        // Mat2_in = 72'b00000000_00001010_00001000_00010101_00000010_00100000_00000100_00000000_00000001;
                        // (0  10 8) 
                        // (21 2  32)
                        // (4  0  1) 
        
        
        /* result should be (365 134 626)
                            (21  52  72) 
                            (356 312 741)    
        0000000101101101_0000000010011010_0000001010000010
        0000000000010101_0000000000110100_0000000001001000
        0000000101100100_0000000100111000_0000001011100101
        */


    end

    always @(posedge clk) begin
    if (done) begin
        result_tb1 <= result_tb[143 -: 16];
        result_tb2 <= result_tb[127 -: 16];
        result_tb3 <= result_tb[111 -: 16];
        result_tb4 <= result_tb[95 -: 16];
        result_tb5 <= result_tb[79 -: 16];
        result_tb6 <= result_tb[63 -: 16];
        result_tb7 <= result_tb[47 -: 16];
        result_tb8 <= result_tb[31 -: 16];
        result_tb9 <= result_tb[15 -: 16];
    end
end

endmodule