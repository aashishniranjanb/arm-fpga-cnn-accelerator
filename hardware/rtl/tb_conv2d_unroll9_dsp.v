`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Testbench for RTL-V4: DSP-Bound Fully Parallel 3×3 Convolution
//-----------------------------------------------------------------------------
// Verifies: Reset, valid handshake, 1-cycle result, output = 9
//-----------------------------------------------------------------------------

module tb_conv2d_unroll9_dsp;

    // Clock & control
    reg clk;
    reg rst;
    reg valid_in;

    // Inputs (signed 3×3 window and kernel)
    reg signed [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8;
    reg signed [7:0] w0, w1, w2, w3, w4, w5, w6, w7, w8;

    // Outputs
    wire signed [15:0] result;
    wire valid_out;

    // Instantiate DUT
    conv2d_unroll9_dsp dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .in0(in0), .in1(in1), .in2(in2),
        .in3(in3), .in4(in4), .in5(in5),
        .in6(in6), .in7(in7), .in8(in8),
        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),
        .result(result),
        .valid_out(valid_out)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        clk      = 0;
        rst      = 1;
        valid_in = 0;

        // All inputs = 1 (deterministic test pattern)
        in0 = 1; in1 = 1; in2 = 1;
        in3 = 1; in4 = 1; in5 = 1;
        in6 = 1; in7 = 1; in8 = 1;

        w0 = 1; w1 = 1; w2 = 1;
        w3 = 1; w4 = 1; w5 = 1;
        w6 = 1; w7 = 1; w8 = 1;

        // Hold reset for 2 cycles
        #20;
        rst = 0;

        // Assert valid_in for 1 cycle
        #10;
        valid_in = 1;
        #10;
        valid_in = 0;

        // Wait for valid_out
        wait (valid_out == 1);

        // Display results
        $display("============================================");
        $display("RTL-V4 DSP-Bound Convolution Test Results");
        $display("============================================");
        $display("Output value: %d", result);
        
        if (result == 16'sd9)
            $display("STATUS: TEST PASSED");
        else
            $display("STATUS: TEST FAILED (Expected 9)");
        
        $display("============================================");

        #20;
        $finish;
    end

endmodule
