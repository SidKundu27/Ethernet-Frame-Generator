#!/bin/bash

# Ethernet Frame Generator - Linux Simulation Script
# Usage: ./run_simulation.sh [test_name]
# Available tests: ethernet_gen, crc32, all

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to check if Vivado is available
check_vivado() {
    if ! command -v vivado &> /dev/null; then
        print_error "Vivado not found in PATH"
        print_status "Please source Vivado settings first:"
        print_status "  source /opt/Xilinx/Vivado/2023.2/settings64.sh"
        print_status "Or adjust the path to match your Vivado installation"
        exit 1
    fi
    
    print_success "Found Vivado: $(which vivado)"
}

# Function to check if xvlog is available
check_xvlog() {
    if ! command -v xvlog &> /dev/null; then
        print_error "xvlog not found in PATH"
        print_status "Make sure Vivado tools are properly sourced"
        exit 1
    fi
    
    print_success "Found xvlog: $(which xvlog)"
}

# Function to get project root directory
get_project_root() {
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Project root is one level up from scripts directory
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    if [[ ! -d "$PROJECT_ROOT/rtl" ]] || [[ ! -d "$PROJECT_ROOT/tb" ]]; then
        print_error "Project structure not found. Expected rtl/ and tb/ directories."
        print_status "Current project root: $PROJECT_ROOT"
        exit 1
    fi
    
    print_success "Project root: $PROJECT_ROOT"
}

# Function to create simulation directory
setup_simulation() {
    local sim_dir="$PROJECT_ROOT/sim_linux"
    
    print_status "Setting up simulation directory: $sim_dir"
    
    # Create simulation directory
    mkdir -p "$sim_dir"
    cd "$sim_dir"
    
    print_success "Simulation directory ready"
}

# Function to compile RTL files
compile_rtl() {
    print_status "Compiling RTL files..."
    
    # Compile RTL modules in dependency order
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
}

# Function to run Ethernet frame generator test
run_ethernet_test() {
    print_status "Running Ethernet Frame Generator test..."
    
    # Compile testbench
    xvlog "$PROJECT_ROOT/tb/tb_ethernet_frame_gen.v" || {
        print_error "Failed to compile ethernet frame generator testbench"
        exit 1
    }
    
    # Create TCL script for simulation
    cat > run_ethernet_sim.tcl << 'EOF'
# Create simulation project
create_project -force ethernet_sim_proj . -part xc7a35tcpg236-1

# Add all RTL files to project
add_files -norecurse {
    ../rtl/crc32_gen.v
    ../rtl/packet_buffer.v
    ../rtl/frame_builder.v
    ../rtl/ethernet_frame_gen.v
}

# Add testbench files
add_files -fileset sim_1 -norecurse {
    ../tb/tb_ethernet_frame_gen.v
}

# Set the top-level testbench
set_property top tb_ethernet_frame_gen [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch simulation
launch_simulation

# Run simulation for sufficient time
run 5ms

# Close simulation
close_sim -force

# Report completion
puts "Ethernet Frame Generator simulation completed successfully!"

# Exit
exit
EOF
    
    # Run simulation
    vivado -mode tcl -source run_ethernet_sim.tcl
    
    print_success "Ethernet Frame Generator test completed"
}

# Function to run CRC32 test
run_crc32_test() {
    print_status "Running CRC32 Generator test..."
    
    # Compile testbench
    xvlog "$PROJECT_ROOT/tb/tb_crc32_gen.v" || {
        print_error "Failed to compile CRC32 testbench"
        exit 1
    }
    
    # Create TCL script for simulation
    cat > run_crc32_sim.tcl << 'EOF'
# Create simulation project
create_project -force crc32_sim_proj . -part xc7a35tcpg236-1

# Add RTL files
add_files -norecurse {
    ../rtl/crc32_gen.v
}

# Add testbench files
add_files -fileset sim_1 -norecurse {
    ../tb/tb_crc32_gen.v
}

# Set the top-level testbench
set_property top tb_crc32_gen [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch simulation
launch_simulation

# Run simulation for sufficient time
run 2ms

# Close simulation
close_sim -force

# Report completion
puts "CRC32 Generator simulation completed successfully!"

# Exit
exit
EOF
    
    # Run simulation
    vivado -mode tcl -source run_crc32_sim.tcl
    
    print_success "CRC32 Generator test completed"
}

# Function to run comprehensive test with GUI
run_gui_simulation() {
    print_status "Running comprehensive simulation with GUI..."
    
    # Create comprehensive TCL script
    cat > run_comprehensive_sim.tcl << 'EOF'
# Create project
create_project -force ethernet_frame_gen_proj . -part xc7a35tcpg236-1

# Add RTL files
add_files -norecurse {
    ../rtl/crc32_gen.v
    ../rtl/packet_buffer.v
    ../rtl/frame_builder.v
    ../rtl/ethernet_frame_gen.v
}

# Add testbench files
add_files -fileset sim_1 -norecurse {
    ../tb/tb_ethernet_frame_gen.v
    ../tb/tb_crc32_gen.v
}

# Set top module
set_property top tb_ethernet_frame_gen [get_filesets sim_1]

# Launch simulation
launch_simulation

# Add all signals to waveform
add_wave /*

# Run simulation for 2ms
run 2ms

# Save waveform configuration
save_wave_config ethernet_frame_gen.wcfg

puts "Simulation completed successfully!"
puts "Check the waveform viewer for results"
EOF
    
    # Run comprehensive simulation
    vivado -mode tcl -source run_comprehensive_sim.tcl
    
    print_success "Comprehensive simulation completed"
}

# Function to display usage
show_usage() {
    echo "Usage: $0 [test_name]"
    echo ""
    echo "Available tests:"
    echo "  ethernet_gen  - Run Ethernet Frame Generator test only"
    echo "  crc32        - Run CRC32 Generator test only"
    echo "  all          - Run all tests (default)"
    echo "  gui          - Run comprehensive test with Vivado GUI"
    echo "  standalone   - Run using xvlog/xelab/xsim directly"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 ethernet_gen       # Run only Ethernet test"
    echo "  $0 gui               # Run with GUI for waveform viewing"
    echo "  $0 standalone        # Run using xvlog/xelab/xsim directly"
    echo ""
    echo "Prerequisites:"
    echo "  - Vivado must be installed and sourced"
    echo "  - Run: source /opt/Xilinx/Vivado/2023.2/settings64.sh"
}

# Main execution
main() {
    print_status "Starting Ethernet Frame Generator simulation on Linux"
    print_status "======================================================="
    
    # Get test name from command line argument
    TEST_NAME="${1:-all}"
    
    # Show usage if help requested
    if [[ "$TEST_NAME" == "help" ]] || [[ "$TEST_NAME" == "-h" ]] || [[ "$TEST_NAME" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Check prerequisites
    check_vivado
    check_xvlog
    
    # Setup project
    get_project_root
    setup_simulation
    
    # Compile RTL files
    compile_rtl
    
    # Run requested test
    case "$TEST_NAME" in
        "ethernet_gen")
            run_ethernet_test
            ;;
        "crc32")
            run_crc32_test
            ;;
        "gui")
            run_gui_simulation
            ;;
        "standalone")
            print_info "Running standalone simulation (xvlog/xelab/xsim)..."
            exec "$SCRIPT_DIR/run_standalone_sim.sh"
            ;;
        "all")
            run_ethernet_test
            run_crc32_test
            print_success "All tests completed successfully!"
            ;;
        *)
            print_error "Unknown test: $TEST_NAME"
            show_usage
            exit 1
            ;;
    esac
    
    print_success "======================================================="
    print_success "Simulation completed successfully!"
    print_status "Results are available in: $(pwd)"
    
    # Show next steps
    echo ""
    print_status "Next steps:"
    print_status "  - Check simulation logs for detailed results"
    print_status "  - Run with 'gui' option to view waveforms:"
    print_status "    $0 gui"
    print_status "  - Simulation files are in: sim_linux/"
}

# Make script executable and run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
