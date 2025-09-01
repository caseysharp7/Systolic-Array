`timescale 1ns / 1ps

module Systolic_Array(
        input clk,
        input reset,
        input start,
        input [(MAT_LEN*DATA_SIZE)-1:0] Mat1_in,
        input [(MAT_LEN*DATA_SIZE)-1:0] Mat2_in,
        output [(MAT_LEN*ACC_SIZE)-1:0] result,
        output reg done
    );

    reg [DATA_SIZE-1:0] A_in1, A_in4, A_in7;
    wire [DATA_SIZE-1:0] A_in2, A_in3, A_in5, A_in6, A_in8, A_in9;
    reg [DATA_SIZE-1:0] B_in1, B_in2, B_in3;
    wire [DATA_SIZE-1:0] B_in4, B_in5, B_in6, B_in7, B_in8, B_in9;
    reg [3:0] counter;
    // reg done;

    parameter MAT_ROWS = 3;
    parameter MAT_COLS = 3;
    parameter MAT_LEN = 9;
    parameter DATA_SIZE = 8;
    parameter ACC_SIZE = 16;

    parameter ROW_SIZE = MAT_ROWS*DATA_SIZE;

    wire [DATA_SIZE-1:0] Mat1[0:MAT_ROWS-1][0:MAT_COLS-1];
    wire [DATA_SIZE-1:0] Mat2[0:MAT_ROWS-1][0:MAT_COLS-1];
    wire [ACC_SIZE-1:0] result_temp[0:MAT_ROWS-1][0:MAT_COLS-1];


    genvar i, j;
    generate
        for(i = MAT_ROWS - 1; i >= 0; i = i-1) begin : loop1
            for(j = MAT_COLS; j >= 1; j = j-1) begin : loop2
                localparam r = (MAT_ROWS-1) - i;
                localparam c = (MAT_COLS) - j;
                assign Mat1[r][c] = Mat1_in[(i*ROW_SIZE + j*DATA_SIZE) - 1 -: DATA_SIZE];
            end
        end
    endgenerate
    generate
        for(i = MAT_ROWS - 1; i >= 0; i = i-1) begin : loop3
            for(j = MAT_COLS; j >= 1; j = j-1) begin : loop4
                localparam r = (MAT_ROWS-1) - i;
                localparam c = (MAT_COLS) - j;
                assign Mat2[r][c] = Mat2_in[(i*ROW_SIZE + j*DATA_SIZE) - 1 -: DATA_SIZE];
            end
        end
    endgenerate


    MAC mac1(.clk(clk), .reset(reset), .A_in(A_in1), .B_in(B_in1), .A_out(A_in2), .B_out(B_in4), .result(result_temp[0][0]));
    MAC mac2(.clk(clk), .reset(reset), .A_in(A_in2), .B_in(B_in2), .A_out(A_in3), .B_out(B_in5), .result(result_temp[0][1]));
    MAC mac3(.clk(clk), .reset(reset), .A_in(A_in3), .B_in(B_in3), .A_out(),      .B_out(B_in6), .result(result_temp[0][2]));
    MAC mac4(.clk(clk), .reset(reset), .A_in(A_in4), .B_in(B_in4), .A_out(A_in5), .B_out(B_in7), .result(result_temp[1][0]));
    MAC mac5(.clk(clk), .reset(reset), .A_in(A_in5), .B_in(B_in5), .A_out(A_in6), .B_out(B_in8), .result(result_temp[1][1]));
    MAC mac6(.clk(clk), .reset(reset), .A_in(A_in6), .B_in(B_in6), .A_out(),      .B_out(B_in9), .result(result_temp[1][2]));
    MAC mac7(.clk(clk), .reset(reset), .A_in(A_in7), .B_in(B_in7), .A_out(A_in8), .B_out(),      .result(result_temp[2][0]));
    MAC mac8(.clk(clk), .reset(reset), .A_in(A_in8), .B_in(B_in8), .A_out(A_in9), .B_out(),      .result(result_temp[2][1]));
    MAC mac9(.clk(clk), .reset(reset), .A_in(A_in9), .B_in(B_in9), .A_out(),      .B_out(),      .result(result_temp[2][2]));

    always@(posedge start) begin
        done = 0;
    end


    always@(posedge clk) begin
        if(reset) begin
            counter <= 0;
            done <= 1;
            A_in1 <= 0;
            B_in1 <= 0;
        end
        else if(!done) begin
            case(counter) // This can also be done in the testbench instead which is likely closer to how a systolic array will
                          // actually be used. In this case I take in the whole matrix and then iterate, but can also just feed
                          // the systolic array from the testbench to simulate the software
                4'b0000: begin
                    A_in1 <= Mat1[0][0];
                    B_in1 <= Mat2[0][0];
                    A_in4 <= 0;
                    B_in2 <= 0;
                    A_in7 <= 0;
                    B_in3 <= 0;
                    counter <= counter + 1;
                end
                4'b0001: begin
                    A_in1 <= Mat1[0][1];
                    B_in1 <= Mat2[1][0];
                    A_in4 <= Mat1[1][0];
                    B_in2 <= Mat2[0][1];
                    A_in7 <= 0;
                    B_in3 <= 0;
                    counter <= counter + 1;
                end
                4'b0010: begin
                    A_in1 <= Mat1[0][2];
                    B_in1 <= Mat2[2][0];
                    A_in4 <= Mat1[1][1];
                    B_in2 <= Mat2[1][1];
                    A_in7 <= Mat1[2][0];
                    B_in3 <= Mat2[0][2];
                    counter <= counter + 1;
                end
                4'b0011: begin
                    A_in1 <= 0;
                    B_in1 <= 0;
                    A_in4 <= Mat1[1][2];
                    B_in2 <= Mat2[2][1];
                    A_in7 <= Mat1[2][1];
                    B_in3 <= Mat2[1][2];
                    counter <= counter + 1;
                end
                4'b0100: begin
                    A_in1 <= 0;
                    B_in1 <= 0;
                    A_in4 <= 0;
                    B_in2 <= 0;
                    A_in7 <= Mat1[2][2];
                    B_in3 <= Mat2[2][2];
                    counter <= counter + 1;
                end
                4'b0110: begin
                    A_in1 <= 0;
                    B_in1 <= 0;
                    A_in4 <= 0;
                    B_in2 <= 0;
                    A_in7 <= 0;
                    B_in3 <= 0;
                    done <= 1;
                end
                default: begin
                    A_in1 <= 0;
                    B_in1 <= 0;
                    A_in4 <= 0;
                    B_in2 <= 0;
                    A_in7 <= 0;
                    B_in3 <= 0;
                    counter <= counter + 1;
                end
            endcase
        end

        else begin
            counter <= 0;
        end
    end

    generate
        for(i = MAT_ROWS - 1; i >= 0; i = i-1) begin : loop5
            for(j = MAT_COLS; j >= 1; j = j-1) begin : loop6
                localparam r = (MAT_ROWS-1) - i;
                localparam c = (MAT_COLS) - j;
                assign result [(i*ROW_SIZE*2 + j*ACC_SIZE) - 1 -: ACC_SIZE] = result_temp[r][c];
            end
        end
    endgenerate



endmodule