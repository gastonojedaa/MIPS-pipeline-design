`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2024 15:58:51
// Design Name: 
// Module Name: ID
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


module ID
#(
    parameter NB_DATA = 32,     
    parameter N_REG = 32,
    parameter NB_INS = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_OP = 6,
    parameter NB_REG_ADDRESS = $clog2(N_REG),
    parameter NB_FUNCTION = 6,
    parameter NB_PC = 32
)
( 
    input   i_clk,
    input   i_reset,
    input   [NB_INS-1:0] i_instruction,  
    input i_debug_unit_enable,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input [NB_DATA-1:0] i_data_to_write_in_register_bank,
    input i_pipeline_stalled_to_control_unit,
    input i_Branch_from_EX_MEM,
    input i_alu_zero_from_ex_mem,
    input [NB_PC-1:0] i_address_plus_4,
    input i_RegWrite_from_WB,
    output  [NB_DATA-1:0] o_rs_data,    
    output  [NB_DATA-1:0] o_rt_data,    
    output  [NB_REG_ADDRESS-1:0] o_rs_address, 
    output  [NB_REG_ADDRESS-1:0] o_rt_address,
    output  [NB_REG_ADDRESS-1:0] o_rd_address,
    output  [NB_DATA_IN-1:0] o_inm_value,
    output  [NB_DATA-1:0] o_sigext,

    output o_PcSrc_to_IF,
    output [1:0] o_RegDst_to_ID_EX,
    output o_ALUSrc_to_ID_EX,
    output [1:0] o_MemtoReg_to_ID_EX,
    output o_Branch_to_ID_EX,
    output [3:0] o_ALUOp_to_ID_EX,
    output o_MemRead_to_ID_EX,
    output o_MemWrite_to_ID_EX,
    output o_RegWrite_to_ID_EX,
    output [NB_FUNCTION-1:0] o_function,
    output [NB_PC-1:0] o_address_plus_4,
   

    input [1:0]i_forward_a,
    input [1:0]i_forward_b,

    input [NB_REG_ADDRESS-1:0] i_write_address_ex_mem,
    input [NB_REG_ADDRESS-1:0] i_write_address_mem_wb
);

wire [NB_REG_ADDRESS-1:0] rs_address;
wire [NB_REG_ADDRESS-1:0] rt_address;
wire [NB_REG_ADDRESS-1:0] rd_address;

wire RegWrite;

assign rs_address = i_instruction[25:21];
assign rt_address = i_instruction[20:16];
assign rd_address = i_instruction[15:11];
assign o_function = i_instruction[5:0];


register_bank
#(
    NB_DATA,
    N_REG,
    NB_REG_ADDRESS
)
u_register_bank
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_data_to_write(i_data_to_write_in_register_bank),
    .i_debug_unit_enable(i_debug_unit_enable),
    .rs_address(i_instruction[25:21]),
    .rt_address(i_instruction[20:16]),    
    .rw_address(i_write_address),          //  vienen de la 
    .i_RegWrite(i_RegWrite_from_WB), //señal de control
    .rs_data(o_rs_data),
    .rt_data(o_rt_data)    
);

sign_ext
#(
    NB_DATA_IN,
    NB_INS
)
u_sign_ext
(
    .i_data_in(i_instruction[15:0]),
    .o_sigext(o_sigext)
); 

//control unit

control_unit
#(
    NB_FUNCTION,
    NB_OP
)
u_control_unit
(      
    .i_opcode(i_instruction[NB_INS-1:NB_INS-NB_OP]),
    .i_function(i_instruction[5:0]),
    .i_pipeline_stalled(i_pipeline_stalled_to_control_unit),
    .i_Branch(i_Branch_from_EX_MEM),
    .i_zero_from_alu(i_alu_zero_from_ex_mem),
    .o_PcSrc(o_PcSrc_to_IF),
    .o_RegDst(o_RegDst_to_ID_EX),
    .O_ALUSrc(o_ALUSrc_to_ID_EX),
    .o_ALUOp(o_ALUOp_to_ID_EX),
    .o_MemRead(o_MemRead_to_ID_EX),
    .o_MemWrite(o_MemWrite_to_ID_EX),
    .o_Branch(o_Branch_to_ID_EX),
    .o_RegWrite(o_RegWrite_to_ID_EX),
    .o_MemtoReg(o_MemtoReg_to_ID_EX)   
);

assign o_inm_value = i_instruction[NB_DATA_IN-1:0]; // [15:0]
assign o_rs_address = rs_address;
assign o_rt_address = rt_address;
// Mux para seleccionar el registro destino
assign o_rd_address = rd_address;
assign o_address_plus_4 = i_address_plus_4;

endmodule
