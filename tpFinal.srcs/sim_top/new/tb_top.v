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
    .NB_PC(32),
    .NB_INS(32),
    .N_REG(32),
    .NB_DATA(32),
    .NB_DATA_IN(16),
    .NB_DATA_OUT(32),
    .NB_OP(4),
    .NB_ADDR(32),
    .NB_FUNCTION(6),
    .NB_OPS(6),
    .NB_ALUCODE(4)
)
u_top
( 
    .i_clk(clk),
    .i_reset(reset)  
);
endmodule
