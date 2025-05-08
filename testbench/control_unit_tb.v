`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2025 16:39:25
// Design Name: 
// Module Name: controlunit_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Code your testbench here
// or browse Examples

module controlunit_tb;

    reg clk, rst;
    reg [2:0] opcode;
    reg is_zero;

    wire sel;
    wire rd;
    wire ld_ir;
    wire halt;
    wire inc_pc;
    wire ld_ac;
    wire ld_pc;
    wire wr;
    wire data_e;
    wire [2:0] current_state;

    // Instantiate the Design Under Test (DUT)
    control_unit dut (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .is_zero(is_zero),
        .sel(sel),
        .rd(rd),
        .ld_ir(ld_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .ld_ac(ld_ac),
        .ld_pc(ld_pc),
        .wr(wr),
        .data_e(data_e),
        .current_state(current_state)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
      $dumpfile("dump.vcd"); 
      $dumpvars(1, controlunit_tb); 
        // Initialize inputs
        clk = 0;
        rst = 1;
        opcode = 3'b000;
        is_zero = 0;

        #10; // Wait for reset
        rst = 0;

        // Loop through all opcode values
        repeat (8) begin
            opcode = opcode + 1;
            is_zero = ~is_zero; // Toggle zero flag to test both states
            #80; // Wait to observe outputs
        end

        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\tOpcode\tis_zero\tsel\trd\tld_ir\thalt\tinc_pc\tld_ac\tld_pc\twr\tdata_e");
        $monitor("%0dns\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
            $time, opcode, is_zero, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
    end

endmodule

