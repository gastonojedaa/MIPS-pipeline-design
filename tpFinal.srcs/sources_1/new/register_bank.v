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
    parameter NB_REG_ADDRESS = 5    
)
(
    input   i_clk,
    input   i_reset,
    input   [NB_DATA-1:0] i_data_to_write,
    input i_debug_unit_enable,
    input   [NB_REG_ADDRESS-1:0] rs_address,
    input   [NB_REG_ADDRESS-1:0] rt_address,
    input   [NB_REG_ADDRESS-1:0] rw_address,
    input   i_RegWrite,   
    input   [NB_REG_ADDRESS-1:0] i_reg_address,
    output [NB_DATA-1:0] o_rs_data,
    output [NB_DATA-1:0] o_rt_data,
    output  [NB_DATA-1:0] o_reg_data
);

integer i;
reg [NB_DATA-1:0] reg_bank[0:N_REG-1];

always@(posedge i_clk)
begin
    if(i_reset)
    begin
        for (i = 0; i <= N_REG-1; i = i + 1) begin
            //reg_bank[i] = (i*2) << 16;
            //reg_bank[i] = (i*2);
            reg_bank[i] = 0;
        end
    end
    else if(i_debug_unit_enable && i_RegWrite)
        reg_bank[rw_address] <= i_data_to_write;
end

// always @(negedge i_clk)
// begin
//     if (i_reset)
//     begin
//         o_rs_data <= 0;
//         o_rt_data <= 0;
//     end
//     else if(i_debug_unit_enable)
//     begin
//         o_rs_data <= reg_bank[rs_address];
//         o_rt_data <= reg_bank[rt_address];
//     end
// end

assign o_rs_data = reg_bank[rs_address];
assign o_rt_data = reg_bank[rt_address];
assign o_reg_data = reg_bank[i_reg_address];
endmodule
