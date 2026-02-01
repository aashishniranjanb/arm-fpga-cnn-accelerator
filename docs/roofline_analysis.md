# Roofline Performance–Energy Analysis

This document applies roofline analysis to the CNN accelerator, showing compute vs bandwidth limitations and energy efficiency.

---

## 1. What a Roofline Model Is

A roofline model shows:
- The **maximum performance** a system can reach
- Limited by either:
  - **Compute capability** (DSPs)
  - **Memory bandwidth**

It answers: *Is my accelerator limited by computation or by memory?*

---

## 2. Axes of the Roofline Plot

### X-Axis: Arithmetic Intensity (AI)
```
AI = Operations / Bytes accessed
```

### Y-Axis: Performance
```
GOPS (Giga Operations per Second)
```

---

## 3. Compute Roof (DSP-Limited Ceiling)

From RTL design:
- DSPs = 9
- Each DSP = 1 MAC / cycle
- Clock = 100 MHz
- Each MAC = 2 ops (mul + add)

```
Peak Compute = 9 × 2 × 100M = 1.8 GOPS
```

This is the **horizontal roofline**.

---

## 4. Memory Roof (Bandwidth Ceiling)

Assume AXI-Stream input:
- Data width = 8 bits
- One pixel per cycle
- 100 MHz clock

```
Bandwidth = 100M × 1 Byte = 100 MB/s
```

Memory roof slope:
```
Performance = AI × Bandwidth
```

---

## 5. Arithmetic Intensity of Fused Design

### Operations per output pixel
- Conv: 9 MACs → 18 ops
- ReLU: 1 compare → 1 op
- Pooling (amortized): ~1 op
- **Total: ~20 ops**

### Memory access per pixel
- Input pixel: 1 byte
- Output write (after pooling): 0.25 byte (amortized)
- **Total: ~1.25 bytes**

### Arithmetic Intensity
```
AI = 20 / 1.25 = 16 ops/byte
```

---

## 6. Roofline Position

Compute-limited threshold:
```
AI_threshold = 1.8 GOPS / 100 MB/s = 18
```

Our design: **AI = 16 ≈ near-compute-bound**

This means:
- ✅ Memory is not the bottleneck
- ✅ DSP utilization is high
- ✅ Fusion successfully increased AI

---

## 7. Energy Roofline (Performance per Watt)

From power model:
- Power = 0.2 W
- Performance = 1.8 GOPS

```
Energy Efficiency = 1.8 / 0.2 = 9 GOPS/W
```

This is excellent for edge FPGA CNNs.

---

## 8. Why Fusion Shifts the Roofline Upwards

| Technique | Effect on Roofline |
|-----------|-------------------|
| Layer fusion | ↑ Arithmetic Intensity |
| Streaming | ↓ Memory traffic |
| DSP binding | ↑ Compute roof |
| No DRAM | ↓ Energy per op |

> Fusion moves the design point upward and right on the roofline.

---

## 9. ASCII Roofline Sketch

```
Performance (GOPS)
│
│         ───────────────  Compute Roof (1.8 GOPS)
│        /
│       /     ● Fused Design (AI=16)
│      /
│     /   ● Unroll-3
│    /
│   / ● Serial
│  /
└───────────────────────────────
          Arithmetic Intensity (ops/byte)
```

---

## Key Takeaway

> By fusing convolution, ReLU, and pooling into a single streaming pipeline, the accelerator increases arithmetic intensity to ~16 ops/byte, operating near the compute roof while achieving ~9 GOPS/W energy efficiency.
