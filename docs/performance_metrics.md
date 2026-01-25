## CPU Baseline Performance

- Platform: Host CPU (Windows)
- Operation: 3×3 convolution
- Image size: 8×8
- Output size: 6×6
- Data type: INT8 × INT8 → INT16

### Results
- Execution time: 166,700 ns
- Output correctness: Verified (output[0][0] = 9)

This baseline represents a CPU-only CNN convolution used for comparison with FPGA acceleration.

---
## Performance Metrics

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
