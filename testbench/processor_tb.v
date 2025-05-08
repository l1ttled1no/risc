// testbench_riscv_simple_processor.v or processor_tb.v
`timescale 1ns / 1ps
`include "parameters.vh" // Ensure this is included

module processor_tb; // Or testbench_riscv_simple_processor if you kept that name

    // Testbench Parameters
    localparam CLK_PERIOD = 10;       // Clock period in ns
    localparam RESET_DURATION = 20;   // Reset duration in ns (2 clock cycles)
    localparam SIMULATION_TIMEOUT = CLK_PERIOD * 800; // Increased timeout for 32 LDAs + HLT
                                                      // 32 LDAs * 8 cycles = 256
                                                      // 1 HLT * 8 cycles = 8
                                                      // Total ~264 cycles. 800 should be very safe.

    // Testbench Signals
    reg clk;
    reg rst;

    // DUT Outputs
    wire cu_sel_o;      // NEW
    wire cu_rd_o;       // NEW
    wire cu_ld_ir_o;    // NEW
    wire cu_halt_o;
    wire cu_inc_pc_o;   // NEW
    wire cu_ld_ac_o;    // NEW
    wire cu_ld_pc_o;    // NEW
    wire cu_wr_o;       // NEW
    wire [`AWIDTH-1:0] current_pc_o;
    wire [`DWIDTH-1:0] acc_val_o;
    wire [2:0]         cu_current_state_o;
    wire [`DWIDTH-1:0] current_instruction_o; // Instruction from IR

    // Instantiate the Device Under Test (DUT)
    riscv_simple_processor dut (
        .clk(clk),
        .rst(rst),
        // Connect to new DUT outputs
        .cu_sel_o(cu_sel_o),
        .cu_rd_o(cu_rd_o),
        .cu_ld_ir_o(cu_ld_ir_o),
        .cu_halt_o(cu_halt_o),
        .cu_inc_pc_o(cu_inc_pc_o),
        .cu_ld_ac_o(cu_ld_ac_o),
        .cu_ld_pc_o(cu_ld_pc_o),
        .cu_wr_o(cu_wr_o),
        // Original outputs
        .current_pc_o(current_pc_o),
        .acc_val_o(acc_val_o),
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
        $display("Starting RISC-V Simple Processor Testbench at time %0t", $time);
        $display("Parameters: AWIDTH=%0d, DWIDTH=%0d", `AWIDTH, `DWIDTH);
        $display("Expected LDA Opcode: %b (Decimal %0d)", `LDA, `LDA);
        $display("========================================================");

        // 1. Apply Reset
        rst = 1'b1;
        $display("[%0t] Asserting Reset...", $time);
        #(RESET_DURATION);
        rst = 1'b0;
        $display("[%0t] De-asserting Reset. Processor should start fetching.", $time);

        // 2. Wait for HALT or Timeout
        wait (cu_halt_o === 1'b1 || $time >= SIMULATION_TIMEOUT);

        if (cu_halt_o === 1'b1) begin
            #(CLK_PERIOD*2); // Wait a couple more cycles for signals to settle and display
            $display("--------------------------------------------------------");
            $display("[%0t] SUCCESS: Processor Halted as expected.", $time);
            $display("Final PC: %h (%0d)", current_pc_o, current_pc_o);
            $display("Final ACC: %h (%0d)", acc_val_o, acc_val_o);
            $display("Final Instruction (in IR): %h", current_instruction_o);
            $display("Final CU State: %b", cu_current_state_o);
            $display("--------------------------------------------------------");
        end else if ($time >= SIMULATION_TIMEOUT) begin
            $display("--------------------------------------------------------");
            $error("[%0t] TIMEOUT: Processor did not HALT within %0d ns.", $time, SIMULATION_TIMEOUT);
            $display("Current PC: %h (%0d)", current_pc_o, current_pc_o);
            $display("Current ACC: %h (%0d)", acc_val_o, acc_val_o);
            $display("Current Instruction (in IR): %h", current_instruction_o);
            $display("Current CU State: %b", cu_current_state_o);
            $display("--------------------------------------------------------");
        end
        $finish;
    end

    // Monitoring (Optional, but very useful for debugging)
    // This monitor will print values whenever any of the listed signals change.
    initial begin
        // Using a more compact monitor, or you can make it wider
        $monitor("[%0t] PC:%2h IR:%2h{Op:%b Ad:%2d} ACC:%3d CU_St:%b SEL:%b RD:%b WR:%b LdIR:%b LdAC:%b IncPC:%b LdPC:%b HLT:%b",
                  $time,
                  current_pc_o,
                  current_instruction_o,
                  current_instruction_o[`DWIDTH-1:`DWIDTH-3], // Opcode
                  current_instruction_o[`DWIDTH-4:0],         // Operand Address
                  acc_val_o, // Display ACC as decimal for easier checking with LDA test
                  cu_current_state_o,
                  // New control signals
                  cu_sel_o,
                  cu_rd_o,
                  cu_wr_o,
                  cu_ld_ir_o,
                  cu_ld_ac_o,
                  cu_inc_pc_o,
                  cu_ld_pc_o,
                  // Halt
                  cu_halt_o);
    end

    // You can also dump waves for detailed debugging with a waveform viewer
    initial begin
        $dumpfile("riscv_simple_processor_waves.vcd");
        $dumpvars(0, processor_tb); // Or testbench_riscv_simple_processor
    end

endmodule