# Running Simulations with Vivado

Since you have `xvlog` and Vivado installed, here are the updated instructions to run the Ethernet Frame Generator simulations:

## Quick Start

### Option 1: Windows - Simple Command Line (Recommended)
```cmd
# From the project root directory
cd c:\Users\sidku\Programming\Hardware\Ethernet-Frame-Generator

# Run the main simulation
vivado -mode tcl -source scripts\run_sim_vivado.tcl
```

### Option 2: Linux - Shell Script (Recommended)
```bash
# From the project root directory
cd /path/to/Ethernet-Frame-Generator

# First-time setup
chmod +x scripts/setup_linux.sh
./scripts/setup_linux.sh

# Source Vivado (adjust path for your installation)
source /opt/Xilinx/Vivado/2022.1/settings64.sh

# Run simulation
chmod +x scripts/run_simulation.sh
./scripts/run_simulation.sh

# Or run specific tests:
./scripts/run_simulation.sh ethernet_gen  # Ethernet test only
./scripts/run_simulation.sh crc32        # CRC32 test only
./scripts/run_simulation.sh gui          # With GUI for waveforms
```

### Option 3: Linux - Direct TCL
```bash
# From project root
vivado -mode tcl -source scripts/run_sim_linux.tcl
```

### Option 4: Windows - Using Batch Script
```cmd
# From the scripts directory
cd scripts
run_simulation.bat all
```

### Option 5: Manual Vivado TCL
```tcl
# Start Vivado in TCL mode
vivado -mode tcl

# Then run (Windows):
source scripts/run_sim_vivado.tcl

# Or run (Linux):
source scripts/run_sim_linux.tcl
```

## What Each Script Does

### Windows Scripts
- **`run_sim_vivado.tcl`** - Simple, reliable script that works from project root
- **`simulate.tcl`** - More comprehensive script with advanced waveform setup  
- **`run_simulation.bat`** - Windows batch file that calls Vivado

### Linux Scripts
- **`run_sim_linux.tcl`** - Optimized TCL script for Linux command-line execution
- **`run_simulation.sh`** - Comprehensive bash script with colored output and error handling
- **`setup_linux.sh`** - First-time environment setup and Vivado detection

### Features
- Creates project and adds all files automatically
- Runs 2-5ms simulation with proper error handling
- Opens GUI for waveform viewing (when requested)
- Supports multiple test modes and comprehensive validation

## Expected Output

### Windows
```
Project root: C:\Users\sidku\Programming\Hardware\Ethernet-Frame-Generator
Adding RTL files...
Adding testbench files...
Launching simulation...
Running simulation for 2ms...

Simulation completed successfully!
Check the Vivado simulator GUI for waveforms and results
```

### Linux
```
[INFO] Starting Ethernet Frame Generator simulation on Linux
[SUCCESS] Found Vivado: /opt/Xilinx/Vivado/2022.1/bin/vivado
[SUCCESS] Found xvlog: /opt/Xilinx/Vivado/2022.1/bin/xvlog
[SUCCESS] Project root: /home/user/projects/Ethernet-Frame-Generator
[INFO] Compiling RTL files...
[SUCCESS] RTL compilation completed
[SUCCESS] Ethernet Frame Generator test completed
[SUCCESS] All tests completed successfully!
```

## Files Created

After running simulation:
- **Windows**: `sim_quick/`, `sim_vivado/`, `sim_results/`
- **Linux**: `sim_linux/` - Contains project and waveform files
- **Both**: Generated waveform files (`.wdb`, `.wcfg`)

## Troubleshooting

### Common Issues Fixed ✅
- **SystemVerilog syntax**: All files now use standard Verilog syntax
- **Variable declarations**: Fixed unnamed block declarations in `crc32_gen.v`
- **Cross-platform paths**: Scripts handle both Windows and Linux paths

### If you get "command not found" errors:
1. **Windows**: Make sure Vivado is in your PATH or run from Vivado Command Prompt
2. **Linux**: Source Vivado settings first: `source /opt/Xilinx/Vivado/2022.1/settings64.sh`
3. Or use full path: `C:\Xilinx\Vivado\2023.2\bin\vivado.exe` (Windows)

### If you get file not found errors:
1. Make sure you're running from the project root directory
2. Check that all RTL files exist in `rtl/` directory
3. Check that testbench files exist in `tb/` directory

### If compilation fails:
1. Check for SystemVerilog syntax (should be fixed now)
2. Verify FPGA part number is available (xc7a35tcpg236-1)
3. Check the compilation log for specific errors

## Next Steps

1. **Run the simulation:**
   ```bash
   # Linux
   ./scripts/run_simulation.sh
   
   # Windows  
   vivado -mode tcl -source scripts\run_sim_vivado.tcl
   ```

2. **View results in Vivado GUI** - waveforms will show frame generation

3. **Check specific signals:**
   - `frame_data` - Generated Ethernet frame bytes
   - `frame_valid` - Data valid signal
   - `frame_sop/frame_eop` - Packet boundaries
   - `crc_out` - CRC-32 calculation results

4. **For GUI waveform viewing on Linux:**
   ```bash
   ./scripts/run_simulation.sh gui
   ```

Your Ethernet Frame Generator is ready to simulate on both Windows and Linux! 🚀

## Recent Fixes Applied ✅

- **Fixed SystemVerilog syntax** in `crc32_gen.v` for Linux compatibility
- **Fixed SystemVerilog syntax** in `packet_buffer.v` - converted `always_ff` → `always`, `always_comb` → `always @(*)`
- **Added comprehensive Linux scripts** with error handling
- **Created cross-platform simulation guide**
- **Added proper `.gitignore`** for FPGA projects
- **Added quick compilation test**: `scripts/test_compile.sh`

## Quick Compilation Test (Linux)

Before running full simulation, you can test compilation:
```bash
chmod +x scripts/test_compile.sh
./scripts/test_compile.sh
```

This will quickly verify all RTL files compile correctly.
