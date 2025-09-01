`timescale 1ns / 1ps

module MAC(
        input clk,
        input reset,
        input [DATA_WIDTH-1:0] A_in,
        input [DATA_WIDTH-1:0] B_in,
        output reg [DATA_WIDTH-1:0] A_out,
        output reg [DATA_WIDTH-1:0] B_out,
        output reg [ACC_WIDTH-1:0] result
    );
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 16;

    wire [ACC_WIDTH-1:0] in, out;
    reg [ACC_WIDTH-1:0] prod;
    
    always@(*) begin 
        if(A_in != 0 && B_in != 0) begin
            prod = A_in*B_in;
        end
        else begin
            prod = 0;
        end
    end

    assign out = in + prod;

    MAC_reg register(
        .clk(clk),
        .reset(reset),
        .d(out),
        .q(in)
    );

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            A_out <= 0;
            B_out <= 0;
            result <= 0;
        end
        else begin
            A_out <= A_in;
            B_out <= B_in;
            result <= out;
        end
    end


endmodule