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
localparam BIT_DURATION = 9780;
localparam START_BIT_DURATION = 4564;

reg clk;
reg reset;
reg halted;
reg rx_data;
reg rx_valid;
reg [NB_DATA-1:0] pc;
reg [NB_DATA-1:0] mem_data [0:MEM_DEPTH];
reg tx_done;
wire [NB_DATA-1:0] data_mem_read_address;

wire [NB_DATA-1:0] mem_slot_data;
wire [NB_REGS-1:0] reg_address;
wire [NB_DATA-1:0] reg_data;
reg [NB_DATA-1:0] reg_bank [0:N_REGS];

assign mem_slot_data = mem_data[data_mem_read_address];

integer i;
initial begin
    for (i = 0; i <= MEM_DEPTH; i = i + 1) begin
        mem_data[i] = i * 2;
    end
end

assign reg_data = reg_bank[reg_address];

initial begin
    for (i = 0; i <= N_REGS; i = i + 1) begin
        reg_bank[i] = i * 3;
    end
end

// Task to send a byte bit by bit
task send_byte;
    input [7:0] byte;
    integer j;
    begin
        // Start bit
        rx_data = 0;
        #BIT_DURATION;
        
        // Data bits
        for (j = 0; j < 8; j = j + 1) 
        begin
            rx_data = byte[j];
            #BIT_DURATION;
        end
        
        // Stop bit
        rx_data = 1;
        #(BIT_DURATION*2);
    end
endtask

initial begin
    #0
    clk = 0;
    reset = 1;
    halted = 0;
    rx_data = 1; // Idle state for UART
    rx_valid = 0;
    pc = 0;
    tx_done = 1;
    
    #10
    reset = 0;
    
    // Send CMD_SET_INST
    #5;
    send_byte(8'b00000001);
    
    // Send number of instructions = 2
    #5;
    send_byte(8'b00000010);
    
    // Send instruction 32'h03020100
    #5;
    send_byte(8'h00);
    #5;
    send_byte(8'h01);
    #5;
    send_byte(8'h02);
    #5;
    send_byte(8'h03);
    
    // Send instruction 32'h01000010
    #5;
    send_byte(8'h10);
    #5;
    send_byte(8'h00);
    #5;
    send_byte(8'h00);
    #5;
    send_byte(8'h01);
    
    // Set Mode Continuous
    #20;
    send_byte(8'b00000010);
    
    // Set PC value
    #20;
    pc = 32'hAABBCCDD;
    
    // Halt reached
    #1;
    halted = 1;
    
    #100000;
    $finish;
end 

always #0.5 clk = ~clk;

debug_unit
#(
    .NB_UART_DATA(NB_UART_DATA),
    .NB_DATA(NB_DATA),
    .NB_STATE(NB_STATE),
    .CLK_FREQ(100000000),
    .BAUD_RATE(9600)
)
u_debug_unit (
    .i_clk(clk),                                                
    .i_reset(reset),
    .i_rx_data(rx_data),
    .i_halted(halted),
    .i_pc(pc),
    .i_reg_data(reg_data),
    .i_mem_data(mem_slot_data),
    .o_reg_address(reg_address),
    .o_data_mem_read_address(data_mem_read_address),
    .o_instruction_mem_write_address(),
    .o_instruction(),
    .o_write_enable(),
    .o_tx_data(),
    .o_tx_valid()
);

endmodule