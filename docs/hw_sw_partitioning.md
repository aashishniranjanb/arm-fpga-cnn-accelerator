## Hardware/Software Partitioning

### Software (Arm CPU) Responsibilities
- Image preprocessing and normalization
- Model parameter loading and management
- DMA transfers to/from FPGA
- Post-processing and inference control

### Hardware (FPGA) Responsibilities
- Parallel convolution computation
- Fixed-point INT8 arithmetic
- Pipelined data flow for throughput optimization
- Result buffering for CPU retrieval

### Interface
- AXI4-Lite for register access and control
- AXI4 or AXI DMA for high-bandwidth data transfers
