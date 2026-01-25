import time

def main():
    input_data = [1, 1, 1, 1, 1, 1, 1, 1, 1]
    kernel = [1, 1, 1, 1, 1, 1, 1, 1, 1]
    
    start = time.perf_counter_ns()
    
    sum_result = 0
    for i in range(9):
        sum_result += input_data[i] * kernel[i]
    
    end = time.perf_counter_ns()
    
    print(f"Output: {sum_result}")
    print(f"Time (ns): {end - start}")

if __name__ == "__main__":
    main()
