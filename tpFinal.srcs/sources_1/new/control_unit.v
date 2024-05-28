`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2024 08:58:36
// Design Name: 
// Module Name: control_unit
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

module control_unit#(
    parameter NB_FUNCTION = 6,
    parameter NB_OP = 6

//OPCODES
    parameter R_type = 6'b000000,
    //I_type
    parameter LB_OP = 6'b100000,
    parameter LH_OP = 6'b100001,
    parameter LW_OP = 6'b100011,
    parameter LWU_OP = 6'b100111,
    parameter LBU_OP = 6'b100100,
    parameter LHU_OP = 6'b100101,
    parameter SB_OP = 6'b101000,
    parameter SH_OP = 6'b101001,
    parameter SW_OP = 6'b101011,
    parameter ADDI_OP = 6'b001000,
    parameter ANDI_OP = 6'b001100,
    parameter ORI_OP = 6'b001101,
    parameter XORI_OP = 6'b001110,
    parameter LUI_OP = 6'b001111,
    parameter SLTI_OP = 6'b001010,
    parameter BEQ_OP = 6'b000100,
    parameter BNE_OP = 6'b000101,

    //J_TYPE
    parameter J_OP = 6'b000010,
    parameter JAL_OP = 6'b000011,
    
    //R_TYPE FUNCTIONS
    parameter SLL_FUNCT = 6'b000000;
    parameter SRL_FUNCT = 6'b000010;
    parameter SRA_FUNCT = 6'b000011;
    parameter SLLV_FUNCT = 6'b000100;
    parameter SRLV_FUNCT = 6'b000110;
    parameter SRAV_FUNCT = 6'b000111;
    parameter ADDU_FUNCT = 6'b100001;
    parameter SUBU_FUNCT = 6'b100011;
    parameter AND_FUNCT = 6'b100100;
    parameter OR_FUNCT = 6'b100101;
    parameter XOR_FUNCT = 6'b100110;
    parameter NOR_FUNCT = 6'b100111;
    parameter SLT_FUNCT = 6'b101010;
    parameter JR_FUNCT = 6'b001000, 
    parameter JALR_FUNCT = 6'b001001,
)
(
    input [NB_OP-1:0] i_opcode,
    output [NB_FUNCTION-1:0] i_function,      

    output o_PcSrc,
    output o_RegDst,
    output o_ALUSrc,
    output [1:0] o_ALUOp,
    output o_MemRead,
    output o_MemWrite,
    output o_Branch,    
    output o_RegWrite,
    output o_MemtoReg    
);
always @(*)
begin
    case(i_opcode)
    R_type: // SLL, SRL, SRA, SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT, JR, JALR
    begin
        
        case (i_function)
            SLL_FUNCT, SRL_FUNCT, SRA_FUNCT:
                begin
                        o_PcSrc = 0; //pc = pc + 4
                        o_RegDst = 0; //rd
                        o_ALUOp = ; //revisar
                        o_ALUSrc = 0; //reg b 
                        o_MemRead = 0; //no lee memoria
                        o_MemWrite = 0; //no escribe memoria
                        o_Branch = 0; //no salta
                        o_RegWrite = 1; //escribe en registro
                        o_MemtoReg = 0; // el dato viene de la ALU 
                        /* o_BHW = 2'b00;  //revisar
                        o_ExtSign = 1'b0;//revisar */
                end
            SLLV_FUNCT, SRLV_FUNCT, SRAV_FUNCT, ADDU_FUNCT, SUBU_FUNCT, AND_FUNCT, OR_FUNCT, XOR_FUNCT, NOR_FUNCT, SLT_FUNCT:
                begin
                        o_PcSrc = 0;
                        o_RegDst = 0;
                        o_ALUOp = ; //revisar
                        o_ALUSrc = 0; 
                        o_MemRead = 0;
                        o_MemWrite = 0;
                        o_Branch = 0;
                        o_RegWrite = 1;
                        o_MemtoReg = 0; 
                        /* o_BHW = 2'b00;//no se usa
                        o_ExtSign = 1'b0;//no se usa */
                end
            JR_FUNCT:
                begin
                        o_PcSrc = 1'b0;  
                        o_RegDst = 1'b0;
                        o_ALUSrc = 1'b0; 
                        o_ALUOp = 2'b00;
                        o_MemRead = 1'b0;
                        o_MemWrite = 1'b0;
                        o_Branch =  1'b0;
                        o_RegWrite = 1'b0;
                        o_MemtoReg = 1'b0; 
                        /* o_BHW = 2'b00;  //no se usa
                        o_ExtSign = 1'b0;//no se usa */
                end
            JALR_FUNCT:
                begin
                        o_PcSrc = 1'b0; 
                        o_RegDst = 1'b1;
                        o_ALUSrc = 1'b0;
                        o_ALUOp = 2'b00;
                        o_MemRead = 1'b0;
                        o_MemWrite = 1'b0;
                        o_Branch = 1'b0;
                        o_RegWrite = 1'b1;
                        o_MemtoReg = 1'b0; 
                        /* o_BHW = 2'b00;  //no se usa
                        o_ExtSign = 1'b0;//no se usa */
                end
            default: //revisar
                begin
                        o_PcSrc = 1'b0; 
                        o_RegDst = 1'b1;
                        o_ALUSrc = 2'b10; 
                        o_MemRead = 1'b0;
                        o_MemWrite = 1'b0;
                        o_Branch = 1'b0;
                        o_RegWrite = 1'b1;
                        o_MemtoReg = 1'b1; 
                        /* o_BHW = 2'b00;  //no se usa
                        o_ExtSign = 1'b0;//no se usa */
                end
        endcase
    end
    //I_type -> LB, LH, LW, LWU, LBU, LHU, SB, SH, SW, ADDI, ANDI, ORI, XORI, LUI, SLTI, BEQ, BNE
    LB_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00;
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;
        o_ExtSign = 1'b1; */
    end
    LH_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;  
       /*  o_BHW = 2'b01;
        o_ExtSign = 1'b1; */
    end
    LW_OP:
    begin
        o_PcSrc = 1'b0;    
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;
        /* o_BHW = 2'b10;
        o_ExtSign = 1'b1; */
    end
    LWU_OP:
    begin
        o_PcSrc = 1'b0;  
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;
        /* o_BHW = 2'b10;
        o_ExtSign = 1'b0; */
    end
    LBU_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;
        /* o_BHW = 2'b00;
        o_ExtSign = 1'b0; */
    end
    LHU_OP:
    begin
        o_PcSrc = 1'b0;  
        o_RegDst = 1'b0;
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;
        /* o_BHW = 2'b01;
        o_ExtSign = 1'b0; */
    end
    SB_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0; //no se usa
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b1;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0;  //no se usa
        /* o_BHW = 2'b00;
        o_ExtSign = 1'b0;//no se usa */
    end
    SH_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0; //no se usa
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b1;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0;  //no se usa
        /* o_BHW = 2'b01;
        o_ExtSign = 1'b0;//no se usa */
    end
    SW_OP:
    begin
        o_PcSrc = 1'b0;           
        o_RegDst = 1'b0; //no se usa
        o_ALUSrc = 1'b1; 
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b1;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0;  //no se usa
        /* o_BHW = 2'b10;
        o_ExtSign = 1'b0;//no se usa        */
    end
    ADDI_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b1;   
        o_ALUOp = 2'b00;
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
       /*  o_BHW = 2'b00;      //no se usa
        o_ExtSign = 1'b0;   //no se usa */
    end
    ANDI_OP:
    begin
        o_PcSrc = 1'b0;
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b1;   
        o_ALUOp = 2'b11;
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    ORI_OP:
    begin
        o_PcSrc = 1'b0;  
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b1;   
        o_ALUOp = 2'b11;
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    XORI_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b1;   
        o_ALUOp = 2'b11;
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    LUI_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b0;   
        o_ALUOp = 2'b00;
        o_MemRead = 1'b1;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b1;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    SLTI_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b1;   
        o_ALUOp = 2'b11;
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    BEQ_OP:
    begin
        o_PcSrc = 1'b0;  
        o_RegDst = 1'b0;   //no se usa
        o_ALUSrc = 1'b0;   
        o_ALUOp = 2'b01; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b1;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0; //no se usa
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    BNE_OP:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;   //no se usa
        o_ALUSrc = 1'b0;   
        o_ALUOp = 2'b01; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b1; //capaz hay que hacer un NeBranch 
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0; //no se usa
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end


    //J_type -> J, JAL
    J_OP:
    begin
        o_PcSrc = 1'b1;  
        o_RegDst = 1'b0;   //no se usa
        o_ALUSrc = 1'b0;   //no se usa
        o_ALUOp = 2'b00;  //no se usa
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0; //no se usa
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    JAL_OP:
    begin
        o_PcSrc = 1'b1;  
        o_RegDst = 1'b0;   
        o_ALUSrc = 1'b0;   //no se usa
        o_ALUOp = 2'b00;  //no se usa
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b1;
        o_MemtoReg = 1'b0; 
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end   
    HALT_OP: //revisar
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b0;   
        o_ALUOp = 2'b00; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg =  1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    default:
    begin
        o_PcSrc = 1'b0; 
        o_RegDst = 1'b0;  
        o_ALUSrc = 1'b0;   
        o_ALUOp = 2'b11; 
        o_MemRead = 1'b0;
        o_MemWrite = 1'b0;
        o_Branch = 1'b0;
        o_RegWrite = 1'b0;
        o_MemtoReg = 1'b0;
        /* o_BHW = 2'b00;//no se usa
        o_ExtSign = 1'b0;//no se usa */
    end
    endcase
end

endmodule



//señaes de control
//IF
////PCSrc
//EX
////RegDst
////ALUSrc
////ALUOp
//MEM
////MemRead
////MemWrite
////Branch
//WB
////RegWrite
////MemtoReg


