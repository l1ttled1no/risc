// testbench_riscv_simple_processor.v or processor_tb.v
`timescale 1ns / 1ps
`include "parameters.vh" // Ensure this is included

module processor_tb; // Or testbench_riscv_simple_processor if you kept that name

    // Testbench Parameters
    localparam CLK_PERIOD = 2;       // Clock period in ns
    localparam RESET_DURATION = 4;   // Reset duration in ns (2 clock cycles @ 2ns period)
    localparam VERY_LONG_SIM_TIMEOUT = CLK_PERIOD * 500000; // e.g., 1 million ns

    // Testbench Signals
    reg clk;
    reg rst;

    // DUT Outputs
    wire cu_sel_o;
    wire cu_rd_o;
    wire cu_ld_ir_o;
    wire cu_halt_o;
    wire cu_inc_pc_o;
    wire cu_ld_ac_o;
    wire cu_ld_pc_o;
    wire cu_wr_o;
    wire [`AWIDTH-1:0] current_pc_o;
    wire [`DWIDTH-1:0] acc_val_o;
    wire [`DWIDTH-1:0] alu_result_o; // Added based on your TB code
    wire [2:0]         cu_current_state_o;
    wire [`DWIDTH-1:0] current_instruction_o; // Instruction from IR

    // Instantiate the Device Under Test (DUT)
    riscv_simple_processor dut (
        .clk(clk),
        .rst(rst),
        .cu_sel_o(cu_sel_o),
        .cu_rd_o(cu_rd_o),
        .cu_ld_ir_o(cu_ld_ir_o),
        .cu_halt_o(cu_halt_o),
        .cu_inc_pc_o(cu_inc_pc_o),
        .cu_ld_ac_o(cu_ld_ac_o),
        .cu_ld_pc_o(cu_ld_pc_o),
        .cu_wr_o(cu_wr_o),
        .current_pc_o(current_pc_o),
        .acc_val_o(acc_val_o),
        .alu_result_o(alu_result_o), // Connect to alu_result_o
        .cu_current_state_o(cu_current_state_o),
        .current_instruction_o(current_instruction_o)
    );

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset Generation and Simulation Control
    initial begin
        $display("========================================================");
        $display("Starting RISC-V Simple Processor Testbench (Continuous Run) at time %0t", $time);
        $display("Parameters: AWIDTH=%0d, DWIDTH=%0d", `AWIDTH, `DWIDTH);
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Reset Duration: %0d ns", RESET_DURATION);
        $display("========================================================");

        // 1. Apply Reset
        rst = 1'b1;
        $display("[%0t] Asserting Reset...", $time);
        #(RESET_DURATION);
        rst = 1'b0;
        $display("[%0t] De-asserting Reset. Processor running...", $time);

        // 2. Run for a very long time, or until manually stopped.
        // The $finish will now only be triggered by this timeout.
        #(VERY_LONG_SIM_TIMEOUT);

        $display("--------------------------------------------------------");
        $display("[%0t] VERY_LONG_SIM_TIMEOUT reached. Finishing simulation.", $time);
        $display("Current PC: %h (%0d)", current_pc_o, current_pc_o);
        $display("Current ACC: %h (%0d)", acc_val_o, acc_val_o);
        $display("Current ALU Result: %h (%0d)", alu_result_o, alu_result_o);
        $display("Current Instruction (in IR): %h", current_instruction_o);
        $display("Current CU State: %b", cu_current_state_o);
        $display("Halt Signal State: %b", cu_halt_o);
        $display("--------------------------------------------------------");
        $finish;
    end

    // Monitoring
    initial begin
        $monitor("[%0t] PC:%2h IR:%2h{Op:%b Ad:%2d} ACC:%3d ALU_Res:%3h CU_St:%b SEL:%b RD:%b WR:%b LdIR:%b LdAC:%b IncPC:%b LdPC:%b HLT:%b",
                  $time,
                  current_pc_o,
                  current_instruction_o,
                  current_instruction_o[`DWIDTH-1:`DWIDTH-3], // Opcode
                  current_instruction_o[`DWIDTH-4:0],         // Operand Address
                  acc_val_o,
                  alu_result_o, // Added ALU result to monitor
                  cu_current_state_o,
                  cu_sel_o,
                  cu_rd_o,
                  cu_wr_o,
                  cu_ld_ir_o,
                  cu_ld_ac_o,
                  cu_inc_pc_o,
                  cu_ld_pc_o,
                  cu_halt_o);
    end

    // VCD dump
    initial begin
        $dumpfile("riscv_simple_processor_waves.vcd");
        $dumpvars(0, processor_tb);
    end

endmodule