`include "parameters.vh"

module accumulator_register (
    input wire clk,                            // Clock input
    input wire rst,                            // Active HIGH reset
    input wire ld_ac,                          // Load control signal for ACC
    input wire [`DWIDTH-1:0] acc_in,       // Data input to ACC (from ALU result or data memory)
    output reg [`DWIDTH-1:0] acc_out       // Stored accumulator value output
);

    // Sequential logic for ACC update
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset - clear ACC
            acc_out <= {`DWIDTH{1'b0}};
        end
        else if (ld_ac) begin
            // Load new value into ACC
            acc_out <= acc_in;
        end
        // else maintain current value
    end

endmodule