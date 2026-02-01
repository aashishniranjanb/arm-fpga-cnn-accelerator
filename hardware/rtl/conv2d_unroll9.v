//-----------------------------------------------------------------------------
// RTL-V3: Fully Parallel 3×3 Convolution (Unroll Factor = 9)
//-----------------------------------------------------------------------------
// Architecture: 9 parallel MAC units + adder tree, 1 cycle per output
// Target: Maximum throughput, highest area usage
//-----------------------------------------------------------------------------

module conv2d_unroll9 (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    // 3×3 input window (flattened)
    input  wire [7:0]  in0, in1, in2, in3, in4, in5, in6, in7, in8,
    
    // 3×3 kernel weights (flattened)
    input  wire [7:0]  k0,  k1,  k2,  k3,  k4,  k5,  k6,  k7,  k8,

    // Output and control
    output reg  [15:0] out,
    output reg         done
);

    // 9 parallel multipliers (combinational)
    wire [15:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;

    assign p0 = in0 * k0;
    assign p1 = in1 * k1;
    assign p2 = in2 * k2;
    assign p3 = in3 * k3;
    assign p4 = in4 * k4;
    assign p5 = in5 * k5;
    assign p6 = in6 * k6;
    assign p7 = in7 * k7;
    assign p8 = in8 * k8;

    // Adder tree (balanced for timing)
    // Level 1: 9 inputs → 5 partial sums
    wire [15:0] sum01, sum23, sum45, sum67;
    assign sum01 = p0 + p1;
    assign sum23 = p2 + p3;
    assign sum45 = p4 + p5;
    assign sum67 = p6 + p7;

    // Level 2: 5 inputs → 3 partial sums
    wire [15:0] sum0123, sum4567;
    assign sum0123 = sum01 + sum23;
    assign sum4567 = sum45 + sum67;

    // Level 3: Final sum
    wire [15:0] sum_all;
    assign sum_all = sum0123 + sum4567 + p8;

    // Output register (single-cycle operation)
    always @(posedge clk) begin
        if (rst) begin
            out  <= 0;
            done <= 0;
        end else begin
            if (start) begin
                out  <= sum_all;
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end

endmodule
