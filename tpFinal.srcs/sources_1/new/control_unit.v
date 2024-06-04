`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2024 08:58:36
// Design Name: 
// Module Name: control_unit
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

module control_unit#(
    parameter NB_FUNCTION = 6,
    parameter NB_OP = 6,    
    parameter NB_CONTROL = 15 // capaz 16 xd

)
(
    input [NB_OP-1:0] i_opcode,
    output [NB_FUNCTION-1:0] i_function,
    output [NB_CONTROL-1:0] o_control
);

reg [NB_CONTROL-1:0] control_data;

/*
*   Con el opcode se determina si la instrucción es de tipo R, I o J
*   Y con el valor de los bits de function se habilitan las señales de control correspondientes 
*   Y despues no sé
*/

always @(*)
begin
    case(i_opcode)
        6'b000000: ; //R
        6'b100011: ; //lw
        6'b101011: ; //sw
        6'b000100: ; //beq
    endcase 
end

endmodule

// Las señales de control son 9, pero no se si son 9 por aluop0 y aluop1 o 9 porque se tiene en cuenta
// tambien el ALUCtr

// A veces hacen referencia a la señal PCsrc pero en las tablas de control no se menciona (debe ser la señal branch)

//el orden que plantea el libro
// 0-5 opcode
// 6 MemToReg
// 7 RegWrite
// 8 MemWrite
// 9 MemRead
// 10 Branch
// 11 ALUSrc
// 12 AluOp0
// 13 AluOp1
// 14 RegDst

//   Señal          |   Tipo R  |   lw  |   sw  |   beq
//  MemToReg        |    1      |   1   |   x   |   x
//  RegWrite        |    1      |   1   |   0   |   0
//  MemWrite        |    0      |   0   |   1   |   0
// MemRead          |    0      |   1   |   0   |   0
//  Branch          |    0      |   0   |   0   |   1
//  ALUSrc          |    0      |   1   |   1   |   0
//  AluOp           |    10     |   00  |   00  |   01
//  RegDst          |    1      |   0   |   x   |   x

