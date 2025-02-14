#!/bin/bash

# =====================================================================
# Script Name: run_sim.sh
# Description: Automates the compilation, simulation, and waveform
#              visualization of Verilog designs.
# Usage:       ./run_sim.sh <verilog_file.v> <testbench_file.v>
# =====================================================================

# ----------------------------
# Function to display usage
# ----------------------------
usage() {
    echo "Usage: $0 <verilog_file.v> <testbench_file.v>"
    echo "Example: $0 counter.v tb_counter.v"
    exit 1
}

# ----------------------------
# Check for correct number of arguments
# ----------------------------
if [ $# -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# ----------------------------
# Assign input arguments to variables
# ----------------------------
VERILOG_FILE="$1"
TESTBENCH_FILE="$2"

# ----------------------------
# Check if Verilog file exists
# ----------------------------
if [ ! -f "$VERILOG_FILE" ]; then
    echo "Error: Verilog file '$VERILOG_FILE' not found!"
    exit 1
fi

# ----------------------------
# Check if Testbench file exists
# ----------------------------
if [ ! -f "$TESTBENCH_FILE" ]; then
    echo "Error: Testbench file '$TESTBENCH_FILE' not found!"
    exit 1
fi

# ----------------------------
# Extract base name from Verilog file (without extension)
# ----------------------------
BASE_NAME=$(basename "$VERILOG_FILE" .v)

# ----------------------------
# Define output executable and VCD file names
# ----------------------------
SIM_EXEC="sim_exec"                     # Name of the simulation executable
VCD_FILE="tb_${BASE_NAME}.vcd"         # VCD file prefixed with 'tb_' and .vcd extension

# ----------------------------
# Compile the Verilog code using iverilog
# ----------------------------
echo "Compiling Verilog files..."
iverilog -o "$SIM_EXEC" "$VERILOG_FILE" "$TESTBENCH_FILE"

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi
echo "Compilation successful. Executable created: $SIM_EXEC"

# ----------------------------
# Run the simulation using vvp
# ----------------------------
echo "Running simulation..."
vvp "$SIM_EXEC"

# Check if simulation was successful
if [ $? -ne 0 ]; then
    echo "Simulation failed!"
    exit 1
fi
echo "Simulation completed successfully."

# ----------------------------
# Open the waveform with gtkwave
# ----------------------------
if [ -f "$VCD_FILE" ]; then
    echo "Opening waveform with gtkwave..."
    gtkwave "$VCD_FILE"
else
    echo "Error: VCD file '$VCD_FILE' not found!"
    exit 1
fi

# ----------------------------
# End of Script
# ----------------------------
