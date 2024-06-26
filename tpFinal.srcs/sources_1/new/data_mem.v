`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2024 17:47:39
// Design Name: 
// Module Name: data_mem
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


module data_mem
#(
    parameter NB_ADDR = 32,
    parameter NB_INS = 32     
)
(
    input   i_clk,    
    input   [NB_ADDR-1:0] i_data_mem_read_address,
    input   [NB_ADDR-1:0] i_data_mem_write_address,
    input   [NB_INS-1:0]  i_data_mem_data,
    input   i_data_mem_write_enable, // 0 NO WRITE - 1 WRITE
    output  [NB_INS-1:0] o_mem_data
);

localparam MEM_SIZE = (2**NB_ADDR) - 1;

integer i;
reg [NB_INS-1:0] mem_data[0:MEM_SIZE];

initial
begin      
    for (i = 0; i <= MEM_SIZE; i = i + 1) begin
        mem_data[i] = 0;
    end
end

always@(posedge i_clk)
begin
    if(i_data_mem_write_enable)
        mem_data[i_data_mem_write_address] <= i_data_mem_data;    
end

assign o_mem_data = mem_data[i_data_mem_read_address];

endmodule
