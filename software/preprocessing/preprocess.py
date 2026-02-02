"""
CPU Preprocessing for CNN Accelerator
Runs on ARM Cortex-A before FPGA inference
"""

import numpy as np

def preprocess(img):
    """
    Preprocess image for FPGA accelerator.
    
    Input:  3x3 grayscale image (uint8)
    Output: int8 flattened vector for AXI-Stream
    """
    # Normalize to int8 range
    img = img.astype(np.int8)
    # Flatten for streaming
    return img.flatten()

def normalize_int8(pixel, mean=128, scale=8):
    """
    Convert uint8 pixel to int8 for DSP-friendly inference.
    Formula: x_norm = (x - mean) / scale
    """
    return np.int8((pixel - mean) >> 3)

# Test
if __name__ == "__main__":
    # Sample 3x3 input (matches RTL testbench)
    img = np.ones((3, 3), dtype=np.uint8)
    result = preprocess(img)
    print(f"Input shape: {img.shape}")
    print(f"Output: {result}")
    print(f"Output dtype: {result.dtype}")
