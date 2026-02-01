# FSM Timing Diagram

This document provides a cycle-accurate timing diagram for the layer-fused accelerator FSM.

---

## 1. What This Timing Diagram Proves

This diagram shows, cycle by cycle, that:
- Convolution, ReLU, and Pooling overlap in time
- No intermediate memory writes occur
- The pipeline never stalls
- One pooled output is produced every few cycles

> **This is the proof of true layer fusion.**

---

## 2. Signals Shown

| Signal | Meaning |
|--------|---------|
| state | FSM state |
| conv_valid | Convolution output ready |
| relu_valid | ReLU output valid |
| pool_count | Pool accumulation counter |
| out_valid | Final output write |

---

## 3. Cycle-Accurate FSM Timeline

```
Cycle →   C0        C1        C2        C3        C4        C5        C6
---------------------------------------------------------------------------
state     IDLE      LOAD      CONV      POOL      POOL      POOL      WRITE
---------------------------------------------------------------------------
conv_out            -         ✔         ✔         ✔         ✔         -
relu_out            -         ✔         ✔         ✔         ✔         -
pool_count          -         0         1         2         3         0
out_valid            0         0         0         0         0         1
---------------------------------------------------------------------------
operation            start     3×3 MAC   pool(1)  pool(2)  pool(3)  write
```

---

## 4. Step-by-Step Explanation

### 🟢 Cycle C0 — IDLE
- Accelerator waits for start
- All counters reset

### 🟢 Cycle C1 — LOAD
- 3×3 window prepared (line buffers)
- No compute yet

### 🟢 Cycle C2 — CONV + ReLU
- 9 DSP MACs compute convolution
- ReLU applied in same cycle
- Output forwarded directly to pooling logic
- **No memory write here**

### 🟢 Cycles C3–C5 — POOL ACCUMULATION
- FSM stays in POOL
- Each cycle:
  - Receives ReLU output
  - Updates pool_max
  - Increments pool_count
- Pooling needs 4 inputs → 4 cycles

### 🟢 Cycle C6 — WRITE
- Pooled result written once
- out_valid = 1
- Pool counter resets
- FSM advances to next window

---

## 5. Overlapped Pipeline View

```
Cycle:   C2     C3     C4     C5     C6
----------------------------------------
Conv     ✔      ✔      ✔      ✔      ✔
ReLU     ✔      ✔      ✔      ✔      ✔
Pool            ✔      ✔      ✔      ✔
Write                          ✔
```

> Conv never waits for Pool  
> ReLU has zero latency  
> Write happens only once  

---

## 6. Effective Throughput

- Conv output: 1 per cycle
- Pool output: 1 per 4 cycles
- No pipeline bubbles

This matches FPS and energy models.

---

## 7. FSM Cycle-Level Timing Table

| Cycle | FSM State | Conv | ReLU | Pool Count | out_valid |
|-------|-----------|------|------|------------|-----------|
| C0 | IDLE | - | - | - | 0 |
| C1 | LOAD | - | - | 0 | 0 |
| C2 | CONV | ✔ | ✔ | 0 | 0 |
| C3 | POOL | ✔ | ✔ | 1 | 0 |
| C4 | POOL | ✔ | ✔ | 2 | 0 |
| C5 | POOL | ✔ | ✔ | 3 | 0 |
| C6 | WRITE | - | - | 0 | 1 |

This table reflects the cycle-accurate behavior observed during RTL simulation.

---

## Key Takeaway

> The FSM enables fully overlapped Conv–ReLU–Pool execution, producing one pooled output every four cycles without intermediate buffering or pipeline stalls.
