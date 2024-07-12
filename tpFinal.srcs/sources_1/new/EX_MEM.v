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
    parameter NB_DATA = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_REG_ADDRESS = 5
)
(    
    input i_clk,
    input i_reset,
    input i_debug_unit_enable,
    input [NB_DATA-1 : 0] i_res,
    input i_alu_zero_from_ex,
    input [NB_DATA-1:0] i_rt_data,
    input [NB_DATA-1:0] i_jump_address,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input [NB_DATA-1:0] i_address_plus_4,
    input i_Branch_from_EX,
    input i_MemRead_from_EX,
    input i_MemWrite_from_EX,
    input i_ex_mem_flush,
   
    input [1:0] i_MemtoReg_from_EX,
    input [1:0] i_BHW_from_EX,
    input i_RegWrite_from_EX,
    input [NB_REG_ADDRESS-1:0] i_rt_address,
    output reg [NB_DATA-1 : 0] o_res,
    output reg o_alu_zero_to_ID,
    output reg [NB_DATA-1: 0] o_rt_data,
    output reg [NB_DATA-1:0] o_jump_address,
    output reg [NB_REG_ADDRESS-1:0] o_write_address,
    output reg [NB_DATA-1:0] o_address_plus_4,
    output reg o_Branch_to_ID,
    output reg o_MemRead_to_MEM,  
    output reg o_MemWrite_to_MEM,
   
    output reg [1:0] o_MemtoReg_to_MEM,
    output reg [1:0] o_BHW_to_MEM,
    output reg o_RegWrite_to_MEM,
    output reg [NB_REG_ADDRESS-1:0] o_rt_address
);
always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_res <= 0;
            o_alu_zero_to_ID <= 0;
            o_rt_data <= 0;
            o_jump_address <= 0;
            o_write_address <= 0;
            o_Branch_to_ID <= 0;
            o_MemRead_to_MEM <= 0; 
            o_write_address <= 0; 
            o_MemWrite_to_MEM <= 0;
            o_address_plus_4 <= 0;
            o_MemtoReg_to_MEM <= 0;
            o_BHW_to_MEM <= 0;
            o_RegWrite_to_MEM <= 0;
            o_rt_address <= 0;
        end
    else if(i_debug_unit_enable)
        begin
            o_res <= i_res;
            o_alu_zero_to_ID <= i_alu_zero_from_ex;
            o_rt_data <= i_rt_data;
            o_jump_address <= i_jump_address;        
            o_write_address <= i_write_address; 
            o_Branch_to_ID <= i_Branch_from_EX;
            o_MemRead_to_MEM <= i_MemRead_from_EX;
            o_MemWrite_to_MEM <= i_MemWrite_from_EX;
            o_address_plus_4 <= i_address_plus_4;
            o_MemtoReg_to_MEM <= i_MemtoReg_from_EX;
            o_BHW_to_MEM <= i_BHW_from_EX;
            o_RegWrite_to_MEM <= i_RegWrite_from_EX;
            o_rt_address <= i_rt_address;
        end
end
endmodule