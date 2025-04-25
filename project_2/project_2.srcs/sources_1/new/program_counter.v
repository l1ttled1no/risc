`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 02:47:40 AM
// Design Name: 
// Module Name: program_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//    Program Counter (PC) for RISC processor
//    - 5-bit counter for addressing 32 memory locations
//    - Synchronous reset (active HIGH)
//    - Increment control
//    - Load control for jumps
// 
// Dependencies: 
//    parameters.vh for AWIDTH definition
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.vh"

module program_counter(
    input wire clk,                    // Clock input
    input wire rst,                    // Active HIGH reset
    input wire inc_pc,                 // Increment control signal
    input wire ld_pc,                  // Load control signal
    input wire [`AWIDTH-1:0] pc_in,    // New address to load
    output reg [`AWIDTH-1:0] pc_out    // Current PC value
);

    // Sequential logic for PC update
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset - set PC to 0
            pc_out <= {`AWIDTH{1'b0}};
        end
        else if (ld_pc) begin
            // Load new address for jumps
            pc_out <= pc_in;
        end
        else if (inc_pc) begin
            // Increment PC
            pc_out <= pc_out + 1'b1;
        end
        // else maintain current value
    end

endmodule
