`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2024 18:13:01
// Design Name: 
// Module Name: shortcircuit_unit
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

module shortcircuit_unit
#(
    parameter N_REG = 32,
    parameter NB_REG_ADDRESS = $clog2(N_REG)
)
(
    //source registers from ID/EX
    input [NB_REG_ADDRESS-1:0] i_rs_address_id_ex,
    input [NB_REG_ADDRESS-1:0] i_rt_address_id_ex,  
    //destination registers from EX/MEM
    input [NB_REG_ADDRESS-1:0] i_rt_address_ex_mem,
    //destination registers from MEM/WB
    input [NB_REG_ADDRESS-1:0] i_rt_address_mem_wb,     
    
    output reg [1:0] o_forward_a,
    output reg [1:0] o_forward_b
);



always@(*)
begin
    if(i_rs_address_id_ex == i_rt_address_ex_mem)
        o_forward_a = 2'b10;
    else if(i_rs_address_id_ex == i_rt_address_mem_wb)
        o_forward_a = 2'b01;
    else
        o_forward_a = 2'b00;

    if(i_rt_address_id_ex == i_rt_address_ex_mem)
        o_forward_b = 2'b10;
    else if(i_rt_address_id_ex == i_rt_address_mem_wb)
        o_forward_b = 2'b01;
    else
        o_forward_b = 2'b00;
end
endmodule
