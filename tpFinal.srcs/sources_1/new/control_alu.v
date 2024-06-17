`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2024 18:02:02
// Design Name: 
// Module Name: control_alu
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

`define  R_TYPE_ALUOP          4'b0000
`define  LOAD_STORE_ADDI_ALUOP 4'b0001
`define  ANDI_ALUOP            4'b0010
`define  ORI_ALUOP             4'b0011
`define  XORI_ALUOP            4'b0100
`define  LUI_ALUOP             4'b0101
`define  SLTI_ALUOP            4'b0110
`define  BEQ_ALUOP             4'b0111
`define  BNE_ALUOP             4'b1000

//R_TYPE FUNCTIONS -> operaciones aritmeticas y logicas
`define SLL_FUNCT   6'b000000
`define SRL_FUNCT   6'b000010
`define SRA_FUNCT   6'b000011
`define SLLV_FUNCT  6'b000100
`define SRLV_FUNCT  6'b000110
`define SRAV_FUNCT  6'b000111
`define ADDU_FUNCT  6'b100001
`define SUBU_FUNCT  6'b100011
`define AND_FUNCT   6'b100100
`define OR_FUNCT    6'b100101
`define XOR_FUNCT   6'b100110
`define NOR_FUNCT   6'b100111
`define SLT_FUNCT   6'b101010
`define JR_FUNCT    6'b001000 
`define JALR_FUNCT  6'b001001

//ALU CODES -> codigo de operacion de la ALU
`define  SLL_ALUCODE  4'b0000
`define  SRL_ALUCODE  4'b0001
`define  SRA_ALUCODE  4'b0010
`define  SLLV_ALUCODE 4'b1010
`define  SRLV_ALUCODE 4'b1011
`define  SRAV_ALUCODE 4'b1100
`define  ADD_ALUCODE  4'b0011
`define  SUB_ALUCODE  4'b0100
`define  AND_ALUCODE  4'b0101
`define  OR_ALUCODE   4'b0110
`define  XOR_ALUCODE  4'b0111
`define  NOR_ALUCODE  4'b1000
`define  SLT_ALUCODE  4'b1001
`define  LUI_ALUCODE  4'b1101
`define  BNE_ALUCODE  4'b1110

module control_alu
#(
    parameter NB_OP = 4,
    parameter NB_FUNCTION = 6,
    parameter NB_ALUCODE = 4

)
(
    input [NB_OP-1:0] i_ALUOp, // -> from control_unit
    input [NB_FUNCTION-1:0]i_funct,

    output reg [NB_ALUCODE-1:0] o_alu_control
);

always @(*)
begin
    case(i_ALUOp)        
        `R_TYPE_ALUOP:
            case(i_funct)
                    `SLL_FUNCT: o_alu_control = `SLL_ALUCODE;
                    `SRL_FUNCT: o_alu_control = `SRL_ALUCODE;
                    `SRA_FUNCT: o_alu_control = `SRA_ALUCODE;
                    `SLLV_FUNCT: o_alu_control = `SLLV_ALUCODE;
                    `SRLV_FUNCT: o_alu_control = `SRLV_ALUCODE;
                    `SRAV_FUNCT: o_alu_control = `SRAV_ALUCODE;
                    `ADDU_FUNCT: o_alu_control = `ADD_ALUCODE;
                    `SUBU_FUNCT: o_alu_control = `SUB_ALUCODE;
                    `AND_FUNCT: o_alu_control = `AND_ALUCODE;
                    `OR_FUNCT: o_alu_control = `OR_ALUCODE;
                    `XOR_FUNCT: o_alu_control = `XOR_ALUCODE;
                    `NOR_FUNCT: o_alu_control = `NOR_ALUCODE;
                    `SLT_FUNCT: o_alu_control = `SLT_ALUCODE;
                    default: o_alu_control = 'b1111  ;                                                     
            endcase  
        `LOAD_STORE_ADDI_ALUOP: o_alu_control = `ADD_ALUCODE; //TODO: revisar
        `ANDI_ALUOP: o_alu_control = `AND_ALUCODE;
        `ORI_ALUOP: o_alu_control = `OR_ALUCODE;
        `XORI_ALUOP: o_alu_control = `XOR_ALUCODE; 
        `LUI_ALUOP: o_alu_control = `LUI_ALUCODE;
        `SLTI_ALUOP: o_alu_control = `SLT_ALUCODE;
        `BEQ_ALUOP: o_alu_control = `SUB_ALUCODE;
        `BNE_ALUOP: o_alu_control = `BNE_ALUCODE;
        default: o_alu_control = 4'b1111;         
    endcase
end    
endmodule