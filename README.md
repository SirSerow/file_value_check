# Simple downcounting timer with dual 7-segment display

This repository contains verilog and test bench files for a simple downcounting timer with dual 7-segment display. The timer counts down from 59 to 0 and then stops. 

## Files

- `timer.v` - Verilog file for the timer
- `tb_timer.v` - Test bench file for the timer
- `expected_vals.txt` - Expected values for the test bench
- `run_sim.sh` - Shell script to run the simulation

## Cloning the repository

This is an open repository. You can clone the repository using the following command:

```bash
git clone https://github.com/SirSerow/file_value_check.git
```


## Running the simulation

**Warning**: To run the simulation, you need to have `iverilog` and `gtkwave` installed on your system. If you are using WSL, run you can the simulation in WSL and view the waveform in Windows GUI using `gtkwave`:

```bash

To run the simulation, execute the following commands:

```bash
chmod +x run_sim.sh
./run_sim.sh
```
