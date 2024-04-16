`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:17:44
// Design Name: 
// Module Name: IF
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


module IF
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32  
)
( 
    input   i_clk,
    input   i_reset,     
    input   [NB_PC-1:0] i_jump_address,
    input   [NB_PC-1:0] i_write_address,
    input   i_is_jump, 
    input   [NB_INS-1:0]i_instruction, 
    input   i_write_enable, // 0 READ - 1 WRITE
    output  [NB_INS-1:0] o_instruction,  
    output  [NB_PC-1:0] o_address_plus_4
);

wire [NB_PC-1:0] new_address;
wire [NB_PC-1:0] address;
wire [NB_PC-1:0] address_plus_4;
reg [NB_PC-1:0] pc;

assign address_plus_4 = address + 4;

// Mux PC - PC + 4 o jump address
always@(*)
begin
    if(i_is_jump)
        new_address = i_jump_address;
    else
        new_address = address_plus_4;
end

// PC
always@(posedge i_clk)
begin
    if(i_reset)
        pc <= 0;
    else
        pc <= new_address;
end


instruction_mem
#(
    NB_PC,
    NB_INS
)
u_instruction_mem
(
    .i_clk(i_clk),
    .i_read_address(address),
    .i_write_address(i_write_address),
    .i_instruction(i_instruction), 
    .i_write_enable(i_write_enable), 
    .o_instruction(o_instruction)         
);

assign o_address_plus_4 = address_plus_4;

endmodule
