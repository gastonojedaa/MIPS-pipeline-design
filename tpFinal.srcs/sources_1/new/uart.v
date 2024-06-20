module uart
#(
    parameter NB_UART_DATA = 8,
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600
)
(
    input i_clk,
    input i_reset,
    input i_valid_tx,
    input [NB_UART_DATA-1:0] i_data_tx,
    input i_rx_data,
    output o_tx_data,
    output [NB_UART_DATA-1:0 ] o_data_rx,
    output o_valid_rx,
    output o_tx_done
);

baud_rate_generator
#(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
)
u_baud_rate_generator
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_tick(bdg_tick)
);

wire bdg_tick;

tx
#(
   NB_UART_DATA
)
u_tx
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_tick(bdg_tick),
    .i_valid(i_valid_tx),
    .i_data(i_data_tx),
    .o_tx_data(o_tx_data),
    .o_tx_done(o_tx_done)
);

rx
#(
    NB_UART_DATA
)
u_rx
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_tick(bdg_tick),
    .i_rx_data(i_rx_data),
    .o_data(o_data_rx),
    .o_valid(o_valid_rx)
);

endmodule