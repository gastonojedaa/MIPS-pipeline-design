`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2024 23:02:01
// Design Name: 
// Module Name: tb_interface_pipeline
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


module tb_interface_pipeline;

parameter NB_UART_DATA = 8;
parameter NB_DATA = 32;
parameter NB_REGS = 5;
parameter MEM_DEPTH = 256;
parameter NB_STATE = 10;

localparam N_REGS = 2**NB_REGS;

reg clk;
reg reset;
reg halted;
reg [NB_UART_DATA-1:0]rx_data;
reg rx_valid;
reg [NB_DATA-1:0]pc;
reg [NB_DATA-1:0]mem_data[0:MEM_DEPTH];
reg tx_done;
wire [NB_DATA-1:0]data_mem_read_address;

wire [NB_DATA-1:0] mem_slot_data;
wire [NB_REGS-1:0] reg_address;
wire [NB_DATA-1:0] reg_data;
reg [NB_DATA-1:0] reg_bank [0:N_REGS];


assign mem_slot_data = mem_data[data_mem_read_address];


integer i;
initial
begin
    for (i = 0; i <= MEM_DEPTH; i = i + 1) begin
        mem_data[i] = i*2;
    end
end



assign reg_data = reg_bank[reg_address];

initial
begin
    for (i = 0; i <= N_REGS; i = i + 1) begin
        reg_bank[i] = i*3;
    end
end

initial
begin
    #0
    clk = 0;
    reset = 1;
    halted = 0;
    rx_data = 0;
    rx_valid = 0;
    pc = 0;
    tx_done = 1;
    #10
    reset = 0;
    // Send CMD_SET_INST
    #5
    rx_data = 8'b000000001;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    // Send number of instructions = 2
    #5
    rx_data = 8'b000000010;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    // Send instruction 32'h03020100
    #5
    rx_data = 8'h00;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h01;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h02;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h03;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    // Send Instruction 32'h01000010
    #5
    rx_data = 8'h10;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h00;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h00;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #5
    rx_data = 8'h01;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #20
    // Set Mode Continuous
    rx_data = 8'b000000010;
    #1
    rx_valid = 1;
    #1
    rx_valid = 0;
    #20
    pc = 32'hAABBCCDD;
    #1
    // Halt reached
    halted = 1;
    #10
    $finish;  
end 

always #0.5 clk = ~clk; 

interface_pipeline
#(
    .NB_UART_DATA(8),
    .NB_DATA(32),
    .NB_REGS(5),
    .MEM_DEPTH(256),
    .NB_STATE(10)
)
u_interface_pipeline
(
    .i_clk(clk),
    .i_reset(reset),     
    .i_halted(halted),
    .i_rx_data(rx_data),
    .i_rx_valid(rx_valid),
    .i_pc(pc),
    .i_mem_data(mem_slot_data),
    .i_tx_done(tx_done),
    .i_reg_data(reg_data),
    .o_enable(),
    .o_instruction_mem_write_address(),
    .o_instruction(),
    .o_write_enable(),
    .o_data_mem_read_address(data_mem_read_address),
    .o_tx_data(),
    .o_tx_valid(),
    .o_reg_address(reg_address)
);
endmodule
