`include "parameters.vh"
module instruction_memory (
    input wire clk,                         // Clock input
    input wire rst,                         // Reset input (active high assumed)
    input wire [`AWIDTH-1:0] addr,          // Address input (from Program Counter)
    input wire rd_en,                       // Read enable (often always true or tied to a fetch cycle signal)
    output reg [`DWIDTH-1:0] instruction_out // Fetched instruction output
);

    // Memory array for instructions
    reg [`DWIDTH-1:0] i_memory [0:(2**`AWIDTH)-1];
    integer i;
    // Initialize instruction memory with a program (for simulation / BRAM initialization)
    initial begin
        // $display("Initializing Instruction Memory at time %0t...", $time);
        // Example program: Instructions are Opcode(bits 7-5) | Operand_Address(bits 4-0)
        // Ensure opcodes match your ALU and controller design.
        // Operand_Address here would refer to an address in the *data_memory*
//        i_memory[0]  = {3'b001, 5'd0};  
//        i_memory[1]  = {3'b010, 5'd0};  
//        i_memory[2]  = {3'b010, 5'd0};  
//        i_memory[3]  = {3'b010, 5'd0};  
//        i_memory[4]  = {3'b110, 5'd1};  
//        i_memory[5]  = {3'b101, 5'd1};  
//        i_memory[6]  = {3'b000, 5'd0};  
//        i_memory[7]  = {3'b000, 5'd0};  
        // ... initialize other instruction locations as needed or to HLT/NOP

        // Initialize remaining instruction memory to a default (e.g., HLT or NOP)
        for ( i = 0; i < (2**`AWIDTH); i = i + 1) begin
            i_memory[i] = {3'b101, i[4:0]};
        end
        
        i_memory[3] = {3'b001, 5'd0};

        // $display("Instruction Memory Initialization Complete.");
    end

    // Synchronous read operation
    always @(posedge clk) begin
        if (rst) begin
            instruction_out <= {`DWIDTH{1'b0}}; // Reset output
        end else begin
            if (rd_en) begin // Read enable for instruction fetch
                instruction_out <= i_memory[addr];
                // $display("INST_MEM READ @%0t: addr=%h, inst_out_next_cycle_will_be=%h", $time, addr, i_memory[addr]);
            end
            // If not rd_en, instruction_out holds its value
        end
    end

endmodule