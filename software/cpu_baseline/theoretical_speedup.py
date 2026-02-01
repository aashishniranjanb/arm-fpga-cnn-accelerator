"""
Theoretical Speedup Calculator
==============================
Compares measured CPU performance vs theoretical FPGA performance
for CNN convolution operations.

This calculator uses the pipelined accelerator model to predict
FPGA execution time and compute expected speedup.
"""

# ========================================
# INPUT: MEASURED CPU PERFORMANCE
# ========================================
# TODO: Replace with your actual benchmark results from cnn_cpu.py
# Run: python cnn_cpu.py and copy the average execution time here

CPU_AVG_TIME_MS = 0.45  # Example value - UPDATE with your measured result
# Calculated from: throughput = 1000 / CPU_AVG_TIME_MS
CPU_THROUGHPUT_RUNS_PER_SEC = 1000 / CPU_AVG_TIME_MS

# ========================================
# FPGA THEORETICAL MODEL PARAMETERS
# ========================================

# Target clock frequency (conservative for Basys3 Artix-7)
FPGA_CLOCK_FREQ_MHZ = 100

# Image and convolution parameters (must match CPU baseline)
IMG_SIZE = 32
KERNEL_SIZE = 3
OUTPUT_SIZE = IMG_SIZE - KERNEL_SIZE + 1  # 30×30 = 900 pixels
TOTAL_OUTPUT_PIXELS = OUTPUT_SIZE * OUTPUT_SIZE

# HLS Pipeline model (expected values - update after synthesis)
PIPELINE_LATENCY_CYCLES = 12  # Initial pipeline fill latency
INITIATION_INTERVAL = 1       # Outputs per cycle (II=1 means fully pipelined)

# ========================================
# FPGA PERFORMANCE CALCULATION
# ========================================

# Total cycles = Latency + (Pixels - 1) × II
TOTAL_CYCLES = PIPELINE_LATENCY_CYCLES + (TOTAL_OUTPUT_PIXELS - 1) * INITIATION_INTERVAL

# Clock period in nanoseconds
CLOCK_PERIOD_NS = 1000 / FPGA_CLOCK_FREQ_MHZ  # 10 ns for 100 MHz

# FPGA execution time
FPGA_TIME_NS = TOTAL_CYCLES * CLOCK_PERIOD_NS
FPGA_TIME_US = FPGA_TIME_NS / 1000
FPGA_TIME_MS = FPGA_TIME_US / 1000

# FPGA throughput
FPGA_THROUGHPUT_RUNS_PER_SEC = 1000 / FPGA_TIME_MS

# ========================================
# SPEEDUP CALCULATION
# ========================================

LATENCY_SPEEDUP = CPU_AVG_TIME_MS / FPGA_TIME_MS
THROUGHPUT_SPEEDUP = FPGA_THROUGHPUT_RUNS_PER_SEC / CPU_THROUGHPUT_RUNS_PER_SEC

# ========================================
# REPORT GENERATION
# ========================================

def print_report():
    """Generate formatted speedup analysis report."""
    
    print("=" * 70)
    print(" THEORETICAL SPEEDUP ANALYSIS: CPU vs FPGA CNN Convolution")
    print("=" * 70)
    
    print("\n📐 CONVOLUTION PARAMETERS")
    print(f"   Image size:       {IMG_SIZE}×{IMG_SIZE}")
    print(f"   Kernel size:      {KERNEL_SIZE}×{KERNEL_SIZE}")
    print(f"   Output size:      {OUTPUT_SIZE}×{OUTPUT_SIZE} = {TOTAL_OUTPUT_PIXELS} pixels")
    
    print("\n📊 CPU PERFORMANCE (Measured)")
    print(f"   Latency:          {CPU_AVG_TIME_MS:.6f} ms ({CPU_AVG_TIME_MS * 1000:.3f} µs)")
    print(f"   Throughput:       {CPU_THROUGHPUT_RUNS_PER_SEC:.2f} runs/sec")
    
    print("\n⚡ FPGA PERFORMANCE (Theoretical)")
    print(f"   Clock frequency:  {FPGA_CLOCK_FREQ_MHZ} MHz")
    print(f"   Clock period:     {CLOCK_PERIOD_NS:.1f} ns")
    print(f"   Pipeline latency: {PIPELINE_LATENCY_CYCLES} cycles")
    print(f"   Initiation Int.:  {INITIATION_INTERVAL} (II={INITIATION_INTERVAL})")
    print(f"   Total cycles:     {TOTAL_CYCLES}")
    print(f"   Latency:          {FPGA_TIME_MS:.6f} ms ({FPGA_TIME_US:.3f} µs)")
    print(f"   Throughput:       {FPGA_THROUGHPUT_RUNS_PER_SEC:.2f} runs/sec")
    
    print("\n🚀 EXPECTED SPEEDUP")
    print(f"   Latency speedup:     {LATENCY_SPEEDUP:.2f}×")
    print(f"   Throughput speedup:  {THROUGHPUT_SPEEDUP:.2f}×")
    
    print("\n" + "-" * 70)
    print(" FORMULA USED:")
    print(f"   T_FPGA = (L + (N-1) × II) × T_clk")
    print(f"          = ({PIPELINE_LATENCY_CYCLES} + ({TOTAL_OUTPUT_PIXELS}-1) × {INITIATION_INTERVAL}) × {CLOCK_PERIOD_NS}ns")
    print(f"          = {TOTAL_CYCLES} × {CLOCK_PERIOD_NS}ns")
    print(f"          = {FPGA_TIME_NS:.1f} ns = {FPGA_TIME_US:.3f} µs")
    print("-" * 70)
    
    print("\n" + "=" * 70)
    print(" ✓ Theoretical model complete. Ready for HLS validation.")
    print("=" * 70)
    
    # Return values for programmatic use
    return {
        "cpu_latency_ms": CPU_AVG_TIME_MS,
        "fpga_latency_ms": FPGA_TIME_MS,
        "latency_speedup": LATENCY_SPEEDUP,
        "throughput_speedup": THROUGHPUT_SPEEDUP,
        "total_cycles": TOTAL_CYCLES
    }


if __name__ == "__main__":
    results = print_report()
