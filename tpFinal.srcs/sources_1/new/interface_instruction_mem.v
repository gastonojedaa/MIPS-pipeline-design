`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 18:12:57
// Design Name: 
// Module Name: interface_instruction_mem
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


module interface_instruction_mem
#(
    parameter NB_PC = 32
)
(
    input   [NB_PC-1:0] i_pc_address,
    input   [NB_PC-1:0] i_ext_address,
    input   i_control, //1 PC - 0 EXT
    output  [NB_PC-1:0] o_address
);

reg   [NB_PC-1:0] address;

always@(*)
begin
    if(i_control)
        address = i_pc_address;
    else
        address = i_ext_address;        
end

assign  o_address = address; 

endmodule
