# Design and Implementation of an ARM Cortex-M0 Microprocessor on FPGA

[cite_start]This repository contains the VHDL source code and documentation for the design, simulation, and hardware implementation of a 32-bit ARM Cortex-M0 microprocessor on an FPGA[cite: 23]. [cite_start]This project was completed as a graduation project for the Department of Electrical and Electronics Engineering at Eskişehir Technical University[cite: 1].

## Abstract

[cite_start]This project presents the design and simulation of a 32-bit ARM Cortex-M0 microprocessor using VHDL[cite: 6]. [cite_start]The design is based on the ARMv6-M architecture, optimized for low-power embedded systems[cite: 6]. [cite_start]It includes core components like the Arithmetic Logic Unit (ALU), register file, instruction decoder, and memory interface, integrated into a three-stage pipeline architecture (Instruction Fetch, Decode, and Execute)[cite: 7]. [cite_start]The processor's functionality was validated with programs for Fibonacci sequence calculation, power computation, and factorial operations[cite: 10]. [cite_start]The design was successfully synthesized and implemented on a Nexys 4 DDR FPGA board, confirming its functionality in a hardware environment[cite: 12]. [cite_start]This work demonstrates the feasibility of creating a compact microprocessor for embedded systems and serves as a foundation for future hardware implementations[cite: 13].

## 🚀 Key Features

* [cite_start]**Processor Architecture**: 32-bit RISC processor based on the ARMv6-M architecture[cite: 24, 75].
* [cite_start]**Pipeline**: 3-stage pipeline (Instruction Fetch, Decode, Execute) for efficient instruction processing[cite: 7, 80].
* [cite_start]**Hardware Language**: Designed and implemented in VHDL[cite: 71].
* [cite_start]**Instruction Set**: Supports a subset of the ARMv6-M Thumb instruction set [cite: 356][cite_start], including arithmetic [cite: 359][cite_start], logical [cite: 371][cite_start], memory [cite: 389][cite_start], and branch operations[cite: 382].
* [cite_start]**Development Tools**: Synthesized, simulated, and tested using the Xilinx Vivado 2024.2 suite[cite: 518].
* [cite_start]**Hardware Platform**: Successfully implemented and verified on a **Nexys 4 DDR FPGA** board (featuring an Artix-7 FPGA)[cite: 512].

## 🏗️ Architecture Overview

[cite_start]The microprocessor employs a three-stage pipeline to maximize instruction throughput[cite: 335].
1.  [cite_start]**Instruction Fetch (IF)**: Fetches the next instruction from memory using the Program Counter (PC)[cite: 81].
2.  [cite_start]**Instruction Decode (ID)**: Decodes the fetched instruction, reads operands from the Register File, and generates control signals[cite: 84].
3.  [cite_start]**Execute (EX)**: Performs the operation specified by the instruction using the ALU and writes the result back to the Register File or memory[cite: 86].

The overall datapath of the processor is illustrated below.

*(To display this image in your README, save Figure 15 from your report as a PNG or JPG file and place it in your repository. Then, update the path below.)*

![Processor Datapath](path/to/your/image/datapath.png)
[cite_start]*Datapath of the implemented ARM Cortex-M0 Processor[cite: 19].*

## 🔬 Verification and Simulation

[cite_start]The processor's correctness was verified through extensive simulations in Vivado[cite: 9, 579]. [cite_start]Several test programs were written in ARM assembly to validate different aspects of the architecture[cite: 72].

### Test Programs
1.  [cite_start]**Fibonacci Sequence**: An iterative program to test arithmetic operations, loops, and conditional branching[cite: 533].
2.  [cite_start]**Voltage/Power Calculation**: A program to test multiplication and data handling[cite: 443].
3.  [cite_start]**Factorial Calculation**: A program to test multiplication, subtraction, and loop control[cite: 477].

## 📈 Hardware Implementation and Results

[cite_start]The design was successfully synthesized and implemented on a **Nexys 4 DDR FPGA** board[cite: 512, 562].

### Timing Analysis
[cite_start]Timing analysis performed in Vivado confirmed that all timing constraints were met[cite: 519, 521].
* [cite_start]**Worst Negative Slack (WNS)**: 5.987 ns[cite: 521, 527].
* [cite_start]**Maximum Operating Frequency ($f_{max}$)**: Approximately **167 MHz**, calculated from the WNS value[cite: 524].

[cite_start]The functionality of the Fibonacci program was visually verified by displaying the output on the FPGA's onboard LEDs[cite: 538, 541, 561].

## 🛠️ Getting Started

To run this project, you will need:
* [cite_start]**Xilinx Vivado 2024.2** or a compatible version[cite: 518].
* [cite_start](Optional) A **Nexys 4 DDR** FPGA board for hardware implementation[cite: 512].

1.  Clone the repository.
2.  Open the project in Xilinx Vivado.
3.  Run the behavioral simulation to observe the test programs executing.
4.  To implement on hardware, run synthesis and implementation, then generate the bitstream and program the FPGA.

## 👥 Project Team

* **Authors**:
    * [cite_start]Yunus Emre Doğan [cite: 1, 5]
    * [cite_start]Hasan Budak [cite: 1, 5]
    * [cite_start]Hayrettin Emre Bayazıt [cite: 1, 5]
* **Supervisor**:
    * Dr. Öğr. [cite_start]Üyesi Burak Batmaz [cite: 4, 6]

---
[cite_start]*This README file was generated based on the project report "Design and Implementation of ARM Cortex-M0 Microprocessor on FPGA," dated June 2025[cite: 1, 3].*
