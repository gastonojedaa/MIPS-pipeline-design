`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2024 17:08:22
// Design Name: 
// Module Name: tb_ID_IDEX
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


module tb_ID_IDEX;

    parameter NB_DATA = 32;     
    parameter N_REG = 32;
    parameter NB_INS = 32;
    parameter NB_DATA_IN = 16;
    parameter NB_OP = 6;
    parameter NB_REG_ADDRESS = $clog2(N_REG);
    parameter NB_PC = 32;
   
    reg clk;
    reg reset;
    reg [NB_INS-1:0] instruction;
    reg [NB_PC-1:0] new_address;  
    wire [NB_DATA-1:0] rs_data;
    wire [NB_DATA-1:0] rt_data;
    wire [NB_OP-1:0] opcode;
    wire [NB_REG_ADDRESS-1:0] rs_address;
    wire [NB_REG_ADDRESS-1:0] rt_address;
    wire [NB_DATA_IN-1:0] inm_value;
    wire [NB_DATA-1:0] sigext;


    initial
    begin
        #0
        clk = 0;
        reset = 1;
        instruction = 0;    
        new_address = 0;      
        
        #10
        instruction = 32'b 000000_00001_00010_00011_00000_100000;
        new_address = 1;
        reset = 0;
        #1        
        instruction = 32'b 111111_11111_11111_11111_11111_111111;
        new_address = 2;
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
        .o_inm_value(inm_value),
        .o_sigext(sigext)
    );

    ID_EX
    #(
        .NB_DATA(NB_DATA),
        .NB_INS(NB_INS),
        .NB_DATA_OUT(NB_DATA),
        .NB_DATA_IN(NB_DATA_IN),
        .NB_OP(NB_OP),
        .NB_REG_ADDRESS(NB_REG_ADDRESS),
        .NB_PC(NB_PC)
    )
    u_ID_EX
    (
        .i_clk(clk),
        .i_reset(reset),
        .i_rs_data(rs_data),
        .i_rt_data(rt_data),
        .i_sigext(sigext),
        .i_opcode(opcode),
        .i_rs_address(rs_address),
        .i_rt_address(rt_address),
        .i_inm_value(inm_value),
        .i_new_address(new_address),
        .o_rs_data(),
        .o_rt_data(),
        .o_sigext(),
        .o_opcode(),
        .o_rs_address(),
        .o_rt_address(),
        .o_inm_value(),
        .o_new_address()  
    );
endmodule
