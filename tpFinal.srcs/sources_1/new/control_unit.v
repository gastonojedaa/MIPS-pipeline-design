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
    parameter NB_OPS = 6,
    
    //ALUOP
    parameter   R_TYPE_ALUOP          =   4'b0000,
    parameter   LOAD_STORE_ADDI_ALUOP =   4'b0001,
    parameter   ANDI_ALUOP            =   4'b0010,
    parameter   ORI_ALUOP             =   4'b0011,
    parameter   XORI_ALUOP            =   4'b0100,
    parameter   LUI_ALUOP             =   4'b0101,
    parameter   SLTI_ALUOP            =   4'b0110,
    parameter   BEQ_ALUOP             =   4'b0111,
    parameter   BNE_ALUOP             =   4'b1000,

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

    //HALT
    parameter HALT_OP = 6'b111111,

    //R_TYPE FUNCTIONS
    parameter SLL_FUNCT = 6'b000000,
    parameter SRL_FUNCT = 6'b000010,
    parameter SRA_FUNCT = 6'b000011,
    parameter SLLV_FUNCT = 6'b000100,
    parameter SRLV_FUNCT = 6'b000110,
    parameter SRAV_FUNCT = 6'b000111,
    parameter ADDU_FUNCT = 6'b100001,
    parameter SUBU_FUNCT = 6'b100011,
    parameter AND_FUNCT = 6'b100100,
    parameter OR_FUNCT = 6'b100101,
    parameter XOR_FUNCT = 6'b100110,
    parameter NOR_FUNCT = 6'b100111,
    parameter SLT_FUNCT = 6'b101010,
    parameter JR_FUNCT = 6'b001000,
    parameter JALR_FUNCT = 6'b001001
)
(
    input [NB_OPS-1:0] i_opcode,
    input [NB_FUNCTION-1:0] i_function,     
    input i_pipeline_stalled, //viene de hazard_detection_unit para insertar nops 
    input i_zero_from_alu,
    
    output [1:0] o_PcSrc,
    output [1:0] o_RegDst,
    output [1:0] O_ALUSrc,
    output [3:0] o_ALUOp, 
    output o_MemRead,
    output o_MemWrite,
    output [1:0] o_Branch,    
    output o_RegWrite,
    output [1:0] o_MemtoReg,
    output [2:0] o_BHW,
    output o_IF_ID_flush,
    output o_EX_MEM_flush
);

reg MemRead, MemWrite, RegWrite, IF_ID_flush, EX_MEM_flush;
reg [1:0] ALUSrc;
reg [1:0] PcSrc;
/*
00 -> PC + 4
01 -> Jump
10 -> Jump Register
*/
reg [3:0] ALUOp;
reg [1:0] MemtoReg; 
reg [1:0] RegDst;
reg [1:0] Branch;
reg [2:0] BHW; 
/*
BHW
111 LW
000 LB
001 LBU
010 LH
011 LHU
*/

always @(*)
    if (i_pipeline_stalled == 1'b1)
        begin
            IF_ID_flush = 1'b0;
            EX_MEM_flush = 1'b0;
            PcSrc = 2'b00; 
            RegDst = 2'b00; 
            ALUSrc = 2'b00; 
            ALUOp = R_TYPE_ALUOP;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 2'b00;
            RegWrite = 1'b0;
            MemtoReg = 2'b00;
            BHW = 3'b111; 
            /* b00;  //no se usa
            ExtSign = 1'b0;//no se usa */
        end
    else
        begin
            IF_ID_flush = 1'b0;
            EX_MEM_flush = 1'b0;
            case(i_opcode)                
                R_type: // SLL, SRL, SRA, SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT, JR, JALR
                begin        
                    case (i_function)    
                        SLL_FUNCT, SRL_FUNCT, SRA_FUNCT:
                            begin
                                    PcSrc = 2'b00; 
                                    RegDst = 2'b01;
                                    ALUSrc = 2'b11; 
                                    ALUOp = R_TYPE_ALUOP;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 2'b00;
                                    RegWrite = 1'b1;
                                    MemtoReg = 2'b01;
                                    BHW = 3'b111; 
                                    /* b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        SLLV_FUNCT, SRLV_FUNCT, SRAV_FUNCT, ADDU_FUNCT, SUBU_FUNCT, AND_FUNCT, OR_FUNCT, XOR_FUNCT, NOR_FUNCT, SLT_FUNCT:
                            begin
                                    PcSrc = 2'b00; 
                                    RegDst = 2'b01;
                                    ALUSrc = 2'b00; 
                                    ALUOp = R_TYPE_ALUOP;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 2'b00;
                                    RegWrite = 1'b1;
                                    MemtoReg = 2'b01;
                                    BHW = 3'b111; 
                                    /* b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        JR_FUNCT:
                            begin
                                    PcSrc = 2'b11;
                                    RegDst = 2'b00; //no se usa
                                    ALUSrc = 2'b00; //no se usa
                                    ALUOp = R_TYPE_ALUOP;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch =  1'b0;
                                    RegWrite = 1'b0;
                                    MemtoReg = 2'b00;
                                    BHW = 3'b111; //no se usa
                                    /* b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        JALR_FUNCT:
                            begin
                                    PcSrc = 2'b11;
                                    RegDst = 2'b01;
                                    ALUSrc = 2'b00; //no se usa
                                    ALUOp = R_TYPE_ALUOP;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 2'b00;
                                    RegWrite = 1'b1;
                                    MemtoReg = 2'b10;
                                    BHW = 3'b111;  
                                    /* b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        default: 
                            begin
                                    PcSrc = 2'b00; 
                                    RegDst = 2'b00;
                                    ALUSrc = 2'b00;
                                    ALUOp = R_TYPE_ALUOP;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 2'b00;
                                    RegWrite = 1'b0;
                                    MemtoReg = 2'b00;
                                    BHW = 3'b111; 
                                    /* b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */                          
                            end                                     
                    endcase               
                end                            
                //I_type -> LB, LH, LW, LWU, LBU, LHU, SB, SH, SW, ADDI, ANDI, ORI, XORI, LUI, SLTI, BEQ, BNE
                LB_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP;
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b000;
                    //ExtSign = 1'b1; */
                end
                LH_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b010;
                    /*b01;
                    ExtSign = 1'b1; */
                end
                LW_OP:
                begin
                    PcSrc = 2'b00;    
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b111;
                    /* b10;
                    ExtSign = 1'b1; */
                end
                LWU_OP:
                begin
                    PcSrc = 2'b00;  
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b111;
                    /* b10;
                    ExtSign = 1'b0; */
                end
                LBU_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b001;
                    /* b00;
                    ExtSign = 1'b0; */
                end
                LHU_OP:
                begin
                    PcSrc = 2'b00;  
                    RegDst = 2'b00;
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b00;
                    BHW = 3'b011;
                    /* b01;
                    ExtSign = 1'b0; */
                end
                SB_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; //no se usa
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b001;
                    //ExtSign = 1'b0;//no se usa */
                end
                SH_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; //no se usa
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b010;
                    /* b01;
                    ExtSign = 1'b0;//no se usa */
                end
                SW_OP:
                begin
                    PcSrc = 2'b00;           
                    RegDst = 2'b00; //no se usa
                    ALUSrc = 2'b01; 
                    ALUOp = LOAD_STORE_ADDI_ALUOP; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b111;
                    /* b10;
                    ExtSign = 1'b0;//no se usa        */
                end
                ADDI_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = LOAD_STORE_ADDI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;      //no se usa
                    ExtSign = 1'b0;   //no se usa */
                end
                ANDI_OP:
                begin
                    PcSrc = 2'b00;
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = ANDI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                ORI_OP:
                begin
                    PcSrc = 2'b00;  
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = ORI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                XORI_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = XORI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                LUI_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = LUI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                SLTI_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00; 
                    ALUSrc = 2'b01;   
                    ALUOp = SLTI_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b01;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                BEQ_OP:
                begin
                    PcSrc = 2'b00;  
                    RegDst = 2'b00; //no se usa
                    ALUSrc = 2'b00;   
                    ALUOp = BEQ_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b01;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b111; //no se usa
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                BNE_OP:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;  //no se usa
                    ALUSrc = 2'b00;   
                    ALUOp = BNE_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b10; //capaz hay que hacer un NeBranch 
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b111; //no se usa
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end        
                //J_type -> J, JAL
                J_OP:
                begin
                    PcSrc = 2'b10;  
                    RegDst = 2'b00;  //no se usa
                    ALUSrc = 2'b00;   //no se usa
                    ALUOp = R_TYPE_ALUOP; //no se usa
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b111; //no se usa
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                JAL_OP:
                begin
                    PcSrc = 2'b10;   
                    RegDst = 2'b10;    
                    ALUSrc = 2'b00;   //no se usa
                    ALUOp = R_TYPE_ALUOP; //no se usa
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b1;
                    MemtoReg = 2'b10;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end   
                HALT_OP: //revisar
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;   
                    ALUSrc = 2'b00;   
                    ALUOp = R_TYPE_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg =  2'b00;
                    BHW = 3'b111;
                end
                default:
                begin
                    PcSrc = 2'b00; 
                    RegDst = 2'b00;  
                    ALUSrc = 2'b00;   
                    ALUOp = R_TYPE_ALUOP;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 2'b00;
                    RegWrite = 1'b0;
                    MemtoReg = 2'b00;
                    BHW = 3'b111;
                    /* b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
            endcase
        end

assign o_PcSrc = PcSrc; 
assign o_RegDst = RegDst;
assign O_ALUSrc = ALUSrc;
assign o_ALUOp = ALUOp; 
assign o_MemRead = MemRead; 
assign o_MemWrite = MemWrite; 
assign o_Branch = Branch;
assign o_RegWrite = RegWrite;
assign o_MemtoReg = MemtoReg;
assign o_IF_ID_flush = IF_ID_flush;
assign o_EX_MEM_flush = EX_MEM_flush;
assign o_BHW = BHW;

endmodule