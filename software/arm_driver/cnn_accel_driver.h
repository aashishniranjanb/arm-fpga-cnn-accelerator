//-----------------------------------------------------------------------------
// CNN Accelerator Driver Header
//-----------------------------------------------------------------------------
// Bare-metal driver for AXI4-Lite CNN accelerator on Zynq-7000
//-----------------------------------------------------------------------------

#ifndef CNN_ACCEL_DRIVER_H
#define CNN_ACCEL_DRIVER_H

#include <stdint.h>

// Base address (update based on Vivado address editor)
#define CNN_BASE_ADDR  0x43C00000

// Driver API
void cnn_write_input(uint8_t index, int8_t value);
void cnn_write_weight(uint8_t index, int8_t value);
void cnn_write_inputs(const int8_t pixels[9]);
void cnn_write_weights(const int8_t weights[9]);
void cnn_start(void);
int  cnn_is_done(void);
void cnn_wait_done(void);
int16_t cnn_read_result(void);
int16_t cnn_convolve(const int8_t pixels[9], const int8_t weights[9]);

#endif // CNN_ACCEL_DRIVER_H
