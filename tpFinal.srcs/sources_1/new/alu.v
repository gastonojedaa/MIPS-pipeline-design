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
        output [NB_DATA-1 : 0] o_res,
        output o_zero
    ); 
    
    reg signed [NB_DATA-1 : 0] res;
    
    always @(*)
    begin
        case(i_alucode)
            SUB_ALUCODE:
                res = i_data_a - i_data_b;
            SLL_ALUCODE:
                res = i_data_b << i_data_a[10:6];
            SRL_ALUCODE:
                res = i_data_a >> i_data_b[10:6];
            SRA_ALUCODE:
                res = $signed(i_data_a) >>> i_data_b[10:6];
            SLLV_ALUCODE:
                res = i_data_b << i_data_a[4:0];
            SRLV_ALUCODE:
                res = i_data_b >> i_data_a[4:0];
            SRAV_ALUCODE:
                res = $signed(i_data_b) >>> i_data_a[4:0];
            ADD_ALUCODE:
                res = i_data_a + i_data_b;
            AND_ALUCODE:
                res = i_data_a & i_data_b;
            OR_ALUCODE:
                res = i_data_a | i_data_b;
            XOR_ALUCODE:
                res = i_data_a ^ i_data_b;
            NOR_ALUCODE:        
                res = ~(i_data_a | i_data_b);
            SLT_ALUCODE:
                res = (i_data_a < i_data_b); 
            LUI_ALUCODE:
                res = i_data_b << 16;
            BNE_ALUCODE:
                res = (i_data_a != i_data_b);                      
            default:
                res = 'hAAAAAAAA;
        endcase
    end
    
    assign o_res = res;
    assign o_zero = (res == 32'b000000000000000000000000000000000);
endmodule

