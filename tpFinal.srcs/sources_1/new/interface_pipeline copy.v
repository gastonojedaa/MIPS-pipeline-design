`timescale 1ns / 1ps

module interface_pipeline
#(
    parameter NB_DATA = 8,
    parameter NB_OPS = 6
)
(
    input i_clk,
    input i_reset,
    input [NB_DATA-1:0] i_rx_data,
    input i_rx_valid,
    input [NB_DATA-1:0] i_res,
    output [NB_DATA-1:0] o_data_a,
    output [NB_DATA-1:0] o_data_b,
    output [NB_OPS-1:0] o_ops,
    output [NB_DATA-1:0] o_tx_data,
    output o_tx_valid
);

    localparam STATE_0 = 4'b0001;
    localparam STATE_1 = 4'b0010;
    localparam STATE_2 = 4'b0100;
    
    reg [NB_DATA-1:0]data_a;
    reg [NB_DATA-1:0]data_b;
    reg [NB_OPS-1:0] ops;
    
    reg [3:0] state;
    reg [3:0] next_state;
    
    reg tx_valid;
    
    reg [1:0] location;
    
    always @(posedge i_clk) 
    begin
        if(i_reset)
            state <= STATE_0;
        else
            state <= next_state;
    end
    
    
    always@(posedge i_clk)
    begin
        if(i_reset)
        begin
            data_a <= 0;
            data_b <= 0;
            ops <= 0;
            location <= 0;
            tx_valid <= 0;
        end
        
        else
        begin
            case(state)
                STATE_0:
                begin
                    tx_valid <= 0;
                    if(i_rx_valid==1)
                    begin
                        if(i_rx_data == 8'hFF)
                            tx_valid <= 1;
                        else
                            location <= i_rx_data[1:0];
                    end
                end
                        
                STATE_1:
                    if(i_rx_valid==1)
                        case(location)
                            0:
                                data_a <= i_rx_data;
                            1:
                                data_b <= i_rx_data;
                            default:
                                ops <= i_rx_data[NB_OPS-1:0];
                        endcase
                STATE_2:
                    tx_valid <= 1;
                default:
                    tx_valid <= 0;
            endcase
        end
    end
    
    always @(*)
    begin
        case(state)
            STATE_0:
                if(i_rx_valid==1)
                    begin
                        if(i_rx_data == 8'hFF)
                            next_state = STATE_2;
                        else
                            next_state = STATE_1;
                    end
                else
                    next_state = state;
            STATE_1:
                if(i_rx_valid==1)
                    next_state = STATE_0;
                else
                    next_state = state;   
            default:
                next_state = STATE_0;
        endcase
    end
    
    //Interface -> ALU
    assign o_data_a = data_a;
    assign o_data_b = data_b;
    assign o_ops = ops;
    
    //Interface -> Tx
    assign o_tx_data = i_res;
    assign o_tx_valid = tx_valid;

endmodule