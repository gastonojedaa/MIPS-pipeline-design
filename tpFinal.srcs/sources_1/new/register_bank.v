`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2024 17:35:30
// Design Name: 
// Module Name: register_bank
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

module register_bank
#(
    parameter NB_DATA = 32,
    parameter N_REG = 32,
    parameter NB_REG_ADDRESS = $clog2(N_REG)    
)
(
    input   i_clk,
    input   i_reset,
    input   [NB_DATA-1:0] i_data,
    input   [NB_REG_ADDRESS-1:0] rs_address,
    input   [NB_REG_ADDRESS-1:0] rt_address,
    input   [NB_REG_ADDRESS-1:0] rd_address,
    input   [NB_REG_ADDRESS-1:0] rw_address,
    input   i_write_enable,   
    output  [NB_DATA-1:0] rs_data,
    output  [NB_DATA-1:0] rt_data    
);

integer i;
reg [NB_DATA-1:0] reg_bank[0:N_REG];

initial
begin
    for (i = 0; i <= N_REG; i = i + 1) begin
        reg_bank[i] = i*2;
    end
end

always@(posedge i_clk)
begin
    if(i_write_enable)
        reg_bank[rw_address] <= i_data;    
end

assign rs_data = reg_bank[rs_address];
assign rt_data = reg_bank[rt_address];
endmodule
