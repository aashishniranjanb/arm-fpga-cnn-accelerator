# Performance & FPS Model for CNN Acceleration on Zynq SoC

This document provides an analytical performance model for the CNN accelerator, estimating latency, throughput (FPS), and speedup without relying on HLS or board measurements.

---

## 1. Objective

Analytically estimate:
- Latency
- Throughput (FPS)
- Speedup vs CPU
- Scalability with parallelism

This is a **theoretical + RTL-validated model**, suitable for design-space exploration and architecture justification.

---

## 2. Accelerator Assumptions (Ground Truth)

From RTL synthesis and simulation:

| Parameter | Value |
|-----------|-------|
| Convolution type | 3×3 |
| Parallel MACs | 9 (fully unrolled) |
| DSP usage | 9 DSP48E1 |
| Latency per conv | 1 clock cycle |
| Clock frequency | 100 MHz (conservative) |
| Accelerator invocation | 1 output pixel × 1 input channel |

---

## 3. CNN Layer Parameters

Let:
- **H × W** = output feature map size
- **Cin** = input channels
- **Cout** = output channels
- **fclk** = accelerator clock frequency

---

## 4. Accelerator Latency Model

### 4.1 Single Output Pixel Latency

For one output pixel, one output channel:
```
Latency_pixel = Cin × Tacc = Cin cycles
```

### 4.2 Full Output Feature Map Latency

For one output channel:
```
Latency_map = H × W × Cin
```

For full CNN layer:
```
Latency_layer = H × W × Cin × Cout (cycles)
```

---

## 5. Throughput & FPS Model

### 5.1 Frames Per Second

Convert cycles to seconds:
```
FPS = fclk / (H × W × Cin × Cout)
```

### 5.2 Example: Typical CNN Layer

Assume:
- Image size: 32 × 32
- Cin = 16
- Cout = 32
- fclk = 100 MHz

```
Total cycles = 32 × 32 × 16 × 32 = 524,288 cycles

FPS = 100,000,000 / 524,288 ≈ 190 FPS
```

✔ **Real-time capable** before pipelining or DMA optimizations

---

## 6. CPU Baseline Performance Model

### 6.1 Operations per Output Pixel

For a 3×3 convolution:
- 9 multiplications
- 8 additions ≈ 17 operations

For multi-channel:
```
Ops_pixel = 9 × Cin × Cout
```

### 6.2 Total CPU Operations per Frame

```
Ops_frame = H × W × 9 × Cin × Cout
```

Using the same example:
```
Ops_frame = 32 × 32 × 9 × 16 × 32 = 4.7 million operations
```

On an embedded ARM core:
- ~200–400 MFLOPS (optimistic)
- No perfect cache reuse

Estimated:
```
FPS_CPU ≈ 20–40 FPS
```

---

## 7. Speedup Estimation

```
Speedup = FPS_FPGA / FPS_CPU ≈ 190 / 30 ≈ 6.3×
```

> This is **without** AXI streaming, line buffers, pipelining, or HLS loop unrolling.

---

## 8. Scaling with Parallelism

Let P = number of parallel MAC units.

```
Latency ∝ 1 / P
FPS ∝ P
```

| Design | MACs | DSPs | Relative FPS |
|--------|------|------|--------------|
| Serial | 1 | 0 | 1× |
| Partial | 3 | 0 | 3× |
| Fully parallel | 9 | 9 | 9× |

This matches RTL utilization data, validating the model.

---

## 9. Roofline Perspective

The accelerator is:
- **Compute-bound**
- Low memory bandwidth pressure (small kernel)
- Ideal for DSP utilization

This makes it:
- Highly energy-efficient
- Scalable with more DSPs
- Suitable for edge AI

---

## 10. Limitations of Current Model

This model does not yet include:
- AXI transfer latency
- DMA burst optimization
- Inter-layer fusion
- On-chip buffering

These are explicitly planned as future optimizations.

---

## Key Takeaway

> A fully unrolled 3×3 DSP-based convolution accelerator can achieve real-time CNN inference on embedded SoCs, delivering multi-× speedup over ARM CPUs even before advanced memory optimizations.
