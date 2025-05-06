`include "parameters.vh"
module instruction_register (
    input wire clk,                         // Clock input
    input wire rst,                         // Active HIGH reset
    input wire ld_ir,                       // Load control signal for IR
    input wire [`DWIDTH-1:0] instruction_in, // Instruction input (from instruction memory)
    output reg [`DWIDTH-1:0] ir_out          // Stored instruction output
);

    // Sequential logic for IR update
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset - clear IR (or set to a NOP/HLT if preferred)
            ir_out <= {`DWIDTH{1'b0}};
        end
        else if (ld_ir) begin
            // Load new instruction
            ir_out <= instruction_in;
        end
        // else maintain current value (instruction is held until next load)
    end

endmodule