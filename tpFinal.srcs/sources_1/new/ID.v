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
    parameter NB_REG_ADDRESS = $clog2(N_REG)
)
( 
    input   i_clk,
    input   i_reset,
    input   [NB_INS-1:0] i_instruction,
    input i_ctrl_regdst,   
    input [NB_REG_ADDRESS-1:0] i_write_address,
    output  [NB_DATA-1:0] o_rs_data,    
    output  [NB_DATA-1:0] o_rt_data,    
    output  [NB_OP-1:0] o_opcode,
    output  [NB_REG_ADDRESS-1:0] o_rs_address,
    output  [NB_REG_ADDRESS-1:0] o_rt_address,
    output [NB_REG_ADDRESS-1:0] o_write_address,
    output  [NB_DATA_IN-1:0] o_inm_value,
    output  [NB_DATA-1:0] o_sigext
);

wire [NB_REG_ADDRESS-1:0] rs_address;
wire [NB_REG_ADDRESS-1:0] rt_address;
wire [NB_REG_ADDRESS-1:0] rd_address;

assign rs_address = i_instruction[25:21];
assign rt_address = i_instruction[20:16];
assign rd_address = i_instruction[15:11];

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
    .i_data(),
    .rs_address(i_instruction[25:21]),
    .rt_address(i_instruction[20:16]),    
    .rw_address(),          //  vienen de la 
    .i_write_enable(),      //  etapa MEM/WB 
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



assign o_opcode = i_instruction[NB_INS-1:NB_INS-NB_OP]; // [31:26]
assign o_inm_value = i_instruction[NB_DATA_IN-1:0]; // [15:0]
assign o_rs_address = rs_address;
assign o_rt_address = rt_address;

// Mux para seleccionar el registro destino
assign o_write_address = i_ctrl_regdst ? rd_address : rt_address;

endmodule
