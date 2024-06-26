`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2024 18:57:46
// Design Name: 
// Module Name: WB
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


module WB
#(
    parameter NB_REG_ADDRESS = 5,
    parameter NB_DATA = 32,
    parameter NB_ADDR = 32    
)
(
    input i_clk,    
    input i_debug_unit_enable,
    input [NB_DATA:0] i_res,
    input [NB_DATA-1:0] i_mem_data,
    input [1:0] i_MemtoReg, 
    input [NB_ADDR-1:0] i_address_plus_4,
    input i_RegWrite_from_MEM_WB,
    output reg o_write_in_register_bank,
    output o_RegWrite_to_ID
);

reg [NB_DATA-1:0] i_return_addr;

assign o_RegWrite_to_ID = i_RegWrite_from_MEM_WB;

always@(posedge i_clk)
begin
    i_return_addr <= i_address_plus_4 + 4;    
    if(i_debug_unit_enable)
    begin       
        if(i_MemtoReg == 2'b00)
        begin        
            o_write_in_register_bank <= i_mem_data;
        end
        else if(i_MemtoReg == 2'b01)
        begin        
            o_write_in_register_bank <= i_res;
        end
        else 
        begin
            o_write_in_register_bank <= i_return_addr; //direccion de retorno
        end
    end
end        
endmodule
