# Full CNN Layer Mapping on Zynq SoC

This document describes how the proposed 3×3 convolution accelerator maps to full CNN layer execution.

---

## 1. What We Have vs What a CNN Layer Needs

### Current Accelerator Capability
- A 3×3 convolution engine
- Computes one output pixel
- Fully parallel (9 MACs)
- DSP-accelerated
- AXI-controlled

### Full CNN Layer Requirements

For a convolution layer:
- **Input feature map**: H × W × Cin
- **Kernel**: 3 × 3 × Cin × Cout
- **Output feature map**: H × W × Cout

Total computation per layer:
```
For each output_channel (Cout):
  For each output_pixel (H×W):
    For each input_channel (Cin):
      partial_sum += conv3x3(input_channel)
```

**→ Our accelerator computes `conv3x3(input_channel)` — the atomic compute unit.**

---

## 2. Layer Decomposition Strategy

We decompose the CNN layer into three nested loops:

```
for each output_channel (Cout):
  for each output_pixel (H×W):
    for each input_channel (Cin):
        partial_sum += conv3x3(input_channel)
```

This mapping is:
- Standard in CNN accelerator literature
- Hardware-friendly
- Scalable to any network size

---

## 3. Sliding Window Mapping (Spatial)

For a 3×3 convolution at position (x, y):

```
I[x-1][y-1][c]  I[x-1][y][c]  I[x-1][y+1][c]
I[x][y-1][c]    I[x][y][c]    I[x][y+1][c]
I[x+1][y-1][c]  I[x+1][y][c]  I[x+1][y+1][c]
```

These 9 values are:
1. Loaded by ARM (or DMA later)
2. Written into AXI registers
3. Fed to the accelerator

Each accelerator invocation → 1 output pixel contribution

---

## 4. Channel Accumulation

For multi-channel CNNs:

```
Output(x,y,cout) = Σ over cin [ Conv3x3( Input(:,:,cin), Kernel(:,:,cin,cout) ) ]
```

### Mapping in Our System

1. Accelerator computes one Cin at a time
2. ARM repeats accelerator calls for each Cin
3. ARM accumulates partial sums in software
4. Final result written to output buffer

> This is called **temporal channel folding**

---

## 5. Tiling Strategy (Memory-Aware)

### Spatial Tiling
- Process image in tiles (e.g., 16×16)
- Reuse kernel weights
- Minimize DRAM traffic

### Channel Tiling
- Process Cin in groups
- Accumulate partial sums per tile

This enables scaling to large CNNs within on-chip memory constraints.

---

## 6. Dataflow Between PS and PL

### Control Plane (AXI-Lite)
- Configure kernel weights
- Provide input pixels
- Start accelerator
- Read result

### Data Plane (Future – AXI-Stream)
- Stream feature maps
- Burst transfers
- Pipeline execution

> For this project, AXI-Lite is sufficient and intentional. AXI-Stream is documented as future work.

---

## 7. End-to-End CNN Layer Execution Flow

1. ARM loads kernel weights for (cin, cout)
2. ARM slides 3×3 window over input feature map
3. For each (x, y):
   - ARM writes 9 pixels to accelerator
   - Starts accelerator
   - Reads partial sum
4. ARM accumulates partial sums across Cin
5. Final output pixel stored
6. Repeat for all Cout

---

## 8. Performance Implications

Let:
- Tacc = accelerator latency = 1 cycle
- Cin = input channels
- H×W = output size

Total accelerator invocations:
```
H × W × Cin × Cout
```

This architecture is:
- Accelerator compute-bound
- Perfect for DSP scaling
- Ideal candidate for future HLS unrolling

---

## 9. Why This Architecture Is Correct

✔ Matches standard CNN computation  
✔ Scales to any image size  
✔ Independent of framework (TensorFlow / PyTorch)  
✔ Maps cleanly to HLS later  
✔ Valid for edge AI workloads  

---

## 10. Future HLS Optimization Path

When Vitis HLS is used later:
- Unroll Cin loop
- Pipeline spatial loop
- Convert AXI-Lite → AXI-Stream
- Add line buffers

**The core mapping remains identical.**

---

## Key Takeaway

> The proposed accelerator implements a scalable 3×3 convolution compute primitive that can be composed temporally and spatially to execute full CNN layers on a Zynq SoC.
