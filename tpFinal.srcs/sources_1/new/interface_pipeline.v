`timescale 1ns / 1ps

module interface_pipeline
#(
    parameter NB_UART_DATA = 8,
    parameter NB_DATA = 32,
    parameter NB_REGS = 5,
    parameter MEM_DEPTH = 256,
    parameter NB_STATE = 10
)
(
    // General
    input i_clk,
    input i_reset,
    input i_halted,

    // Rx
    input [NB_UART_DATA-1:0] i_rx_data,
    input i_rx_valid,

    // From Pipeline  
    input [NB_DATA-1:0] i_pc,
    input [NB_DATA-1:0] i_reg_data,
    input [NB_DATA-1:0] i_mem_data,
    input i_tx_done,

    // To Pipeline
    output o_enable,

    // Reg Bank Out
    output [NB_REGS-1:0] o_reg_address,
    
    // Instruction mem
    output [NB_DATA-1:0] o_instruction_mem_write_address,
    output [NB_DATA-1:0] o_instruction,
    output o_write_enable,
    
    // Data mem
    output [NB_DATA-1:0] o_data_mem_read_address,

    // Tx out
    output [NB_UART_DATA-1:0] o_tx_data,
    output o_tx_valid,
    output [NB_STATE-1:0] o_state

   
); 
    localparam N_REGS = 2**NB_REGS;

    // States
    localparam UNINITIALIZED = 10'b0000000001;
    localparam LOADING_INSTRUCTIONS = 10'b0000000010;
    localparam SET_MODE = 10'b0000000100;
    localparam READING_REGS = 10'b0000001000;
    localparam READING_MEM = 10'b0000010000;
    localparam READING_PC = 10'b0000100000;
    localparam CONTINUOUS = 10'b0001000000;
    localparam IDLE_STEP_BY_STEP = 10'b0010000000;
    localparam RUN_STEP = 10'b0100000000;
    localparam HALTED = 10'b1000000000;
    
    // Commands
    localparam CMD_SET_INST = 8'd1;
    localparam CMD_SET_CONTINUOUS = 8'd2;
    localparam CMD_SET_STEP_BY_STEP = 8'd3;
    localparam CMD_RUN_STEP = 8'd4;
    localparam CMD_RESET = 8'd5;

    reg [NB_STATE-1:0] state, next_state;

    /* Utils */
    /* ------------------- */
    // Bytes loaded per 32 bit
    reg [1:0] bytes_to_load;
    // Data
    reg [NB_DATA-1:0] work_reg;
    /* ------------------- */

    /* Load instructions */
    /* ------------------- */
    // Instrction mem address
    reg [NB_DATA-1:0] instruction_mem_write_address;

    // Instructions counter UP TO 255 INSTRUCTIONS
    reg [NB_UART_DATA-1:0] instructions_counter;
    reg ins_counter_flag;// 0 -> Not set, 1 -> Set
    reg first_instruction_loaded;// 0 -> Not loaded, 1 -> Loaded
    /* ------------------- */

    /* Read PC */
    /* ------------------- */
    reg pc_sent;
    /* ------------------- */

    /* Read registers */
    reg [NB_REGS-1:0] regs_counter;

    /* ------------------- */

    /* Read data memory */
    reg [NB_UART_DATA-1:0] mem_slot_counter;

    /* ------------------- */
    reg [NB_UART_DATA-1:0] tx_data;
    /*UART*/
    reg tx_valid;
    
    always @(posedge i_clk) 
    begin
        if(i_reset)
            state <= UNINITIALIZED;
        else
            state <= next_state;
    end
    
    
    always@(posedge i_clk)
    begin
        if(i_reset)
        begin
            bytes_to_load <= 0;
            work_reg <= 0;
            ins_counter_flag <= 0;
            instructions_counter <= 0;
            first_instruction_loaded <= 0;
            instruction_mem_write_address <= 0;
            regs_counter <= 0;
            mem_slot_counter <= 0;
        end
        
        else
        begin
            case(state)      
                LOADING_INSTRUCTIONS:
                    if(i_rx_valid==1)
                    begin
                        if(ins_counter_flag == 0)
                        begin
                            instructions_counter <= i_rx_data;
                            ins_counter_flag <= 1;
                        end
                        else
                        begin
                            case (bytes_to_load)
                                2'b00: work_reg[7:0]   <= i_rx_data;
                                2'b01: work_reg[15:8]  <= i_rx_data;
                                2'b10: work_reg[23:16] <= i_rx_data;
                                2'b11: work_reg[31:24] <= i_rx_data;
                            endcase
                            bytes_to_load <= bytes_to_load + 1; // Automatically resets to 0
                            if(bytes_to_load == 3)
                                begin
                                    if(first_instruction_loaded == 0)
                                        first_instruction_loaded <= 1;
                                    else
                                        instruction_mem_write_address <= instruction_mem_write_address + 1;
                                        
                                    instructions_counter <= instructions_counter - 1;
                                end
                        end
                    end
                READING_PC:
                begin
                    bytes_to_load <= i_tx_done ? bytes_to_load + 1 : bytes_to_load;
                end
                READING_REGS:
                begin
                   bytes_to_load <= i_tx_done ? bytes_to_load + 1 : bytes_to_load;
                   
                   if(bytes_to_load == 3 && i_tx_done == 1)
                   begin
                        regs_counter <= regs_counter + 1; // Automatically resets to 0
                   end
                        
                end
                READING_MEM:
                begin
                   bytes_to_load <= i_tx_done ? bytes_to_load + 1 : bytes_to_load;
                   if(bytes_to_load == 3 && i_tx_done == 1)
                   begin
                        mem_slot_counter <= mem_slot_counter + 1; // Automatically resets to 0
                   end
                      
                end
                   
                   
            endcase
        end
    end
    
    always @(*)
    begin
        case(state)
            UNINITIALIZED:
                if(i_rx_valid==1 && i_rx_data == CMD_SET_INST)
                    next_state = LOADING_INSTRUCTIONS;      
                else
                    next_state = UNINITIALIZED;
            LOADING_INSTRUCTIONS:
                // If all instructions are loaded move to next state
                if(ins_counter_flag == 1 && instructions_counter == 0)
                    next_state = SET_MODE;
                else
                    next_state = LOADING_INSTRUCTIONS;
            SET_MODE:
                if(i_rx_valid==1)
                   begin
                        case(i_rx_data)
                            CMD_SET_CONTINUOUS:
                                    next_state = CONTINUOUS;
                            CMD_SET_STEP_BY_STEP:
                                    next_state = IDLE_STEP_BY_STEP;
                            CMD_RESET:
                                    next_state = UNINITIALIZED;
                            default:
                                    next_state = SET_MODE;
                        endcase
                   end
                else
                    next_state = SET_MODE;
            CONTINUOUS:
                if(i_halted)
                    next_state = READING_PC;
                else
                    next_state = CONTINUOUS;
            IDLE_STEP_BY_STEP:
                if(i_rx_valid==1)
                    begin
                        case(i_rx_data)
                            CMD_RUN_STEP:
                                next_state = RUN_STEP;
                            CMD_RESET:
                                next_state = UNINITIALIZED;
                            default:
                                next_state = IDLE_STEP_BY_STEP;
                        endcase
                    end
                else
                    next_state = IDLE_STEP_BY_STEP;
            RUN_STEP:
                next_state = READING_PC;
            READING_PC:
                if(bytes_to_load == 3 && i_tx_done == 1)
                    next_state = READING_REGS;
                else
                    next_state = READING_PC;
            READING_REGS:
                if(regs_counter == (N_REGS-1) && bytes_to_load == 3 && i_tx_done == 1)
                    next_state = READING_MEM;
                else
                    next_state = READING_REGS;
            READING_MEM:
                if(mem_slot_counter == (MEM_DEPTH-1) && bytes_to_load == 3 && i_tx_done == 1)
                    if(i_halted)
                        next_state = HALTED;
                    else
                        next_state = IDLE_STEP_BY_STEP;
                else
                    next_state = READING_MEM;
            HALTED:
                if(i_rx_valid==1 && i_rx_data == CMD_RESET)
                    next_state = UNINITIALIZED;
                else
                    next_state = HALTED;
            default:
                next_state = UNINITIALIZED;
        endcase
    end

    // Tx Data & tx_valid
    always @(*)
    begin
        case(state)
            READING_PC:
            begin
                tx_data = i_pc[bytes_to_load*8 +: 8];
                tx_valid = i_tx_done;
            end
            READING_REGS:
            begin
                tx_data = i_reg_data[bytes_to_load*8 +: 8];
                tx_valid = i_tx_done;
            end
            READING_MEM:
            begin
                tx_data = i_mem_data[bytes_to_load*8 +: 8];
                tx_valid = i_tx_done;
            end
               
            default:
                tx_data = 0;
        endcase
    end

    assign o_write_enable = (state == LOADING_INSTRUCTIONS && bytes_to_load==0 && first_instruction_loaded==1) ? 1 : 0;
    assign o_instruction = work_reg;
    assign o_instruction_mem_write_address = instruction_mem_write_address;

    assign o_enable = (state == CONTINUOUS || state == RUN_STEP) ? 1 : 0;

    assign o_tx_valid = (state == READING_PC || state == READING_REGS || state == READING_MEM) && i_tx_done ? 1 : 0;
    
    assign o_tx_data = tx_data;
    assign o_reg_address = regs_counter;
    assign o_data_mem_read_address = mem_slot_counter;
    
    assign o_state = state;
endmodule