`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2024 17:46:43
// Design Name: 
// Module Name: MEM
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


module MEM
#(
    parameter NB_DATA = 8,
    parameter NB_REG_ADDRESS = 5,
    parameter NB_ADDR = 32,
    parameter NB_INS = 32  
)
(
    input i_clk,
    input i_reset,
    input i_debug_unit_enable,
    input [NB_DATA:0] i_res,
    input i_zero,
    input [NB_DATA:0] i_rt_data,
    input [NB_DATA-1:0] i_jump_address,
    input [NB_REG_ADDRESS-1:0] i_write_address,
    output reg [NB_DATA:0] o_res,
    output reg [NB_DATA-1:0] o_mem_data,
    output reg [NB_REG_ADDRESS-1:0] o_write_address
);

always@(posedge i_clk)
begin 
    if(i_reset)
        begin
            o_res <= 0;
            o_mem_data <= 0;
            o_write_address <= 0;
        end
    else if(i_debug_unit_enable)
        begin
            o_res <= i_res;
            o_mem_data <= i_rt_data;
            o_write_address <= i_write_address;
        end
end

always@(*)
begin //FIXME: qué
    /* if(signal_control_mem_write) //se escribe en la memoria
        begin
            //se escribe en la memoria
        end
    else if(signal_control_mem_read) //se lee de la memoria
        begin
            //se lee de la memoria
        end
    else
        begin
            //no se hace nada
        end    */    
end


data_mem
#(
    NB_ADDR,
    NB_INS
)
u_data_mem
(
    .i_clk(i_clk),
    .i_data_mem_read_address(i_res),
    .i_data_mem_write_address(i_res),
    .i_data_mem_data(i_rt_data),
    .i_data_mem_write_enable(),
    .o_mem_data(o_mem_data)
);
endmodule
