`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// AXI4-Lite Wrapper for DSP-Accelerated CNN Convolution
//-----------------------------------------------------------------------------
// Purpose: Enables ARM CPU control of CNN accelerator via memory-mapped I/O
// Interface: AXI4-Lite slave (32-bit data, 6-bit address)
// Accelerator: conv2d_unroll9_dsp (9 DSP48E1, 1-cycle latency)
//-----------------------------------------------------------------------------
// Register Map:
//   0x00 - CTRL: bit[0]=start, bit[1]=done (read-only)
//   0x04-0x24 - IN0-IN8: Input pixels (signed 8-bit)
//   0x28-0x48 - W0-W8: Kernel weights (signed 8-bit)
//   0x4C - OUT: Convolution result (signed 16-bit)
//-----------------------------------------------------------------------------

module conv2d_axi_lite #
(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 7
)
(
    // AXI4-Lite Clock and Reset
    input wire  S_AXI_ACLK,
    input wire  S_AXI_ARESETN,

    // AXI4-Lite Write Address Channel
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input wire S_AXI_AWVALID,
    output reg  S_AXI_AWREADY,

    // AXI4-Lite Write Data Channel
    input wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input wire S_AXI_WVALID,
    output reg  S_AXI_WREADY,

    // AXI4-Lite Write Response Channel
    output reg  [1:0] S_AXI_BRESP,
    output reg  S_AXI_BVALID,
    input wire  S_AXI_BREADY,

    // AXI4-Lite Read Address Channel
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input wire S_AXI_ARVALID,
    output reg  S_AXI_ARREADY,

    // AXI4-Lite Read Data Channel
    output reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input wire  S_AXI_RREADY
);

    // ------------------------------------------------------------
    // Internal registers for accelerator control
    // ------------------------------------------------------------

    reg start;
    wire done;

    reg signed [7:0] in [0:8];
    reg signed [7:0] w  [0:8];
    wire signed [15:0] result;

    // ------------------------------------------------------------
    // AXI Write Handling
    // ------------------------------------------------------------

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            S_AXI_BVALID  <= 0;
            start <= 0;
        end else begin
            S_AXI_AWREADY <= S_AXI_AWVALID;
            S_AXI_WREADY  <= S_AXI_WVALID;

            if (S_AXI_AWVALID && S_AXI_WVALID) begin
                case (S_AXI_AWADDR[6:0])
                    7'h00: start <= S_AXI_WDATA[0];

                    // Input pixels (0x04 - 0x24)
                    7'h04: in[0] <= S_AXI_WDATA[7:0];
                    7'h08: in[1] <= S_AXI_WDATA[7:0];
                    7'h0C: in[2] <= S_AXI_WDATA[7:0];
                    7'h10: in[3] <= S_AXI_WDATA[7:0];
                    7'h14: in[4] <= S_AXI_WDATA[7:0];
                    7'h18: in[5] <= S_AXI_WDATA[7:0];
                    7'h1C: in[6] <= S_AXI_WDATA[7:0];
                    7'h20: in[7] <= S_AXI_WDATA[7:0];
                    7'h24: in[8] <= S_AXI_WDATA[7:0];

                    // Kernel weights (0x28 - 0x48)
                    7'h28: w[0] <= S_AXI_WDATA[7:0];
                    7'h2C: w[1] <= S_AXI_WDATA[7:0];
                    7'h30: w[2] <= S_AXI_WDATA[7:0];
                    7'h34: w[3] <= S_AXI_WDATA[7:0];
                    7'h38: w[4] <= S_AXI_WDATA[7:0];
                    7'h3C: w[5] <= S_AXI_WDATA[7:0];
                    7'h40: w[6] <= S_AXI_WDATA[7:0];
                    7'h44: w[7] <= S_AXI_WDATA[7:0];
                    7'h48: w[8] <= S_AXI_WDATA[7:0];
                endcase

                S_AXI_BVALID <= 1;
                S_AXI_BRESP  <= 2'b00; // OKAY
            end

            if (S_AXI_BREADY && S_AXI_BVALID)
                S_AXI_BVALID <= 0;
        end
    end

    // ------------------------------------------------------------
    // AXI Read Handling
    // ------------------------------------------------------------

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            S_AXI_ARREADY <= 0;
            S_AXI_RVALID  <= 0;
            S_AXI_RDATA   <= 0;
        end else begin
            S_AXI_ARREADY <= S_AXI_ARVALID;

            if (S_AXI_ARVALID) begin
                case (S_AXI_ARADDR[6:0])
                    7'h00: S_AXI_RDATA <= {30'd0, done, start};
                    7'h4C: S_AXI_RDATA <= {{16{result[15]}}, result}; // Sign-extend
                    default: S_AXI_RDATA <= 32'd0;
                endcase

                S_AXI_RVALID <= 1;
                S_AXI_RRESP  <= 2'b00; // OKAY
            end

            if (S_AXI_RREADY && S_AXI_RVALID)
                S_AXI_RVALID <= 0;
        end
    end

    // ------------------------------------------------------------
    // CNN Accelerator Instance (DSP-bound)
    // ------------------------------------------------------------

    conv2d_unroll9_dsp u_accel (
        .clk       (S_AXI_ACLK),
        .rst       (!S_AXI_ARESETN),
        .valid_in  (start),

        .in0(in[0]), .in1(in[1]), .in2(in[2]),
        .in3(in[3]), .in4(in[4]), .in5(in[5]),
        .in6(in[6]), .in7(in[7]), .in8(in[8]),

        .w0(w[0]), .w1(w[1]), .w2(w[2]),
        .w3(w[3]), .w4(w[4]), .w5(w[5]),
        .w6(w[6]), .w7(w[7]), .w8(w[8]),

        .valid_out (done),
        .result    (result)
    );

endmodule
