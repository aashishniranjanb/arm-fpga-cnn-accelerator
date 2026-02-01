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

## Conclusion

*To be filled after DSE completion:*

The design-space exploration reveals that ___ provides the best trade-off between performance and resource utilization for the target Artix-7 FPGA.

---

**Status**: Tables defined. Ready for HLS synthesis results.
