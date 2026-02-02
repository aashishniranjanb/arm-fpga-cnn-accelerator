/**
 * CPU Preprocessing for CNN Accelerator
 * Runs on ARM Cortex-A before FPGA inference
 * 
 * Requires OpenCV: g++ preprocess.cpp -o preprocess `pkg-config --cflags --libs opencv4`
 */

#include <opencv2/opencv.hpp>
#include <iostream>
#include <stdint.h>

int main() {
    // Load grayscale image
    cv::Mat img = cv::imread("../../datasets/sample_images/img_0.png", cv::IMREAD_GRAYSCALE);
    
    if (img.empty()) {
        std::cerr << "Error: Could not load image" << std::endl;
        return 1;
    }
    
    // Resize to 32x32
    cv::resize(img, img, cv::Size(32, 32));
    
    // Extract and print 3x3 window
    std::cout << "3x3 window (int8 quantized):" << std::endl;
    int8_t window[9];
    int idx = 0;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            // Normalize to int8: (pixel / 255) * 127
            int8_t val = (img.at<uchar>(i, j) * 127) / 255;
            window[idx++] = val;
            std::cout << (int)val << " ";
        }
        std::cout << std::endl;
    }
    
    // Print flattened array (for AXI-Stream)
    std::cout << "\nFlattened for AXI-Stream: ";
    for (int i = 0; i < 9; i++) {
        std::cout << (int)window[i] << " ";
    }
    std::cout << std::endl;
    
    return 0;
}
