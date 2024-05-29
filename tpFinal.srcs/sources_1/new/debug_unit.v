module debug_unit
#(
    parameter NB_UART_DATA = 8,
    parameter NB_DATA = 32,
    parameter NB_STATE = 10
)
(
    input i_clk,
    input i_reset,
    input i_rx_data,
    input i_halted,
    input i_pc,
    input [NB_DATA-1:0] i_mem_data,
    output [NB_DATA-1:0] o_data_mem_read_address,
    output o_tx_data,
    output o_tx_valid
);

// Signals
wire [NB_UART_DATA-1:0] data_tx;
wire valid_tx;
wire data_rx;
wire valid_rx;

uart
#(
    .NB_UART_DATA(NB_UART_DATA)
)
u_uart
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_valid_tx(valid_tx),
    .i_data_tx(data_tx),
    .i_rx_data(i_rx_data),
    .o_tx_data(o_tx_data),
    .o_data_rx(data_rx),
    .o_valid_rx(valid_rx),
    .o_tx_done(tx_done)
);

interface_pipeline
#(
    .NB_UART_DATA(NB_UART_DATA),
    .NB_DATA(NB_DATA),
    .NB_STATE(NB_STATE)
)
u_interface_pipeline
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rx_data(data_rx),
    .i_rx_valid(valid_rx),
    .i_pc(),
    .i_mem_data(),
    .i_tx_done(tx_done),
    .o_data_mem_read_address(),
    .o_tx_data(data_tx),
    .o_tx_valid(valid_tx)
);
endmodule