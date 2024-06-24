`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2024 18:45:25
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB
#(
    parameter NB_REG_ADDRESS = 5,
    parameter NB_DATA = 8 //FIXME: esto estaba en 32, revisar bits
)
(
input i_clk,
input i_reset,
input i_debug_unit_enable,
input [NB_REG_ADDRESS-1:0] i_write_address,//pa que es esto
input [NB_DATA:0] i_res, // TODO: Revisar si es necesario el +1 por el carry
input [NB_DATA-1:0] i_mem_data, 
output reg [NB_REG_ADDRESS-1:0] o_write_address,//pa que es esto
output reg [NB_DATA:0] o_res,
output reg [NB_DATA-1:0] o_mem_data
);

always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_write_address <= 0;
            o_res <= 0;
            o_mem_data <= 0;
        end
    else if(i_debug_unit_enable)
        begin
            o_write_address <= i_write_address;
            o_res <= i_res;
            o_mem_data <= i_mem_data;
        end
end
endmodule