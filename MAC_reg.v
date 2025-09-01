`timescale 1ns / 1ps

module MAC_reg #(parameter ACC_WIDTH = 16)(
    input clk, reset,
    input [ACC_WIDTH-1:0] d,
    output reg [ACC_WIDTH-1:0] q
    );
    
    always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
            q <= 0;  
        else
            q <= d;  
    end  
endmodule
