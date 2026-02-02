# CPU Preprocessing Pipeline

Image preprocessing is executed on the Arm Cortex-A processor prior to FPGA acceleration.

---

## 1. Why Preprocessing Runs on CPU

Before the FPGA accelerator can work, the raw image must be:
- Read from memory / camera
- Converted into the right format
- Normalized
- Arranged into a stream

These steps are **control-heavy, not compute-heavy**, so they are best done on the **ARM CPU**, not FPGA.

This is **industry standard**.

---

## 2. CPU vs FPGA Task Allocation

| Task | CPU | FPGA |
|------|-----|------|
| File I/O | ✅ | ❌ |
| Image resize | ✅ | ❌ |
| Normalization | ✅ | ⚠️ |
| Control logic | ✅ | ❌ |
| CNN MACs | ❌ | ✅ |

> FPGA is for **regular, heavy math**
> CPU is for **irregular, control-heavy work**

---

## 3. Preprocessing Pipeline

```
Image load (from DDR/camera)
  ↓
Resize to CNN input size (224×224)
  ↓
Grayscale conversion (optional)
  ↓
INT8 normalization
  ↓
Flatten / stream formatting
  ↓
Send to FPGA via AXI-Stream
```

---

## 4. Preprocessing Steps Explained

### 4.1 Resize
```
224×224 → 224×224 (or target size)
```
- Ensures fixed CNN input
- Done using OpenCV / C code

### 4.2 Grayscale (Optional)
```
Gray = 0.299R + 0.587G + 0.114B
```
- Reduces channels
- Saves FPGA resources

### 4.3 Normalization (Critical)

Convert pixels to INT8:
```
x_norm = (x - mean) / scale
```

Example C code:
```c
int8_t px = (pixel - 128) >> 3;
```

This matches the **DSP-friendly INT8 CNN** accelerator.

### 4.4 Stream Formatting
- Linear array
- Row-major order
- Ready for AXI-Stream

---

## 5. PS–PL Dataflow

```
ARM Cortex-A (PS)
 ├─ Image I/O
 ├─ Resize
 ├─ Normalize
 ├─ AXI Stream TX
 │
 ▼
FPGA Fabric (PL)
 ├─ Conv
 ├─ ReLU
 ├─ Pool
 └─ AXI Stream RX
```

---

## 6. Preprocessing Latency

| Stage | Time |
|-------|------|
| Resize + normalize | ~1–2 ms |
| FPGA inference | ~0.5 ms |
| Total | ~2.5 ms |

> CPU preprocessing latency can be overlapped with FPGA execution.

---

## 7. Key Design Decision

This PS–PL partitioning follows standard SoC design practices:
- CPU handles control-dominated tasks
- FPGA handles compute-dominated tasks
- Minimizes overall system energy consumption

---

## Key Takeaway

> "The ARM CPU performs lightweight preprocessing and data orchestration, while the FPGA accelerator focuses solely on convolutional computation."
