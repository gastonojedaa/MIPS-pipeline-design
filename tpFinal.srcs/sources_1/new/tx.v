`timescale 1ns / 1ps

module tx
#(
    parameter NB_DATA = 8
)
(
    input i_clk,
    input i_reset,
    input i_tick,
    input i_valid,
    input [NB_DATA-1:0] i_data,
    output o_tx_done,
    output o_tx_data
);

    localparam STATE_0 = 2'b01;
    localparam STATE_1 = 2'b10;

    reg[2:0] state;
    reg[2:0] next_state;
    reg[NB_DATA:0] data;
    reg[3:0] tick_counter;
    reg[3:0] tx_bit_counter;
    reg tx_data;

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
            data[0] <= 0;
            tick_counter <= 0;
            tx_bit_counter <= 0;
        end
            
        else
        begin
            case(state) 
            STATE_0:
                begin
                    if(i_valid)
                        data[NB_DATA:1] <= i_data;
                    tx_bit_counter <= 0;
                    tick_counter <= 0;
                end
            STATE_1:
                begin
                   if(i_tick)
                   begin
                        tick_counter <= (tick_counter + 1)%16;
                        
                        if(tick_counter==15)
                        begin
                          data <= {data[0],data[NB_DATA:1]};
                          tx_bit_counter <= tx_bit_counter + 1;
                        end
                   end
                end
        endcase 
        end
   
                 
    end
        

    always @(*)
    begin
        case(state)
            STATE_0:
            begin
                if(i_valid)
                    next_state = STATE_1;
                else
                    next_state = STATE_0;
            end
                       
            STATE_1:
            begin
                if(tx_bit_counter == 9)
                    next_state = STATE_0;
                else
                    next_state = STATE_1;
            end
            default:
                next_state = STATE_0;                 
        endcase
    end
    
    always@(*)
    begin
        case(state)
            STATE_1:
                tx_data = data[0];
            default:
                tx_data = 1;
        endcase
    end
    
    assign o_tx_data = tx_data;
    assign o_tx_done = (state == STATE_0) ? 1 : 0;

endmodule