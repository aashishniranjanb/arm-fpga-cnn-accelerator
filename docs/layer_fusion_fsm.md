# Layer Fusion Control FSM (RTL-Level)

This document describes the FSM that orchestrates Conv–ReLU–Pool layer fusion.

---

## 1. What the FSM Does

In a layer-fused accelerator, Conv, ReLU, and Pool do not run as separate blocks. Instead:
- Convolution streams pixels
- ReLU is applied immediately
- Pooling collects values on the fly
- Output is written only once

**The FSM controls timing and correctness of this stream.**

> Without this FSM, fusion is not real.

---

## 2. Why an FSM Is Required

Fusion introduces data dependency constraints:

| Operation | Dependency |
|-----------|------------|
| Conv | Needs 9 inputs |
| ReLU | Needs conv output |
| Pool | Needs 4 ReLU outputs |

The FSM ensures:
- Correct ordering
- No extra buffering
- No pipeline bubbles

---

## 3. FSM States

```
IDLE
 ↓
LOAD_WINDOW
 ↓
CONV_COMPUTE
 ↓
RELU_APPLY
 ↓
POOL_ACCUMULATE
 ↓
WRITE_OUTPUT
 ↓
NEXT_PIXEL / DONE
```

---

## 4. State-by-State Behavior

### IDLE
- Wait for start
- Reset counters and registers

### LOAD_WINDOW
- Load 3×3 input window
- Advance input stream
- Line buffers active

### CONV_COMPUTE
- Perform 9 MACs (DSPs)
- Output available in same cycle (fully parallel)

### RELU_APPLY
- Clamp negative values to zero
- Single comparator

### POOL_ACCUMULATE
- Collect 4 ReLU outputs
- Track max value
- Increment pool counter

### WRITE_OUTPUT
- Write pooled output
- Assert out_valid
- Reset pool registers

### NEXT_PIXEL / DONE
- Advance window
- Loop or assert done

---

## 5. FSM State Diagram

```
IDLE
  |
  v
LOAD_WINDOW → CONV_COMPUTE → RELU_APPLY → POOL_ACCUMULATE
                                          |
                                          v
                                     WRITE_OUTPUT
                                          |
                                          v
                                     LOAD_WINDOW / DONE
```

---

## 6. FSM Timing (Cycle-Level)

| Cycle | Operation |
|-------|-----------|
| N | Conv + ReLU |
| N+1 | Pool (1/4) |
| N+2 | Pool (2/4) |
| N+3 | Pool (3/4) |
| N+4 | Pool (4/4) + Write |

> Conv never stalls → streaming pipeline

---

## 7. RTL FSM (Synthesizable Verilog)

### State Encoding
```verilog
typedef enum logic [2:0] {
    S_IDLE,
    S_LOAD,
    S_CONV,
    S_RELU,
    S_POOL,
    S_WRITE
} fsm_state_t;
```

### FSM Registers
```verilog
fsm_state_t state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= S_IDLE;
    else
        state <= next_state;
end
```

### Next-State Logic
```verilog
always_comb begin
    next_state = state;
    case (state)
        S_IDLE:
            if (start)
                next_state = S_LOAD;

        S_LOAD:
            next_state = S_CONV;

        S_CONV:
            next_state = S_RELU;

        S_RELU:
            next_state = S_POOL;

        S_POOL:
            if (pool_count == 2'd3)
                next_state = S_WRITE;
            else
                next_state = S_POOL;

        S_WRITE:
            if (last_pixel)
                next_state = S_IDLE;
            else
                next_state = S_LOAD;

        default:
            next_state = S_IDLE;
    endcase
end
```

---

## 8. Pool Accumulator Logic

```verilog
always_ff @(posedge clk) begin
    if (state == S_RELU) begin
        relu_out <= (conv_out[MSB]) ? 0 : conv_out;
    end

    if (state == S_POOL) begin
        if (pool_count == 0)
            pool_max <= relu_out;
        else if (relu_out > pool_max)
            pool_max <= relu_out;

        pool_count <= pool_count + 1;
    end

    if (state == S_WRITE) begin
        out_data  <= pool_max;
        out_valid <= 1'b1;
        pool_count <= 0;
    end else begin
        out_valid <= 1'b0;
    end
end
```

---

## 9. Why This FSM Is Optimal

✔ No intermediate buffers  
✔ No off-chip memory  
✔ Deterministic latency  
✔ Fully pipelined  
✔ Easy AXI-Stream integration  

> This FSM is the proof of fusion.

---

## Key Takeaway

> A lightweight FSM orchestrates Conv–ReLU–Pool execution in a single streaming pipeline, ensuring zero intermediate storage and cycle-accurate layer fusion.
