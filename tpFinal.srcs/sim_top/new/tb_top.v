`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:13:01
// Design Name: 
// Module Name: tb_top
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


module tb_top;

parameter NB_PC = 32;
parameter NB_INS = 32;  
parameter N_REG = 32;
parameter NB_DATA = 32;
parameter NB_DATA_IN = 16;
parameter NB_DATA_OUT = 32;
parameter NB_OP = 6;
parameter NB_ADDR = 32;

reg clk;
reg reset;

always #0.5 clk = ~clk;

initial
begin
    clk = 0;
    reset = 1;

    #10
    reset = 0;
end

top
#(
    .NB_PC(NB_PC),
    .NB_INS(NB_INS),
    .N_REG(N_REG),
    .NB_DATA(NB_DATA),
    .NB_DATA_IN(NB_DATA_IN),
    .NB_DATA_OUT(NB_DATA_OUT),
    .NB_OP(NB_OP),
    .NB_ADDR(NB_ADDR)
)
u_top
( 
    .i_clk(clk),
    .i_reset(reset)  
);
endmodule
