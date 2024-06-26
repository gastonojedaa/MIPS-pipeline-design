module top_debug_unit
#(
    parameter NB_UART_DATA = 8,
    parameter NB_DATA = 32,
    parameter NB_STATE = 10,
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600,
    parameter MEM_DEPTH = 256,
    parameter NB_REGS = 5
)
(
    input i_clk,
    input i_reset,
    input i_rx_data,
    input i_halted,
    input i_toggle_led,
    output o_tx_data,
    output o_led_1,
    output reg o_led_2,
    output [NB_STATE-1:0] o_state
);

localparam N_REGS = 2**NB_REGS;



// Mock mem
reg [NB_DATA-1:0] mem_data [0:MEM_DEPTH-1];
wire [NB_DATA-1:0] mem_slot_data;
wire [NB_DATA-1:0] data_mem_read_address;


// Mock regs
reg [NB_DATA-1:0] reg_bank [0:N_REGS-1];
wire [NB_REGS-1:0] reg_address;
wire [NB_DATA-1:0] reg_data;

// Mock pc
reg [NB_DATA-1:0] pc;

// Assigns
assign mem_slot_data = mem_data[data_mem_read_address];
assign reg_data = reg_bank[reg_address];

// Initializations
integer i;
always @(posedge i_clk) begin
    if (i_reset) begin
        for (i = 0; i <= MEM_DEPTH; i = i + 1) begin
            mem_data[i] <= i * 2;
        end
    end
end

always @(posedge i_clk) begin
    if (i_reset) begin
        for (i = 0; i <= N_REGS; i = i + 1) begin
            reg_bank[i] <= i * 3;
        end
    end
end

always @(posedge i_clk) begin
    if (i_reset) begin
        pc <= 32'hAABBCCDD;
    end
end

debug_unit
#(
    .NB_UART_DATA(NB_UART_DATA),
    .NB_DATA(NB_DATA),
    .NB_STATE(NB_STATE),
    .CLK_FREQ(100000000),
    .BAUD_RATE(9600)
)
u_debug_unit (
    .i_clk(i_clk),                                                
    .i_reset(i_reset),
    .i_rx_data(i_rx_data),
    .i_halted(i_halted),
    .i_pc(pc),
    .i_reg_data(reg_data),
    .i_mem_data(mem_slot_data),
    .o_reg_address(reg_address),
    .o_data_mem_read_address(data_mem_read_address),
    .o_instruction_mem_write_address(),
    .o_instruction(),
    .o_write_enable(),
    .o_tx_data(o_tx_data),
    .o_state(o_state)
);

assign o_led_1 = 1'b1;

always @(posedge i_clk) begin
    if(i_reset)
        o_led_2 <= 1'b0;
    else if(i_toggle_led)
        o_led_2 <= ~o_led_2;
end

endmodule