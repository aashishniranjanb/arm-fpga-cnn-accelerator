# System Architecture Overview

The proposed system is a **hardware/software co-designed CNN accelerator** on a Xilinx Zynq SoC, targeting real-time image classification with FPGA-accelerated convolution.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ZYNQ SoC PLATFORM                            │
├────────────────────────────┬────────────────────────────────────────┤
│   PROCESSING SYSTEM (PS)   │      PROGRAMMABLE LOGIC (PL)          │
│        Arm Cortex-A9       │           Artix-7 FPGA                 │
│                            │                                        │
│  ┌──────────────────────┐  │  ┌──────────────────────────────────┐ │
│  │  Image Acquisition   │  │  │    CNN CONVOLUTION ACCELERATOR   │ │
│  │  (Camera / Dataset)  │  │  │                                  │ │
│  └──────────┬───────────┘  │  │  ┌────────┐  ┌────────────────┐  │ │
│             ▼              │  │  │ Input  │  │  3×3 Kernel    │  │ │
│  ┌──────────────────────┐  │  │  │ BRAM   │──│  MAC Pipeline  │  │ │
│  │   Preprocessing      │  │  │  └────────┘  │  (9 DSP48E1)   │  │ │
│  │ • Resize to 32×32    │  │  │              └───────┬────────┘  │ │
│  │ • INT8 Quantization  │  │  │                      ▼           │ │
│  │ • Normalization      │──────│─── AXI4 ───▶ ┌────────────────┐  │ │
│  └──────────────────────┘  │  │              │  Accumulator   │  │ │
│             ▲              │  │              │  (INT16)       │  │ │
│             │              │  │              └───────┬────────┘  │ │
│  ┌──────────────────────┐  │  │                      ▼           │ │
│  │   Post-processing    │  │  │              ┌────────────────┐  │ │
│  │ • ReLU Activation    │◀─────│◀── AXI4 ────│  Output BRAM   │  │ │
│  │ • Max Pooling        │  │  │              └────────────────┘  │ │
│  │ • Classification     │  │  │                                  │ │
│  └──────────┬───────────┘  │  └──────────────────────────────────┘ │
│             ▼              │                                        │
│  ┌──────────────────────┐  │                                        │
│  │   Result Output      │  │                                        │
│  │   (Display / Log)    │  │                                        │
│  └──────────────────────┘  │                                        │
└────────────────────────────┴────────────────────────────────────────┘
```

---

## Processing System (Arm CPU)

The PS handles all control, orchestration, and non-compute-intensive tasks:

| Function | Description |
|----------|-------------|
| **Image Acquisition** | Load images from camera/dataset |
| **Preprocessing** | Resize, normalize, quantize to INT8 |
| **Control & Orchestration** | Manage data flow between PS↔PL |
| **Post-processing** | ReLU, pooling, softmax (if needed) |
| **Performance Measurement** | Timing, benchmarking, logging |

### Software Stack
- **OS**: Bare-metal or Linux (PetaLinux)
- **Language**: C/C++ for embedded, Python for host testing
- **Libraries**: OpenCV (preprocessing), custom drivers (AXI)

---

## Programmable Logic (FPGA)

The PL implements the compute-intensive CNN convolution:

| Component | Specification |
|-----------|---------------|
| **Operation** | 3×3 2D Convolution |
| **Data Type** | INT8 input, INT16 accumulator |
| **Parallelism** | 9 parallel MAC units (1 per kernel weight) |
| **Pipeline** | Fully pipelined (II=1) |
| **Memory** | On-chip BRAM for input/output buffers |
| **Interface** | AXI4-Lite (control), AXI4-Stream (data) |

### HLS Optimization Targets
- **Latency**: 10-15 cycles (pipeline fill)
- **Throughput**: 1 output pixel per clock cycle
- **Clock**: 100 MHz (10 ns period)

---

## Data Flow

```
1. CPU loads image → DDR memory
2. CPU triggers accelerator via AXI control
3. DMA transfers input tile → PL BRAM
4. Accelerator computes convolution (pipelined)
5. DMA transfers output → DDR memory
6. CPU performs post-processing
7. CPU outputs final result
```

---

## Interface Specification

| Interface | Type | Direction | Purpose |
|-----------|------|-----------|---------|
| `s_axi_control` | AXI4-Lite | PS→PL | Accelerator control/status |
| `m_axi_gmem` | AXI4 | PS↔PL | Memory-mapped data transfer |
| `s_axis_input` | AXI4-Stream | PS→PL | Streaming input data |
| `m_axis_output` | AXI4-Stream | PL→PS | Streaming output data |

---

## Resource Estimates (Artix-7)

| Resource | Estimated Usage | Available | Utilization |
|----------|-----------------|-----------|-------------|
| LUTs | ~2,000 | 20,800 | ~10% |
| FFs | ~1,500 | 41,600 | ~4% |
| BRAM | 4 (18Kb) | 50 | 8% |
| DSP48E1 | 9 | 90 | 10% |

---

## Design Rationale

### Why Hardware/Software Co-Design?

1. **CPU Strengths**: Flexibility, complex control flow, I/O handling
2. **FPGA Strengths**: Parallel computation, deterministic latency
3. **Optimal Split**: CPU handles preprocessing/control, FPGA handles MAC-heavy convolution

### Why This Architecture Wins

- **Clean separation** of concerns (PS vs PL)
- **Scalable**: Unroll factor can be adjusted for larger FPGAs
- **Measurable**: Clear speedup metrics at each stage
- **Realistic**: Matches actual Zynq SoC capabilities

---

**Status**: Architecture defined. Ready for HLS implementation.
