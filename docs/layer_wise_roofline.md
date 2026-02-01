# CNN Layer-Wise Roofline Analysis

This document compares the roofline characteristics of Convolution, ReLU, and Pooling layers to justify layer fusion.

---

## 1. Why Layer-Wise Roofline Matters

A full CNN layer stack contains very different computational behaviors:

| Layer | Compute | Memory |
|-------|---------|--------|
| Convolution | High | Moderate |
| ReLU | Very Low | High |
| Pooling | Low | Moderate |

A single roofline point hides this. **Layer-wise roofline shows which layers waste performance and energy.**

---

## 2. Convolution Layer Roofline

### Operations (per output pixel)
- 3×3 convolution = 9 MACs
- Each MAC = 2 ops
- **Ops_conv = 18**

### Memory Access
- 9 input pixels = 9 bytes
- 1 output pixel = 1 byte
- **Bytes_conv = 10**

### Arithmetic Intensity
```
AI_conv = 18 / 10 = 1.8 ops/byte
```

### Interpretation
- Medium arithmetic intensity
- Close to compute-bound when data reused (line buffers)
- **Best candidate for hardware acceleration**

> Convolution defines the compute roof.

---

## 3. ReLU Layer Roofline

### Operations
- 1 comparison per pixel
- **Ops_relu = 1**

### Memory Access
- Read 1 pixel, Write 1 pixel
- **Bytes_relu = 2**

### Arithmetic Intensity
```
AI_relu = 1 / 2 = 0.5 ops/byte
```

### Interpretation
- **Extremely memory-bound**
- Poor standalone accelerator candidate
- Dominated by memory traffic

> Never accelerate ReLU alone.

---

## 4. Pooling Layer Roofline (2×2 Max Pool)

### Operations
- 3 comparisons per output
- **Ops_pool = 3**

### Memory Access
- Read 4 inputs, Write 1 output
- **Bytes_pool = 5**

### Arithmetic Intensity
```
AI_pool = 3 / 5 = 0.6 ops/byte
```

### Interpretation
- Memory-bound
- Low compute density
- **Acceleration alone yields low gains**

> Pooling benefits only when fused.

---

## 5. Layer-Wise Summary Table

| Layer | Ops | Bytes | AI (ops/byte) | Bottleneck |
|-------|-----|-------|---------------|------------|
| Convolution | 18 | 10 | 1.8 | Compute-leaning |
| ReLU | 1 | 2 | 0.5 | Memory-bound |
| Pooling | 3 | 5 | 0.6 | Memory-bound |

---

## 6. Effect of Layer Fusion

### Fused Conv + ReLU + Pool

**Total operations:**
```
18 + 1 + 3 = 22 ops
```

**Total memory (fused):**
- Input read once
- Output written once
- **Bytes_fused ≈ 1.25**

**Fused Arithmetic Intensity:**
```
AI_fused = 22 / 1.25 = 17.6 ops/byte
```

> **~10× increase in arithmetic intensity**

---

## 7. Roofline Comparison

| Design | AI (ops/byte) | Roofline Position |
|--------|---------------|-------------------|
| Conv only | ~1.8 | Near bandwidth wall |
| ReLU only | ~0.5 | Deep memory-bound |
| Pool only | ~0.6 | Memory-bound |
| **Fused layer** | **~17.6** | **Near compute roof** |

---

## Key Takeaway

> While ReLU and pooling are inherently memory-bound and inefficient as standalone accelerators, fusing them with convolution increases arithmetic intensity by nearly an order of magnitude, shifting execution from the bandwidth-limited region to the compute-bound roofline.
