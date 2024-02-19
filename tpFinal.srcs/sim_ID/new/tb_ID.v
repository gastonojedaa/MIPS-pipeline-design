`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2024 17:44:49
// Design Name: 
// Module Name: tb_ID
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


module tb_ID;
    parameter NB_DATA = 32;     
    parameter N_REG = 32;
    parameter NB_INS = 32;
    parameter NB_DATA_IN = 16;
    parameter NB_OP = 6;
    parameter NB_REG_ADDRESS = $clog2(N_REG);
   
    reg clk;
    reg reset;
    reg [NB_INS-1:0]instruction;
    wire [NB_DATA-1:0]rs_data;
    wire [NB_DATA-1:0]rt_data;
    wire [NB_OP-1:0]opcode;
    wire [NB_REG_ADDRESS-1:0]rs_address;
    wire [NB_REG_ADDRESS-1:0]rt_address;
    wire [NB_DATA_IN-1:0]inm_value;
    
    initial
    begin
        #0
        clk = 0;
        reset = 1;
        instruction = 32'b 000000_00001_00010_00011_00000_100000;  
        
        #10
        reset = 0;
        $finish;
    end

    always #0.5 clk = ~clk;

    ID
    #(
        .NB_DATA(NB_DATA),
        .N_REG(N_REG),
        .NB_INS(NB_INS),
        .NB_DATA_IN(NB_DATA_IN),
        .NB_OP(NB_OP),
        .NB_REG_ADDRESS(NB_REG_ADDRESS)
    )
    u_ID
    (
        .i_clk(clk),
        .i_reset(reset),
        .i_instruction(instruction),
        .o_rs_data(rs_data),
        .o_rt_data(rt_data),
        .o_opcode(opcode),
        .o_rs_address(rs_address),
        .o_rt_address(rt_address),
        .o_inm_value(inm_value)
    );

endmodule