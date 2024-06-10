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

//OPCODES
`define R_type = 6'b000000
//I_type
`define LB_OP = 6'b100000
`define LH_OP = 6'b100001
`define LW_OP = 6'b100011
`define LWU_OP = 6'b100111
`define LBU_OP = 6'b100100
`define LHU_OP = 6'b100101
`define SB_OP = 6'b101000
`define SH_OP = 6'b101001
`define SW_OP = 6'b101011
`define ADDI_OP = 6'b001000
`define ANDI_OP = 6'b001100
`define ORI_OP = 6'b001101
`define XORI_OP = 6'b001110
`define LUI_OP = 6'b001111
`define SLTI_OP = 6'b001010
`define BEQ_OP = 6'b000100
`define BNE_OP = 6'b000101

//J_TYPE
`define J_OP = 6'b000010
`define JAL_OP = 6'b000011

//HALT
`define HALT_OP = 6'b111111

//R_TYPE FUNCTIONS
`define SLL_FUNCT = 6'b000000
`define SRL_FUNCT = 6'b000010
`define SRA_FUNCT = 6'b000011
`define SLLV_FUNCT = 6'b000100
`define SRLV_FUNCT = 6'b000110
`define SRAV_FUNCT = 6'b000111
`define ADDU_FUNCT = 6'b100001
`define SUBU_FUNCT = 6'b100011
`define AND_FUNCT = 6'b100100
`define OR_FUNCT = 6'b100101
`define XOR_FUNCT = 6'b100110
`define NOR_FUNCT = 6'b100111
`define SLT_FUNCT = 6'b101010
`define JR_FUNCT = 6'b001000 
`define JALR_FUNCT = 6'b001001

module control_unit#(
    parameter NB_FUNCTION = 6,
    parameter NB_OP = 6
)
(
    input [NB_OP-1:0] i_opcode,
    input [NB_FUNCTION-1:0] i_function,     
    input i_pipeline_stalled, //viene de hazard_detection_unit para insertar nops 

    output o_PcSrc,
    output o_RegDst,
    output O_ALUSrc,
    output [1:0] o_ALUOp, //TODO: modificar esto porque son 4 bits (ver alu control)
    output o_MemRead,
    output o_MemWrite,
    output o_Branch,    
    output o_RegWrite,
    output o_MemtoReg    
);

reg PCSrc, RegDst, ALUSrc, MemRead, MemWrite, Branch, RegWrite, MemtoReg;
reg [1:0] ALUOp;

always @(*)
    if (i_pipeline_stalled == 1'b1)
        begin
            PcSrc = 1'b0; 
            RegDst = 1'b0;
            ALUSrc = 1'b0; 
            ALUOp = 2'b00;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            RegWrite = 1'b0;
            MemtoReg = 1'b0; 
            /* BHW = 2'b00;  //no se usa
            ExtSign = 1'b0;//no se usa */
        end
    else
        begin
            case(i_opcode)
                R_type: // SLL, SRL, SRA, SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT, JR, JALR
                begin        
                    case (i_function)            
                        JR_FUNCT:
                            begin
                                    PcSrc = 1'b0;  
                                    RegDst = 1'b0;
                                    ALUSrc = 1'b0; 
                                    ALUOp = 2'b00;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch =  1'b0;
                                    RegWrite = 1'b0;
                                    MemtoReg = 1'b0; 
                                    /* BHW = 2'b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        JALR_FUNCT:
                            begin
                                    PcSrc = 1'b0; 
                                    RegDst = 1'b1;
                                    ALUSrc = 1'b0;
                                    ALUOp = 2'b00;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 1'b0;
                                    RegWrite = 1'b1;
                                    MemtoReg = 1'b0; 
                                    /* BHW = 2'b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end
                        default: //revisar
                            begin
                                    PcSrc = 1'b0; 
                                    RegDst = 1'b1;
                                    ALUSrc = 1'b0; 
                                    ALUOp = 2'b10;
                                    MemRead = 1'b0;
                                    MemWrite = 1'b0;
                                    Branch = 1'b0;
                                    RegWrite = 1'b1;
                                    MemtoReg = 1'b0; 
                                    /* BHW = 2'b00;  //no se usa
                                    ExtSign = 1'b0;//no se usa */
                            end

                            //en teoria en el default de arriba entran todas las funciones de R_type que faltan
                            /* SLL_FUNCT, SRL_FUNCT, SRA_FUNCT:
                            begin
                                    PcSrc = 0; //pc = pc + 4
                                    RegDst = 0; //rd
                                    ALUSrc = 0; // -------------> revisar
                                    ALUOp = 2'b00; // -------------> revisar
                                    MemRead = 0; //no lee memoria
                                    MemWrite = 0; //no escribe memoria
                                    Branch = 0; //no salta
                                    RegWrite = 1; // -------------> revisar
                                    MemtoReg = 0; // el dato viene de la ALU 
                                    BHW = 2'b00;  //revisar
                                    ExtSign = 1'b0;//revisar 
                            end
                        SLLV_FUNCT, SRLV_FUNCT, SRAV_FUNCT, ADDU_FUNCT, SUBU_FUNCT, AND_FUNCT, OR_FUNCT, XOR_FUNCT, NOR_FUNCT, SLT_FUNCT:
                            begin
                                    PcSrc = 0;
                                    RegDst = 0;
                                    ALUSrc = 0; // -------------> revisar
                                    ALUOp = 2'b00; // -------------> revisar
                                    MemRead = 0;
                                    MemWrite = 0;
                                    Branch = 0;
                                    RegWrite = 1; // -------------> revisar
                                    MemtoReg = 0; 
                                    BHW = 2'b00;//no se usa
                                    ExtSign = 1'b0;//no se usa 
                            end */
                    endcase
                end
                //I_type -> LB, LH, LW, LWU, LBU, LHU, SB, SH, SW, ADDI, ANDI, ORI, XORI, LUI, SLTI, BEQ, BNE
                LB_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00;
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;
                    ExtSign = 1'b1; */
                end
                LH_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;  
                    /*BHW = 2'b01;
                    ExtSign = 1'b1; */
                end
                LW_OP:
                begin
                    PcSrc = 1'b0;    
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    /* BHW = 2'b10;
                    ExtSign = 1'b1; */
                end
                LWU_OP:
                begin
                    PcSrc = 1'b0;  
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    /* BHW = 2'b10;
                    ExtSign = 1'b0; */
                end
                LBU_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    /* BHW = 2'b00;
                    ExtSign = 1'b0; */
                end
                LHU_OP:
                begin
                    PcSrc = 1'b0;  
                    RegDst = 1'b0;
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    /* BHW = 2'b01;
                    ExtSign = 1'b0; */
                end
                SB_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0; //no se usa
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;  //no se usa
                    /* BHW = 2'b00;
                    ExtSign = 1'b0;//no se usa */
                end
                SH_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0; //no se usa
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;  //no se usa
                    /* BHW = 2'b01;
                    ExtSign = 1'b0;//no se usa */
                end
                SW_OP:
                begin
                    PcSrc = 1'b0;           
                    RegDst = 1'b0; //no se usa
                    ALUSrc = 1'b1; 
                    ALUOp = 2'b00; 
                    MemRead = 1'b0;
                    MemWrite = 1'b1;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;  //no se usa
                    /* BHW = 2'b10;
                    ExtSign = 1'b0;//no se usa        */
                end
                ADDI_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b1;   
                    ALUOp = 2'b00;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;      //no se usa
                    ExtSign = 1'b0;   //no se usa */
                end
                ANDI_OP:
                begin
                    PcSrc = 1'b0;
                    RegDst = 1'b0;  
                    ALUSrc = 1'b1;   
                    ALUOp = 2'b11;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                ORI_OP:
                begin
                    PcSrc = 1'b0;  
                    RegDst = 1'b0;  
                    ALUSrc = 1'b1;   
                    ALUOp = 2'b11;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                XORI_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b1;   
                    ALUOp = 2'b11;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                LUI_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b0;   
                    ALUOp = 2'b00;
                    MemRead = 1'b1;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                SLTI_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b1;   
                    ALUOp = 2'b11;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                BEQ_OP:
                begin
                    PcSrc = 1'b0;  
                    RegDst = 1'b0;   //no se usa
                    ALUSrc = 1'b0;   
                    ALUOp = 2'b01; 
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b1;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0; //no se usa
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                BNE_OP:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;   //no se usa
                    ALUSrc = 1'b0;   
                    ALUOp = 2'b01; 
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b1; //capaz hay que hacer un NeBranch 
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0; //no se usa
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end        
                //J_type -> J, JAL
                J_OP:
                begin
                    PcSrc = 1'b1;  
                    RegDst = 1'b0;   //no se usa
                    ALUSrc = 1'b0;   //no se usa
                    ALUOp = 2'b00;  //no se usa
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0; //no se usa
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                JAL_OP:
                begin
                    PcSrc = 1'b1;  
                    RegDst = 1'b0;   
                    ALUSrc = 1'b0;   //no se usa
                    ALUOp = 2'b00;  //no se usa
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b1;
                    MemtoReg = 1'b0; 
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end   
                HALT_OP: //revisar
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b0;   
                    ALUOp = 2'b00; 
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg =  1'b0;
                    /* BHW = 2'b00;//no se usa
                    ExtSign = 1'b0;//no se usa */
                end
                default:
                begin
                    PcSrc = 1'b0; 
                    RegDst = 1'b0;  
                    ALUSrc = 1'b0;   
                    ALUOp = 2'b11; 
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    Branch = 1'b0;
                    RegWrite = 1'b0;
                    MemtoReg = 1'b0;
                    /* BHW = 2'b00;//no se usa
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

endmodule

// TODO: cuando se toma un salto se deben eliminar las instrucciones que entraron en el pipeline despues del salto?





