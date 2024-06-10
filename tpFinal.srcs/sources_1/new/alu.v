`timescale 1ns / 1ps

module alu
    #(

        parameter  SLL_ALUCODE =  4'b0000,
        parameter  SRL_ALUCODE =  4'b0001,
        parameter  SRA_ALUCODE =  4'b0010,
        parameter  SLLV_ALUCODE = 4'b1010,
        parameter  SRLV_ALUCODE = 4'b1011,
        parameter  SRAV_ALUCODE = 4'b1100,
        parameter  ADD_ALUCODE =  4'b0011,
        parameter  SUB_ALUCODE =  4'b0100,
        parameter  AND_ALUCODE =  4'b0101,
        parameter  OR_ALUCODE  =  4'b0110,
        parameter  XOR_ALUCODE =  4'b0111,
        parameter  NOR_ALUCODE =  4'b1000,
        parameter  SLT_ALUCODE =  4'b1001,
        parameter  LUI_ALUCODE =  4'b1101,
        parameter  BNE_ALUCODE =  4'b1110,

        parameter NB_DATA = 32,
        parameter NB_ALUCODE = 4 
    )
    (
        input [NB_DATA-1 : 0] i_data_a,
        input [NB_DATA-1 : 0] i_data_b,
        input [NB_ALUCODE-1 : 0] i_alucode,
        output [NB_DATA : 0] o_res, // carry + result
        output o_zero
    ); 
    
    reg [NB_DATA-1 : 0] res;
    reg carry;
    
    always @(*)
    begin
        case(i_alucode)
            SLL_ALUCODE:
                {carry,res} = i_data_a << i_data_b;
            SRL_ALUCODE:
                {carry,res} = i_data_a >> i_data_b;
            SRA_ALUCODE:
                {carry,res} = $signed(i_data_a) >>> i_data_b;
            SLLV_ALUCODE:
                {carry,res} = i_data_a << i_data_b;
            SRLV_ALUCODE:
                {carry,res} = i_data_a >> i_data_b;
            SRAV_ALUCODE:
                {carry,res} = $signed(i_data_a) >>> i_data_b;
            ADD_ALUCODE:
                {carry,res} = i_data_a + i_data_b;
            SUB_ALUCODE:
                {carry,res} = $signed(i_data_a) - $signed(i_data_b);
            AND_ALUCODE:
                {carry,res} = {1'b0, i_data_a & i_data_b};
            OR_ALUCODE:
                {carry,res} = {1'b0, i_data_a | i_data_b};
            XOR_ALUCODE:
                {carry,res} = {1'b0, i_data_a ^ i_data_b};
            NOR_ALUCODE:        
                {carry,res} = {1'b0, ~(i_data_a | i_data_b)};
            SLT_ALUCODE:
                {carry,res} = (i_data_a < i_data_b); 
            LUI_ALUCODE:
                {carry,res} = i_data_b << 16;
            BNE_ALUCODE:
                {carry,res} = (i_data_a != i_data_b);
            //JR_OPCODE:
            //    {carry,res} = i_data_a; //TODO: check if this is correct, JALR too
            //JALR_OPCODE:
            //    {carry,res} = i_data_a;            
            default:
                {carry,res} = 'hFF;
        endcase
    end
    
    assign o_res = {carry,res};
    assign o_zero = ({carry,res} == 0);
endmodule

