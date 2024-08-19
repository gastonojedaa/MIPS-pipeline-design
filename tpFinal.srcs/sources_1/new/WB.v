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
    input i_debug_unit_enable,
    input [NB_DATA-1:0] i_res,
    input [NB_DATA-1:0] i_mem_data,
    input [NB_ADDR-1:0] i_address_plus_4,
    input [1:0] i_MemtoReg, 
    input i_RegWrite_from_MEM_WB,
    output [NB_DATA-1:0] o_write_in_register_bank,
    output o_RegWrite_to_ID
);
reg [NB_DATA-1:0] write_in_register_bank;

always@(*)
begin 
    if(i_debug_unit_enable)
    begin       
        if(i_MemtoReg == 2'b00)
        begin        
            write_in_register_bank = i_mem_data;
        end
        else if(i_MemtoReg == 2'b01)
        begin        
            write_in_register_bank = i_res;
        end
        else 
        begin
            write_in_register_bank = i_address_plus_4 + 1; // return address
        end
    end
    else
        write_in_register_bank = i_res;
    
end        

assign o_RegWrite_to_ID = i_RegWrite_from_MEM_WB;
assign o_write_in_register_bank = write_in_register_bank;

endmodule
