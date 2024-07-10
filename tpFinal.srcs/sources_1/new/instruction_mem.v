`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:51:51
// Design Name: 
// Module Name: instruction_mem
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


module instruction_mem
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32     
)
(
    input   i_clk,    
    input  [NB_PC-1:0] i_read_address,
    input   [NB_PC-1:0] i_write_address,
    input   [NB_INS-1:0] i_instruction,
    input   i_write_enable, // 0 READ - 1 WRITE
    output  [NB_INS-1:0] o_instruction
);

//localparam MEM_SIZE = (2**NB_PC) - 1;
localparam MEM_SIZE = 255;

integer i;
reg [NB_INS-1:0] ins_mem[0:MEM_SIZE];

// initial
// begin
//     for (i = 0; i <= MEM_SIZE; i = i + 1) begin
//         ins_mem[i] = i*2;
//     end
// end
// initial
// begin
//     ins_mem[0] = 32'b00111100000000110000000000000000;//lui r3, 0
//     ins_mem[1] = 32'b00111100000001010000000000001010;//lui r5, a
//     ins_mem[2] = 32'b00111100000001010000000000001010;//lui r5, a
//     ins_mem[3] = 32'b00111100000001010000000000001010;//lui r5, a
//     ins_mem[4] = 32'b00111100000001010000000000001010;//lui r5, a
//     ins_mem[5] = 32'b00010000000000110000000000000001;//beq r0 r3 1
//     ins_mem[6] = 32'b00111100000111110000000011111111;//lui r31, ff
//     ins_mem[7] = 32'b11111111111111111111111111111111;
// end
initial
begin
    ins_mem[0] = 32'b00111100000000110000000000001010;//LUI r3 10
    ins_mem[1] = 32'b00111100000001010000000000001010;//LUI r5 10
    ins_mem[2] = 32'b00100000001000010000000000000010;//ADDI r1 r1 2
    ins_mem[3] = 32'b00100000010000100000000000000011;//ADDI r2 r2 3
    ins_mem[4] = 32'b00100000011000110000000000000001;//ADDI r3 r3 1
    ins_mem[5] = 32'b00010000000001100000000000000001;//BEQ r0 r6 1
    ins_mem[6] = 32'b00111100000111110000000011111111;//LUI r31 255
    ins_mem[7] = 32'b00100011110111100000000001000000;//ADDI r30 r30 64
    ins_mem[8] = 32'b11111111111111111111111111111111;//HALT
end

always@(posedge i_clk)
begin
    if(i_write_enable)
        ins_mem[i_write_address] <= i_instruction;    
end

assign o_instruction = ins_mem[i_read_address];

endmodule
