`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2024 17:01:47
// Design Name: 
// Module Name: EX
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


module EX
#(    
    parameter NB_DATA = 32, 
    parameter NB_INS = 32,
    parameter NB_DATA_OUT = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_OP = 6,
    parameter NB_REG_ADDRESS = 5,
    parameter NB_PC = 32,   
    parameter NB_OPS = 6 
)
(
    input i_clk,
    input i_reset,
    input [31:0] i_rs_data,
    input [31:0] i_rt_data,
    input [31:0] i_sigext,    
    input [5:0] i_opcode,
    input [4:0] i_rs_address,
    input [4:0] i_rt_address,
    input [15:0] i_inm_value,
    input [31:0] i_new_address, //address from ID/EX
    output [NB_DATA : 0] o_res,
    output o_zero,
    output [NB_DATA : 0] o_rt_data,

    //input temporal
    input i_src_data_b //0 rt, 1 inmediate
);

wire [31:0] data_b;

assign data_b = i_src_data_b ? i_sigext : i_rt_data;  //mux entre rt e sig_ext
assign o_rt_data = i_rt_data; //rt que pasa directo

alu#(
    NB_DATA,
    NB_OPS
)
u_alu(
    .i_data_a(i_rs_data),
    .i_data_b(data_b),
    .i_ops(i_opcode),
    .o_res(o_res),
    .o_zero(o_zero)
);


endmodule
