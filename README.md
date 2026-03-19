# VLSI-project
## picoComputer FPGA Implementation
This project involves the design, simulation, and hardware synthesis of a picoComputer architecture on an FPGA. It spans from basic digital logic components to a fully functional Finite State Machine (FSM) based CPU capable of executing machine-level instructions and interfacing with external peripherals.
## Project Overview
The core of this project is a 16-bit processor implemented as a complex Finite State Machine (FSM). The system is designed to run on a Cyclone series FPGA (III or V), utilizing a divided 1 Hz clock for observable execution during the synthesis phase.
### CPU Architecture & Instruction Set
The CPU utilizes a three-address instruction format, with instructions occupying either one or two 16-bit memory words. Key architectural components include:
- **Registers**: Program Counter (PC), Stack Pointer (SP), Instruction Register (IR), Accumulator (A), and Memory interface registers (MAR/MDR).
- **Memory Layout**: 64 words of 16-bit memory, divided into a General Purpose Register zone (first 8 locations) and a free zone for programs and the stack.
In addition to standard operations, this implementation includes:
- **Arithmetic/Logic**: ADD, SUB, MUL, and XOR/OR/AND (via a parameterized ALU).
- **Data Movement**: Single-word MOV  and an extended two-word MOV for advanced addressing.
- **Control Flow**: Standard STOP  and a custom BEG (Branch) instruction for program flow control.
- **I/O**: IN (blocking input) and OUT (output).
### Hardware Synthesis & Peripherals
The project was synthesized to interface with real-world hardware on the DE0 development board:
- **Input Interfaces**: PS/2 Keyboard controller to capture scan codes and translate them into numerical data for the CPU.
- **Output Interfaces**:
  - **VGA Controller**: Displays color-coded data on a monitor, with the screen split to represent different data values.
  - **7-Segment Displays (HEX)**: Real-time visualization of the Program Counter (PC) and Stack Pointer (SP).
  - **LEDs**: Used for status indicators, such as CPU readiness and standard output.
- **Support Modules**: Implementation of debouncers, clock dividers (50MHz to 1Hz), and Binary Coded Decimal (BCD) to Seven-Segment decoders.
### Simulation & Verification
Prior to synthesis, the modules underwent rigorous testing:
- **Functional Simulation**: The ALU and Register modules were verified using testbenches to ensure logical correctness across all operation codes.
- **UVM Verification**: Advanced verification of the Register module was performed using the Universal Verification Methodology (UVM).
- **Code Coverage**: Detailed HTML reports were generated to ensure high quality and completeness of the verification environment.
