/**
 * CPU Preprocessing for CNN Accelerator
 * Runs on ARM Cortex-A before FPGA inference
 */

#include <iostream>
#include <stdint.h>

/**
 * Preprocess 3x3 image for FPGA accelerator
 * @param img   Input 3x3 grayscale image (uint8)
 * @param out   Output flattened int8 array for AXI-Stream
 */
void preprocess(uint8_t img[3][3], int8_t out[9]) {
    for (int i = 0; i < 9; i++) {
        out[i] = (int8_t)img[i / 3][i % 3];
    }
}

/**
 * Normalize pixel to int8 for DSP-friendly inference
 * Formula: x_norm = (x - mean) / scale
 */
int8_t normalize_int8(uint8_t pixel) {
    return (int8_t)((pixel - 128) >> 3);
}

int main() {
    // Sample 3x3 input (matches RTL testbench)
    uint8_t img[3][3] = {
        {1, 1, 1},
        {1, 1, 1},
        {1, 1, 1}
    };
    int8_t out[9];
    
    preprocess(img, out);
    
    std::cout << "Preprocessing OK" << std::endl;
    std::cout << "Output: ";
    for (int i = 0; i < 9; i++) {
        std::cout << (int)out[i] << " ";
    }
    std::cout << std::endl;
    
    return 0;
}
