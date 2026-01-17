#include <stdint.h>

void conv2d(
    int8_t input[9],
    int8_t kernel[9],
    int16_t *output
) {
#pragma HLS PIPELINE
    int16_t sum = 0;
    for (int i = 0; i < 9; i++) {
#pragma HLS UNROLL
        sum += input[i] * kernel[i];
    }
    *output = sum;
}
