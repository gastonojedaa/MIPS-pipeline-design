`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2024 17:46:43
// Design Name: 
// Module Name: MEM
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


module MEM
#(
    parameter NB_DATA = 32,
    parameter NB_REG_ADDRESS = 5,
    parameter NB_ADDR = 32,
    parameter NB_INS = 32  
)
(
    input i_clk,
    input i_reset,
    input i_debug_unit_enable,
    input [NB_DATA-1:0] i_res,
    input [NB_DATA-1:0] i_read_address_from_du,  
    input [NB_DATA-1:0] i_rt_data,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input [NB_DATA-1:0] i_address_plus_4,
    input i_MemRead_from_EX_MEM,
    input i_MemWrite_from_EX_MEM,
    input [1:0] i_MemtoReg_from_EX_MEM,
    input [2:0] i_BHW_from_EX_MEM,
    input i_RegWrite_from_EX_MEM,
    input [NB_REG_ADDRESS-1:0] i_rt_address,
    output [NB_DATA-1:0] o_res,
    output [NB_DATA-1:0] o_mem_data,
    output [NB_REG_ADDRESS-1:0] o_write_address,
    output [NB_DATA-1:0] o_address_plus_4,
    output [1:0] o_MemtoReg_to_MEM_WB,
    output o_RegWrite_to_MEM_WB,
    output [NB_REG_ADDRESS-1:0] o_rt_address,
    output [NB_DATA-1:0] o_rt_data

);
reg [NB_DATA-1:0] read_address;
reg [2:0] bhw;

always@(*)
begin
    read_address = i_debug_unit_enable ? i_res : i_read_address_from_du;
    bhw = i_debug_unit_enable ? i_BHW_from_EX_MEM : 3'b111;
end

assign o_address_plus_4 = i_address_plus_4;
assign o_write_address = i_write_address;
assign o_res = i_res;
assign o_MemtoReg_to_MEM_WB = i_MemtoReg_from_EX_MEM;
assign o_RegWrite_to_MEM_WB = i_RegWrite_from_EX_MEM;
assign o_rt_address = i_rt_address;
assign o_rt_data = i_rt_data;

data_mem
#(
    .NB_ADDR(NB_ADDR),
    .NB_INS(NB_INS)
)
u_data_mem
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_data_mem_read_address(read_address), 
    .i_data_mem_write_address(i_res),
    .i_data_mem_data(i_rt_data), 
    .i_data_mem_write_enable(i_MemWrite_from_EX_MEM),
    .i_data_mem_bhw(bhw),
    .o_mem_data(o_mem_data)
);
endmodule
