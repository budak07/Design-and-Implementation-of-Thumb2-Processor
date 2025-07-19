# Design and Implementation of a Thumb 2 Processor on FPGA

This repository contains the VHDL source code and documentation for the design, simulation, and hardware implementation of a 32-bit microprocessor on an FPGA. This project was completed as a graduation project for the Department of Electrical and Electronics Engineering at Eskişehir Technical University.

## Abstract

This project presents the design and simulation of a 32-bit Thumb 2 Processor using VHDL. The design is based on the Thumb 2 Processor architecture, optimized for low-power embedded systems. It includes core components like the Arithmetic Logic Unit (ALU), register file, instruction decoder, and memory interface, integrated into a three-stage pipeline architecture (Instruction Fetch, Decode, and Execute). The processor's functionality was validated with programs for Fibonacci sequence calculation, power computation, and factorial operations. The design was successfully synthesized and implemented on a Nexys 4 DDR FPGA board, confirming its functionality in a hardware environment. This work demonstrates the feasibility of creating a compact microprocessor for embedded systems and serves as a foundation for future hardware implementations.

## 🚀 Key Features

* **Processor Architecture**: 32-bit RISC processor based on the Thumb 2 Processor architecture.
* **Pipeline**: 3-stage pipeline (Instruction Fetch, Decode, Execute) for efficient instruction processing.
* **Hardware Language**: Designed and implemented in VHDL.
* **Instruction Set**: Supports a subset of the Thumb 2 instruction set, including arithmetic, logical, memory, and branch operations.
* **Development Tools**: Synthesized, simulated, and tested using the Xilinx Vivado 2024.2 suite.
* **Hardware Platform**: Successfully implemented and verified on a **Nexys 4 DDR FPGA** board (featuring an Artix-7 FPGA).

## 🏗️ Architecture Overview

The microprocessor employs a three-stage pipeline to maximize instruction throughput.
1.  **Instruction Fetch (IF)**: Fetches the next instruction from memory using the Program Counter (PC).
2.  **Instruction Decode (ID)**: Decodes the fetched instruction, reads operands from the Register File, and generates control signals.
3.  **Execute (EX)**: Performs the operation specified by the instruction using the ALU and writes the result back to the Register File or memory.


## 🔬 Verification and Simulation

The processor's correctness was verified through extensive simulations in Vivado. Several test programs were written in Thumb 2 Processor assembly to validate different aspects of the architecture.

### Test Programs
1.  **Fibonacci Sequence**: An iterative program to test arithmetic operations, loops, and conditional branching.
2.  **Voltage/Power Calculation**: A program to test multiplication and data handling.
3.  **Factorial Calculation**: A program to test multiplication, subtraction, and loop control.

## 📈 Hardware Implementation and Results

The design was successfully synthesized and implemented on a **Nexys 4 DDR FPGA** board.

### Timing Analysis
Timing analysis performed in Vivado confirmed that all timing constraints were met.
* **Worst Negative Slack (WNS)**: 5.987 ns
* **Maximum Operating Frequency ($f_{max}$)**: Approximately **167 MHz**

The functionality of the Fibonacci program was visually verified by displaying the output on the FPGA's onboard LEDs.



## 👥 Project Team

* **Authors**:
    * Yunus Emre Doğan
    * Hasan Budak
    * Hayrettin Emre Bayazıt


