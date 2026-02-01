`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// RTL-V4: Fully Parallel 3×3 Convolution with DSP48 Binding
//-----------------------------------------------------------------------------
// Architecture: 9 parallel DSP48E1 MACs + adder tree, 1 cycle per output
// Target: Maximum throughput, DSP-optimized for power efficiency
// Synthesis: use_dsp = "yes" attribute enforces DSP48 mapping
//-----------------------------------------------------------------------------

module conv2d_unroll9_dsp (
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 valid_in,

    input  wire signed [7:0]    in0, in1, in2,
    input  wire signed [7:0]    in3, in4, in5,
    input  wire signed [7:0]    in6, in7, in8,

    input  wire signed [7:0]    w0, w1, w2,
    input  wire signed [7:0]    w3, w4, w5,
    input  wire signed [7:0]    w6, w7, w8,

    output reg                  valid_out,
    output reg  signed [15:0]   result
);

    // ------------------------------------------------------------
    // DSP-bound multipliers (CRITICAL PART)
    // (* use_dsp = "yes" *) forces Vivado to map to DSP48E1
    // ------------------------------------------------------------

    (* use_dsp = "yes" *) wire signed [15:0] m0 = in0 * w0;
    (* use_dsp = "yes" *) wire signed [15:0] m1 = in1 * w1;
    (* use_dsp = "yes" *) wire signed [15:0] m2 = in2 * w2;

    (* use_dsp = "yes" *) wire signed [15:0] m3 = in3 * w3;
    (* use_dsp = "yes" *) wire signed [15:0] m4 = in4 * w4;
    (* use_dsp = "yes" *) wire signed [15:0] m5 = in5 * w5;

    (* use_dsp = "yes" *) wire signed [15:0] m6 = in6 * w6;
    (* use_dsp = "yes" *) wire signed [15:0] m7 = in7 * w7;
    (* use_dsp = "yes" *) wire signed [15:0] m8 = in8 * w8;

    // ------------------------------------------------------------
    // Adder tree (combinational, uses DSP48 post-adders)
    // ------------------------------------------------------------

    wire signed [17:0] sum0 = m0 + m1 + m2;
    wire signed [17:0] sum1 = m3 + m4 + m5;
    wire signed [17:0] sum2 = m6 + m7 + m8;

    wire signed [18:0] final_sum = sum0 + sum1 + sum2;

    // ------------------------------------------------------------
    // Output register (1-cycle latency)
    // ------------------------------------------------------------

    always @(posedge clk) begin
        if (rst) begin
            result    <= 16'sd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            result    <= final_sum[15:0]; // truncate (as in int CNN)
        end
    end

endmodule
