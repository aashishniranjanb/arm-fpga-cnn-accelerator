//-----------------------------------------------------------------------------
// Testbench for RTL-V1: Serial 3×3 Convolution
//-----------------------------------------------------------------------------
// Verifies: Reset, start trigger, 9-cycle MAC, done signal, output = 9
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_conv2d_serial;

    // Clock & control
    reg clk;
    reg rst;
    reg start;

    // Inputs (3×3 window and kernel)
    reg [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8;
    reg [7:0] k0,  k1,  k2,  k3,  k4,  k5,  k6,  k7,  k8;

    // Outputs
    wire [15:0] out;
    wire done;

    // Instantiate DUT
    conv2d_serial dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in0(in0), .in1(in1), .in2(in2),
        .in3(in3), .in4(in4), .in5(in5),
        .in6(in6), .in7(in7), .in8(in8),
        .k0(k0), .k1(k1), .k2(k2),
        .k3(k3), .k4(k4), .k5(k5),
        .k6(k6), .k7(k7), .k8(k8),
        .out(out),
        .done(done)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Cycle counter for analysis
    integer cycle_count;

    // Test sequence
    initial begin
        // Initialize signals
        clk   = 0;
        rst   = 1;
        start = 0;
        cycle_count = 0;

        // All inputs = 1 (deterministic test pattern)
        in0 = 1; in1 = 1; in2 = 1;
        in3 = 1; in4 = 1; in5 = 1;
        in6 = 1; in7 = 1; in8 = 1;

        k0 = 1; k1 = 1; k2 = 1;
        k3 = 1; k4 = 1; k5 = 1;
        k6 = 1; k7 = 1; k8 = 1;

        // Hold reset for 2 cycles
        #20;
        rst = 0;

        // Pulse start for 1 cycle
        #10;
        start = 1;
        #10;
        start = 0;

        // Count cycles until done
        while (done == 0) begin
            #10;
            cycle_count = cycle_count + 1;
        end

        // Display results
        $display("========================================");
        $display("RTL-V1 Serial Convolution Test Results");
        $display("========================================");
        $display("Cycles to complete: %d", cycle_count);
        $display("Output value: %d", out);
        
        if (out == 16'd9)
            $display("STATUS: TEST PASSED");
        else
            $display("STATUS: TEST FAILED (Expected 9)");
        
        $display("========================================");

        #20;
        $finish;
    end

endmodule
