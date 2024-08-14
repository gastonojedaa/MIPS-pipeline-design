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
    parameter NB_OPS = 6,
    parameter NB_FUNCTION = 6,
    parameter NB_PC = 32,
    parameter NB_DATA_OUT = 32,
    parameter NB_REG_ADDRESS = $clog2(N_REG)
)
(
    input   i_clk,
    input   i_reset,
    input   i_debug_unit_enable,
    input   i_pipeline_stalled_to_control_unit,
    input   i_alu_zero_from_ex_mem,
    input   i_RegWrite_from_WB,
    input [NB_REG_ADDRESS-1:0] i_reg_address_from_DU,
    input   [NB_INS-1:0] i_instruction,  
    input   [NB_REG_ADDRESS-1:0] i_write_address,
    input   [NB_DATA-1:0] i_data_to_write_in_register_bank,
    input   [NB_PC-1:0] i_address_plus_4,
    input   [NB_DATA-1:0] i_rs_data_from_shortcircuit,
    input   [NB_DATA-1:0] i_rt_data_from_shortcircuit,
    output  [NB_DATA-1:0] o_rs_data,    
    output  [NB_DATA-1:0] o_rt_data,    
    output  [NB_REG_ADDRESS-1:0] o_rs_address, 
    output  [NB_REG_ADDRESS-1:0] o_rt_address,
    output  [NB_REG_ADDRESS-1:0] o_rd_address,
    output  [NB_DATA_IN-1:0] o_inm_value,
    output  [NB_DATA-1:0] o_sigext,
    output [NB_FUNCTION-1:0] o_function,
    output [NB_PC-1:0] o_address_plus_4,
    //señales de control
    output [1:0] o_PcSrc_to_IF,
    output [1:0] o_RegDst_to_ID_EX,
    output [1:0] o_ALUSrc_to_ID_EX,
    output [3:0] o_ALUOp_to_ID_EX,
    output reg o_MemRead_to_ID_EX,
    output o_MemWrite_to_ID_EX,
    //output o_Branch_to_ID_EX,
    output o_RegWrite_to_ID_EX,
    output [1:0] o_MemtoReg_to_ID_EX,
    output [2:0] o_BHW_to_ID_EX,
    output reg o_execute_branch,
    output o_IF_ID_flush,
    output o_ex_mem_flush,
    output reg [NB_PC-1:0] o_jump_address,
    output [NB_DATA-1:0] o_reg_data_to_DU
);

wire [NB_REG_ADDRESS-1:0] rs_address;
wire [NB_REG_ADDRESS-1:0] rt_address;
wire [NB_REG_ADDRESS-1:0] rd_address;

wire RegWrite;

assign rs_address = i_instruction[25:21];
assign rt_address = i_instruction[20:16];
assign rd_address = i_instruction[15:11];
assign o_function = i_instruction[5:0];


wire MemRead;
wire [NB_DATA-1:0] rs_data;
wire [NB_DATA-1:0] rt_data;
wire [1:0] branch;

wire  [NB_DATA-1:0] sigext;


register_bank
#(
    .NB_DATA(NB_DATA),
    .N_REG(N_REG),
    .NB_REG_ADDRESS(NB_REG_ADDRESS)
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
    .i_reg_address(i_reg_address_from_DU),
    .o_rs_data(rs_data),
    .o_rt_data(rt_data),
    .o_reg_data(o_reg_data_to_DU) 
);

sign_ext
#(
    .NB_DATA_IN(NB_DATA_IN),
    .NB_DATA_OUT(NB_DATA_OUT)
)
u_sign_ext
(
    .i_data_in(i_instruction[15:0]),
    .o_sigext(sigext)
); 

wire [1:0] PcSrc_to_IF;

//control unit
control_unit
#(
    .NB_FUNCTION(NB_FUNCTION),
    .NB_OPS(NB_OPS)
)
u_control_unit
(      
    .i_opcode(i_instruction[NB_INS-1:NB_INS-NB_OPS]),
    .i_function(i_instruction[5:0]),
    .i_pipeline_stalled(i_pipeline_stalled_to_control_unit),
    .i_zero_from_alu(i_alu_zero_from_ex_mem),
    .o_PcSrc(PcSrc_to_IF),
    .o_RegDst(o_RegDst_to_ID_EX),
    .O_ALUSrc(o_ALUSrc_to_ID_EX),
    .o_ALUOp(o_ALUOp_to_ID_EX),
    .o_MemRead(MemRead),
    .o_MemWrite(o_MemWrite_to_ID_EX),
    .o_Branch(branch),
    .o_RegWrite(o_RegWrite_to_ID_EX),
    .o_MemtoReg(o_MemtoReg_to_ID_EX),
    .o_BHW(o_BHW_to_ID_EX),
    .o_IF_ID_flush(o_IF_ID_flush),
    .o_EX_MEM_flush(o_ex_mem_flush)
);

assign o_PcSrc_to_IF = PcSrc_to_IF;

always@(*)
begin
if(branch==2'b01 && i_rs_data_from_shortcircuit == i_rt_data_from_shortcircuit)
    o_execute_branch = 1;
else if(branch==2'b10 && i_rs_data_from_shortcircuit != i_rt_data_from_shortcircuit)
    o_execute_branch = 1;
else
    o_execute_branch = 0;
end

assign o_inm_value = i_instruction[NB_DATA_IN-1:0]; // [15:0]
assign o_rs_address = rs_address;
assign o_rt_address = rt_address;
// Mux para seleccionar el registro destino
assign o_rd_address = rd_address;
assign o_address_plus_4 = i_address_plus_4;

always@(*)
begin
    case(PcSrc_to_IF)
        2'b00: o_jump_address = i_address_plus_4 + sigext;
        2'b10: o_jump_address = {6'b0, i_instruction[25:0]};
        2'b11: o_jump_address = rs_data;
        default: o_jump_address = i_address_plus_4 + sigext;// Should not happen
    endcase
end

always@(posedge i_clk)
begin
    if(i_reset)
        o_MemRead_to_ID_EX <= 0;
    else
        o_MemRead_to_ID_EX <= MemRead;
end

assign o_rs_data = rs_data;
assign o_rt_data = rt_data;
assign o_sigext = sigext;

endmodule
