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


module tb_debug_unit;

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

debug_unit
#(
    .NB_UART_DATA(NB_UART_DATA),
    .NB_DATA(NB_DATA),
    .NB_STATE(NB_STATE)
)
u_debug_unit(
    .i_clk(clk),                                                
    .i_reset(reset),
    .i_rx_data(rx_data),
    .i_halted(halted),
    .i_pc(pc),
    .i_mem_data(mem_slot_data),
    .o_data_mem_read_address(data_mem_read_address),
    .o_tx_data(),
    .o_tx_valid()
)

endmodule
