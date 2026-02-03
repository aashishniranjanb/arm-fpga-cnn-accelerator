# CPU Preprocessing

The CPU (ARM Cortex-A9) performs:

1. **Image loading** from storage
2. **Resize** to 32×32 grayscale
3. **Normalization** to INT8
4. **Sliding window extraction** (3×3)

Only convolution math is offloaded to FPGA.
This minimizes FPGA control logic and maximizes efficiency.

---

## Why CPU for Preprocessing?

| Task | CPU | FPGA |
|------|-----|------|
| File I/O | ✅ | ❌ |
| Resize/Interpolation | ✅ | ❌ |
| Irregular control | ✅ | ❌ |
| Heavy MAC ops | ❌ | ✅ |

This partitioning follows standard **SoC design practices**.

---

## Files

| File | Description |
|------|-------------|
| `preprocess.py` | Python preprocessing (PIL-based) |
| `preprocess.cpp` | C++ preprocessing (OpenCV) |
| `generate_dataset.py` | Sample image generator |

---

## Usage

```bash
# Generate sample dataset
python generate_dataset.py

# Run preprocessing
python preprocess.py
```

---

## Output Format

Preprocessed data is:
- Flattened to 9-element int8 array
- Ready for AXI-Stream to FPGA accelerator
