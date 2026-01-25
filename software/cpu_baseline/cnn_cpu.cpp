#include <iostream>
#include <chrono>

int main() {
    int input[9]  = {1,1,1,1,1,1,1,1,1};
    int kernel[9] = {1,1,1,1,1,1,1,1,1};

    auto start = std::chrono::high_resolution_clock::now();

    int sum = 0;
    for (int i = 0; i < 9; i++) {
        sum += input[i] * kernel[i];
    }

    auto end = std::chrono::high_resolution_clock::now();

    std::cout << "Output: " << sum << std::endl;
    std::cout << "Time (ns): "
              << std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count()
              << std::endl;

    return 0;
}
