`timescale 1ns / 1ps

module rx
#(
    parameter NB_DATA = 8
)
(
    input i_clk,
    input i_reset,
    input i_tick,
    input i_rx_data,
    output [NB_DATA-1:0]o_data,
    output o_valid
);

    localparam STATE_0 = 4'b0001;
    localparam STATE_1 = 4'b0010;
    localparam STATE_2 = 4'b0100;
    localparam STATE_3 = 4'b1000;

    reg valid;
    reg[3:0] state;
    reg[3:0] next_state;
    reg[NB_DATA-1:0] data;
    reg[3:0] tick_counter_15;
    reg[2:0] tick_counter_7;
    reg[3:0] rx_bit_counter;

    always @(posedge i_clk) 
    begin
        if(i_reset)
            state <= STATE_0;
        else
            state <= next_state;
    end
    
    always@(negedge i_clk)
    begin
        if(i_reset)
        begin
            tick_counter_7 <= 0;
            tick_counter_15 <= 0;
            rx_bit_counter <= 0;
        end
        
        else
        begin
            if(i_tick)
            begin
                case(state)
                    STATE_1:
                    begin
                        tick_counter_7 <= (tick_counter_7 + 1)%8;
                    end
                    STATE_2:
                    begin
                        tick_counter_15 <= (tick_counter_15 + 1)%16;
                        if(tick_counter_15==15)
                            begin
                                rx_bit_counter <= rx_bit_counter + 1;
                                data[rx_bit_counter] <= i_rx_data;
                            end
                    end
                    default:
                        begin
                            tick_counter_15 <= 0;
                            tick_counter_7 <= 0;
                            rx_bit_counter <= 0;
                        end
                endcase
            end
        end
          
    end
        

    always @(*)
    begin
        case(state)
            STATE_0:
                if(i_rx_data)
                    next_state = STATE_0;
                else
                    next_state = STATE_1;
                    
            STATE_1:
                if(tick_counter_7<7)
                    next_state = STATE_1;
                else
                    if(i_rx_data == 1)
                        next_state = STATE_0;
                    else
                        next_state = STATE_2;
                        
            STATE_2:
                if(rx_bit_counter==9)
                    begin
                        if(i_rx_data==1)
                            next_state = STATE_3;
                        else
                            next_state = STATE_0;
                    end
                else
                    next_state = STATE_2;
                    
            STATE_3:
                next_state = STATE_0;
                
            default:
                next_state = STATE_0;
        endcase
    end
    
    always@(*)
    begin
        case(state)
            STATE_3:
                valid = 1;
            default:
                valid = 0;
        endcase
    end
    
    assign o_data = data;
    assign o_valid = valid;

endmodule