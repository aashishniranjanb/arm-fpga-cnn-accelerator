import cv2
import numpy as np
import time

# -----------------------------
# Configuration
# -----------------------------
IMG_SIZE = 32          # larger than toy, still manageable
KERNEL_SIZE = 3
DTYPE = np.int8        # match FPGA intent
REPEAT = 1000          # for stable timing

# -----------------------------
# Input Data
# -----------------------------
image = np.ones((IMG_SIZE, IMG_SIZE), dtype=DTYPE)

kernel = np.array([
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1]
], dtype=DTYPE)

# -----------------------------
# Convolution Function
# -----------------------------
def cpu_convolution(img, ker):
    """
    Perform 2D convolution using OpenCV filter2D.
    Uses int16 accumulator to avoid overflow with INT8 inputs.
    This matches the FPGA accelerator's data path exactly.
    """
    output = cv2.filter2D(
        img.astype(np.int16),
        ddepth=cv2.CV_16S,
        kernel=ker.astype(np.int16)
    )
    return output

# -----------------------------
# Warm-up (IMPORTANT)
# Avoids cache cold-start bias and
# one-time OpenCV setup overhead
# -----------------------------
for _ in range(10):
    cpu_convolution(image, kernel)

# -----------------------------
# Timing
# Using averaged iterations for stable,
# repeatable benchmarking results
# -----------------------------
start = time.perf_counter()

for _ in range(REPEAT):
    output = cpu_convolution(image, kernel)

end = time.perf_counter()

avg_time_ms = ((end - start) / REPEAT) * 1000

# -----------------------------
# Results
# -----------------------------
print("=" * 40)
print("CPU CNN Convolution (OpenCV)")
print("=" * 40)
print(f"Image size: {IMG_SIZE} x {IMG_SIZE}")
print(f"Kernel size: {KERNEL_SIZE}x{KERNEL_SIZE}")
print(f"Data type: {DTYPE}")
print(f"Output[0,0]: {int(output[0, 0])}")
print(f"Average execution time per run (ms): {avg_time_ms:.6f}")
print("=" * 40)
