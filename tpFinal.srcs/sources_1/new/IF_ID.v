`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2024 16:06:56
// Design Name: 
// Module Name: IF_ID
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


module IF_ID
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32  
)
( 
    input   i_clk,
    input   i_reset, 
    input i_debug_unit_enable,
    input   [NB_INS-1:0] i_instruction,
    input   [NB_PC-1:0] i_address_plus_4,
    output reg  [NB_INS-1:0] o_instruction,
    output reg  [NB_PC-1:0] o_address_plus_4,

    //signal from hazard detection unit
    input IFIDwrite        
);

always@(posedge i_clk)
begin
    if(i_reset)
        begin
            o_instruction <= 'hFFFFFFFF;
            o_address_plus_4 <= 0; 
        end 
    else if(i_debug_unit_enable)
        begin
            //handle the stall signal
            if(IFIDwrite)
                begin
                    o_instruction <= o_instruction;
                    o_address_plus_4 <= o_address_plus_4;
                end
            else
                begin
                    o_instruction <= i_instruction;
                    o_address_plus_4 <= i_address_plus_4;
                end            
        end   
end

endmodule
