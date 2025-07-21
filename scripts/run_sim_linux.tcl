# Ethernet Frame Generator - Linux Vivado Simulation Script
# This script runs the simulation in command-line mode on Linux

# Set up variables
set project_root [file normalize [file dirname [file dirname [info script]]]]
set sim_dir "$project_root/sim_linux"

puts "=== Ethernet Frame Generator Simulation ==="
puts "Project root: $project_root"
puts "Simulation directory: $sim_dir"

# Create simulation directory if it doesn't exist
file mkdir $sim_dir
cd $sim_dir

# Check if RTL files exist
set rtl_files [list \
    "$project_root/rtl/crc32_gen.v" \
    "$project_root/rtl/packet_buffer.v" \
    "$project_root/rtl/frame_builder.v" \
    "$project_root/rtl/ethernet_frame_gen.v" \
]

set tb_files [list \
    "$project_root/tb/tb_ethernet_frame_gen.v" \
    "$project_root/tb/tb_crc32_gen.v" \
]

# Verify all files exist
foreach file $rtl_files {
    if {![file exists $file]} {
        puts "ERROR: RTL file not found: $file"
        exit 1
    }
}

foreach file $tb_files {
    if {![file exists $file]} {
        puts "ERROR: Testbench file not found: $file"
        exit 1
    }
}

puts "All source files found successfully"

# Create a new project
create_project -force ethernet_frame_gen_linux . -part xc7a35tcpg236-1

# Add RTL files to project
add_files -norecurse $rtl_files
update_compile_order -fileset sources_1

# Add testbench files
add_files -fileset sim_1 -norecurse $tb_files
update_compile_order -fileset sim_1

# Set the top-level testbench
set_property top tb_ethernet_frame_gen [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

puts "Project setup completed"

# Launch simulation
puts "Launching simulation..."
launch_simulation

# Run simulation for sufficient time to complete all tests
puts "Running simulation for 5ms..."
run 5ms

# Check if simulation completed successfully
set sim_status [get_property STATUS [current_sim]]
if {$sim_status eq "PAUSED" || $sim_status eq "STOPPED"} {
    puts "=== SIMULATION COMPLETED ==="
} else {
    puts "=== SIMULATION STATUS: $sim_status ==="
}

# Save simulation results
puts "Saving simulation results..."
close_sim -force

# Optional: Generate basic report
puts ""
puts "=== SIMULATION SUMMARY ==="
puts "- RTL modules compiled successfully"
puts "- Testbench executed for 5ms simulation time"
puts "- Results saved in: $sim_dir"
puts "- To view waveforms, use Vivado GUI with saved project"
puts ""
puts "To run with GUI for waveform viewing:"
puts "  vivado $sim_dir/ethernet_frame_gen_linux.xpr"
puts ""

puts "Linux simulation completed!"
exit
