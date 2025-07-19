Design and Implementation of an ARM Cortex-M0 Microprocessor on FPGA
This repository contains the VHDL source code and documentation for the design, simulation, and hardware implementation of a 32-bit ARM Cortex-M0 microprocessor on an FPGA. This project was completed as a graduation requirement for the Department of Electrical and Electronics Engineering at Eskişehir Technical University.


Abstract
This project presents the design and simulation of an ARM Cortex-M0 microprocessor using VHDL, focusing on developing a 32-bit processor based on the ARMv6-M architecture, which is optimized for low-power embedded systems. The design includes core components such as the Arithmetic Logic Unit (ALU), register file, instruction decoder, and memory interface, all integrated into a three-stage pipeline architecture (Instruction Fetch, Decode, and Execute). The processor's functionality was validated through extensive simulations in Xilinx Vivado, running programs like Fibonacci sequence calculation, power computation, and factorial operations. Finally, the design was successfully synthesized and implemented on the Nexys 4 DDR FPGA board, confirming its functionality in a real hardware environment. This work demonstrates the feasibility of creating a compact and efficient microprocessor for embedded systems and IoT applications.





🚀 Key Features
Processor Architecture: 32-bit RISC processor based on the ARMv6-M architecture.





Pipeline: 3-stage pipeline (Instruction Fetch, Decode, Execute) for efficient instruction processing.



Hardware Language: Designed and implemented in VHDL for modularity and scalability.



Instruction Set: Supports a subset of the ARMv6-M Thumb instruction set, including arithmetic, logical, memory, and branch operations.





Development Tools: Synthesized, simulated, and tested using the Xilinx Vivado 2024.2 suite.


Hardware Platform: Successfully implemented and verified on a Nexys 4 DDR FPGA board (featuring an Artix-7 FPGA).



🏗️ Architecture Overview
The microprocessor employs a three-stage pipeline to maximize instruction throughput.



Instruction Fetch (IF): Fetches the next instruction from memory using the Program Counter (PC).


Instruction Decode (ID): Decodes the fetched instruction, reads operands from the Register File, and generates control signals.


Execute (EX): Performs the operation specified by the instruction using the ALU and writes the result back to the Register File or memory.


The overall datapath of the processor is illustrated below.

(To display this image in your README, save Figure 15 from your report as a PNG or JPG file and place it in your repository. Then, update the path below.)

Datapath of the implemented ARM Cortex-M0 Processor. 

Modular Components

The design is highly modular, with each component developed and tested independently:


Arithmetic Logic Unit (ALU) 

Register File (16 x 32-bit registers) 

Instruction Decoder 

Instruction and Data Memory 


Program Counter (PC) 

Status Register (for condition flags) 

Extender Module (for immediate values) 

Pipeline Registers (ID/EX) 

🔬 Verification and Simulation
The processor's correctness was verified through extensive simulations in Vivado. Several test programs were written in ARM assembly to validate different aspects of the architecture.


Test Programs

Fibonacci Sequence: An iterative program to test arithmetic operations, loops, and conditional branching.


Voltage/Power Calculation: A program to test multiplication and data handling by calculating power from voltage and current (P=(I
timesR)
timesI).


Factorial Calculation: A recursive-style program to test multiplication, subtraction, and loop control.


Example: Fibonacci Sequence Assembly Code
my_function:
    mov R0, #0        // Move 0 to register R0
    mov R1, #1        // Move 1 to register R1
loop:
    add R2, R1, R0    // R2 = R1 + R0 (Calculate next Fibonacci number)
    cmp R2, #34       // Compare the result with 34
    b.ge finish       // If R2 >= 34, exit the loop
    mov R0, R1        // Update R0 with the previous R1
    mov R1, R2        // Update R1 with the new result
    b loop            // Repeat the loop
finish:
    str R2, [R0, #9]  // Store the final result in memory
    ret


📈 Hardware Implementation and Results
The design was successfully synthesized and implemented on a 

Nexys 4 DDR FPGA board.


Timing Analysis

Timing analysis performed in Vivado confirmed that all timing constraints were met.

Worst Negative Slack (WNS): 5.987 ns 


Maximum Operating Frequency (f_max): Approximately 167 MHz (1/5.987
textns) 


The functionality of the Fibonacci program was visually verified by displaying the output on the FPGA's onboard LEDs.

👥 Project Team
Authors:

Yunus Emre Doğan 

Hasan Budak 

Hayrettin Emre Bayazıt 






