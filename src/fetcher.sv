
import opcode_pkg::*;

module Fetcher
(
    /* Clock and Reset */
    input clk, 
    input reset, 
    /* Fetcher Input */
    input [11:0] pc_in, 
    input fetch_start, 
    input fetch_done_ack, 
    input [3:0] inst_data_in, 
    input [2:0] inst_len,
    /* Fetcher Output */
    output rom_select, 
    output [11:0] pc_out,
    output fetch_done,
    output [15:0] inst_out
);

    enum reg [2:0] {
        IDLE, 
        FETCH_OP_A, 
        FETCH_OP_B,
        FETCH_OP_C, 
        FETCH_OP_D, 
        DONE
    } state;

    opcode_pkg::opcode_t opcode_reg;
    reg [11:0] pc;
    reg [15:0] inst;

    /* Sequential State Control */
    always_ff @( posedge clk ) begin : fetcher_seq
        
        if (reset) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: state <= fetch_start ? FETCH_OP_A : IDLE;
                FETCH_OP_A: state <= FETCH_OP_B;
                FETCH_OP_B: state <= inst_len == 3'd2 ? FETCH_OP_C : DONE;
                FETCH_OP_C: state <= FETCH_OP_D;
                FETCH_OP_D: state <= DONE;
                DONE: state <= fetch_done_ack ? IDLE : DONE;
                default: state <= IDLE;
            endcase
        end

    end

    assign fetch_done = state == DONE ? 1'b1 : 1'b0;

    /* PC Control */
    always_ff @( posedge clk ) begin : pc_ctrl_seq
        if (reset) begin
            pc <= 12'd0;
        end else begin
            case (state)
                IDLE: pc <= fetch_start ? pc_in : pc;
                DONE: pc <= pc;
                default: pc <= pc + 12'b1;
            endcase
        end
    end

    assign pc_out = pc;

    /* Inst Load Sequential */
    always_ff @( posedge clk ) begin : inst_load_seq
        if (reset) begin
            inst <= 16'd0;
        end else begin
            case (state)
                IDLE: inst <= inst;
                DONE: inst <= inst;
                default: inst <= {inst_data_in, inst[15:4]};
            endcase
        end
    end

    assign rom_select = (state == IDLE && state == DONE) ? 1'b0 : 1'b1;
    assign inst_out = inst;

endmodule
