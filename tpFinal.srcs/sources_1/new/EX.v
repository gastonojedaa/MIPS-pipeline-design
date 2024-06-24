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
    parameter NB_DATA_OUT = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_OP = 6,
    parameter NB_REG_ADDRESS = 5,
    parameter NB_PC = 32,   
    parameter NB_OPS = 6,
    parameter NB_ALUCODE = 4,
    parameter NB_FUNCTION = 6
)
(
    input i_clk,
    input i_reset,
    input [NB_DATA-1:0] i_rs_data,
    input [NB_DATA-1:0] i_rt_data,
    input [NB_DATA-1:0] i_sigext,    
    input [NB_OP-1:0] i_opcode, 
    input [NB_REG_ADDRESS-1:0] i_rs_address,
    input [NB_REG_ADDRESS-1:0] i_rt_address,
    input [NB_DATA_IN-1:0] i_inm_value,
    input [NB_DATA-1:0] i_address_plus_4, //address from ID/EX
    input [NB_REG_ADDRESS-1:0] i_write_address, //para multiplexar con rt la señal de control
    
    input i_RegDst, //señal de control
    input i_ALUSrc, //señal de control
    input i_Branch_from_ID_EX, //señal de control
    input i_ALUOp_from_ID_EX, //señal de control
    input [NB_FUNCTION-1:0]i_function_from_id_ex, //señal de control
    
    output [NB_DATA : 0] o_res,
    output o_alu_zero_to_ex_mem,
    output [NB_DATA : 0] o_rt_data,
    output [NB_DATA - 1 : 0] o_jump_address,
    output reg [NB_REG_ADDRESS-1:0] o_write_address,
    output o_Branch_to_EX_MEM
);

wire [NB_DATA-1:0] data_b;

assign data_b = i_ALUSrc ? i_sigext : i_rt_data;  //mux entre rt e sig_ext
assign o_rt_data = i_rt_data; //rt que pasa directo
assign o_Branch_to_EX_MEM = i_Branch_from_ID_EX; //Branch que pasa directo
// Calc jump address
assign o_jump_address = i_address_plus_4 + i_sigext<<2;

always @(*)
begin
    if(i_RegDst)
        o_write_address = i_write_address;
    else
        o_write_address = i_rt_address;
end
   
alu#(
    NB_DATA,
    NB_ALUCODE
)
u_alu(
    .i_data_a(i_rs_data),
    .i_data_b(data_b),
    .i_alucode(o_alu_control), 
    .o_res(o_res),
    .o_zero(o_alu_zero_to_ex_mem)
);

control_alu
#(
    NB_OP,
    NB_FUNCTION,
    NB_ALUCODE
)
u_control_alu(
    .i_ALUOp(i_ALUOp_from_ID_EX),
    .i_funct(i_function_from_id_ex), 
    .o_alu_control(o_alu_control)
);


endmodule
