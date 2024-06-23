module debug_unit
#(
    parameter NB_UART_DATA = 8,
    parameter NB_DATA = 32,
    parameter NB_STATE = 10,
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600,
    parameter NB_REGS = 5
)
(
    input i_clk,
    input i_reset,
    input i_rx_data,
    input i_halted,
    input [NB_DATA-1:0] i_pc,
    input [NB_DATA-1:0] i_reg_data,
    input [NB_DATA-1:0] i_mem_data,
    output [NB_REGS-1:0] o_reg_address,
    output [NB_DATA-1:0] o_data_mem_read_address,
    output [NB_DATA-1:0] o_instruction_mem_write_address,
    output [NB_DATA-1:0] o_instruction,
    output o_write_enable,
    output o_tx_data,
    output o_tx_valid
);

// Signals
wire [NB_UART_DATA-1:0] data_tx;
wire valid_tx;
wire [NB_UART_DATA-1:0] data_rx;
wire valid_rx;

uart
#(
    .NB_UART_DATA(NB_UART_DATA),
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
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
    .i_halted(i_halted),
    .i_rx_data(data_rx),
    .i_rx_valid(valid_rx),
    .i_pc(i_pc),
    .i_reg_data(i_reg_data),
    .i_mem_data(i_mem_data),
    .i_tx_done(tx_done),
    .o_enable(),
    .o_reg_address(o_reg_address),
    .o_instruction_mem_write_address(),
    .o_instruction(),
    .o_write_enable(),
    .o_data_mem_read_address(o_data_mem_read_address),
    .o_tx_data(data_tx),
    .o_tx_valid(valid_tx)
);
endmodule