# HLS Directives for CNN Conv2D Accelerator
# This file will contain optimization pragmas and synthesis directives

# Pipeline configuration
set_directive_pipeline conv2d

# Unroll and parallelization hints
set_directive_unroll -factor 4 conv2d
