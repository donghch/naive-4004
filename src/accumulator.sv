module Accumulator
(
    /* Clock and Reset */
    input clock, 
    input reset, 
    /* Input */
    input [3:0] data_in, 
    input write_enable,
    input inc, 
    input select,
    /* Output */
    output [3:0] out
);


    reg [3:0] acc_reg;

    always_ff @(posedge clock) begin
        
        acc_reg <= acc_reg + (inc ? 1 : 0);

        if (reset) begin
            acc_reg <= 4'b0;
        end else if (write_enable) begin
            acc_reg <= data_in;
        end

    end

    assign out = select ? acc_reg : 4'bz;


endmodule