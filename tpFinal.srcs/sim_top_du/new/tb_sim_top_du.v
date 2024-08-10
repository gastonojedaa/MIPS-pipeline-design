`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2024 16:58:08
// Design Name: 
// Module Name: tb_sim_top_du
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


module tb_sim_top_du;
parameter NB_UART_DATA = 8;
parameter NB_DATA = 32;
parameter NB_REGS = 5;
parameter MEM_DEPTH = 256;
parameter NB_STATE = 10;

localparam N_REGS = 2**NB_REGS;
localparam BIT_DURATION = 9780;
localparam START_BIT_DURATION = 4564;
// localparam BIT_DURATION = 4882;//9780 antes
// localparam START_BIT_DURATION = 2600;//4564 antes


reg clk;
reg reset;
reg rx_data;

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

// Task to send a word
task send_word;
    input [31:0] word;
    begin
        send_byte(word[7:0]);
        send_byte(word[15:8]);
        send_byte(word[23:16]);
        send_byte(word[31:24]);
    end
endtask


initial begin
    #0
    clk = 0;
    reset = 1;
    rx_data = 1; // Idle state for UART

    #300;
    reset = 0;
    
    // Send CMD_SET_INST
    #200;
    send_byte(8'b00000001);
    
    // Send number of instructions = 2
    #5;
    send_byte(8'b00000010);
    
    // Send instruction
    #5;
    send_word(32'h3c010001);
    
    // // Send instruction
    // #5;
    // send_word(32'h3c020002);

    // // Send instruction
    // #5;
    // send_word(32'h3c030003);

    // // Send instruction
    // #5;
    // send_word(32'h3c040004);

    // // Send instruction
    // #5;
    // send_word(32'h3c050005);

    // Send instruction
    #5;
    send_word(32'hffffffff);
    
    // Set Mode Continuous
    #20;
    send_byte(8'b00000010);
    
    #100000;
    $finish;
end 

always #0.5 clk = ~clk;

top
#(
    // .CLK_FREQ(100000000)
)
u_top
(
    .i_clk(clk),
    .i_reset(reset),
    .i_toggle_led(1'b0),
    .i_rx_data(rx_data),
    .o_tx_data(),
    .o_led_1(),
    .o_led_2(),
    .o_state()
);

endmodule
