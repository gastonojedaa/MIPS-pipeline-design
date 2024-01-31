`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:25:27
// Design Name: 
// Module Name: PC
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


module PC
#(
    parameter NB_PC = 32 
)
(
    input   i_clk,
    input   i_reset,
    input   [NB_PC-1:0] i_jump_address,
    input   i_is_jump,
    output  [NB_PC-1:0] o_current_address,
    output  [NB_PC-1:0] o_new_address   
);

reg [NB_PC-1:0] address;
reg [NB_PC-1:0] new_address;

always@(*)
begin
    if(i_is_jump)
        new_address = i_jump_address;
    else
        new_address = address + 4;
end

always@(posedge i_clk)
begin
    if(i_reset)
        address <= 0;
    else
        address <= new_address;    
end

assign o_current_address = address;
assign o_new_address = new_address;

endmodule
