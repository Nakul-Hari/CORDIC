# CORDIC Verilog Implementation: Vectoring and Rotation

## Overview

This repository hosts Verilog implementations of the Coordinate Rotation Digital Computer (CORDIC) algorithm, tailored for both vectoring and rotation operations. CORDIC is a powerful algorithm widely used for trigonometric calculations, polar-to-Cartesian conversions (vectoring), and Cartesian-to-polar conversions (rotation). The implementations provided here are optimized for FPGA and ASIC environments, featuring both pipelined and iterative processing options.

## Theory

### CORDIC Algorithm

The CORDIC algorithm operates by iteratively rotating a vector toward a desired angle or finding the magnitude and phase of a vector. It uses only simple arithmetic operations such as shifts, additions, and subtractions, making it highly suitable for hardware implementation.

### Vectoring

Vectoring refers to the process of converting Cartesian coordinates (x, y) to polar coordinates (magnitude, phase). In CORDIC, this is achieved by iteratively rotating the vector until the y-coordinate approaches zero, effectively determining the angle of the vector.

### Rotation

Rotation, on the other hand, involves rotating a vector by a specified angle while maintaining its magnitude. In CORDIC, this is accomplished by iteratively adjusting the vector's coordinates based on the desired rotation angle.

## Implementation

### Verilog Code

The Verilog code provided in this repository includes optimized implementations of the CORDIC algorithm for both vectoring and rotation operations. The code is modular and well-documented, facilitating easy integration into FPGA or ASIC designs.

### Pipelined Processing

Pipelined processing enhances performance by breaking down the computation into stages that execute concurrently. This reduces the overall latency of the algorithm, making it suitable for real-time applications.

### Iterative Processing

In iterative processing, each stage of computation depends on the result of the previous stage. While iterative processing may have higher latency compared to pipelined processing, it often requires fewer hardware resources, making it advantageous for resource-constrained environments.

## Acknowledgements

This implementation is part of the lab work for the EE5516 VLSI Architectures for Signal Processing and Machine Learning course.


