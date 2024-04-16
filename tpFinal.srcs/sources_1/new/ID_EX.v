`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2024 17:45:29
// Design Name: 
// Module Name: ID_EX
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


module ID_EX
#(
    parameter NB_DATA = 32, 
    parameter NB_INS = 32,
    parameter NB_DATA_OUT = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_OP = 6,
    parameter NB_REG_ADDRESS = 5,
    parameter NB_PC = 32        
)
(
    input i_clk,
    input i_reset,
    input [NB_DATA-1:0] i_rs_data,
    input [NB_DATA-1:0] i_rt_data,
    input [NB_DATA_OUT-1:0] i_sigext,    
    input [NB_OP-1:0] i_opcode,
    input [NB_REG_ADDRESS-1:0] i_rs_address,
    input [NB_REG_ADDRESS-1:0] i_rt_address,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input [NB_PC-1:0] i_address_plus_4, //address from IF/ID
    output reg [NB_DATA-1:0] o_rs_data,
    output reg [NB_DATA-1:0] o_rt_data,
    output reg [NB_INS-1:0] o_sigext,
    output reg [NB_OP-1:0] o_opcode,
    output reg [NB_REG_ADDRESS-1:0] o_rs_address,
    output reg [NB_REG_ADDRESS-1:0] o_rt_address,
    output reg [NB_REG_ADDRESS-1:0] o_write_address,
    output reg [NB_PC-1:0] o_address_plus_4
);
    
always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_rs_data <= 0;
            o_rt_data <= 0;
            o_sigext <= 0;
            o_opcode <= 0;
            o_rs_address <= 0;
            o_rt_address <= 0;
            o_write_address <= 0;
            o_address_plus_4 <= 0;
        end
    else
        begin                              
            o_rs_data <= i_rs_data;
            o_rt_data <= i_rt_data;
            o_sigext <= i_sigext;
            o_opcode <= i_opcode;
            o_rs_address <= i_rs_address;
            o_rt_address <= i_rt_address;
            o_write_address <= i_write_address;      
            o_address_plus_4 <= i_address_plus_4;     
        end
end

endmodule
