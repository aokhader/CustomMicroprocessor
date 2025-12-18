# Custom Microprocessor

### Authors: Talal Jeddawi, Abdulaziz Khader

## Overview of the ISA
The ISA follows a load-store architecture. It aims to maximize register-register operations with respect to the 9-bit instruction width limit, and as such, we are pre-defining lookup tables to store recurring constants and branch destinations. A full list of the ISA operations and examples of how they work is found in [this document](./isa_reference.md).

## Programs
This CPU was developed to simulate and synthesize the following programs: 
1. Closest pair – A program designed to find the smallest and largest Hamming distances among all pairs of values in an array of 16 bytes: 
   - We assume all values are 8-bit integers, and the array of integers starts at memory location 0.
   - The minimum distance is written in location 16 and the maximum distance in location 17.
2. 2-Term Product – A program that finds the product of two 2's complement numbers, i.e., A * B:
   - We assume the operands are found in memory locations 0 (A), and 1 (B). 
   - The result are written into locations 3 (high bits) and 2 (low bits). 
3. 3-Term Product – An extension of program 2 that finds the product of three 2’s complement numbers, i.e., A * B * C:
   - Similarly, we assume the operands are found in memory locations 0 (A), and 1 (B), and 2 (C). 
   - The result will be written into locations 5 (highest bits), 4 (middle bits), and 3 (low bits).

## Simulation and Synthesis Instructions
To get the program binaries, we have written an [assembler](./assembler.py) to help us assemble our code. To get the binary file for each program. run ``python assembler.py`` and it will run for all the programs. Each binary file will end with "_machine.txt", and we use that as input to our hardware, which is ``mach_code.txt``. The assembler automatically updates this file as well.

To simulate and synthesize the programs, we used EDAPlayground as the platform of choice. Each program has a corresponding testbench, which can be found in the program's folder labeled "pX_testbench". For simulation, we used Siemens Questa. For synthesis, we used Siemens Precision.
