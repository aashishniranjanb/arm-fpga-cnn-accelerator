# Evaluator Story

## Project Overview

This project demonstrates how **architectural decisions impact CNN acceleration** on Arm–FPGA SoCs.

---

## Development Approach

The work follows a systematic engineering methodology:

1. **CPU Baseline**: Clean reference implementations in Python/OpenCV and C++ establish measurable performance targets.

2. **Theoretical Modeling**: A mathematical performance model predicts FPGA acceleration before hardware implementation.

3. **Hardware Design**: A CNN convolution accelerator is designed using High-Level Synthesis (HLS) targeting Xilinx Artix-7.

4. **Design-Space Exploration**: Multiple design variants are evaluated across performance–area trade-offs.

---

## Key Differentiator

Rather than optimizing a single design point, this project performs **systematic design-space exploration** to study:

- Impact of loop unrolling on latency and throughput
- Resource utilization vs. performance trade-offs
- Efficiency metrics (speedup per DSP)

This introduces a **resource efficiency metric** to guide architectural decisions.

---

## Engineering Rigor

The project demonstrates:

| Aspect | Implementation |
|--------|----------------|
| **Reproducibility** | Fixed synthetic dataset for fair comparison |
| **Correctness** | Deterministic outputs verified across all implementations |
| **Measurement** | Averaged timing with warm-up iterations |
| **Documentation** | Clear methodology at each stage |

---

## Real-World Relevance

This approach mirrors accelerator development workflows used in industry:

- **AWS Inferentia** team uses similar DSE for ML accelerator design
- **Google TPU** evolved through systematic architectural exploration
- **NVIDIA GPU** generations reflect performance/efficiency trade-offs

Understanding these trade-offs is essential for hardware-aware ML deployment.

---

## Summary

> *"We intentionally focused on architectural exploration rather than end-to-end application deployment, demonstrating how design decisions impact CNN acceleration performance."*

This project shows not just *that* FPGAs accelerate CNNs, but *why* and *how much* — with quantified evidence.
