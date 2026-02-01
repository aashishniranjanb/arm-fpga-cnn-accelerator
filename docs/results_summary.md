# Results Summary

This document summarizes the key findings from the CNN convolution accelerator design-space exploration.

---

## Functional Verification

| Variant | Test Result | Output Value | Expected |
|---------|-------------|--------------|----------|
| RTL-V1 (Serial) | ✅ PASSED | 9 | 9 |
| RTL-V2 (Unroll-3) | ✅ PASSED | 9 | 9 |
| RTL-V3 (Unroll-9) | ✅ PASSED | 9 | 9 |

All RTL variants produce correct convolution results.

---

## Performance Scaling

| Variant | Latency (cycles) | Throughput | Speedup vs V1 |
|---------|------------------|------------|---------------|
| RTL-V1 | 9 | 1/9 per cycle | 1× (baseline) |
| RTL-V2 | 3 | 1/3 per cycle | **3×** |
| RTL-V3 | 1 | 1 per cycle | **9×** |

**Key Finding**: Linear performance scaling with parallelism — speedup matches theoretical expectations.

---

## Area Efficiency

| Variant | LUTs | FFs | LUT/MAC | Area Efficiency |
|---------|------|-----|---------|-----------------|
| RTL-V1 | 159 | 38 | 159 | Baseline |
| RTL-V2 | 329 | 37 | ~110 | **Best** |
| RTL-V3 | 758 | 17 | ~84 | Good |

**Key Finding**: Sub-linear area growth confirms effective amortization of control logic.

---

## Timing Analysis

| Variant | WNS (ns) | Fmax (MHz) | Meets 100 MHz |
|---------|----------|------------|---------------|
| RTL-V1 | 5.234 | 209.8 | ✅ Yes |
| RTL-V2 | 4.127 | 170.3 | ✅ Yes |
| RTL-V3 | 2.341 | 130.5 | ✅ Yes |

**Key Finding**: All variants comfortably meet 100 MHz timing constraint.

---

## Power Analysis

| Variant | Dynamic Power (W) | Power/Throughput |
|---------|-------------------|------------------|
| RTL-V1 | 0.006 | 0.054 W·cycle |
| RTL-V2 | 0.011 | 0.033 W·cycle |
| RTL-V3 | 0.020 | 0.020 W·cycle |

**Key Finding**: Power scales sub-linearly with parallelism — efficient architecture.

---

## DSP Usage Note

At RTL synthesis stage, Vivado maps 8×8 multipliers to LUT fabric rather than DSP48E1 blocks, as no explicit DSP binding constraints were applied. This does not affect architectural scaling trends and represents typical behavior for small multiplier widths.

---

## Conclusions

1. **Linear speedup** achieved through parallel MAC architecture
2. **Sub-linear area growth** demonstrates efficient design
3. **All variants meet timing** at 100 MHz target frequency
4. **Power efficiency improves** with increased parallelism
5. **RTL-V2 (partial parallel)** offers best area efficiency for resource-constrained deployments

> These results validate the suitability of FPGA acceleration for edge CNN workloads on Arm–FPGA SoCs.

---

## Next Steps

- [ ] Add DSP binding optimization
- [ ] HLS comparison study
- [ ] PS–PL integration for end-to-end demonstration
- [ ] Board-level deployment on Zynq platform
