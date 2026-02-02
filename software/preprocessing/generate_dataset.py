"""
Dataset Generator for CNN Accelerator Validation
Generates small grayscale images for hardware correctness testing
Uses PIL (Pillow) - standard library alternative to OpenCV
"""

import numpy as np
import os

try:
    from PIL import Image
    USE_PIL = True
except ImportError:
    USE_PIL = False
    print("PIL not available, generating raw numpy files instead")

# Output directory (relative to this script)
out_dir = "../../datasets/sample_images"
os.makedirs(out_dir, exist_ok=True)

# Set seed for reproducibility
np.random.seed(42)

# Generate 3 sample images (32x32 grayscale)
for i in range(3):
    img = np.random.randint(0, 256, (32, 32), dtype=np.uint8)
    
    if USE_PIL:
        # Save as PNG using PIL
        Image.fromarray(img, mode='L').save(f"{out_dir}/img_{i}.png")
        print(f"Generated: img_{i}.png (32x32 grayscale)")
    else:
        # Save as numpy text file
        np.savetxt(f"{out_dir}/img_{i}.txt", img, fmt='%d')
        print(f"Generated: img_{i}.txt (32x32 grayscale)")

# Generate labels file
with open(f"{out_dir}/labels.txt", "w") as f:
    for i in range(3):
        ext = ".png" if USE_PIL else ".txt"
        f.write(f"img_{i}{ext} 0\n")

print(f"\nDataset generated in {out_dir}/")
