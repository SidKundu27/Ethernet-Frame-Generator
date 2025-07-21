#!/bin/bash

# Quick compilation test for Linux
# This script just tests compilation without running full simulation

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

print_info "Quick compilation test for Ethernet Frame Generator"
print_info "Project root: $PROJECT_ROOT"

# Check if Vivado is available
if ! command -v xvlog &> /dev/null; then
    print_error "xvlog not found. Please source Vivado settings:"
    print_error "  source /opt/Xilinx/Vivado/2022.1/settings64.sh"
    exit 1
fi

print_success "Found xvlog: $(which xvlog)"

# Create temporary directory
TEMP_DIR="$PROJECT_ROOT/temp_compile_test"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

print_info "Testing RTL compilation..."

# Test compile each file individually
RTL_FILES=(
    "$PROJECT_ROOT/rtl/crc32_gen.v"
    "$PROJECT_ROOT/rtl/packet_buffer.v" 
    "$PROJECT_ROOT/rtl/frame_builder.v"
    "$PROJECT_ROOT/rtl/ethernet_frame_gen.v"
)

for file in "${RTL_FILES[@]}"; do
    filename=$(basename "$file")
    print_info "Compiling $filename..."
    
    # Capture both stdout and stderr
    if xvlog "$file" > compile_log.txt 2>&1; then
        print_success "$filename compiled successfully"
    else
        print_error "$filename compilation failed"
        echo "=== Compilation errors for $filename ==="
        cat compile_log.txt
        echo "========================================="
        exit 1
    fi
done

print_info "Testing testbench compilation..."

# Test compile testbenches
TB_FILES=(
    "$PROJECT_ROOT/tb/tb_crc32_gen.v"
    "$PROJECT_ROOT/tb/tb_ethernet_frame_gen.v"
)

for file in "${TB_FILES[@]}"; do
    filename=$(basename "$file")
    print_info "Compiling $filename..."
    
    # Capture both stdout and stderr
    if xvlog "$file" > compile_log.txt 2>&1; then
        print_success "$filename compiled successfully"
    else
        print_error "$filename compilation failed"
        echo "=== Compilation errors for $filename ==="
        cat compile_log.txt
        echo "========================================="
        exit 1
    fi
done

# Cleanup
cd "$PROJECT_ROOT"
rm -rf "$TEMP_DIR"

print_success "All files compiled successfully!"
print_info "You can now run the full simulation with:"
print_info "  ./scripts/run_simulation.sh"
