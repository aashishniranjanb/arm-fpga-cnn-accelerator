# Sample Dataset

This dataset contains small grayscale images used to validate the CPU preprocessing and FPGA convolution pipeline.

## Purpose

Images are intentionally small (32×32) to focus on **hardware correctness and latency** rather than model accuracy.

## Contents

| File | Description |
|------|-------------|
| `img_0.png` | 32×32 grayscale sample image |
| `img_1.png` | 32×32 grayscale sample image |
| `img_2.png` | 32×32 grayscale sample image |
| `labels.txt` | Image labels (placeholder) |
| `sample_3x3.txt` | Raw 3×3 matrix for RTL testbench |

## Generation

Images are generated using:
```bash
cd software/preprocessing
python generate_dataset.py
```

## Usage

```python
import cv2
img = cv2.imread('datasets/sample_images/img_0.png', cv2.IMREAD_GRAYSCALE)
```

## Future Expansion

Full datasets (CIFAR-10, MNIST) will be integrated in later stages for end-to-end inference validation.
