# RTL Convolution Design-Space Exploration

This directory contains four RTL implementations of 3×3 CNN convolution with varying levels of parallelism and resource binding for design-space exploration.

---

## Architecture Variants

| File | Variant | Parallel MACs | Latency | Architecture |
|------|---------|---------------|---------|--------------|
| `conv2d_serial.v` | RTL-V1 | 1 | 9 cycles | Sequential MAC |
| `conv2d_unroll3.v` | RTL-V2 | 3 | 3 cycles | Partial parallel |
| `conv2d_unroll9.v` | RTL-V3 | 9 | 1 cycle | Fully parallel (LUT) |
| `conv2d_unroll9_dsp.v` | RTL-V4 | 9 | 1 cycle | Fully parallel (DSP48) |

---

## Verified Synthesis Results (Vivado 2024.1 on xc7z020clg400-1)

| Variant | DSPs | LUTs | FFs | Speedup |
|---------|------|------|-----|---------|
| RTL-V1 | 0 | 159 | 38 | 1× |
| RTL-V2 | 0 | 329 | 37 | **3×** |
| RTL-V3 | 0 | 758 | 17 | **9×** |
| **RTL-V4** | **9** | **0** | 1 | **9×** |

> **Key Finding**: V4 achieves same 9× speedup as V3 but with **0 LUTs** by using DSP48E1 blocks.

---

## Common Interface (V1-V3)

```verilog
module conv2d_* (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [7:0]  in0, in1, in2, in3, in4, in5, in6, in7, in8,  // 3×3 input
    input  wire [7:0]  k0,  k1,  k2,  k3,  k4,  k5,  k6,  k7,  k8,   // 3×3 kernel
    output reg  [15:0] out,
    output reg         done
);
```

---

## V4 DSP Interface (Signed)

```verilog
module conv2d_unroll9_dsp (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 valid_in,
    input  wire signed [7:0]    in0, ..., in8,  // Signed inputs
    input  wire signed [7:0]    w0, ..., w8,    // Signed weights
    output reg  signed [15:0]   result,
    output reg                  valid_out
);
```

---

## Testbenches

| File | Tests |
|------|-------|
| `tb_conv2d_serial.v` | RTL-V1 correctness |
| `tb_conv2d_unroll3.v` | RTL-V2 correctness |
| `tb_conv2d_unroll9.v` | RTL-V3 correctness |
| `tb_conv2d_unroll9_dsp.v` | RTL-V4 correctness |

---

## LUT vs DSP Trade-off

| Metric | V3 (LUT) | V4 (DSP) | Winner |
|--------|----------|----------|--------|
| LUTs | 758 | **0** | V4 |
| DSPs | 0 | 9 | V3 |
| Energy/MAC | Higher | **Lower** | V4 |

**Use V4 (DSP)** when LUT budget is tight or power efficiency is critical.

---

## Target Device

- **FPGA**: Xilinx Zynq-7020 (xc7z020clg400-1)
- **DSPs Available**: 220
- **Clock**: 100 MHz (10 ns period)

