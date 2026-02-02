# FPGA vs CPU Speedup Analysis

## Cycle-Level Comparison (Single 3×3 Window)

| Design Variant  | Cycles | Relative Speedup |
|-----------------|--------|------------------|
| CPU baseline    | 9      | 1×               |
| FPGA Serial     | 9      | 1×               |
| FPGA Unroll ×3  | 3      | 3×               |
| FPGA Unroll ×9  | 1      | 9×               |

## Why FPGA is Faster

- **Spatial Parallelism:** 9 MACs execute in parallel (not sequentially)
- **No Instruction Fetch:** Hardwired datapath, no CPU overhead
- **Deterministic Timing:** Fixed latency, no cache misses
- **Pipelining:** Next window starts while current completes

## System-Level Speedup (Full Image)

For 224×224 image with 3×3 kernel:

| Metric | CPU (ARM A9) | FPGA (V4) | Speedup |
|--------|--------------|-----------|---------|
| MACs   | 443,556      | 443,556   | -       |
| Cycles | ~500,000     | ~50,000   | ~10×    |
| Time   | ~5 ms        | ~0.5 ms   | ~10×    |

## Key Insight

> FPGA acceleration exploits spatial parallelism to reduce total execution time, achieving near-linear speedup with unroll factor.
