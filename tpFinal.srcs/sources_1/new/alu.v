`timescale 1ns / 1ps

module alu
    #(
        parameter NB_DATA = 8,
        parameter NB_OPS = 5 //TODO: son 6 bits
    )
    (
        input [NB_DATA-1 : 0] i_data_a,
        input [NB_DATA-1 : 0] i_data_b,
        input [NB_OPS-1 : 0] i_ops,
        output [NB_DATA : 0] o_res,
        output o_zero
    );

    localparam SLL_OPCODE = 5'b00000;
    localparam SRL_OPCODE = 5'b00001;
    localparam SRA_OPCODE = 5'b00010;
    localparam SLLV_OPCODE = 5'b00011;
    localparam SRLV_OPCODE = 5'b00100;
    localparam SRAV_OPCODE = 5'b00101;
    localparam ADDU_OPCODE = 5'b00110;
    localparam SUBU_OPCODE = 5'b00111;
    localparam AND_OPCODE = 5'b01000;
    localparam OR_OPCODE = 5'b01001;
    localparam XOR_OPCODE = 5'b01010;
    localparam NOR_OPCODE = 5'b01011;
    localparam SLT_OPCODE = 5'b01100;
    
    reg [NB_DATA-1 : 0] res;
    reg carry;
    
    always @(*)
    begin
        case(i_ops)
            SLL_OPCODE:
                {carry,res} = i_data_b << i_data_a;
            SRL_OPCODE:
                {carry,res} = i_data_b >> i_data_a;
            SRA_OPCODE:
                {carry,res} = $signed(i_data_b) >>> i_data_a;
            SLLV_OPCODE:
                {carry,res} = i_data_b << i_data_a;
            SRLV_OPCODE:
                {carry,res} = i_data_b >> i_data_a;
            SRAV_OPCODE:
                {carry,res} = $signed(i_data_b) >>> i_data_a;
            ADDU_OPCODE:
                {carry,res} = i_data_a + i_data_b;
            SUBU_OPCODE:
                {carry,res} = $signed(i_data_a) - $signed(i_data_b);
            AND_OPCODE:
                {carry,res} = {1'b0 , i_data_a & i_data_b};
            OR_OPCODE:
                {carry,res} = {1'b0 , i_data_a | i_data_b};
            XOR_OPCODE:
                {carry,res} = {1'b0 , i_data_a ^ i_data_b};
            NOR_OPCODE:        
                {carry,res} = {1'b0 , ~(i_data_a | i_data_b)};
            SLT_OPCODE:
                {carry,res} = (i_data_a < i_data_b);
            default:
                {carry,res} = 'hFF;
        endcase
    end
    
    assign o_res = {carry,res};
    assign o_zero = ({carry,res} == 0);
endmodule