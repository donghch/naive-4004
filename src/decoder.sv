import accumulator_optype::*; // Import the accumulator operation type
import opcode_pkg::*; // Import the opcode package

module Decoder
(
    /* Input Signals */
    input opcode_pkg::opcode_t op, 
    /* Output Signals */
    output [2:0] inst_len,
    // accumulator
    output accumulator_select, 
    output accumulator_optype::acu_op_t accumulator_opcode
);

    reg [2:0] inst_len_reg;

    /* Opcode to Instruction Length Mapping */
    always_comb begin

        inst_len_reg = 3'd1;

        case (op)
            // 1 word
            NOP, SRC, FIN, JIN, INC, ADD, SUB, XCH, BBL,
            CLB, CLB_NOP, CLB_CLB, CLB_IAC, CLB_CMC, CLB_CMA, CLB_RAL, CLB_RAR, CLB_TCC, CLB_DAC, CLB_STC, CLB_DAA, CLB_TCS,
            WRM, WRR, WR0, WR1, WR2, WR3, SBM, RDM, ADM, SB0, SB1, SB2, SB3, ADM0, ADM1, ADM2: begin
                inst_len_reg = 3'd1;
            end
            // 2 words
            JCN, FIM, JUN, JMS, ISZ, LDM: begin
                inst_len_reg = 3'd2;
            end
            default: begin
                inst_len_reg = 3'd1;
            end
        endcase

    end
    assign inst_len = inst_len_reg;

endmodule