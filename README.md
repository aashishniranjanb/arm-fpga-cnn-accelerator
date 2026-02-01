# Hardware-Accelerated CNN on Arm–FPGA SoC

## Overview
This project implements a hardware-accelerated convolutional neural network (CNN) inference pipeline on a Xilinx Zynq System-on-Chip (SoC). The design follows a hardware/software co-design approach, where compute-intensive CNN layers are accelerated in FPGA fabric while control, preprocessing, and post-processing run on the Arm CPU.

## Objective
To quantitatively demonstrate performance improvements (latency and throughput) of FPGA-accelerated CNN inference compared to a CPU-only implementation on an Arm processor.

## Key Features
- Lightweight CNN for edge vision tasks
- INT8 convolution accelerator using Vivado/Vitis HLS
- Arm CPU baseline implementation for comparison
- Hardware/software partitioning using AXI interfaces
- Performance evaluation using synthesis and simulation reports

## Target Platform
- Xilinx Zynq-7000 family (board-independent design)
- Arm Cortex-A class processor
- FPGA fabric for CNN acceleration

## Project Status
✅ **Design-Space Exploration Complete**

---

## Key Results

| Metric | RTL-V1 (Serial) | RTL-V2 (Partial) | RTL-V3 (LUT) | RTL-V4 (DSP) |
|--------|-----------------|------------------|--------------|--------------|
| Parallel MACs | 1 | 3 | 9 | 9 |
| Latency (cycles) | 9 | 3 | 1 | 1 |
| LUTs | 159 | 329 | 758 | **0** |
| DSPs | 0 | 0 | 0 | **9** |
| Speedup | 1× | **3×** | **9×** | **9×** |

### Highlights
- Achieved up to **9× speedup** via RTL parallelization
- Demonstrated clear **latency–area trade-offs**
- **DSP binding eliminates LUT usage** — V4 achieves 0 LUTs with 9 DSP48E1 blocks
- **Sub-linear area scaling** confirms efficient architecture
- All variants meet **100 MHz timing** constraint

---

## Documentation

| Document | Description |
|----------|-------------|
| [System Architecture](docs/system_architecture.md) | PS/PL partitioning and interfaces |
| [Design-Space Exploration](docs/design_space_exploration.md) | DSE methodology and results |
| [Results Summary](docs/results_summary.md) | Comprehensive findings |
| [Theoretical Speedup](docs/theoretical_speedup.md) | Performance modeling |

---

## Repository Structure

```
├── docs/                    # Documentation
├── hardware/
│   ├── rtl/                 # Verilog RTL implementations
│   └── reports/             # Synthesis reports (utilization, timing, power)
├── software/
│   └── cpu_baseline/        # Python/C++ reference implementations
└── scripts/                 # Automation scripts
```

