
import accumulator_optype::*;

module Accumulator
(
    /* Clock and Reset */
    input clock, 
    input reset, 
    /* Input */
    input select,
    input [3:0] data_in, 
    input accumulator_optype::acu_op_t opcode,
    /* Output */
    output [3:0] out, 
    output reg carry, 
    output reg borrow
);


    reg [3:0] acc_reg;

    // next value
    reg [3:0] next_val;
    reg next_carry;
    reg next_borrow;
    always_comb begin

        next_val = acc_reg;
        next_carry = carry;
        next_borrow = borrow;

        case (opcode)
            accumulator_optype::INC: begin
                next_val = acc_reg + 4'b1;
                next_carry = acc_reg[3] & ~next_val[3];
            end
            accumulator_optype::DEC: begin
                next_val = acc_reg - 4'b1;
                next_borrow = ~acc_reg[3] & next_val[3];
            end
            accumulator_optype::ROT_LEFT: begin
                next_val = {acc_reg[2:0], acc_reg[3]};
            end
            accumulator_optype::ROT_RIGHT: begin
                next_val = {acc_reg[0], acc_reg[3:1]};
            end
            accumulator_optype::WRITE: begin
                next_val = data_in;
            end
        endcase
    end

    always_ff @(posedge clock) begin

        if (reset) begin
            acc_reg <= 4'b0;
            carry <= 0;
            borrow <= 0;
        end else begin
            acc_reg <= select ? next_val : acc_reg;
            carry <= select ? next_carry : carry;
            borrow <= select ? next_borrow : borrow;
        end

    end

    assign out = select ? acc_reg : 4'bz;


endmodule