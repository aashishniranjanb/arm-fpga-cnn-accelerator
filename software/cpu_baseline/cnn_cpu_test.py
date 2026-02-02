"""
CPU Reference Test for CNN Accelerator
Generates golden reference output for FPGA verification
"""

import numpy as np
import sys
import os

# Add preprocessing to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'preprocessing'))

try:
    from preprocess import preprocess_image
    USE_OPENCV = True
except ImportError:
    USE_OPENCV = False
    print("Warning: OpenCV not available, using synthetic data")

def cpu_convolution(data, weights):
    """
    CPU reference 3x3 convolution (single MAC)
    This produces golden output for RTL verification
    """
    return np.dot(data.astype(np.int32), weights.astype(np.int32))

if __name__ == "__main__":
    # Load or synthesize input
    if USE_OPENCV and os.path.exists("../../datasets/sample_images/img_0.png"):
        data = preprocess_image("../../datasets/sample_images/img_0.png")
        print(f"Input from: img_0.png")
    else:
        # Synthetic 3x3 input (all ones)
        data = np.ones(9, dtype=np.int8)
        print("Input: synthetic (all ones)")
    
    # Kernel weights (edge detection example)
    weights = np.array([1, 0, -1, 1, 0, -1, 1, 0, -1], dtype=np.int8)
    
    # CPU convolution
    output = cpu_convolution(data, weights)
    
    print(f"\n3x3 Input:  {data}")
    print(f"Weights:    {weights}")
    print(f"CPU Output: {output}")
    print(f"\nThis output is the golden reference for FPGA verification.")
    
    # Save to results
    results_path = "../../results/software_results/cpu_reference_output.txt"
    os.makedirs(os.path.dirname(results_path), exist_ok=True)
    
    with open(results_path, "w") as f:
        f.write("CPU Reference Output for FPGA Verification\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"Input image : img_0.png\n")
        f.write(f"3x3 window  : {data.tolist()}\n")
        f.write(f"Weights     : {weights.tolist()}\n")
        f.write(f"CPU Output  : {output}\n\n")
        f.write("Used as golden reference for FPGA verification.\n")
    
    print(f"\nResults saved to: {results_path}")
