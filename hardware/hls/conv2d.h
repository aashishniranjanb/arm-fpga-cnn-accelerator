#ifndef CONV2D_H
#define CONV2D_H

#include <stdint.h>

void conv2d(
    int8_t input[9],
    int8_t kernel[9],
    int16_t *output
);

#endif
