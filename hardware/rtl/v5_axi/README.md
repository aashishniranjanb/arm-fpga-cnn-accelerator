# RTL-V5: AXI4-Lite CNN Accelerator

This directory contains the AXI4-Lite wrapped version of the DSP-accelerated CNN convolution core, enabling ARM CPU control via memory-mapped registers.

---

## Files

| File | Description |
|------|-------------|
| `conv2d_axi_lite.v` | AXI4-Lite wrapper for CNN accelerator |
| `tb_conv2d_axi_lite.v` | Testbench simulating ARM CPU control |

---

## Architecture

```
ARM CPU (PS)
     │
     │ AXI4-Lite (32-bit data, 7-bit addr)
     ▼
┌─────────────────────────┐
│   conv2d_axi_lite       │
│   ┌─────────────────┐   │
│   │  Register File  │   │
│   │  (19 registers) │   │
│   └────────┬────────┘   │
│            ▼            │
│   ┌─────────────────┐   │
│   │ conv2d_unroll9  │   │
│   │     _dsp        │   │
│   │  (9 DSP48E1)    │   │
│   └─────────────────┘   │
└─────────────────────────┘
```

---

## Register Map

| Offset | Name | Description |
|--------|------|-------------|
| 0x00 | CTRL | bit[0]=start, bit[1]=done |
| 0x04–0x24 | IN0–IN8 | Input pixels (signed 8-bit) |
| 0x28–0x48 | W0–W8 | Kernel weights (signed 8-bit) |
| 0x4C | OUT | Result (signed 16-bit) |

---

## Expected Synthesis Results

| Resource | Count |
|----------|-------|
| DSP48E1 | 9 |
| LUTs | ~50 (AXI logic) |
| FFs | ~100 (registers) |

---

## Simulation

Run testbench in Vivado:
1. Add both files to project
2. Set `tb_conv2d_axi_lite` as simulation top
3. Run Behavioral Simulation
4. Expected output: `Result = 9, STATUS: TEST PASSED`

---

## Target Device

- Xilinx Zynq-7020 (xc7z020clg400-1)
- AXI base address: 0x43C00000
