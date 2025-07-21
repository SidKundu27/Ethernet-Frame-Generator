# Simple Vivado simulation script for Ethernet Frame Generator
# Run from project root directory

# Clean up any previous simulation
catch {close_sim}
catch {close_project}

# Get current directory
set project_root [pwd]
puts "Project root: $project_root"

# Check if we're in the right directory
if {![file exists "rtl/ethernet_frame_gen.v"]} {
    puts "ERROR: Please run this script from the project root directory"
    puts "Expected to find rtl/ethernet_frame_gen.v"
    exit 1
}

# Create simulation directory
set sim_dir "sim_quick"
file delete -force $sim_dir
file mkdir $sim_dir

# Create new project
create_project ethernet_sim $sim_dir -part xc7a35tcpg236-1 -force

# Add all source files
puts "Adding RTL files..."
add_files -fileset sources_1 {
    rtl/ethernet_frame_gen.v
    rtl/crc32_gen.v
    rtl/frame_builder.v
    rtl/packet_buffer.v
}

# Add testbench files
puts "Adding testbench files..."
add_files -fileset sim_1 {
    tb/tb_ethernet_frame_gen.v
    tb/tb_crc32_gen.v
}

# Set top module
set_property top tb_ethernet_frame_gen [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch simulation
puts "Launching simulation..."
launch_simulation

# Run simulation
puts "Running simulation for 2ms..."
run 2ms

puts ""
puts "Simulation completed successfully!"
puts "Check the Vivado simulator GUI for waveforms and results"
puts "Simulation files are in: $sim_dir"
