@echo off
REM Batch script to run Ethernet Frame Generator simulation
REM Compatible with Vivado on Windows

echo === Ethernet Frame Generator Simulation Script ===
echo.

if "%1"=="help" (
    echo Usage: run_simulation.bat [test_case]
    echo.
    echo Test Cases:
    echo   all       - Run all testbenches
    echo   ethernet  - Run Ethernet frame generator testbench only
    echo   crc       - Run CRC-32 testbench only
    echo   help      - Show this help
    echo.
    echo Examples:
    echo   run_simulation.bat all
    echo   run_simulation.bat crc
    goto :end
)

set TEST_CASE=%1
if "%TEST_CASE%"=="" set TEST_CASE=all

echo Selected test case: %TEST_CASE%
echo.

REM Check if Vivado is available
where vivado >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Vivado not found in PATH
    echo Please add Vivado to your system PATH or run from Vivado command prompt
    echo Example: C:\Xilinx\Vivado\2023.2\bin
    echo.
    echo Alternatively, try running:
    echo   vivado -mode tcl -source scripts\run_sim_vivado.tcl
    goto :end
)

echo ✓ Vivado found in PATH
echo ✓ xvlog available for compilation
echo.

REM Change to project root directory
cd /d "%~dp0\.."
echo Project root: %CD%

REM Check for required files
set MISSING_FILES=0

if not exist "rtl\ethernet_frame_gen.v" (
    echo ✗ Missing: rtl\ethernet_frame_gen.v
    set MISSING_FILES=1
)
if not exist "rtl\crc32_gen.v" (
    echo ✗ Missing: rtl\crc32_gen.v
    set MISSING_FILES=1
)
if not exist "tb\tb_ethernet_frame_gen.v" (
    echo ✗ Missing: tb\tb_ethernet_frame_gen.v
    set MISSING_FILES=1
)
if not exist "tb\tb_crc32_gen.v" (
    echo ✗ Missing: tb\tb_crc32_gen.v
    set MISSING_FILES=1
)

if %MISSING_FILES%==1 (
    echo.
    echo ERROR: Required files missing
    goto :end
)

echo ✓ All required files found
echo.

REM Create simulation directory
if exist "sim_results" rmdir /s /q "sim_results"
mkdir "sim_results"

REM Run simulations based on test case
if "%TEST_CASE%"=="all" (
    echo Running all test cases...
    echo.
    
    echo 1. Running Ethernet Frame Generator testbench...
    echo    Using: vivado -mode batch -source scripts\run_sim_vivado.tcl
    vivado -mode batch -source scripts\run_sim_vivado.tcl -log sim_results\ethernet_sim.log
    
    echo.
    echo 2. Running CRC-32 testbench...
    echo create_project crc_sim sim_results/crc_sim -part xc7a35tcpg236-1 -force > sim_results\crc_simulate.tcl
    echo add_files -fileset sources_1 rtl/crc32_gen.v >> sim_results\crc_simulate.tcl
    echo add_files -fileset sim_1 tb/tb_crc32_gen.v >> sim_results\crc_simulate.tcl
    echo set_property top tb_crc32_gen [get_filesets sim_1] >> sim_results\crc_simulate.tcl
    echo update_compile_order -fileset sources_1 >> sim_results\crc_simulate.tcl
    echo update_compile_order -fileset sim_1 >> sim_results\crc_simulate.tcl
    echo launch_simulation >> sim_results\crc_simulate.tcl
    echo run 100us >> sim_results\crc_simulate.tcl
    echo exit >> sim_results\crc_simulate.tcl
    
    vivado -mode batch -source sim_results\crc_simulate.tcl -log sim_results\crc_sim.log
    
) else if "%TEST_CASE%"=="ethernet" (
    echo Running Ethernet Frame Generator testbench...
    echo Using: vivado -mode batch -source scripts\run_sim_vivado.tcl
    vivado -mode batch -source scripts\run_sim_vivado.tcl -log sim_results\ethernet_sim.log
    
) else if "%TEST_CASE%"=="crc" (
    echo Running CRC-32 testbench...
    echo create_project crc_sim sim_results/crc_sim -part xc7a35tcpg236-1 -force > sim_results\crc_simulate.tcl
    echo add_files -fileset sources_1 rtl/crc32_gen.v >> sim_results\crc_simulate.tcl
    echo add_files -fileset sim_1 tb/tb_crc32_gen.v >> sim_results\crc_simulate.tcl
    echo set_property top tb_crc32_gen [get_filesets sim_1] >> sim_results\crc_simulate.tcl
    echo update_compile_order -fileset sources_1 >> sim_results\crc_simulate.tcl
    echo update_compile_order -fileset sim_1 >> sim_results\crc_simulate.tcl
    echo launch_simulation >> sim_results\crc_simulate.tcl
    echo run 100us >> sim_results\crc_simulate.tcl
    echo exit >> sim_results\crc_simulate.tcl
    
    vivado -mode batch -source sim_results\crc_simulate.tcl -log sim_results\crc_sim.log
    
) else (
    echo ERROR: Unknown test case: %TEST_CASE%
    echo Valid options: all, ethernet, crc, help
    goto :end
)

echo.
echo === Simulation Complete ===
echo Results saved in: sim_results\
echo Check log files for detailed output

:end
echo.
pause
