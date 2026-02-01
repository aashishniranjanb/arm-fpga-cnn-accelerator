# Scope and Limitations

This document clearly defines what is and is not included in the project scope.

---

## In Scope ✅

| Area | Description |
|------|-------------|
| **CNN Convolution Acceleration** | 3×3 2D convolution using FPGA |
| **Hardware/Software Co-Design** | Clear PS/PL partitioning on Zynq SoC |
| **Performance Analysis** | Latency, throughput, speedup metrics |
| **Resource Analysis** | DSP, LUT, BRAM utilization |
| **Design-Space Exploration** | Unrolling factor trade-offs |
| **Efficiency Metrics** | Speedup per DSP resource |

---

## Out of Scope ❌

| Area | Reason |
|------|--------|
| **Full Multi-Layer CNN** | Focus is on accelerator architecture, not model complexity |
| **Model Training** | No ML training — inference acceleration only |
| **Accuracy Evaluation** | Fixed synthetic dataset for DSE; accuracy is orthogonal |
| **Board-Level Deployment** | Simulation/synthesis validated; hardware bring-up not required |
| **Power Measurement** | Requires physical board instrumentation |
| **AXI DMA Integration** | Planned but not implemented in current scope |

---

## Design Decisions

### Why Focus on Single Convolution Layer?

1. **Clarity**: Isolates accelerator performance from system integration complexity
2. **Measurability**: Clean speedup metrics without I/O bottlenecks
3. **Extensibility**: Design can tile larger images or stack layers

### Why Synthetic Dataset?

1. **Determinism**: Eliminates data-dependent performance variation
2. **Correctness**: Easy verification (output = 9 for all-ones input)
3. **DSE Focus**: Isolates architectural impact from workload effects

---

## Future Extensions

If time permits or for follow-up work:

- [ ] Add DMA-based data transfer measurement
- [ ] Implement multi-channel convolution
- [ ] Test with real image (CIFAR-10 grayscale)
- [ ] Deploy on physical Zynq board
- [ ] Measure actual power consumption

---

## Summary

> The project intentionally focuses on **architectural exploration** rather than end-to-end application deployment. This targeted scope allows deeper analysis of design trade-offs that are often overlooked in broader implementations.

---

**This document demonstrates engineering maturity by clearly communicating project boundaries.**
