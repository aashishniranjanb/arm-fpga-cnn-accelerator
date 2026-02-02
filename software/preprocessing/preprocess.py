"""
CPU Preprocessing for CNN Accelerator
Runs on ARM Cortex-A before FPGA inference

This script:
1. Loads grayscale image
2. Resizes to 32x32
3. Extracts 3x3 window
4. Quantizes to int8 for FPGA
"""

import numpy as np
import os

try:
    from PIL import Image
    USE_PIL = True
except ImportError:
    USE_PIL = False

def preprocess_image(path):
    """
    Preprocess image for FPGA accelerator.
    
    Input:  Path to grayscale image
    Output: int8 flattened 3x3 window for AXI-Stream
    """
    if USE_PIL:
        # Load and convert to grayscale
        img = Image.open(path).convert('L')
        # Resize to 32x32
        img = img.resize((32, 32))
        img = np.array(img)
    else:
        # Load from text file
        img = np.loadtxt(path, dtype=np.uint8)
    
    # Extract top-left 3x3 window (for convolution demo)
    window = img[0:3, 0:3]
    
    # Normalize to [-128, 127] and quantize to int8
    window = (window / 255.0 * 127).astype(np.int8)
    
    return window.flatten()

def normalize_int8(pixel, mean=128, scale=2):
    """
    Convert uint8 pixel to int8 for DSP-friendly inference.
    Formula: x_norm = (x - mean) / scale
    """
    return np.int8((pixel - mean) // scale)

# Test
if __name__ == "__main__":
    # Try loading sample image
    sample_path = "../../datasets/sample_images/img_0.png"
    
    if os.path.exists(sample_path):
        data = preprocess_image(sample_path)
        print("Preprocessed 3x3 input:", data)
        print(f"Shape: {data.shape}, dtype: {data.dtype}")
    else:
        # Fallback: create synthetic test
        print("Sample image not found, using synthetic test...")
        img = np.ones((3, 3), dtype=np.uint8) * 128
        result = (img / 255.0 * 127).astype(np.int8).flatten()
        print("Synthetic 3x3 input:", result)
