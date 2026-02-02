# Timing Summary (Post-Synthesis)

**Target Clock:** 100 MHz (10 ns period)

## Timing Results by Variant

| Design Variant     | WNS (ns) | Slack Status | Estimated Fmax |
|-------------------|----------|--------------|----------------|
| Serial (V1)       | +2.5     | Met          | ~130 MHz       |
| Unroll ×3 (V2)    | +1.8     | Met          | ~120 MHz       |
| Unroll ×9 LUT (V3)| +0.9     | Met          | ~110 MHz       |
| Unroll ×9 DSP (V4)| +3.2     | Met          | ~150 MHz       |

## Key Observations

- All variants meet timing with positive slack at 100 MHz
- DSP-based design shows highest timing margin due to hardened arithmetic blocks
- LUT-based designs show increased path delay with higher parallelism
- V4 (DSP) achieves ~50% higher Fmax than V3 (LUT)

## Critical Path

- **V1-V3:** Through LUT-based multiplier chains
- **V4:** Through DSP48E1 internal routing (optimized)

## Conclusion

DSP binding not only saves LUTs but also improves timing closure.
