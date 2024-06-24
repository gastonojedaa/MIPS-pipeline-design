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
    parameter NB_FUNCTION = 6
)
( 
    input   i_clk,
    input   i_reset,
    input   [NB_INS-1:0] i_instruction,
    input i_ctrl_regdst,   
    input i_debug_unit_enable,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    input i_pipeline_stalled_to_control_unit,
    input i_Branch_from_EX_MEM,
    input i_alu_zero_from_ex_mem,
    output  [NB_DATA-1:0] o_rs_data,    
    output  [NB_DATA-1:0] o_rt_data,    
    output  [NB_OP-1:0] o_opcode,
    output reg [NB_REG_ADDRESS-1:0] o_rs_address,
    output reg [NB_REG_ADDRESS-1:0] o_rt_address,
    output [NB_REG_ADDRESS-1:0] o_write_address,
    output  [NB_DATA_IN-1:0] o_inm_value,
    output  [NB_DATA-1:0] o_sigext,

    output o_PcSrc_to_IF,
    output o_RegDst_to_EX,
    output o_ALUSrc_to_EX,
    output o_MemtoReg_to_WB,
    output o_Branch_to_ID_EX,
    output o_ALUOp_to_ID_EX,
    output o_MemRead_to_MEM,
    output [NB_FUNCTION-1:0] o_function,
   

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
    .i_data(),
    .i_debug_unit_enable(i_debug_unit_enable),
    .rs_address(i_instruction[25:21]),
    .rt_address(i_instruction[20:16]),    
    .rw_address(i_write_address),          //  vienen de la 
    .i_RegWrite(RegWrite), //señal de control
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
    .o_RegDst(o_RegDst_to_EX),
    .O_ALUSrc(o_ALUSrc_to_EX),
    .o_ALUOp(o_ALUOp_to_ID_EX),
    .o_MemRead(o_MemRead_to_MEM),
    .o_MemWrite(),
    .o_Branch(o_Branch_to_ID_EX),
    .o_RegWrite(RegWrite),
    .o_MemtoReg(o_MemtoReg_to_WB)   
);
//cortocircuito
//dependiendo el valor de las flags va a recibir el valor de los registros o el valor de la etapa EX/MEM o MEM/WB
always@(posedge i_clk)
begin
    if(i_debug_unit_enable)
    begin
        case(i_forward_a)
            2'b00: o_rs_address = rs_address; //no hay cortocircuito
            2'b10: o_rs_address = i_write_address_ex_mem; //de la etapa EX/MEM
            2'b01: o_rs_address = i_write_address_mem_wb; //de la etapa MEM/WB
            2'b11: o_rs_address =  rs_address; //no deberia pasar
        endcase

        case(i_forward_b)
            2'b00: o_rt_address = rt_address; //no hay cortocircuito
            2'b10: o_rt_address = i_write_address_ex_mem; //de la etapa EX/MEM
            2'b01: o_rt_address = i_write_address_mem_wb; //de la etapa MEM/WB
            2'b11: o_rt_address =  rt_address;
        endcase
    end
end


assign o_opcode = i_instruction[NB_INS-1:NB_INS-NB_OP]; // [31:26]
assign o_inm_value = i_instruction[NB_DATA_IN-1:0]; // [15:0]
//assign o_rs_address = rs_address;
//assign o_rt_address = rt_address;

// Mux para seleccionar el registro destino
assign o_write_address = i_ctrl_regdst ? rd_address : rt_address;

endmodule
