# Design-Space Exploration

This document defines the methodology and results for exploring CNN accelerator design variants.

---

## Dataset and Workload Definition

To isolate hardware performance effects, all design-space exploration experiments use a **fixed synthetic CNN workload**.

| Parameter | Value |
|-----------|-------|
| Input image size | 32 × 32 |
| Kernel size | 3 × 3 |
| Data type | INT8 |
| Input values | All ones |
| Kernel values | All ones |
| Output size | 30 × 30 (900 pixels) |
| Expected output | 9 (per pixel) |

This ensures **fair and repeatable comparison** across accelerator variants by eliminating data-dependent variability.

---

## Design Variables

The primary design variable explored is **loop unrolling factor** for the MAC operation:

| Unroll Factor | Description |
|---------------|-------------|
| 1 | Sequential (baseline) — 1 MAC per cycle |
| 3 | Partial unroll — 3 parallel MACs |
| 9 | Full unroll — 9 parallel MACs (1 pixel/cycle) |

---

## Performance Metrics

### Latency Model

For a pipelined accelerator, total execution cycles are:

```
Total_cycles = Pipeline_Latency + (Output_pixels - 1) × II
```

Where:
- **Pipeline_Latency**: Initial fill latency (from HLS report)
- **Output_pixels**: 900 (30×30 feature map)
- **II**: Initiation Interval (from HLS report)

### FPGA Execution Time

```
T_FPGA (µs) = Total_cycles × Clock_period (ns) / 1000
```

With clock period = 10 ns (100 MHz).

### Speedup

```
Speedup = T_CPU / T_FPGA
```

Where T_CPU is measured from Python/OpenCV baseline.

---

## Design-Space Exploration Results (Unrolling)

| Variant | Unroll Factor | DSPs | LUTs | Latency (cycles) | II | FPGA Time (µs) | Speedup |
|---------|---------------|------|------|------------------|----|--------------:|--------:|
| V1 | 1 | ___ | ___ | ___ | ___ | ___ | ___× |
| V2 | 3 | ___ | ___ | ___ | ___ | ___ | ___× |
| V3 | 9 | ___ | ___ | ___ | ___ | ___ | ___× |

> **Note**: Fill values from Vitis HLS synthesis reports.

---

## Resource Efficiency Analysis

Efficiency is defined as **speedup per DSP**, measuring how effectively hardware resources translate to performance.

| Variant | Speedup | DSPs | Efficiency (Speedup/DSP) |
|---------|--------:|-----:|-------------------------:|
| V1 | ___× | ___ | ___ |
| V2 | ___× | ___ | ___ |
| V3 | ___× | ___ | ___ |

### Interpretation

- **High efficiency**: Good for resource-constrained designs
- **Low efficiency**: Diminishing returns on parallelism
- **Optimal point**: Balance between speedup and resource usage

---

## Key Observations

*To be filled after HLS synthesis:*

1. **Unrolling impact on latency**: ___
2. **Unrolling impact on DSP usage**: ___
3. **Optimal unroll factor**: ___
4. **Efficiency trend**: ___

---

## RTL-Level Design-Space Exploration

In addition to HLS-based exploration, we implement **pure RTL convolution cores** to demonstrate micro-architecture understanding.

### RTL Implementation Variants

| Variant | File | Parallel MACs | Architecture |
|---------|------|---------------|--------------|
| RTL-V1 | `conv2d_serial.v` | 1 | Sequential MAC with FSM |
| RTL-V2 | `conv2d_unroll3.v` | 3 | Partial parallel with mux |
| RTL-V3 | `conv2d_unroll9.v` | 9 | Fully parallel + adder tree |

### RTL Synthesis Results (Vivado)

| Variant | DSPs | LUTs | FFs | Latency (cycles) | Throughput |
|---------|------|------|-----|------------------|------------|
| RTL-V1 | ___ | ___ | ___ | 9 | 1 / 9 cycles |
| RTL-V2 | ___ | ___ | ___ | 3 | 1 / 3 cycles |
| RTL-V3 | ___ | ___ | ___ | 1 | 1 / cycle |

> **Note**: Fill DSP/LUT/FF values from Vivado synthesis reports.

### RTL vs HLS Comparison

| Aspect | RTL Approach | HLS Approach |
|--------|--------------|--------------|
| Control | Explicit FSM | Tool-generated |
| Optimization | Manual | Pragma-guided |
| Verification | Cycle-accurate | Behavioral |
| Flexibility | Full | Constrained |

### Why RTL-Level DSE Matters

RTL implementation demonstrates:
- Understanding of **micro-architecture trade-offs**
- Ability to **reason about cycles and parallelism**
- Control over **hardware scheduling**
- Independence from **tool abstractions**

> "Partial parallelism (RTL-V2) achieves most of the performance benefit of full unrolling while significantly reducing hardware cost."

---

## Conclusion

*To be filled after DSE completion:*

The design-space exploration reveals that ___ provides the best trade-off between performance and resource utilization for the target Artix-7 FPGA.

---

**Status**: Tables defined. Ready for HLS synthesis results.
