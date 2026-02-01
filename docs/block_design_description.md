# Block Design Description

## PS–PL Integration Architecture

The CNN accelerator is integrated into a Zynq-7000 SoC using AXI4-Lite.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Zynq-7000 SoC                        │
├─────────────────────────┬───────────────────────────────┤
│   Processing System     │     Programmable Logic        │
│   (ARM Cortex-A9)       │         (FPGA)                │
│                         │                               │
│   ┌─────────────────┐   │   ┌───────────────────────┐   │
│   │   Application   │   │   │    AXI Interconnect   │   │
│   │     (C code)    │   │   └───────────┬───────────┘   │
│   └────────┬────────┘   │               │               │
│            │            │   ┌───────────▼───────────┐   │
│            │            │   │   conv2d_axi_lite     │   │
│   ┌────────▼────────┐   │   │   ┌───────────────┐   │   │
│   │   AXI Master    │───┼───│   │ conv2d_unroll │   │   │
│   │   (M_AXI_GP0)   │   │   │   │   9_dsp       │   │   │
│   └─────────────────┘   │   │   │ (9 DSP48E1)   │   │   │
│                         │   │   └───────────────┘   │   │
└─────────────────────────┴───┴───────────────────────────┘
```

---

## Key Components

### Processing System (PS)
- **ARM Cortex-A9** dual-core processor
- Runs bare-metal or Linux application
- Controls accelerator via AXI master port

### Programmable Logic (PL)
- **AXI4-Lite Wrapper** interfaces with PS
- **CNN Accelerator** performs 3×3 convolution
- 9 DSP48E1 blocks for parallel MAC operations

### AXI Interface
- **Protocol:** AXI4-Lite (memory-mapped)
- **Data Width:** 32 bits
- **Address Space:** 0x43C00000 (64KB)

---

## Address Map

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | CTRL | Control (start/done) |
| 0x04–0x24 | IN0–IN8 | Input pixels |
| 0x28–0x48 | W0–W8 | Kernel weights |
| 0x4C | OUT | Convolution result |

---

## Data Flow

1. ARM writes kernel weights (once per layer)
2. ARM writes 3×3 input window
3. ARM asserts start bit
4. Accelerator computes in 1 cycle
5. ARM polls done bit
6. ARM reads result

---

## Integration Benefits

- ✅ Software-controlled hardware acceleration
- ✅ Memory-mapped I/O (simple programming model)
- ✅ Zero-copy interface (direct register access)
- ✅ Deterministic latency (1 cycle compute)

---

## Vivado Block Design Steps

1. **Create Block Design** → Name: `cnn_zynq_bd`
2. **Add Zynq PS** → Run Block Automation
3. **Add CNN IP** → `conv2d_axi_lite`
4. **Run Connection Automation** → Connect to M_AXI_GP0
5. **Address Editor** → Set base to 0x43C00000
6. **Validate Design** → Generate HDL Wrapper

---

## Key Takeaway

> This enables end-to-end hardware/software co-design on Zynq SoC, where ARM software controls a custom CNN accelerator through a standard AXI interface.
