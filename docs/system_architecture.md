## System Architecture

The system is divided into two main components:

### Processing System (Arm CPU)
- Image acquisition or dataset loading
- Image preprocessing (resize, normalization)
- Control logic and data movement
- Post-processing and result visualization

### Programmable Logic (FPGA)
- Hardware-accelerated convolution layer
- INT8 fixed-point arithmetic
- Pipelined and parallel MAC operations

Data is transferred between PS and PL using AXI interfaces.
