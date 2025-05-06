`timescale 1ns / 1ps

module alu_tb;

    // Inputs to ALU (DUT)
    reg [7:0] tb_inA;
    reg [7:0] tb_inB;
    reg [2:0] tb_opcode;

    // Outputs from ALU (DUT)
    wire [7:0] tb_result;
    wire       tb_is_zero;

    // Instantiate the Device Under Test (DUT)
    alu dut (
        .inA(tb_inA),
        .inB(tb_inB),
        .opcode(tb_opcode),
        .result(tb_result),
        .is_zero(tb_is_zero)
    );

    // Test sequence
    initial begin
        $display("---------------------------------------------------------");
        $display("Starting ALU Testbench");
        $display("Time\tinA\tinB\tOp\tResult\tis_zero (expected_is_zero_based_on_inA)");
        $display("---------------------------------------------------------");

        // Test HLT (000): result = inA
        tb_opcode = 3'b000;
        tb_inA = 8'hAA; tb_inB = 8'h55; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'h11; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test SKZ (001): result = inA
        tb_opcode = 3'b001;
        tb_inA = 8'hBB; tb_inB = 8'hCC; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'hDD; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test ADD (010): result = inA + inB
        tb_opcode = 3'b010;
        tb_inA = 8'd10; tb_inB = 8'd20; #10; // 10 + 20 = 30
        $display("%0t\t%d\t%d\t%b\t%d\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'd250; tb_inB = 8'd10; #10; // 250 + 10 = 260 -> 4 (overflow)
        $display("%0t\t%d\t%d\t%b\t%d\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'd0; tb_inB = 8'd5; #10; // 0 + 5 = 5
        $display("%0t\t%d\t%d\t%b\t%d\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test AND (011): result = inA & inB
        tb_opcode = 3'b011;
        tb_inA = 8'b11001100; tb_inB = 8'b10101010; #10; // Expected: 10001000
        $display("%0t\t%b\t%b\t%b\t%b\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'hFF; #10; // Expected: 00000000
        $display("%0t\t%b\t%b\t%b\t%b\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test XOR (100): result = inA ^ inB
        tb_opcode = 3'b100;
        tb_inA = 8'b11001100; tb_inB = 8'b10101010; #10; // Expected: 01100110
        $display("%0t\t%b\t%b\t%b\t%b\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'hF0; tb_inB = 8'hF0; #10; // Expected: 00000000
        $display("%0t\t%b\t%b\t%b\t%b\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test LDA (101): result = inB
        tb_opcode = 3'b101;
        tb_inA = 8'h12; tb_inB = 8'h34; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'h56; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test STO (110): result = inA
        tb_opcode = 3'b110;
        tb_inA = 8'h78; tb_inB = 8'h9A; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'hBC; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        // Test JMP (111): result = inA
        tb_opcode = 3'b111;
        tb_inA = 8'hDE; tb_inB = 8'hF0; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));
        tb_inA = 8'h00; tb_inB = 8'h01; #10;
        $display("%0t\t%h\t%h\t%b\t%h\t%b (%b)", $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero, (tb_inA == 0));

        $display("---------------------------------------------------------");
        $display("ALU Testbench Finished");
        $display("---------------------------------------------------------");
        #10 $finish; // End simulation
    end

    // Optional: Monitor changes
    // initial begin
    //     $monitor("Time=%0t inA=%h, inB=%h, opcode=%b => result=%h, is_zero=%b",
    //              $time, tb_inA, tb_inB, tb_opcode, tb_result, tb_is_zero);
    // end

endmodule