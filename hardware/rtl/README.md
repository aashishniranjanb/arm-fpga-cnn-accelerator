# RTL Convolution Design-Space Exploration

This directory contains three RTL implementations of 3×3 CNN convolution with varying levels of parallelism for design-space exploration.

---

## Architecture Variants

| File | Variant | Parallel MACs | Latency | Architecture |
|------|---------|---------------|---------|--------------|
| `conv2d_serial.v` | RTL-V1 | 1 | 9 cycles | Sequential MAC |
| `conv2d_unroll3.v` | RTL-V2 | 3 | 3 cycles | Partial parallel |
| `conv2d_unroll9.v` | RTL-V3 | 9 | 1 cycle | Fully parallel + adder tree |

---

## Common Interface

All variants share the same interface for fair comparison:

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

## Test Dataset

All simulations use the same deterministic test pattern:

- **Input values**: All ones (1)
- **Kernel values**: All ones (1)
- **Expected output**: 9

This ensures correctness verification across all variants.

---

## Testbenches

| File | Tests |
|------|-------|
| `tb_conv2d_serial.v` | RTL-V1 correctness |
| `tb_conv2d_unroll3.v` | RTL-V2 correctness |
| `tb_conv2d_unroll9.v` | RTL-V3 correctness |

---

## Vivado Simulation Steps

1. Create new project targeting Artix-7 (xc7a35tcpg236-1)
2. Add design source (e.g., `conv2d_serial.v`)
3. Add simulation source (e.g., `tb_conv2d_serial.v`)
4. Run **Behavioral Simulation**
5. Verify output = 9 in console log

---

## Synthesis Flow (DSE)

For each variant:

1. Run **Synthesis** (default settings)
2. Open **Synthesis Report**
3. Record from **Utilization Summary**:
   - LUTs
   - DSP48E1 blocks
   - FFs (optional)

---

## Expected DSE Results

| Variant | DSPs | LUTs | Latency | Throughput | Efficiency |
|---------|------|------|---------|------------|------------|
| RTL-V1 | ~1 | Low | 9 cycles | 1/9 per cycle | Baseline |
| RTL-V2 | ~3 | Medium | 3 cycles | 1/3 per cycle | **Best** |
| RTL-V3 | ~9 | High | 1 cycle | 1 per cycle | Diminishing |

---

## Design Philosophy

> "Partial parallelism (RTL-V2) achieves most of the performance benefit of full unrolling while significantly reducing hardware cost, making it ideal for resource-constrained edge SoCs."

---

## Target Device

- **FPGA**: Xilinx Artix-7 (xc7a35tcpg236-1)
- **Board**: Basys3 (or equivalent)
- **Clock**: 100 MHz (10 ns period)
