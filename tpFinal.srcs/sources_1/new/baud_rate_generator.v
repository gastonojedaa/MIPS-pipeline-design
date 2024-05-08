`timescale 1ns / 1ps

module baud_rate_generator
#(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600
)
(
    input i_clk,
    input i_reset,
    output o_tick
);
    localparam COUNT_MAX_VALUE = CLK_FREQ / (BAUD_RATE * 16);
    localparam NB_COUNTER = $clog2(COUNT_MAX_VALUE);

    reg tick;
    reg [NB_COUNTER-1:0] counter;
    
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin
            counter <= 0;
        end
            
        else
        begin
            if(counter==COUNT_MAX_VALUE)
            begin
               counter <= 0;
            end
            else
            begin
                counter <= counter + 1;
            end       
        end
    end
    
    always@(*)
    begin
    if(counter==COUNT_MAX_VALUE)
        tick = 1;
    else
        tick = 0;
    end
    
    assign o_tick = tick;
    
endmodule