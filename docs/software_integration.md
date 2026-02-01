# ARM–FPGA Software Integration

This document describes the hardware/software interface between the ARM Processing System (PS) and the CNN accelerator in the FPGA Programmable Logic (PL).

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Zynq-7000 SoC                        │
├─────────────────────────┬───────────────────────────────┤
│   Processing System     │     Programmable Logic        │
│   (ARM Cortex-A9)       │         (FPGA)                │
│                         │                               │
│   ┌─────────────────┐   │   ┌───────────────────────┐   │
│   │  ARM C Driver   │───┼───│   AXI4-Lite Wrapper   │   │
│   │  (bare-metal)   │   │   │                       │   │
│   └─────────────────┘   │   │   ┌───────────────┐   │   │
│                         │   │   │ conv2d_dsp    │   │   │
│   Memory-Mapped I/O     │   │   │ (9 DSP48E1)   │   │   │
│   @ 0x43C00000          │   │   └───────────────┘   │   │
│                         │   └───────────────────────┘   │
└─────────────────────────┴───────────────────────────────┘
```

---

## AXI4-Lite Register Map

The accelerator is controlled via memory-mapped registers:

| Offset | Name | Width | Access | Description |
|--------|------|-------|--------|-------------|
| 0x00 | CTRL | 32 | R/W | Control: bit[0]=start, bit[1]=done |
| 0x04 | IN0 | 8 | W | Input pixel 0 |
| 0x08 | IN1 | 8 | W | Input pixel 1 |
| ... | ... | ... | ... | ... |
| 0x24 | IN8 | 8 | W | Input pixel 8 |
| 0x28 | W0 | 8 | W | Kernel weight 0 |
| ... | ... | ... | ... | ... |
| 0x48 | W8 | 8 | W | Kernel weight 8 |
| 0x4C | OUT | 16 | R | Convolution result (signed) |

---

## ARM Driver API

The bare-metal driver provides a simple API:

```c
// Write single input/weight
void cnn_write_input(uint8_t index, int8_t value);
void cnn_write_weight(uint8_t index, int8_t value);

// Bulk write operations
void cnn_write_inputs(const int8_t pixels[9]);
void cnn_write_weights(const int8_t weights[9]);

// Control operations
void cnn_start(void);
int  cnn_is_done(void);
void cnn_wait_done(void);

// Result retrieval
int16_t cnn_read_result(void);

// High-level convolution function
int16_t cnn_convolve(const int8_t pixels[9], const int8_t weights[9]);
```

---

## Usage Example

```c
#include "cnn_accel_driver.h"

int main() {
    int8_t pixels[9]  = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    int8_t weights[9] = {1, 0, -1, 2, 0, -2, 1, 0, -1};
    
    int16_t result = cnn_convolve(pixels, weights);
    
    printf("Convolution result: %d\n", result);
    return 0;
}
```

---

## Software Flow

1. **Configure**: Write 9 input pixels to registers 0x04–0x24
2. **Load Kernel**: Write 9 weights to registers 0x28–0x48
3. **Start**: Write 1 to CTRL register (0x00)
4. **Poll**: Read CTRL register until bit[1] (done) is set
5. **Read**: Read result from OUT register (0x4C)

---

## Performance Characteristics

| Metric | Value |
|--------|-------|
| Register writes per convolution | 19 (9 inputs + 9 weights + 1 start) |
| Hardware latency | 1 clock cycle |
| Total latency (SW + HW) | ~20 AXI transactions |
| Throughput | Limited by AXI bus bandwidth |

---

## Files

| File | Description |
|------|-------------|
| `hardware/rtl/v5_axi/conv2d_axi_lite.v` | AXI4-Lite wrapper RTL |
| `hardware/rtl/v5_axi/tb_conv2d_axi_lite.v` | AXI testbench |
| `software/arm_driver/cnn_accel_driver.c` | ARM bare-metal driver |
| `software/arm_driver/cnn_accel_driver.h` | Driver header file |

---

## Verification Status

- ✅ AXI wrapper synthesizes correctly
- ✅ Testbench verifies complete transaction flow
- ✅ Driver implements full register map
- ⏳ Hardware validation pending (requires Zynq board)

---

## Integration Notes

For Vivado block design integration:

1. Package `conv2d_axi_lite` as custom IP
2. Connect to Zynq PS via AXI Interconnect
3. Assign base address in Address Editor (default: 0x43C00000)
4. Generate bitstream and export hardware
5. Import to Vitis for bare-metal application development
