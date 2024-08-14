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
    parameter N_REG = 32, 
    parameter NB_DATA_OUT = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_OP = 4,
    parameter NB_REG_ADDRESS = $clog2(N_REG),
    parameter NB_PC = 32,   
    parameter NB_OPS = 6,
    parameter NB_ALUCODE = 4,
    parameter NB_FUNCTION = 6
)
(
    input i_debug_unit_enable,
    input [NB_DATA-1:0] i_rs_data,
    input [NB_DATA-1:0] i_rt_data,
    input [NB_DATA-1:0] i_sigext,
    input [NB_REG_ADDRESS-1:0] i_rt_address,    
    input [NB_REG_ADDRESS-1:0] i_rd_address, //para multiplexar con rt la señal de control
    input [NB_DATA-1:0] i_address_plus_4, //address from ID/EX
    input [NB_FUNCTION-1:0]i_function_from_id_ex, //señal de control
    input [1:0] i_forward_a,
    input [1:0] i_forward_b,
    //cortocircuito
    input [NB_DATA-1:0] i_rt_data_ex_mem,
    input [NB_DATA-1:0] i_rt_data_mem_wb,

    input [1:0] i_RegDst_from_ID_EX, //señal de control
    input [1:0] i_ALUSrc_from_ID_EX, //señal de control
    input [3:0] i_ALUOp_from_ID_EX, //señal de control
    input i_MemRead_from_ID_EX, //señal de control
    input i_MemWrite_from_ID_EX, //señal de control
    input [1:0] i_MemtoReg_from_ID_EX, //señal de control
    input i_RegWrite_from_ID_EX, //señal de control

    output [NB_DATA-1 : 0] o_res,
    output o_alu_zero_to_ex_mem,
    output [NB_DATA-1: 0] o_rt_data,
    output [NB_DATA-1: 0] o_rs_data,
    output reg [NB_REG_ADDRESS-1:0] o_write_address,
    output o_MemRead_to_EX_MEM,
    output o_MemWrite_to_EX_MEM,
    output [NB_DATA-1:0] o_address_plus_4,
    output [1:0] o_MemtoReg_to_EX_MEM,
    output o_RegWrite_to_EX_MEM,

    output [NB_REG_ADDRESS-1:0] o_rt_address //to short circuit

);

reg [NB_DATA-1:0] rs_data;
reg [NB_DATA-1:0] rt_data;
wire [NB_DATA-1:0] data_a;
wire [NB_DATA-1:0] data_b;


//aca hay que asignar el rt_data y rs_data a los mux de forward
//cortocircuito
//dependiendo el valor de las flags va a recibir el valor de los registros o el valor de la etapa EX/MEM o MEM/WB
always@(*)
begin
    case(i_forward_a)
        2'b00: rs_data = i_rs_data; //no hay cortocircuito
        2'b10: rs_data = i_rt_data_ex_mem; //de la etapa EX/MEM
        2'b01: rs_data = i_rt_data_mem_wb; //de la etapa MEM/WB
        2'b11: rs_data = i_rs_data; //no deberia pasar
    endcase

    case(i_forward_b)
        2'b00: rt_data = i_rt_data; //no hay cortocircuito
        2'b10: rt_data = i_rt_data_ex_mem; //de la etapa EX/MEM
        2'b01: rt_data = i_rt_data_mem_wb; //de la etapa MEM/WB
        2'b11: rt_data = i_rt_data;
    endcase
end

assign data_a = i_ALUSrc_from_ID_EX[1] ? rt_data : rs_data;  //mux entre rt y rs
assign data_b = i_ALUSrc_from_ID_EX[0] ? i_sigext : rt_data;  //mux entre rt e sig_ext
assign o_MemRead_to_EX_MEM = i_MemRead_from_ID_EX; //MemRead que pasa directo
assign o_MemWrite_to_EX_MEM = i_MemWrite_from_ID_EX; //MemWrite que pasa directo

assign o_address_plus_4 = i_address_plus_4;
assign o_MemtoReg_to_EX_MEM = i_MemtoReg_from_ID_EX;
assign o_RegWrite_to_EX_MEM = i_RegWrite_from_ID_EX;
assign o_rt_data = rt_data;
assign o_rs_data = rs_data;
assign o_rt_address = i_rt_address;

always @(*)
begin
    if(i_RegDst_from_ID_EX == 2'b00) 
        o_write_address = i_rt_address;
    else if(i_RegDst_from_ID_EX == 2'b01)
        o_write_address = i_rd_address;
    else
        o_write_address = 5'b11111; //JAL and JALR
end

wire [NB_ALUCODE-1:0] alu_control;

alu#(
    .NB_DATA(NB_DATA),
    .NB_ALUCODE(NB_ALUCODE)
)
u_alu(
    .i_data_a(data_a),
    .i_data_b(data_b),
    .i_alucode(alu_control), 
    .o_res(o_res),
    .o_zero(o_alu_zero_to_ex_mem)
);

control_alu
#(
    .NB_OP(NB_OP),
    .NB_FUNCTION(NB_FUNCTION),
    .NB_ALUCODE(NB_ALUCODE)
)
u_control_alu(
    .i_ALUOp(i_ALUOp_from_ID_EX),
    .i_funct(i_function_from_id_ex), 
    .o_alu_control(alu_control)
);


endmodule
