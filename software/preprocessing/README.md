# CPU Preprocessing Stage

This folder contains CPU-side preprocessing code executed on the Arm processor.
Preprocessing is kept on CPU to avoid wasting FPGA resources.

## Pipeline Steps

1. **Image loading** — Read from memory/camera
2. **Grayscale conversion** — RGB to single channel
3. **Normalization to int8** — Scale for FPGA-friendly inference
4. **Sliding-window extraction** — Prepare 3×3 windows for convolution

## Output

Preprocessed data is streamed to the FPGA accelerator via AXI-Stream.

## Why CPU?

| Task | CPU | FPGA |
|------|-----|------|
| File I/O | ✅ | ❌ |
| Irregular control | ✅ | ❌ |
| Heavy MAC ops | ❌ | ✅ |

This partitioning follows standard SoC design practices.
