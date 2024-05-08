`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2023 20:21:51
// Design Name: 
// Module Name: top
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


module top
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32,  
    parameter N_REG = 32,
    parameter NB_DATA = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_DATA_OUT = 32,
    parameter NB_OP = 6
)
( 
    input   i_clk,
    input   i_reset    
);

localparam NB_REG_ADDRESS = $clog2(N_REG);

IF
#(
    NB_PC,
    NB_INS
)
u_IF
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_jump_address(),// TODO: Connect to a signal
    .i_write_address(),// TODO: Connect to a signal
    .i_is_jump(), // TODO: Connect to a signal
    .i_instruction(), // TODO: Connect to a signal
    .i_write_enable(),// TODO: Connect to a signal
    .o_instruction(if_instruction_if_id),  
    .o_address_plus_4(if_address_plus_4_if_id)
);

wire [NB_INS-1:0] if_instruction_if_id;
wire [NB_PC-1:0] if_address_plus_4_if_id;

IF_ID
#(
    NB_PC,
    NB_INS
)
u_if_id
( 
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_instruction(if_instruction_if_id), 
    .i_address_plus_4(if_address_plus_4_if_id),
    .o_instruction(if_id_instruction_id), 
    .o_address_plus_4(if_id_address_plus_4_id_ex)// TODO: Connect the other end of the signal
);

wire [NB_INS-1:0] if_id_instruction_id;
wire [NB_PC-1:0] if_id_address_plus_4_id_ex;

ID
#(
    NB_DATA,      
    N_REG, 
    NB_INS, 
    NB_DATA_IN,
    NB_OP
)
u_id
( 
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_instruction(if_id_instruction_id),
    .i_ctrl_regdst(),   
    .i_write_address(), 
    .o_rs_data(id_rs_data_id_ex),    
    .o_rt_data(id_rt_data_id_ex),    
    .o_opcode(id_opcode_id_ex),
    .o_rs_address(id_rs_address_id_ex),
    .o_rt_address(id_rt_address_id_ex),
    .o_write_address(id_write_address_id_ex),
    .o_inm_value(id_inm_value_id_ex),
    .o_sigext(id_sigext_id_ex)
);

wire [NB_DATA-1:0] id_rs_data_id_ex;
wire [NB_DATA-1:0] id_rt_data_id_ex;
wire [NB_OP-1:0] id_opcode_id_ex;
wire [NB_REG_ADDRESS-1:0] id_rs_address_id_ex;
wire [NB_REG_ADDRESS-1:0] id_rt_address_id_ex;
wire [NB_REG_ADDRESS-1:0] id_write_address_id_ex;
wire [NB_DATA_IN-1:0] id_inm_value_id_ex;
wire [NB_DATA-1:0] id_sigext_id_ex;


ID_EX
#(
    NB_DATA,
    NB_INS,
    NB_DATA_OUT,
    NB_DATA_IN,
    NB_OP,
    NB_REG_ADDRESS,
    NB_PC        
)
u_id_ex
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rs_data(id_rs_data_id_ex),
    .i_rt_data(id_rt_data_id_ex),
    .i_sigext(id_sigext_id_ex),    
    .i_opcode(id_opcode_id_ex),
    .i_rs_address(id_rs_address_id_ex),
    .i_rt_address(id_rt_address_id_ex),
    .i_write_address(id_write_address_id_ex),
    .i_address_plus_4(if_id_address_plus_4_id_ex),
    .o_rs_data(id_ex_rs_data_ex),
    .o_rt_data(id_ex_rt_data_ex),
    .o_sigext(id_ex_sigext_ex),
    .o_opcode(id_ex_opcode_ex),
    .o_rs_address(id_ex_rs_address_ex),
    .o_rt_address(id_ex_rt_address_ex),
    .o_write_address(id_ex_write_address_ex),
    .o_address_plus_4(id_ex_address_plus_4_ex)
);

wire [NB_DATA-1:0] id_ex_rs_data_ex;
wire [NB_DATA-1:0] id_ex_rt_data_ex;
wire [NB_INS-1:0] id_ex_sigext_ex;
wire [NB_OP-1:0] id_ex_opcode_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_rs_address_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_rt_address_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_write_address_ex;
wire [NB_PC-1:0] id_ex_address_plus_4_ex;

EX
#(    
    NB_DATA, 
    NB_INS,
    NB_DATA_OUT,
    NB_DATA_IN,
    NB_OP,
    NB_REG_ADDRESS,
    NB_PC,   
    NB_OP 
)
u_ex
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rs_data(id_ex_rs_data_ex),
    .i_rt_data(id_ex_rt_data_ex),
    .i_sigext(id_ex_sigext_ex),    
    .i_opcode(id_ex_opcode_ex),
    .i_rs_address(id_ex_rs_address_ex),
    .i_rt_address(id_ex_rt_address_ex),
    .i_inm_value(),
    .i_address_plus_4(id_ex_address_plus_4_ex),
    .o_res(ex_res_ex_mem),
    .o_zero(ex_zero_ex_mem),
    .o_rt_data(ex_rt_data_ex_mem),
    .o_jump_address(ex_jump_address_ex_mem),

    //input temporal
    .i_src_data_b() //0 rt, 1 inmediate
);

wire [NB_DATA-1:0] ex_res_ex_mem;
wire ex_zero_ex_mem;
wire [NB_DATA-1:0] ex_rt_data_ex_mem;
wire [NB_DATA-1:0] ex_jump_address_ex_mem;

EX_MEM
#(
    NB_DATA,
    NB_OP,
    NB_DATA_IN,
    NB_REG_ADDRESS
)
u_ex_mem
(    
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_res(ex_res_ex_mem),
    .i_zero(ex_zero_ex_mem),
    .i_rt_data(ex_rt_data_ex_mem),
    .i_jump_address(ex_jump_address_ex_mem),
    .i_write_address(),
    .o_res(),
    .o_zero(),
    .o_rt_data(),
    .o_jump_address(),
    .o_write_address()
);

endmodule