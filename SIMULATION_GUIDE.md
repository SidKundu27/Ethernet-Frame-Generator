# Running Simulations with Vivado

Since you have `xvlog` and Vivado installed, here are the updated instructions to run the Ethernet Frame Generator simulations:

## Quick Start

### Option 1: Simple Command Line (Recommended)
```bash
# From the project root directory
cd c:\Users\sidku\Programming\Hardware\Ethernet-Frame-Generator

# Run the main simulation
vivado -mode tcl -source scripts\run_sim_vivado.tcl
```

### Option 2: Using Batch Script
```cmd
# From the scripts directory
cd scripts
run_simulation.bat all
```

### Option 3: Manual Vivado TCL
```tcl
# Start Vivado in TCL mode
vivado -mode tcl

# Then run:
source scripts/run_sim_vivado.tcl
```

## What Each Script Does

### `run_sim_vivado.tcl` (New - Recommended)
- Simple, reliable script that works from project root
- Creates project and adds all files automatically
- Runs 2ms simulation with proper error handling
- Opens GUI for waveform viewing

### `simulate.tcl` (Updated)
- More comprehensive script with advanced waveform setup
- Better error handling and path management
- Good for detailed analysis

### `run_simulation.bat` (Updated)
- Windows batch file that calls Vivado
- Supports multiple test cases
- Good for automated testing

## Expected Output

When you run the simulation successfully, you should see:
```
Project root: C:\Users\sidku\Programming\Hardware\Ethernet-Frame-Generator
Adding RTL files...
Adding testbench files...
Launching simulation...
Running simulation for 2ms...

Simulation completed successfully!
Check the Vivado simulator GUI for waveforms and results
```

## Files Created

After running simulation:
- `sim_quick/` - Vivado project files
- `sim_vivado/` - Alternative simulation directory
- `sim_results/` - Batch script results

## Troubleshooting

### If you get "command not found" errors:
1. Make sure Vivado is in your PATH
2. Or run from Vivado Command Prompt
3. Or use full path: `C:\Xilinx\Vivado\2023.2\bin\vivado.exe`

### If you get file not found errors:
1. Make sure you're running from the project root directory
2. Check that all RTL files exist in `rtl/` directory
3. Check that testbench files exist in `tb/` directory

### If simulation doesn't start:
1. Check the log files in simulation directory
2. Look for compile errors in Vivado TCL console
3. Verify FPGA part number is available (xc7a35tcpg236-1)

## Next Steps

1. **Run the simulation:**
   ```bash
   vivado -mode tcl -source scripts\run_sim_vivado.tcl
   ```

2. **View results in Vivado GUI** - waveforms will show frame generation

3. **Check specific signals:**
   - `frame_data` - Generated Ethernet frame bytes
   - `frame_valid` - Data valid signal
   - `frame_sop/frame_eop` - Packet boundaries
   - `crc_out` - CRC-32 calculation results

Your Ethernet Frame Generator is ready to simulate! 🚀
