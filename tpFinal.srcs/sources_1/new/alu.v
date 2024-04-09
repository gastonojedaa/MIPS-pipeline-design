`timescale 1ns / 1ps

module alu
    #(
        parameter NB_DATA = 8,
        parameter NB_OPS = 6 
    )
    (
        input [NB_DATA-1 : 0] i_data_a,
        input [NB_DATA-1 : 0] i_data_b,
        input [NB_OPS-1 : 0] i_ops,
        output [NB_DATA : 0] o_res,
        output o_zero
    ); 
        
    localparam SLL_OPCODE = 6'b000000;
    localparam SRL_OPCODE = 6'b000001;
    localparam SRA_OPCODE = 6'b000010;
    localparam SLLV_OPCODE = 6'b000011;
    localparam SRLV_OPCODE = 6'b000100;
    localparam SRAV_OPCODE = 6'b000101;
    localparam ADDU_OPCODE = 6'b000110;
    localparam SUBU_OPCODE = 6'b000111;
    localparam AND_OPCODE = 6'b001000;
    localparam OR_OPCODE = 6'b001001;
    localparam XOR_OPCODE = 6'b001010;
    localparam NOR_OPCODE = 6'b001011;
    localparam SLT_OPCODE = 6'b001100;   

    
    reg [NB_DATA-1 : 0] res;
    reg carry;
    
    always @(*)
    begin
        case(i_ops)
            SLL_OPCODE:
                {carry,res} = i_data_a << i_data_b;
            SRL_OPCODE:
                {carry,res} = i_data_a >> i_data_b;
            SRA_OPCODE:
                {carry,res} = $signed(i_data_a) >>> i_data_b;
            SLLV_OPCODE:
                {carry,res} = i_data_a << i_data_b;
            SRLV_OPCODE:
                {carry,res} = i_data_a >> i_data_b;
            SRAV_OPCODE:
                {carry,res} = $signed(i_data_a) >>> i_data_b;
            ADDU_OPCODE:
                {carry,res} = i_data_a + i_data_b;
            SUBU_OPCODE:
                {carry,res} = $signed(i_data_a) - $signed(i_data_b);
            AND_OPCODE:
                {carry,res} = {1'b0, i_data_a & i_data_b};
            OR_OPCODE:
                {carry,res} = {1'b0, i_data_a | i_data_b};
            XOR_OPCODE:
                {carry,res} = {1'b0, i_data_a ^ i_data_b};
            NOR_OPCODE:        
                {carry,res} = {1'b0, ~(i_data_a | i_data_b)};
            SLT_OPCODE:
                {carry,res} = (i_data_a < i_data_b); 
            default:
                {carry,res} = 'hFF;
        endcase
    end
    
    assign o_res = {carry,res};
    assign o_zero = ({carry,res} == 0);
endmodule

