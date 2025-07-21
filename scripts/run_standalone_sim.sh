#!/bin/bash

# Simple standalone simulation test for Linux
# This script uses xvlog and xsim directly without creating Vivado projects

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_info "Simple standalone simulation test"
print_info "Project root: $PROJECT_ROOT"

# Check if tools are available
if ! command -v xvlog &> /dev/null; then
    print_error "xvlog not found. Please source Vivado settings first."
    exit 1
fi

if ! command -v xelab &> /dev/null; then
    print_error "xelab not found. Please source Vivado settings first."
    exit 1
fi

if ! command -v xsim &> /dev/null; then
    print_error "xsim not found. Please source Vivado settings first."
    exit 1
fi

print_success "Found Vivado simulation tools"

# Create simulation directory
SIM_DIR="$PROJECT_ROOT/sim_standalone"
mkdir -p "$SIM_DIR"
cd "$SIM_DIR"

print_info "Compiling RTL files..."

# Compile RTL files in dependency order
xvlog "$PROJECT_ROOT/rtl/crc32_gen.v" || {
    print_error "Failed to compile crc32_gen.v"
    exit 1
}

xvlog "$PROJECT_ROOT/rtl/packet_buffer.v" || {
    print_error "Failed to compile packet_buffer.v"
    exit 1
}

xvlog "$PROJECT_ROOT/rtl/frame_builder.v" || {
    print_error "Failed to compile frame_builder.v"
    exit 1
}

xvlog "$PROJECT_ROOT/rtl/ethernet_frame_gen.v" || {
    print_error "Failed to compile ethernet_frame_gen.v"
    exit 1
}

print_success "RTL compilation completed"

print_info "Compiling testbench..."

# Compile testbench
xvlog "$PROJECT_ROOT/tb/tb_ethernet_frame_gen.v" || {
    print_error "Failed to compile testbench"
    exit 1
}

print_success "Testbench compilation completed"

print_info "Elaborating design..."

# Elaborate the design
xelab -debug typical tb_ethernet_frame_gen -s ethernet_sim || {
    print_error "Failed to elaborate design"
    exit 1
}

print_success "Design elaboration completed"

print_info "Running simulation..."

# Create simulation script
cat > run_sim.tcl << 'EOF'
# Run simulation for sufficient time
run 5ms

# Check for any errors
set error_count [get_value -radix decimal /tb_ethernet_frame_gen/error_count]
if {$error_count == 0} {
    puts "=== SIMULATION PASSED - No errors detected ==="
} else {
    puts "=== SIMULATION FAILED - $error_count errors detected ==="
}

puts "Simulation completed at [current_time]"
quit
EOF

# Run simulation
if xsim ethernet_sim -tclbatch run_sim.tcl; then
    print_success "Simulation completed successfully"
else
    print_error "Simulation failed"
    exit 1
fi

print_info "Simulation results saved in: $SIM_DIR"
print_success "Standalone simulation test completed!"

# Optional: Show simulation summary
if [ -f "webtalk.log" ]; then
    print_info "Simulation summary:"
    grep -i "simulation\|error\|warning" webtalk.log | tail -5 || true
fi
