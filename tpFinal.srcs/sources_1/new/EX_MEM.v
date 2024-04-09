`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2024 15:00:54
// Design Name: 
// Module Name: EX_MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EX_MEM
#(
    parameter NB_DATA = 8,
    parameter NB_OPS = 6,
    parameter NB_DATA_IN = 16
)
(    
    input i_clk,
    input i_reset,
    input [NB_DATA : 0] i_res,
    input i_zero,
    input [NB_DATA:0] i_rt_data,
    output reg [NB_DATA : 0] o_res,
    output reg o_zero,
    output reg [NB_DATA : 0] o_rt_data
);
always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_res <= 0;
            o_zero <= 0;
            o_rt_data <= 0;
        end
    else
        begin
            o_res <= i_res;
            o_zero <= i_zero;
            o_rt_data <= i_rt_data;            
        end
end
endmodule