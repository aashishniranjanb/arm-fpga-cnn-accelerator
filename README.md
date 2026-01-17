# Hardware-Accelerated CNN on Arm–FPGA SoC

## Overview
This project implements a hardware-accelerated convolutional neural network (CNN) inference pipeline on a Xilinx Zynq System-on-Chip (SoC). The design follows a hardware/software co-design approach, where compute-intensive CNN layers are accelerated in FPGA fabric while control, preprocessing, and post-processing run on the Arm CPU.

## Objective
To quantitatively demonstrate performance improvements (latency and throughput) of FPGA-accelerated CNN inference compared to a CPU-only implementation on an Arm processor.

## Key Features
- Lightweight CNN for edge vision tasks
- INT8 convolution accelerator using Vivado/Vitis HLS
- Arm CPU baseline implementation for comparison
- Hardware/software partitioning using AXI interfaces
- Performance evaluation using synthesis and simulation reports

## Target Platform
- Xilinx Zynq-7000 family (board-independent design)
- Arm Cortex-A class processor
- FPGA fabric for CNN acceleration

## Project Status
🚧 In progress – architecture and baseline implementation underway.
