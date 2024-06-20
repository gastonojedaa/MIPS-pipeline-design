`timescale 1ns / 1ps

module tb_rx;
    parameter NB_DATA = 8;
    
    reg clk;
    reg reset;
    wire tb_tick;
    reg rx_data;
    wire [NB_DATA-1:0]data;
    wire valid;
    
    initial
    begin
        #0
        clk = 0;
        reset = 1;
        rx_data = 1;

        #20
        reset = 0;
        
        #50
        rx_data = 0;
        
        #4000
        rx_data = 1;
        
        #20000
        rx_data = 0;
        
        #4.564
        rx_data = 0;
        
        #9780
        rx_data = 1;
        
        #9780
        rx_data = 1;
        
        #9780
        rx_data = 1;
        
        #9780
        rx_data = 1;
        
        #9780
        rx_data = 0;
        
        #9780
        rx_data = 0;
        
        #9780
        rx_data = 1;
        
        #9780
        rx_data = 0;
        
        #9780
        rx_data = 1;

        #9780
        
        $finish;  
    end    
    
    always #0.5 clk = ~clk;
    
    baud_rate_generator
    u_baud_rate_generator
    (
        .i_clk(clk),
        .i_reset(reset),
        .o_tick(tb_tick)
    );
    
    rx
    #(
        .NB_DATA( NB_DATA )        
    )
    u_rx
    (
        .i_clk(clk),
        .i_reset(reset),
        .i_tick(tb_tick),
        .i_rx_data(rx_data),                
        .o_data(data),
        .o_valid(valid)        
    );
endmodule