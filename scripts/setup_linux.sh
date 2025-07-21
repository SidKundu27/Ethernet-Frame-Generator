#!/bin/bash

# Ethernet Frame Generator - Linux Setup Script
# This script helps set up the environment for running Vivado simulations

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Ethernet Frame Generator - Linux Environment Setup"
print_info "=================================================="

# Common Vivado installation paths
VIVADO_PATHS=(
    "/opt/Xilinx/Vivado/2023.2/settings64.sh"
    "/opt/Xilinx/Vivado/2023.1/settings64.sh"
    "/opt/Xilinx/Vivado/2022.2/settings64.sh"
    "/opt/Xilinx/Vivado/2022.1/settings64.sh"
    "/tools/Xilinx/Vivado/2023.2/settings64.sh"
    "/usr/local/Xilinx/Vivado/2023.2/settings64.sh"
)

# Function to find Vivado installation
find_vivado() {
    print_info "Searching for Vivado installation..."
    
    for path in "${VIVADO_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            print_success "Found Vivado settings: $path"
            export VIVADO_SETTINGS="$path"
            return 0
        fi
    done
    
    print_warning "Vivado settings not found in common locations"
    return 1
}

# Function to check if Vivado is already sourced
check_vivado_sourced() {
    if command -v vivado &> /dev/null; then
        print_success "Vivado is already available in PATH"
        print_info "Vivado location: $(which vivado)"
        return 0
    fi
    return 1
}

# Function to source Vivado
source_vivado() {
    if [[ -n "$VIVADO_SETTINGS" ]]; then
        print_info "Sourcing Vivado settings..."
        source "$VIVADO_SETTINGS"
        
        if command -v vivado &> /dev/null; then
            print_success "Vivado successfully sourced"
            print_info "Vivado version: $(vivado -version | head -1)"
        else
            print_error "Failed to source Vivado properly"
            return 1
        fi
    else
        print_error "No Vivado settings file found"
        return 1
    fi
}

# Function to make scripts executable
setup_scripts() {
    print_info "Making simulation scripts executable..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    chmod +x "$SCRIPT_DIR/run_simulation.sh"
    chmod +x "$SCRIPT_DIR/setup_linux.sh"
    
    print_success "Scripts are now executable"
}

# Function to verify project structure
verify_project() {
    print_info "Verifying project structure..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    local required_dirs=("rtl" "tb" "scripts")
    local required_files=(
        "rtl/ethernet_frame_gen.v"
        "rtl/crc32_gen.v"
        "rtl/frame_builder.v"
        "rtl/packet_buffer.v"
        "tb/tb_ethernet_frame_gen.v"
        "tb/tb_crc32_gen.v"
    )
    
    # Check directories
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$PROJECT_ROOT/$dir" ]]; then
            print_error "Missing directory: $PROJECT_ROOT/$dir"
            return 1
        fi
    done
    
    # Check files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
            print_error "Missing file: $PROJECT_ROOT/$file"
            return 1
        fi
    done
    
    print_success "Project structure verified"
    print_info "Project root: $PROJECT_ROOT"
}

# Function to show usage instructions
show_usage() {
    print_info ""
    print_info "Setup completed! Here's how to run simulations:"
    print_info ""
    print_info "1. Quick simulation (all tests):"
    print_info "   ./scripts/run_simulation.sh"
    print_info ""
    print_info "2. Specific test:"
    print_info "   ./scripts/run_simulation.sh ethernet_gen"
    print_info "   ./scripts/run_simulation.sh crc32"
    print_info ""
    print_info "3. With GUI for waveform viewing:"
    print_info "   ./scripts/run_simulation.sh gui"
    print_info ""
    print_info "4. Direct TCL execution:"
    print_info "   vivado -mode tcl -source scripts/run_sim_linux.tcl"
    print_info ""
    print_info "Note: If Vivado is not in your PATH, first run:"
    print_info "   source /opt/Xilinx/Vivado/2023.2/settings64.sh"
    print_info "   (adjust path to match your installation)"
}

# Main execution
main() {
    # Setup scripts
    setup_scripts
    
    # Verify project structure
    if ! verify_project; then
        print_error "Project verification failed"
        exit 1
    fi
    
    # Check if Vivado is available
    if ! check_vivado_sourced; then
        print_info "Vivado not found in PATH, attempting to locate..."
        
        if find_vivado; then
            print_info "Found Vivado installation"
            print_warning "You'll need to source Vivado settings before running simulations:"
            print_warning "  source $VIVADO_SETTINGS"
        else
            print_warning "Vivado installation not found in common locations"
            print_warning "Please manually source your Vivado settings:"
            print_warning "  source /path/to/your/vivado/settings64.sh"
        fi
    fi
    
    # Show usage instructions
    show_usage
    
    print_success "Linux setup completed!"
}

# Run main function
main "$@"
