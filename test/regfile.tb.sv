`timescale 1ps/1ps

module RegFile_tb();

    /* Setup Signals */
    reg clock, reset;
    reg [3:0] addr, data_in;
    reg write_enable, select;
    wire [3:0] data_out;
    integer i;

    /* Instantiate the RegFile */
    RegFile regfile_inst
    (
        .clock(clock),
        .addr(addr),
        .data_in(data_in),
        .write_enable(write_enable),
        .select(select),
        .data_out(data_out)
    );

    /* Clock Generation */
    initial begin
        clock = 0;
        forever begin
            #10000 clock = ~clock; // 10000 ps clock period
        end
    end



    // Individual task for exhaustive register file test
    task automatic regfile_exhaustive_rw_test;
        begin
            // Write unique values to all registers
            for (i = 0; i < 16; i = i + 1) begin
                @(negedge clock);
                addr = i[3:0];
                data_in = i[3:0];
                write_enable = 1;
                select = 1;
                @(negedge clock);
                write_enable = 0;
                select = 0;
            end
            // Read and check all registers
            for (i = 0; i < 16; i = i + 1) begin
                @(negedge clock);
                addr = i[3:0];
                select = 1;
                @(negedge clock);
                if (data_out !== i[3:0]) begin
                    $display("[FAIL] Reg[%0d] expected %0h, got %0h", i, i[3:0], data_out);
                end else begin
                    $display("[PASS] Reg[%0d] = %0h", i, data_out);
                end
            end
            select = 0;
        end
    endtask

    initial begin
        write_enable = 0;
        select = 0;
        $display("Start register file testbench");
        regfile_exhaustive_rw_test();
        $display("Finish register file testbench");
        $stop;
    end
    
endmodule