`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2024 18:57:46
// Design Name: 
// Module Name: WB
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


module WB
#(
    parameter NB_REG_ADDRESS = 5,
    parameter NB_DATA = 32    
)
(
    input i_clk,    
    input i_debug_unit_enable,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input [NB_DATA:0] i_res,
    input [NB_DATA-1:0] i_mem_data,
    input i_MemtoReg,
    output reg o_write_in_register_bank 
);

always@(posedge i_clk)
begin
    if(i_debug_unit_enable)
    begin
        if(i_MemtoReg)
        begin        
            o_write_in_register_bank <= i_mem_data;
        end
        else
        begin        
            o_write_in_register_bank <= i_res;
        end
    end
end        
endmodule
