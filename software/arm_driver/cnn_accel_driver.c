//-----------------------------------------------------------------------------
// CNN Accelerator ARM Driver (Bare-metal)
//-----------------------------------------------------------------------------
// Target: Xilinx Zynq-7000 ARM Cortex-A9
// Interface: AXI4-Lite memory-mapped registers
// Purpose: Configure, start, and read results from CNN accelerator
//-----------------------------------------------------------------------------

#include <stdint.h>
#include <stdio.h>

// --------------------------------------------------
// AXI Base Address (typical for Zynq PL peripheral)
// --------------------------------------------------
#define CNN_BASE_ADDR  0x43C00000

// --------------------------------------------------
// Register Offsets (match RTL register map)
// --------------------------------------------------
#define REG_CTRL   0x00    // bit[0]=start, bit[1]=done
#define REG_IN0    0x04    // First input pixel
#define REG_W0     0x28    // First kernel weight
#define REG_OUT    0x4C    // Convolution result

// --------------------------------------------------
// Memory-Mapped I/O Access Macros
// --------------------------------------------------
#define REG32(addr)       (*(volatile uint32_t *)(addr))
#define CNN_REG(offset)   REG32(CNN_BASE_ADDR + (offset))

// --------------------------------------------------
// CNN Driver API Functions
// --------------------------------------------------

/**
 * Write a single input pixel to the accelerator
 * @param index Pixel index (0-8 for 3x3 window)
 * @param value Signed 8-bit pixel value
 */
void cnn_write_input(uint8_t index, int8_t value) {
    if (index < 9) {
        CNN_REG(REG_IN0 + index * 4) = (uint32_t)(uint8_t)value;
    }
}

/**
 * Write a single kernel weight to the accelerator
 * @param index Weight index (0-8 for 3x3 kernel)
 * @param value Signed 8-bit weight value
 */
void cnn_write_weight(uint8_t index, int8_t value) {
    if (index < 9) {
        CNN_REG(REG_W0 + index * 4) = (uint32_t)(uint8_t)value;
    }
}

/**
 * Write all 9 input pixels at once
 * @param pixels Array of 9 signed 8-bit values
 */
void cnn_write_inputs(const int8_t pixels[9]) {
    for (int i = 0; i < 9; i++) {
        cnn_write_input(i, pixels[i]);
    }
}

/**
 * Write all 9 kernel weights at once
 * @param weights Array of 9 signed 8-bit values
 */
void cnn_write_weights(const int8_t weights[9]) {
    for (int i = 0; i < 9; i++) {
        cnn_write_weight(i, weights[i]);
    }
}

/**
 * Start the CNN accelerator computation
 */
void cnn_start(void) {
    CNN_REG(REG_CTRL) = 0x1;
}

/**
 * Check if accelerator has completed
 * @return 1 if done, 0 otherwise
 */
int cnn_is_done(void) {
    return (CNN_REG(REG_CTRL) >> 1) & 0x1;
}

/**
 * Wait for accelerator to complete (blocking)
 */
void cnn_wait_done(void) {
    while (!cnn_is_done());
}

/**
 * Read the convolution result
 * @return Signed 16-bit result
 */
int16_t cnn_read_result(void) {
    return (int16_t)CNN_REG(REG_OUT);
}

/**
 * Perform a complete convolution operation
 * @param pixels Input pixel window (3x3)
 * @param weights Kernel weights (3x3)
 * @return Convolution result
 */
int16_t cnn_convolve(const int8_t pixels[9], const int8_t weights[9]) {
    cnn_write_inputs(pixels);
    cnn_write_weights(weights);
    cnn_start();
    cnn_wait_done();
    return cnn_read_result();
}

// --------------------------------------------------
// Test Program (Bare-metal main)
// --------------------------------------------------

#ifdef CNN_DRIVER_TEST

int main(void) {
    int16_t result;

    // Test data: all ones
    int8_t test_pixels[9]  = {1, 1, 1, 1, 1, 1, 1, 1, 1};
    int8_t test_weights[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};

    printf("===========================================\n");
    printf("CNN Accelerator Driver Test (Bare-metal)\n");
    printf("Target: Zynq-7000 @ 0x%08X\n", CNN_BASE_ADDR);
    printf("===========================================\n");

    // Run convolution
    result = cnn_convolve(test_pixels, test_weights);

    // Display results
    printf("Convolution Result = %d\n", result);
    printf("Expected Result    = 9\n");
    printf("Status: %s\n", (result == 9) ? "PASSED" : "FAILED");
    printf("===========================================\n");

    // Halt
    while (1);

    return 0;
}

#endif // CNN_DRIVER_TEST
