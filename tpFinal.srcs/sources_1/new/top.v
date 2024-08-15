`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2023 20:21:51
// Design Name: 
// Module Name: top
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


module top
#(
    parameter NB_PC = 32,
    parameter NB_INS = 32,  
    parameter N_REG = 32,
    parameter NB_DATA = 32,
    parameter NB_DATA_IN = 16,
    parameter NB_DATA_OUT = 32,
    parameter NB_OP = 4,
    parameter NB_ADDR = 32,
    parameter NB_FUNCTION = 6,
    parameter NB_OPS = 6,
    parameter NB_ALUCODE = 4,
    parameter NB_STATE = 10,
    parameter CLK_FREQ = 45000000
)
( 
    input i_clk,
    input i_reset,
    input i_toggle_led,
    input i_rx_data,
    output o_tx_data,
    output o_led_1,
    output reg o_led_2,
    output [NB_STATE-1:0] o_state
);

localparam NB_REG_ADDRESS = $clog2(N_REG);

wire debug_unit_enable;
wire [NB_PC-1:0] jump_address_to_if;
wire [1:0] PcSrc;
wire PCwrite_to_IF;
wire execute_branch_to_IF;
wire [NB_INS-1:0] if_instruction_if_id;
wire [NB_PC-1:0] if_address_plus_4_if_id;
wire [NB_PC-1:0] pc_to_debug_unit;
wire halted_to_if_id;
wire [NB_INS-1:0] instruction_to_if;
wire [NB_PC-1:0] instruction_mem_write_address_to_if;

wire system_clk;

clk_wiz_0
#() 
u_clk_wiz_0
(
    .clk_in1(i_clk),
    .reset(1'b0), 
    .clk_out1(system_clk),     
    .locked()
);

IF
#(
    .NB_PC(NB_PC),
    .NB_INS(NB_INS)
)
u_IF
(
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_PcSrc(PcSrc), 
    .i_write_enable(write_enable_to_if),
    .i_jump_address(jump_address_to_if),
    .i_write_address(instruction_mem_write_address_to_if),
    .i_instruction(instruction_to_if),
    .i_PCwrite(PCwrite_to_IF),
    .i_execute_branch(execute_branch_to_IF),
    .o_instruction(if_instruction_if_id),  
    .o_address_plus_4(if_address_plus_4_if_id),
    .o_is_halted(halted_to_if_id),
    .o_pc(pc_to_debug_unit)
);

wire IFIDwrite;
wire [NB_INS-1:0] if_id_instruction_id;
wire [NB_PC-1:0] if_id_address_plus_4_id;
wire IF_ID_flush;
wire halted_to_id_ex;

IF_ID
#(
    .NB_PC(NB_PC),
    .NB_INS(NB_INS)
)
u_if_id
( 
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_instruction(if_instruction_if_id), 
    .i_address_plus_4(if_address_plus_4_if_id),
    .i_IFIDwrite(IFIDwrite),
    .i_IF_ID_flush(execute_branch_to_IF || (PcSrc!=2'b00)),
    .i_is_halted(halted_to_if_id),
    .o_instruction(if_id_instruction_id), 
    .o_address_plus_4(if_id_address_plus_4_id),
    .o_is_halted(halted_to_id_ex)
);


wire [NB_DATA-1:0] write_address_to_register_bank;

//to ID
wire [NB_REG_ADDRESS-1:0] write_address_to_id;
wire pipeline_stalled_to_ID;
wire Branch_to_ID;
wire alu_zero_ID;
wire RegWrite_to_id;
//to ID_EX
wire [NB_DATA-1:0] id_rs_data_id_ex;
wire [NB_DATA-1:0] id_rt_data_id_ex;
wire [NB_REG_ADDRESS-1:0] id_rs_address_id_ex;
wire [NB_REG_ADDRESS-1:0] id_rt_address_id_ex;
wire [NB_REG_ADDRESS-1:0] id_rd_address_id_ex;
wire [NB_DATA_IN-1:0] id_inm_value_id_ex;
wire [NB_DATA-1:0] id_sigext_id_ex;
wire [1:0] RegDst_to_ID_EX;
wire [1:0] ALUSrc_to_ID_EX;
wire MemRead_to_id_ex;
wire MemWrite_to_id_ex;
wire Branch_to_ID_EX;
wire RegWrite_to_id_ex;
wire [1:0] memtoReg_to_id_ex;
wire [2:0] bhw_to_id_ex;
wire [3:0] ALUOp_to_id_ex;
wire [NB_FUNCTION-1:0] function_to_id_ex;
wire [NB_PC-1:0] if_id_address_plus_4_id_ex;
wire flush_to_ex_mem;

wire [NB_DATA-1:0] rs_data_from_shortcircuit;
wire [NB_DATA-1:0] reg_data_to_debug_unit;
wire [NB_REG_ADDRESS-1:0] reg_address_to_id;

ID
#(
    .NB_DATA(NB_DATA),
    .N_REG(N_REG),
    .NB_INS(NB_INS),
    .NB_DATA_IN(NB_DATA_IN),
    .NB_OPS(NB_OPS),
    .NB_FUNCTION(NB_FUNCTION),
    .NB_PC(NB_PC),
    .NB_DATA_OUT(NB_DATA_OUT)
)
u_id
( 
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_pipeline_stalled_to_control_unit(pipeline_stalled_to_ID),    
    .i_alu_zero_from_ex_mem(alu_zero_ID),
    .i_RegWrite_from_WB(RegWrite_to_id),
    .i_reg_address_from_DU(reg_address_to_id),
    .i_instruction(if_id_instruction_id),      
    .i_write_address(write_address_to_id),
    .i_data_to_write_in_register_bank(write_address_to_register_bank),
    .i_address_plus_4(if_id_address_plus_4_id),
    .i_rs_data_from_shortcircuit(rs_data_from_shortcircuit),
    .i_rt_data_from_shortcircuit(id_ex_rt_data_ex_mem),
    
    .o_rs_data(id_rs_data_id_ex),    
    .o_rt_data(id_rt_data_id_ex),    
    .o_rs_address(id_rs_address_id_ex),
    .o_rt_address(id_rt_address_id_ex),
    .o_rd_address(id_rd_address_id_ex),
    .o_inm_value(id_inm_value_id_ex),
    .o_sigext(id_sigext_id_ex),    
    .o_function(function_to_id_ex),
    .o_address_plus_4(if_id_address_plus_4_id_ex),
    .o_jump_address(jump_address_to_if),

    // control signals
    .o_PcSrc_to_IF(PcSrc),
    .o_RegDst_to_ID_EX(RegDst_to_ID_EX),
    .o_ALUSrc_to_ID_EX(ALUSrc_to_ID_EX),
    .o_ALUOp_to_ID_EX(ALUOp_to_id_ex),
    .o_MemRead_to_ID_EX(MemRead_to_id_ex),
    .o_MemWrite_to_ID_EX(MemWrite_to_id_ex),
    .o_RegWrite_to_ID_EX(RegWrite_to_id_ex),
    .o_MemtoReg_to_ID_EX(memtoReg_to_id_ex),
    .o_BHW_to_ID_EX(bhw_to_id_ex),
    .o_execute_branch(execute_branch_to_IF),
    .o_IF_ID_flush(IF_ID_flush),
    .o_ex_mem_flush(flush_to_ex_mem),
    .o_reg_data_to_DU(reg_data_to_debug_unit)
);

//to EX
wire [NB_DATA-1:0] id_ex_rs_data_ex;
wire [NB_DATA-1:0] id_ex_rt_data_ex;
wire [NB_INS-1:0] id_ex_sigext_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_rs_address_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_rt_address_ex;
wire [NB_REG_ADDRESS-1:0] id_ex_rd_address_to_ex;
wire [NB_PC-1:0] id_ex_address_plus_4_ex;
wire [NB_FUNCTION-1:0] function_to_ex;

wire [1:0] RegDst_to_ex;
wire [1:0] ALUSrc_to_ex;
wire MemRead_to_ex;
wire MemWrite_to_ex;
wire RegWrite_to_ex;
wire [1:0] memtoReg_to_ex;
wire [2:0] bhw_to_ex_mem;
wire [3:0] ALUOp_to_ex;
wire halted_to_ex_mem;

ID_EX
#(
    .NB_DATA(NB_DATA),
    .N_REG(N_REG),
    .NB_INS(NB_INS),
    .NB_DATA_OUT(NB_DATA_OUT),
    .NB_DATA_IN(NB_DATA_IN),
    .NB_PC(NB_PC),
    .NB_FUNCTION(NB_FUNCTION)       
)
u_id_ex
(
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_rs_data(id_rs_data_id_ex),
    .i_rt_data(id_rt_data_id_ex),
    .i_sigext(id_sigext_id_ex),   
    .i_rs_address(id_rs_address_id_ex),
    .i_rt_address(id_rt_address_id_ex),
    .i_rd_address(id_rd_address_id_ex),
    .i_address_plus_4(if_id_address_plus_4_id_ex),
    .i_function_from_id(function_to_id_ex),

    // control signals
    .i_RegDst_from_ID(RegDst_to_ID_EX),
    .i_ALUSrc_from_ID(ALUSrc_to_ID_EX),
    .i_MemRead_from_ID(MemRead_to_id_ex),
    .i_MemWrite_from_ID(MemWrite_to_id_ex),
    .i_RegWrite_from_ID(RegWrite_to_id_ex),
    .i_MemtoReg_from_ID(memtoReg_to_id_ex),
    .i_BHW_from_ID(bhw_to_id_ex),
    .i_ALUOp_from_ID(ALUOp_to_id_ex),
    .i_is_halted(halted_to_id_ex),
    .i_pipeline_stalled(pipeline_stalled_to_ID),

    .o_rs_data(id_ex_rs_data_ex),
    .o_rt_data(id_ex_rt_data_ex),
    .o_sigext(id_ex_sigext_ex),
    .o_rs_address(id_ex_rs_address_ex),
    .o_rt_address(id_ex_rt_address_ex),
    .o_rd_address(id_ex_rd_address_to_ex),
    .o_address_plus_4(id_ex_address_plus_4_ex),
    .o_function_to_EX(function_to_ex),

    // control signals
    .o_RegDst_to_EX(RegDst_to_ex),
    .o_ALUSrc_to_EX(ALUSrc_to_ex),
    .o_MemRead_to_EX(MemRead_to_ex),
    .o_MemWrite_to_EX(MemWrite_to_ex),
    .o_RegWrite_to_EX(RegWrite_to_ex),
    .o_MemtoReg_to_EX(memtoReg_to_ex),
    .o_BHW_to_EX(bhw_to_ex_mem),
    .o_ALUOp_to_EX(ALUOp_to_ex),
    .o_is_halted(halted_to_ex_mem)
    
);

wire [1:0] data_a_mux;
wire [1:0] data_b_mux;
//to EX_MEM
wire [NB_DATA-1:0] ex_res_ex_mem;
wire alu_zero_ex_mem;

wire MemRead_to_ex_mem;
wire MemWrite_to_ex_mem;
wire [1:0] memtoReg_to_ex_mem;
wire RegWrite_to_ex_mem;

wire [NB_REG_ADDRESS-1:0] write_address_to_ex_mem;
wire [NB_DATA-1:0] address_plus_4_to_ex_mem;
wire [NB_DATA-1:0] id_ex_rt_data_ex_mem;
wire [NB_REG_ADDRESS-1:0] rt_address_to_ex_mem;

wire [NB_DATA-1:0] rt_data_to_ex_from_mem_wb;


EX
#(    
    .NB_DATA(NB_DATA),
    .NB_DATA_OUT(NB_DATA_OUT),
    .NB_DATA_IN(NB_DATA_IN),
    .NB_OP(NB_OP),
    .NB_REG_ADDRESS(NB_REG_ADDRESS),
    .NB_PC(NB_PC),
    .NB_OPS(NB_OPS),
    .NB_ALUCODE(NB_ALUCODE),
    .NB_FUNCTION(NB_FUNCTION)
)
u_ex
(
    .i_debug_unit_enable(debug_unit_enable),
    .i_rs_data(id_ex_rs_data_ex),
    .i_rt_data(id_ex_rt_data_ex),
    .i_sigext(id_ex_sigext_ex),
    .i_rt_address(id_ex_rt_address_ex),  
    .i_rd_address(id_ex_rd_address_to_ex),
    .i_address_plus_4(id_ex_address_plus_4_ex),
    .i_function_from_id_ex(function_to_ex),

    // control signals
    .i_RegDst_from_ID_EX(RegDst_to_ex),
    .i_ALUSrc_from_ID_EX(ALUSrc_to_ex),
    .i_MemRead_from_ID_EX(MemRead_to_ex),
    .i_MemWrite_from_ID_EX(MemWrite_to_ex),
    .i_RegWrite_from_ID_EX(RegWrite_to_ex),
    .i_MemtoReg_from_ID_EX(memtoReg_to_ex),
    .i_ALUOp_from_ID_EX(ALUOp_to_ex),

    .i_forward_a(data_a_mux),
    .i_forward_b(data_b_mux),
    .i_rt_data_ex_mem(ex_res_to_mem),
    .i_rt_data_mem_wb(res_to_wb),

    .o_res(ex_res_ex_mem),
    .o_alu_zero_to_ex_mem(alu_zero_ex_mem),
    
    // control signals
    .o_MemRead_to_EX_MEM(MemRead_to_ex_mem),
    .o_MemWrite_to_EX_MEM(MemWrite_to_ex_mem), 
    .o_MemtoReg_to_EX_MEM(memtoReg_to_ex_mem),
    .o_RegWrite_to_EX_MEM(RegWrite_to_ex_mem),
    
    .o_write_address(write_address_to_ex_mem),
    .o_address_plus_4(address_plus_4_to_ex_mem),
    .o_rt_data(id_ex_rt_data_ex_mem),
    .o_rs_data(rs_data_from_shortcircuit),
    .o_rt_address(rt_address_to_ex_mem)
);

//to MEM
wire [NB_DATA-1:0] ex_res_to_mem;
wire [NB_DATA-1:0] rt_data_to_mem;
wire [NB_REG_ADDRESS-1:0] write_address_to_mem;
wire [NB_PC-1:0] address_plus_4_to_mem;
wire MemRead_to_mem;
wire MemWrite_to_mem; 
wire [1:0] memtoReg_to_mem;
wire [2:0] bhw_to_mem;
wire RegWrite_to_mem;
wire [NB_REG_ADDRESS-1:0] rt_address_to_mem;
wire halted_to_mem_wb;

EX_MEM
#(
    .NB_DATA(NB_DATA),
    .NB_DATA_IN(NB_DATA_IN),
    .NB_REG_ADDRESS(NB_REG_ADDRESS)
)
u_ex_mem
(    
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_res(ex_res_ex_mem),
    .i_alu_zero_from_ex(alu_zero_ex_mem),
    .i_rt_data(id_ex_rt_data_ex_mem),
    .i_write_address(write_address_to_ex_mem),
    .i_address_plus_4(address_plus_4_to_ex_mem),

    // control signals
    .i_MemRead_from_EX(MemRead_to_ex_mem),
    .i_MemWrite_from_EX(MemWrite_to_ex_mem),
   
    .i_MemtoReg_from_EX(memtoReg_to_ex_mem),
    .i_BHW_from_EX(bhw_to_ex_mem),
    .i_RegWrite_from_EX(RegWrite_to_ex_mem),
    .i_rt_address(rt_address_to_ex_mem), 
    .i_ex_mem_flush(flush_to_ex_mem),   
    .i_is_halted(halted_to_ex_mem),
    
    .o_res(ex_res_to_mem),
    .o_alu_zero_to_ID(alu_zero_ID),
    .o_rt_data(rt_data_to_mem),
    .o_write_address(write_address_to_mem),
    .o_address_plus_4(address_plus_4_to_mem),
    
    // control signals
    .o_MemRead_to_MEM(MemRead_to_mem),
    .o_MemWrite_to_MEM(MemWrite_to_mem),
    .o_MemtoReg_to_MEM(memtoReg_to_mem),
    .o_BHW_to_MEM(bhw_to_mem),
    .o_RegWrite_to_MEM(RegWrite_to_mem),
    .o_rt_address(rt_address_to_mem),
    .o_is_halted(halted_to_mem_wb)
);

wire [NB_DATA-1:0] ex_res_to_mem_wb;
wire [NB_DATA-1:0] mem_data_to_mem_wb;
wire [NB_REG_ADDRESS-1:0] write_address_to_mem_wb;
wire [NB_PC-1:0] address_plus_4_to_mem_wb;
wire [1:0] memtoReg_to_mem_wb;
wire RegWrite_to_mem_wb;
wire [NB_REG_ADDRESS-1:0] rt_address_to_mem_wb;
wire [NB_DATA-1:0] rt_data_to_mem_wb;
wire [NB_PC-1:0] data_mem_read_address_to_mem;

MEM
#(
    .NB_DATA(NB_DATA),
    .NB_REG_ADDRESS(NB_REG_ADDRESS),
    .NB_ADDR(NB_ADDR),
    .NB_INS(NB_INS)
)
u_mem
(
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_res(ex_res_to_mem),
    .i_read_address_from_du(data_mem_read_address_to_mem),
    .i_rt_data(rt_data_to_mem),
    .i_write_address(write_address_to_mem),
    .i_address_plus_4(address_plus_4_to_mem),

    // control signals
    .i_MemRead_from_EX_MEM(MemRead_to_mem),
    .i_MemWrite_from_EX_MEM(MemWrite_to_mem),
    .i_MemtoReg_from_EX_MEM(memtoReg_to_mem),
    .i_BHW_from_EX_MEM(bhw_to_mem),
    .i_RegWrite_from_EX_MEM(RegWrite_to_mem),

    .i_rt_address(rt_address_to_mem),
    
    .o_res(ex_res_to_mem_wb),
    .o_mem_data(mem_data_to_mem_wb),
    .o_write_address(write_address_to_mem_wb),
    .o_address_plus_4(address_plus_4_to_mem_wb),

    // control signals
    .o_MemtoReg_to_MEM_WB(memtoReg_to_mem_wb),
    .o_RegWrite_to_MEM_WB(RegWrite_to_mem_wb),
    .o_rt_address(rt_address_to_mem_wb),
    .o_rt_data(rt_data_to_mem_wb)    
);

wire [NB_DATA-1:0] res_to_wb;
wire [NB_DATA-1:0] mem_data_to_wb;
wire [NB_PC-1:0] address_plus_4_to_wb;
wire [1:0] MemtoReg_to_wb;
wire RegWrite_to_wb;
wire [NB_REG_ADDRESS-1:0] rt_address_to_shortcircuit;
wire halted_to_debug_unit;

MEM_WB
#(
    .NB_DATA(NB_DATA),
    .NB_REG_ADDRESS(NB_REG_ADDRESS) 
)
u_mem_wb
(
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_debug_unit_enable(debug_unit_enable),
    .i_write_address(write_address_to_mem_wb),
    .i_res(ex_res_to_mem_wb),   
    .i_mem_data(mem_data_to_mem_wb),
    .i_address_plus_4(address_plus_4_to_mem_wb),

    // control signals
    .i_MemtoReg_from_MEM(memtoReg_to_mem_wb),
    .i_RegWrite_from_MEM(RegWrite_to_mem_wb),

    .i_rt_address(rt_address_to_mem_wb),
    .i_rt_data(rt_data_to_mem_wb),
    .i_is_halted(halted_to_mem_wb),

    .o_write_address(write_address_to_id),
    .o_res(res_to_wb),
    .o_mem_data(mem_data_to_wb),
  
    .o_address_plus_4(address_plus_4_to_wb),

    // control signals
    .o_MemtoReg_to_WB(MemtoReg_to_wb),
    .o_RegWrite_to_WB(RegWrite_to_wb),
    .o_rt_address(rt_address_to_shortcircuit),
    .o_rt_data(rt_data_to_ex_from_mem_wb),
    .o_is_halted(halted_to_debug_unit)
);

WB
#(
    .NB_REG_ADDRESS(NB_REG_ADDRESS),
    .NB_DATA(NB_DATA),
    .NB_ADDR(NB_ADDR)
)
u_wb
( 
    .i_debug_unit_enable(debug_unit_enable),
    .i_res(res_to_wb),
    .i_mem_data(mem_data_to_wb), 
    .i_address_plus_4(address_plus_4_to_wb),
    // control signals 
    .i_MemtoReg(MemtoReg_to_wb),
    .i_RegWrite_from_MEM_WB(RegWrite_to_wb),    

    .o_write_in_register_bank(write_address_to_register_bank),  
    
    // control signals
    .o_RegWrite_to_ID(RegWrite_to_id) 
);

hazard_detection_unit
#(
    .N_REG(N_REG)
)
u_hazard_detection_unit
(
    .i_rs_address_id(id_rs_address_id_ex),
    .i_rt_address_id(id_rt_address_id_ex),
    .i_MemRead(MemRead_to_id_ex), 
    .i_rt_address_ex(id_ex_rt_address_ex),
    .o_PCwrite(PCwrite_to_IF),
    .o_IFIDwrite(IFIDwrite),
    .o_pipeline_stalled_to_ID(pipeline_stalled_to_ID)
);

shortcircuit_unit
#(
    .N_REG(N_REG)
)
u_shortcircuit_unit
(
    .i_RegWrite_from_EX_MEM(RegWrite_to_mem),
    .i_RegWrite_from_MEM_WB(RegWrite_to_wb),
    .i_rs_address_id_ex(id_ex_rs_address_ex),
    .i_rt_address_id_ex(id_ex_rt_address_ex),
    .i_rt_address_ex_mem(rt_address_to_mem),
    .i_rt_address_mem_wb(rt_address_to_shortcircuit), 
    .o_forward_a(data_a_mux),
    .o_forward_b(data_b_mux)
);

debug_unit
#(
    .CLK_FREQ(CLK_FREQ)
)
u_debug_unit
(
    .i_clk(system_clk),
    .i_reset(i_reset),
    .i_rx_data(i_rx_data),
    .i_halted(halted_to_debug_unit),
    .i_pc(pc_to_debug_unit),
    .i_reg_data(reg_data_to_debug_unit),
    .i_mem_data(mem_data_to_mem_wb),
    .o_reg_address(reg_address_to_id),
    .o_data_mem_read_address(data_mem_read_address_to_mem),
    .o_instruction_mem_write_address(instruction_mem_write_address_to_if),
    .o_instruction(instruction_to_if),
    .o_write_enable(write_enable_to_if),
    .o_tx_data(o_tx_data),
    .o_tx_valid(),
    .o_state(o_state),
    .o_debug_unit_enable(debug_unit_enable)
);

assign o_led_1 = 1'b1;

always @(posedge system_clk) begin
    if(i_reset)
        o_led_2 <= 1'b0;
    else if(i_toggle_led)
        o_led_2 <= ~o_led_2;
end

endmodule