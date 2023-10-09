`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2023 17:26:30
// Design Name: 
// Module Name: tb_IF
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

module tb_IF;

parameter NB_PC = 32;
parameter NB_INS = 32;

reg clk;
reg reset;
reg jump_address;
reg is_jump;
reg input_instruction;
reg control;// 1 READ - 0 WRITE
wire output_instruction;

initial
begin
    #0
    clk = 0;
    reset = 1;
    jump_address = 0;
    is_jump = 0;
    input_instruction = 0;
    control = 1;
    #10
    reset = 0;
    $finish;  
end 

always #0.5 clk = ~clk; 

IF
#(
    .NB_PC(NB_PC),
    .NB_INS(NB_INS)   
)
u_IF
(
    .i_clk(clk),
    .i_reset(reset),     
    .i_jump_address(jump_address),
    .i_is_jump(is_jump), 
    .i_instruction(input_instruction), 
    .i_control(control), // 1 READ - 0 WRITE
    .o_instruction(output_instruction) 
);

endmodule
