## Problem Statement 5: Hardware-Accelerated CNN on Zynq SoC

The objective of this project is to design and implement a real-time CNN inference system on a Xilinx Zynq SoC by leveraging FPGA fabric to accelerate compute-intensive operations. The system must demonstrate measurable performance improvements over a software-only CNN execution on the Arm CPU.

The design follows a hardware/software co-design paradigm:
- The Arm CPU handles image preprocessing, control logic, and post-processing.
- The FPGA fabric accelerates convolutional layers using parallel hardware execution.

Performance is evaluated through latency, throughput, and FPGA resource utilization, validated using synthesis and simulation.
