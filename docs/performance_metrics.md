# Performance Metrics

This document tracks benchmarking results for CPU baseline and FPGA accelerated implementations.

---

## CPU CNN Baseline – Python (OpenCV)

- **Image size**: 32×32
- **Kernel**: 3×3
- **Data type**: INT8
- **Accumulator**: INT16
- **Library**: OpenCV filter2D

### Timing Methodology

| Parameter | Value |
|-----------|-------|
| Warm-up iterations | 10 |
| Measured iterations | 1000 |
| Metric | Average execution time |

### Results

- **Output correctness**: Verified (output[0,0] = 9)
- **Average execution time**: `___ ms` *(fill after running)*

---

## Performance Comparison Framework

### Latency

- End-to-end inference time for a single image
- CPU-only vs. FPGA-accelerated comparison
- Breakdown: preprocessing, convolution, post-processing

### Throughput

- Images processed per second
- For fixed batch size and varying input dimensions

### Resource Utilization

- FPGA LUTs, BRAMs, DSP slices used
- Power consumption (if available)

### Speedup Factor

- Ratio of CPU latency to FPGA latency
- Target: 5–20× speedup depending on network size

### Accuracy Validation

- INT8 quantization impact on inference accuracy
- Validation against FP32 reference model

---

## FPGA Baseline Results

*To be populated after HLS synthesis and hardware testing.*

| Metric | CPU | FPGA | Speedup |
|--------|-----|------|---------|
| Convolution latency | TBD | TBD | TBD |
| Throughput (img/s) | TBD | TBD | TBD |
| Power (W) | TBD | TBD | TBD |
