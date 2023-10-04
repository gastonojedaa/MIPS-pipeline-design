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
    input   [NB_PC-1:0] i_address,
    input   [NB_INS-1:0]i_instruction, 
    input   i_control, // 1 READ - 0 WRITE
    output  [NB_INS-1:0] o_instruction
);

reg [NB_PC-1:0] ins_mem[NB_INS-1:0];

always@(posedge i_clk)
begin
    if(!i_control)
        ins_mem[i_address] <= i_instruction;
    else
        ins_mem[i_address] <= ins_mem[i_address];
end

assign o_instruction = ins_mem[i_address];

endmodule
