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

module tb_IF_IFID;

parameter NB_PC = 8;
parameter NB_INS = 32;

reg clk;
reg reset;
reg [NB_PC-1:0]jump_address;
reg [NB_PC-1:0]write_address;
reg is_jump;
reg [NB_INS-1:0]input_instruction;
reg write_enable;// 1 READ - 0 WRITE

wire [NB_INS-1:0]output_instruction;
wire [NB_PC-1:0] new_address;

initial
begin
    #0
    clk = 0;
    reset = 1;
    jump_address = 0;
    write_address = 0;
    is_jump = 0;
    input_instruction = 0;
    write_enable = 0;
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
    .i_write_address(write_address),
    .i_is_jump(is_jump), 
    .i_instruction(input_instruction), 
    .i_write_enable(write_enable), // 1 READ - 0 WRITE
    .o_instruction(output_instruction), 
    .o_new_address(new_address)
);

IF_ID
#(
    .NB_PC(NB_PC),
    .NB_INS(NB_INS)   
)
u_IF_ID
(
    .i_clk(clk),
    .i_reset(reset),  
    .i_instruction(output_instruction),  
    .o_instruction(),
    .i_new_address(new_address), 
    .o_new_address() 
);

endmodule

