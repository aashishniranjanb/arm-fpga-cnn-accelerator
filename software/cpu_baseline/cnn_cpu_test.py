import time

IMG_SIZE = 8
KERNEL_SIZE = 3
OUT_SIZE = IMG_SIZE - KERNEL_SIZE + 1

# Initialize image and kernel with all 1s
image = [[1 for _ in range(IMG_SIZE)] for _ in range(IMG_SIZE)]
kernel = [[1 for _ in range(KERNEL_SIZE)] for _ in range(KERNEL_SIZE)]
output = [[0 for _ in range(OUT_SIZE)] for _ in range(OUT_SIZE)]

# Measure time
start = time.perf_counter_ns()

# 3x3 Convolution
for i in range(OUT_SIZE):
    for j in range(OUT_SIZE):
        sum_val = 0
        for ki in range(KERNEL_SIZE):
            for kj in range(KERNEL_SIZE):
                sum_val += image[i + ki][j + kj] * kernel[ki][kj]
        output[i][j] = sum_val

end = time.perf_counter_ns()

duration = end - start

print("CPU Convolution completed")
print(f"Execution time (ns): {duration}")
print(f"Sample output[0][0]: {output[0][0]}")
