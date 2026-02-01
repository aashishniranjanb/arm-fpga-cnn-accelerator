//-----------------------------------------------------------------------------
// RTL-V1: Serial 3×3 Convolution (Unroll Factor = 1)
//-----------------------------------------------------------------------------
// Architecture: 1 MAC unit, 9 cycles per output
// Target: Minimum area baseline for DSE comparison
//-----------------------------------------------------------------------------

module conv2d_serial (
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
    reg [3:0] cycle;     // 0-9 counter
    reg [15:0] acc;      // Accumulator
    reg running;         // Operation in progress

    // Input/kernel multiplexing based on cycle
    reg [7:0] mux_in;
    reg [7:0] mux_k;

    // Multiplexer for serial access
    always @(*) begin
        case (cycle)
            4'd0: begin mux_in = in0; mux_k = k0; end
            4'd1: begin mux_in = in1; mux_k = k1; end
            4'd2: begin mux_in = in2; mux_k = k2; end
            4'd3: begin mux_in = in3; mux_k = k3; end
            4'd4: begin mux_in = in4; mux_k = k4; end
            4'd5: begin mux_in = in5; mux_k = k5; end
            4'd6: begin mux_in = in6; mux_k = k6; end
            4'd7: begin mux_in = in7; mux_k = k7; end
            4'd8: begin mux_in = in8; mux_k = k8; end
            default: begin mux_in = 0; mux_k = 0; end
        endcase
    end

    // Sequential MAC logic
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
                if (cycle < 4'd9) begin
                    // MAC operation
                    acc   <= acc + (mux_in * mux_k);
                    cycle <= cycle + 1;
                end
                
                if (cycle == 4'd8) begin
                    // Complete after 9 MACs
                    out     <= acc + (mux_in * mux_k);
                    done    <= 1;
                    running <= 0;
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule
