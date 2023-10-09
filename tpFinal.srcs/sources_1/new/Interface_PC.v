`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:39:11
// Design Name: 
// Module Name: Interface_PC
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


module Interface_PC
#(
    parameter NB_PC = 32
)
(   
    input   i_clk, 
    input   [NB_PC-1:0] i_address,
    input   [NB_PC-1:0] i_jump_address,
    input   i_is_jump,
    output  [NB_PC-1:0] o_new_address
);

reg   [NB_PC-1:0] new_address;

always@(posedge i_clk)
begin
    if(i_is_jump)
        new_address <= i_jump_address;
    else
        new_address <= i_address + 4;
end

assign o_new_address = new_address;

endmodule
