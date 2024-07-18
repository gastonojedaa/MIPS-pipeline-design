`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2024 18:45:25
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB
#(
    parameter NB_DATA = 32,
    parameter NB_REG_ADDRESS = 5
)
(
input i_clk,
input i_reset,
input i_debug_unit_enable,
input [NB_REG_ADDRESS-1:0] i_write_address,
input [NB_DATA-1:0] i_res,
input [NB_DATA-1:0] i_mem_data, 
input [NB_DATA-1:0] i_address_plus_4,
input [1:0] i_MemtoReg_from_MEM,
input i_RegWrite_from_MEM,
input [NB_REG_ADDRESS-1:0] i_rt_address,
input [NB_DATA-1:0] i_rt_data,
output reg [NB_REG_ADDRESS-1:0] o_write_address,
output reg [NB_DATA-1:0] o_res,
output reg [NB_DATA-1:0] o_mem_data,
output reg [NB_DATA-1:0] o_address_plus_4,
output reg [1:0] o_MemtoReg_to_WB,
output reg o_RegWrite_to_WB,
output reg [NB_REG_ADDRESS-1:0] o_rt_address,
output reg [NB_DATA-1:0] o_rt_data
);

always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_write_address <= 0;
            o_res <= 0;
            o_mem_data <= 0;
            o_address_plus_4 <= 0;
            o_MemtoReg_to_WB <= 0;
            o_RegWrite_to_WB <= 0;
            o_rt_address <= 31;
            o_rt_data <= 0;
        end
    else if(i_debug_unit_enable)
        begin
            o_write_address <= i_write_address;
            o_res <= i_res;
            o_mem_data <= i_mem_data;
            o_address_plus_4 <= i_address_plus_4;
            o_MemtoReg_to_WB <= i_MemtoReg_from_MEM;
            o_RegWrite_to_WB <= i_RegWrite_from_MEM;
            o_rt_address <= i_rt_address;
            o_rt_data <= i_rt_data;
        end
end
endmodule