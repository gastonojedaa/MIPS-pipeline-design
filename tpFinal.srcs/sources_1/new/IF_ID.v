`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2024 16:06:56
// Design Name: 
// Module Name: IF_ID
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


module IF_ID
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32  
)
( 
    input   i_clk,
    input   i_reset, 
    input   [NB_INS-1:0] i_instruction,
    input   [NB_PC-1:0] i_new_address,
    output reg  [NB_INS-1:0] o_instruction,
    output reg  [NB_PC-1:0] o_new_address  
        
);

always@(posedge i_clk)
begin
    if(i_reset)
        begin
            o_instruction <= 'hFFFFFFFF;
            o_new_address <= 0; 
        end 
    else
        begin
            o_instruction <= i_instruction;
            o_new_address <= i_new_address;
        end   
end

endmodule
