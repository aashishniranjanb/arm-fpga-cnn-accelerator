//-----------------------------------------------------------------------------
// RTL-V2: Partial Parallel 3×3 Convolution (Unroll Factor = 3)
//-----------------------------------------------------------------------------
// Architecture: 3 parallel MAC units, 3 cycles per output
// Target: Balanced performance/area trade-off (sweet spot design)
//-----------------------------------------------------------------------------

module conv2d_unroll3 (
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

    // FSM state
    reg [1:0] cycle;     // 0,1,2 counter
    reg [15:0] acc;      // Accumulator
    reg running;         // Operation in progress

    // 3 parallel multipliers (wires for combinational products)
    wire [15:0] mac0, mac1, mac2;

    // Cycle 0: Process pixels 0,1,2
    // Cycle 1: Process pixels 3,4,5
    // Cycle 2: Process pixels 6,7,8
    
    reg [7:0] sel_in0, sel_in1, sel_in2;
    reg [7:0] sel_k0,  sel_k1,  sel_k2;

    // Input selection multiplexer
    always @(*) begin
        case (cycle)
            2'd0: begin
                sel_in0 = in0; sel_in1 = in1; sel_in2 = in2;
                sel_k0  = k0;  sel_k1  = k1;  sel_k2  = k2;
            end
            2'd1: begin
                sel_in0 = in3; sel_in1 = in4; sel_in2 = in5;
                sel_k0  = k3;  sel_k1  = k4;  sel_k2  = k5;
            end
            2'd2: begin
                sel_in0 = in6; sel_in1 = in7; sel_in2 = in8;
                sel_k0  = k6;  sel_k1  = k7;  sel_k2  = k8;
            end
            default: begin
                sel_in0 = 0; sel_in1 = 0; sel_in2 = 0;
                sel_k0  = 0; sel_k1  = 0; sel_k2  = 0;
            end
        endcase
    end

    // 3 parallel MAC units
    assign mac0 = sel_in0 * sel_k0;
    assign mac1 = sel_in1 * sel_k1;
    assign mac2 = sel_in2 * sel_k2;

    // Sequential accumulation logic
    always @(posedge clk) begin
        if (rst) begin
            cycle   <= 0;
            acc     <= 0;
            out     <= 0;
            done    <= 0;
            running <= 0;
        end else begin
            if (start && !running) begin
                // Start new computation
                cycle   <= 0;
                acc     <= 0;
                done    <= 0;
                running <= 1;
            end else if (running) begin
                case (cycle)
                    2'd0: begin
                        acc   <= mac0 + mac1 + mac2;
                        cycle <= 2'd1;
                    end
                    2'd1: begin
                        acc   <= acc + mac0 + mac1 + mac2;
                        cycle <= 2'd2;
                    end
                    2'd2: begin
                        out     <= acc + mac0 + mac1 + mac2;
                        done    <= 1;
                        running <= 0;
                        cycle   <= 2'd0;
                    end
                endcase
            end else begin
                done <= 0;
            end
        end
    end

endmodule
