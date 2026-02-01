"""
CNN Utility Functions
=====================
Additional CNN stages for conceptual completeness.
These functions are not timed — they demonstrate the full
CNN pipeline structure that pairs with the FPGA-accelerated
convolution layer.
"""

import numpy as np

def relu(feature_map):
    """
    ReLU (Rectified Linear Unit) activation function.
    Sets all negative values to zero.
    
    Args:
        feature_map: Input feature map (numpy array)
    
    Returns:
        Activated feature map with same shape
    """
    return np.maximum(feature_map, 0)


def max_pool(feature_map, pool_size=2):
    """
    Max pooling operation for downsampling.
    Reduces spatial dimensions by selecting maximum
    value in each pooling window.
    
    Args:
        feature_map: Input feature map (2D numpy array)
        pool_size: Size of pooling window (default: 2)
    
    Returns:
        Pooled feature map with reduced dimensions
    """
    h, w = feature_map.shape
    pooled = np.zeros((h // pool_size, w // pool_size), dtype=feature_map.dtype)

    for i in range(0, h, pool_size):
        for j in range(0, w, pool_size):
            pooled[i // pool_size, j // pool_size] = np.max(
                feature_map[i:i+pool_size, j:j+pool_size]
            )

    return pooled
