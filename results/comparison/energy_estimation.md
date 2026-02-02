# Energy per Inference Estimation

## Methodology

Energy = Power × Time

Using Vivado power estimates and measured latencies.

## Energy Comparison

| Platform | Power (mW) | Time (ms) | Energy (mJ) | Relative |
|----------|------------|-----------|-------------|----------|
| CPU (ARM A9) | 500 | 5.0 | 2.50 | 1× |
| FPGA Serial (V1) | 115 | 0.9 | 0.10 | 25× better |
| FPGA Unroll ×9 (V3) | 145 | 0.1 | 0.015 | 167× better |
| FPGA DSP (V4) | 172 | 0.1 | 0.017 | 147× better |

## Key Observations

1. **Serial design:** Low area, higher latency, moderate energy
2. **Unrolled LUT design:** Higher power, lowest energy per inference
3. **DSP design:** Best energy efficiency when accounting for full system

## Energy Efficiency Trend

```
Energy/Inference vs Parallelism

High |  ●─CPU
     |      \
     |       \
     |        ●─V1 (Serial)
     |              \
     |               \
Low  |                ●─V4 (DSP)
     +────────────────────────►
             Parallelism
```

## Conclusion

> FPGA acceleration provides 100-150× energy reduction per inference compared to CPU baseline, making it ideal for edge deployment.
