`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 17:17:44
// Design Name: 
// Module Name: IF
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

module IF #(
    parameter NB_PC  = 32,
    parameter NB_INS = 32
) (
    input i_clk,
    input i_reset,
    input i_debug_unit_enable,
    input [1:0] i_PcSrc, 
    input i_write_enable,  
    input [NB_PC-1:0] i_jump_address,
    input [NB_PC-1:0] i_write_address,
    input [NB_INS-1:0] i_instruction,
    //signal to hazard detection unit
    input i_PCwrite,  //1 to stall, 0 to not stall
    input i_execute_branch,

    output [NB_INS-1:0] o_instruction,
    output [NB_PC-1:0] o_address_plus_4,
    output o_is_halted,
    output [NB_PC-1:0] o_pc

);
  reg pipeline_halted;
  wire [NB_INS-1:0] instruction_from_mem;
  reg [NB_PC-1:0] new_address;
  wire [NB_PC-1:0] address_plus_4;
  reg [NB_PC-1:0] pc;
  wire is_halted;

  always @(posedge i_clk) begin
    if (i_reset) pipeline_halted <= 0;
    else if (pipeline_halted) pipeline_halted <= 1;
    else if (is_halted) pipeline_halted <= 1;
    else pipeline_halted <= 0;
  end


  assign is_halted = (instruction_from_mem[31:26] == 6'b111111);

  assign address_plus_4 = pc + 1;

  // Mux PC - PC + 4 o jump address
  always @(*) begin
    if (i_PCwrite || !i_debug_unit_enable || pipeline_halted || is_halted) new_address = pc;
    else begin
      if ((i_PcSrc != 2'b00) || i_execute_branch) new_address = i_jump_address;
      else new_address = address_plus_4;
    end
  end

  // PC
  always @(posedge i_clk) begin
    if (i_reset) pc <= 0;
    else pc <= new_address;
  end


  instruction_mem #(.NB_PC(NB_PC), .NB_INS(NB_INS)) u_instruction_mem (
      .i_clk(i_clk),
      .i_read_address(pc),
      .i_write_address(i_write_address),
      .i_instruction(i_instruction),
      .i_write_enable(i_write_enable),
      .o_instruction(instruction_from_mem)
  );

  assign o_address_plus_4 = address_plus_4;
  assign o_instruction = instruction_from_mem;
  assign o_is_halted = pipeline_halted || is_halted;
  assign o_pc = pc;

endmodule
