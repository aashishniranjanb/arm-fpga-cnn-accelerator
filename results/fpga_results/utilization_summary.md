# FPGA Resource Utilization Summary

**Target Device:** Xilinx Zynq-7000 (xc7z020clg400-1)

## Resource Usage by Variant

| Design Variant        | LUTs | FFs | DSPs | BRAM |
|----------------------|------|-----|------|------|
| Serial (V1)          | 159  | 38  | 0    | 0    |
| Unroll ×3 (V2)       | 329  | 37  | 0    | 0    |
| Unroll ×9 LUT (V3)   | 758  | 17  | 0    | 0    |
| Unroll ×9 DSP (V4)   | 0    | 1   | 9    | 0    |

## Key Observations

1. **Parallelism Trade-off:** Increasing unroll factor linearly increases LUT usage
2. **DSP Binding:** Using DSP48E1 blocks eliminates LUT cost for MAC operations
3. **Register Usage:** Lower FF count in unrolled designs due to reduced FSM complexity
4. **Optimal Choice:** V4 (DSP-bound) provides best performance-area trade-off

## Device Utilization (xc7z020)

| Resource | Available | V4 Used | % |
|----------|-----------|---------|---|
| LUTs     | 53,200    | ~100    | <0.2% |
| DSPs     | 220       | 9       | 4.1% |
| BRAM     | 140       | 0       | 0% |
