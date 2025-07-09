`timescale 1ps/1ps

import opcode_pkg::*;

module Fetcher_tb();

    // Inputs
    reg clk;
    reg reset;
    reg [11:0] pc_in;
    reg fetch_start;
    reg fetch_done_ack;
    reg [3:0] inst_data_in;
    reg [2:0] inst_len;

    // Outputs
    wire rom_select;
    wire [11:0] pc_out;
    wire fetch_done;
    wire [15:0] inst_out;

    // Instantiate Fetcher
    Fetcher uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .fetch_start(fetch_start),
        .fetch_done_ack(fetch_done_ack),
        .inst_data_in(inst_data_in),
        .inst_len(inst_len),
        .rom_select(rom_select),
        .pc_out(pc_out),
        .fetch_done(fetch_done),
        .inst_out(inst_out)
    );

    // clk signal
    initial begin
        clk = 1'b0;
        forever #10000 clk = ~clk;
    end


    // setup other signals
    initial begin
        reset = 1'b0;
        pc_in = 12'h0;
        fetch_start = 1'b0;
        fetch_done_ack = 1'b0;
        inst_data_in = 4'b0;
        inst_len = 3'd1; // one word instruction
    end

    task automatic check_signal(input string signal_name, input logic [31:0] actual, input logic [31:0] expected);
        begin
            if (actual !== expected) begin
                $display("[FAIL] %s: Expected = %h, Actual = %h", signal_name, expected, actual);
            end else begin
                $display("[PASS] %s: Value = %h", signal_name, actual);
            end
        end
    endtask

    // Unit test: one word instruction fetching (task block)
    task automatic one_word_fetch_test(input [7:0] inst_data);
        begin
            // reset
            @(negedge clk)
            reset = 1'b1;
            @(negedge clk);
            reset = 1'b0;
            @(negedge clk);

            // setup fetch
            pc_in = 12'hdea;
            fetch_start = 1'b1;
            check_signal("rom_select", rom_select, 1'b0);
            @(negedge clk);
            fetch_start = 1'b0;

            // fetch first 4 bits
            inst_data_in = inst_data[7:4];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'hdea);
            @(negedge clk);

            // fetch 2nd 4 bits
            inst_data_in = inst_data[3:0];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'hdeb);
            @(negedge clk);


            // now the fetch should be done
            check_signal("fetch_done", fetch_done, 1'b1);

            $display("[TEST] Fetch done. inst_out = %h, pc_out = %h", inst_out, pc_out);
            // Check result
            if (inst_out[15:8] == inst_data) begin
                $display("[PASS] One word instruction fetch test passed.");
            end else begin
                $display("[FAIL] One word instruction fetch test failed. inst_out = %h, pc_out = %h", inst_out, pc_out);
            end

            // Acknowledge fetch done
            fetch_done_ack = 1'b1;
            @(negedge clk);
            check_signal("fetch_done", fetch_done, 1'b0);
            fetch_done_ack = 1'b0;
        end
    endtask

 
    // Unit test: two word instruction fetching (task block)
    task automatic two_word_fetch_test(input [7:0] inst_data_hi, input [7:0] inst_data_lo);
        begin
            // reset
            @(negedge clk)
            reset = 1'b1;
            @(negedge clk);
            reset = 1'b0;
            @(negedge clk);

            // setup fetch
            pc_in = 12'habc;
            inst_len = 3'd2; // two word instruction
            fetch_start = 1'b1;
            check_signal("rom_select", rom_select, 1'b0);
            @(negedge clk);
            fetch_start = 1'b0;

            // fetch first 4 bits (high byte)
            inst_data_in = inst_data_hi[7:4];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'habc);
            @(negedge clk);

            // fetch 2nd 4 bits (high byte)
            inst_data_in = inst_data_hi[3:0];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'habd);
            @(negedge clk);

            // fetch 3rd 4 bits (low byte)
            inst_data_in = inst_data_lo[7:4];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'habe);
            @(negedge clk);

            // fetch 4th 4 bits (low byte)
            inst_data_in = inst_data_lo[3:0];
            check_signal("rom_select", rom_select, 1'b1);
            check_signal("pc_out", pc_out, 12'habf);
            @(negedge clk);

            // now the fetch should be done
            check_signal("fetch_done", fetch_done, 1'b1);

            $display("[TEST] Fetch done. inst_out = %h, pc_out = %h", inst_out, pc_out);
            // Check result
            if (inst_out[15:8] == inst_data_hi && inst_out[7:0] == inst_data_lo) begin
                $display("[PASS] Two word instruction fetch test passed.");
            end else begin
                $display("[FAIL] Two word instruction fetch test failed. inst_out = %h, pc_out = %h", inst_out, pc_out);
            end

            // Acknowledge fetch done
            fetch_done_ack = 1'b1;
            @(negedge clk);
            check_signal("fetch_done", fetch_done, 1'b0);
            fetch_done_ack = 1'b0;
        end
    endtask

    // Call the test tasks
    initial begin
        one_word_fetch_test(8'hA5); // example: 0xA5
        two_word_fetch_test(8'h3C, 8'h7E); // example: 0x3C7E
    end

    
endmodule