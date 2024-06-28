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
initial
begin
    ins_mem[0] = 32'b00111100000000110000000000001010;
    ins_mem[1] = 32'b11111111111111111111111111111111;
end

always@(posedge i_clk)
begin
    if(i_write_enable)
        ins_mem[i_write_address] <= i_instruction;    
end

assign o_instruction = ins_mem[i_read_address];

endmodule
