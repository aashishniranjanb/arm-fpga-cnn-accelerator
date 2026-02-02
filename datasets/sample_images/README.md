# Sample Dataset

This folder contains minimal sample inputs used for validating CNN convolution correctness.

## Contents

| File | Description |
|------|-------------|
| `sample_3x3.txt` | 3×3 input matrix for RTL testbench validation |

## Purpose

- Verify RTL functional correctness
- Match CPU golden reference output
- Minimal footprint for quick testing

## Future Expansion

Full datasets (CIFAR-10, MNIST) will be integrated in later stages for end-to-end inference validation.

## Usage

```python
import numpy as np
img = np.loadtxt('sample_3x3.txt', dtype=np.int8)
```
