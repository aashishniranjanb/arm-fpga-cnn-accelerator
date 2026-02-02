# Power Estimation Summary

**Estimation Method:** Vivado Power Analysis (Vector-less)

## Power by Variant

| Design Variant     | Dynamic (mW) | Static (mW) | Total (mW) |
|-------------------|--------------|-------------|------------|
| Serial (V1)       | ~15          | ~100        | ~115       |
| Unroll ×3 (V2)    | ~25          | ~100        | ~125       |
| Unroll ×9 LUT (V3)| ~45          | ~100        | ~145       |
| Unroll ×9 DSP (V4)| ~72          | ~100        | ~172       |

## Power Breakdown (V4 - DSP Design)

| Component | Power (mW) | % of Dynamic |
|-----------|------------|--------------|
| DSP48E1   | ~54        | 75%          |
| Logic     | ~8         | 11%          |
| Signals   | ~6         | 8%           |
| Clock     | ~4         | 6%           |

## Key Observations

- Static power dominates in all designs (~100 mW baseline)
- DSP blocks consume more instantaneous power but less energy per operation
- Clock and I/O power significant due to test configuration
- Final power will reduce after PS–PL integration (shared resources)

## Energy per Inference

| Variant | Latency (ns) | Power (mW) | Energy (pJ) |
|---------|--------------|------------|-------------|
| V1      | 90           | 115        | 10,350      |
| V4      | 10           | 172        | 1,720       |

**Conclusion:** V4 uses 83% less energy per inference despite higher power.
