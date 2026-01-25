#include <iostream>
#include <chrono>
#include <cstdint>

#define IMG_SIZE 8
#define KERNEL_SIZE 3
#define OUT_SIZE (IMG_SIZE - KERNEL_SIZE + 1)

int main() {
    int8_t image[IMG_SIZE][IMG_SIZE];
    int8_t kernel[KERNEL_SIZE][KERNEL_SIZE];
    int16_t output[OUT_SIZE][OUT_SIZE];

    // Initialize image and kernel
    for (int i = 0; i < IMG_SIZE; i++)
        for (int j = 0; j < IMG_SIZE; j++)
            image[i][j] = 1;

    for (int i = 0; i < KERNEL_SIZE; i++)
        for (int j = 0; j < KERNEL_SIZE; j++)
            kernel[i][j] = 1;

    auto start = std::chrono::high_resolution_clock::now();

    // 3x3 Convolution
    for (int i = 0; i < OUT_SIZE; i++) {
        for (int j = 0; j < OUT_SIZE; j++) {
            int16_t sum = 0;
            for (int ki = 0; ki < KERNEL_SIZE; ki++) {
                for (int kj = 0; kj < KERNEL_SIZE; kj++) {
                    sum += image[i + ki][j + kj] * kernel[ki][kj];
                }
            }
            output[i][j] = sum;
        }
    }

    auto end = std::chrono::high_resolution_clock::now();

    auto duration =
        std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);

    std::cout << "CPU Convolution completed\n";
    std::cout << "Execution time (ns): " << duration.count() << std::endl;
    std::cout << "Sample output[0][0]: " << output[0][0] << std::endl;

    return 0;
}
