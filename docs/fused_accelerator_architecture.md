# Layer-Fused RTL Micro-Architecture

This document describes the block-level RTL architecture for a fused Conv–ReLU–Pool accelerator.

---

## 1. Design Goal

Design a streaming RTL accelerator that computes convolution, ReLU activation, and pooling in a single pass, eliminating intermediate memory traffic and maximizing arithmetic intensity.

---

## 2. High-Level Dataflow

```
AXI-Stream In
     ↓
Line Buffer + Window Generator
     ↓
DSP MAC Array (Convolution)
     ↓
ReLU (Comparator)
     ↓
Pooling Unit (2×2 Max)
     ↓
AXI-Stream Out
```

**Key principle:** Data flows forward once. No write-back until final output.

---

## 3. Top-Level Block Diagram

```
+----------------------------------------------------+
|                ConvReLUPool_Accel                  |
|                                                    |
|  +---------+   +-----------+   +---------------+  |
|  | AXI In  |-->| Line Buf  |-->| Window (3×3)  |  |
|  +---------+   +-----------+   +---------------+  |
|                                      ↓            |
|                               +----------------+  |
|                               | DSP MAC Array  |  |
|                               +----------------+  |
|                                      ↓            |
|                               +----------------+  |
|                               | ReLU Unit      |  |
|                               +----------------+  |
|                                      ↓            |
|                               +----------------+  |
|                               | Pooling Unit   |  |
|                               +----------------+  |
|                                      ↓            |
|                                +--------------+   |
|                                | AXI Out      |   |
|                                +--------------+   |
+----------------------------------------------------+
```

---

## 4. Module-by-Module Breakdown

### 4.1 Line Buffer + Window Generator

**Purpose:** Generate sliding 3×3 windows from input stream.

**Implementation:**
- 2 line buffers (shift registers or BRAM)
- 3 shift registers per row
- Outputs 9 pixels per cycle (after pipeline fill)

**Signals:**
- `pixel_in`
- `window[0:8]`
- `valid_window`

> This block enables streaming convolution.

---

### 4.2 DSP MAC Array (Convolution Core)

The existing unroll-9 DSP design fits here.

**Operation per cycle:**
```
sum = Σ (window[i] × weight[i]), i = 0..8
```

**Characteristics:**
- Fully parallel (9 DSP48E1)
- One output per cycle after pipeline fill
- INT8 × INT8 → INT16 accumulation

> This is the compute roof block.

---

### 4.3 ReLU Unit (Inline Activation)

**Operation:**
```
relu_out = (sum > 0) ? sum : 0
```

**Implementation:**
- One comparator
- One mux
- Zero DSPs

**Why inline?**
- No memory write
- No latency penalty
- Zero impact on throughput

> ReLU becomes "free".

---

### 4.4 Pooling Unit (2×2 Max Pool)

**Goal:** Reduce spatial resolution while preserving peak values.

**Strategy:**
- Pool after ReLU
- Maintain small pooling window buffer
- Compare 4 values → 1 output

**Implementation:**
- 2×2 register window
- 3 comparators
- 1 output every 4 input pixels

> Throughput controlled by pooling stride.

---

### 4.5 AXI Streaming Interface

**Why AXI-Stream:**
- Natural for video/CNN pipelines
- Back-pressure support
- Easy PS–PL integration

**Signals:**
- `tdata`, `tvalid`, `tready`, `tlast`

> Only final pooled output goes to memory.

---

## 5. Pipeline Timing

```
Cycle 0–N:  Line buffer fill
Cycle N+1:  First 3×3 window valid
Cycle N+2:  First Conv output
Cycle N+3:  ReLU applied
Cycle N+4:  Pooling output valid
```

After fill: One pooled output every few cycles. No stalls if AXI ready is high.

---

## 6. Throughput & Bottleneck Analysis

| Block | Bottleneck? |
|-------|-------------|
| Line buffer | No |
| DSP MAC | No (parallel) |
| ReLU | No |
| Pooling | Yes (stride-dependent) |
| AXI Out | Only if memory stalls |

> Pooling stride becomes the throughput limiter, not compute.

---

## 7. Resource Mapping Summary

| Block | LUT | FF | DSP | BRAM |
|-------|-----|----|-----|------|
| Line Buffer | Medium | Medium | 0 | Small |
| Conv MAC | Low | Low | 9 | 0 |
| ReLU | Tiny | Tiny | 0 | 0 |
| Pool | Low | Low | 0 | 0 |
| AXI | Medium | Medium | 0 | 0 |

> DSPs used only where they matter.

---

## 8. Why This Architecture Is Strong

✔ Fully streaming  
✔ No intermediate memory  
✔ Roofline-justified  
✔ Energy-efficient  
✔ AXI-friendly  
✔ Maps cleanly to HLS later  

> This is how real CNN accelerators are architected.
