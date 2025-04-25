`timescale 1ns / 1ps

module program_counter_tb();

    // Define parameters locally to avoid include file dependency
    localparam AWIDTH = 5;

    // Testbench signals
    reg clk;
    reg rst;
    reg inc_pc;
    reg ld_pc;
    reg [AWIDTH-1:0] pc_in;
    wire [AWIDTH-1:0] pc_out;
    
    // Instantiate the program counter
    program_counter uut (
        .clk(clk),
        .rst(rst),
        .inc_pc(inc_pc),
        .ld_pc(ld_pc),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    // Clock generation (50MHz - 20ns period)
    always begin
        clk = 1'b0;
        #10;  // 10ns delay
        clk = 1'b1;
        #10;  // 10ns delay
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1'b0;
        inc_pc = 1'b0;
        ld_pc = 1'b0;
        pc_in = 0;
        
        // Wait for 100ns for global reset
        #100;
        
        // Test 1: Reset functionality
        $display("Test 1: Testing reset");
        rst = 1'b1;
        #20; // Wait one clock cycle
        rst = 1'b0;
        if (pc_out !== 0) $display("Reset test failed! PC should be 0");
        
        // Test 2: Increment functionality
        $display("Test 2: Testing increment");
        inc_pc = 1'b1;
        #20; // Wait one clock cycle
        if (pc_out !== 1) $display("Increment test failed! PC should be 1");
        #20; // Wait another clock cycle
        if (pc_out !== 2) $display("Increment test failed! PC should be 2");
        inc_pc = 1'b0;
        
        // Test 3: Load functionality
        $display("Test 3: Testing load");
        pc_in = 5'b10101; // Load value 21
        ld_pc = 1'b1;
        #20; // Wait one clock cycle
        if (pc_out !== 5'b10101) $display("Load test failed! PC should be 21");
        ld_pc = 1'b0;
        
        // Test 4: Priority check (Reset over Load)
        $display("Test 4: Testing priority - Reset over Load");
        pc_in = 5'b11111;
        ld_pc = 1'b1;
        rst = 1'b1;
        #20; // Wait one clock cycle
        if (pc_out !== 0) $display("Priority test failed! Reset should override Load");
        rst = 1'b0;
        ld_pc = 1'b0;
        
        // Test 5: Priority check (Load over Increment)
        $display("Test 5: Testing priority - Load over Increment");
        pc_in = 5'b01010; // Load value 10
        inc_pc = 1'b1;
        ld_pc = 1'b1;
        #20; // Wait one clock cycle
        if (pc_out !== 5'b01010) $display("Priority test failed! Load should override Increment");
        
        // Test 6: Hold value when no control signals
        $display("Test 6: Testing hold functionality");
        inc_pc = 1'b0;
        ld_pc = 1'b0;
        #20; // Wait one clock cycle
        if (pc_out !== 5'b01010) $display("Hold test failed! PC should maintain its value");
        
        // End simulation
        #100;
        $display("All tests completed!");
        $finish;
    end

endmodule 