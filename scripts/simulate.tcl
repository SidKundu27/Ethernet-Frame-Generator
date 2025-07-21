# Simulation Script for Ethernet Frame Generator
# Compatible with Vivado Simulator and ModelSim

# Get current script directory and project root
set script_dir [file dirname [info script]]
set project_root [file normalize [file join $script_dir ..]]

# Set simulation directory
set sim_dir [file join $project_root "sim_vivado"]
file mkdir $sim_dir

# Create project
create_project ethernet_frame_sim $sim_dir -part xc7a35tcpg236-1 -force

# Add RTL source files with explicit paths
set rtl_files [glob -nocomplain [file join $project_root "rtl" "*.v"]]
if {[llength $rtl_files] > 0} {
    add_files -fileset sources_1 $rtl_files
} else {
    puts "ERROR: No RTL files found in [file join $project_root rtl]"
    exit 1
}

# Add testbench files with explicit paths  
set tb_files [glob -nocomplain [file join $project_root "tb" "tb_*.v"]]
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 $tb_files
} else {
    puts "ERROR: No testbench files found in [file join $project_root tb]"
    exit 1
}

# Set top module for simulation
set_property top tb_ethernet_frame_gen [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Configure simulation settings
set_property -name {xsim.simulate.runtime} -value {1ms} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.saif} -value {} -objects [get_filesets sim_1]

puts "Starting simulation launch..."

# Run simulation
launch_simulation

# Wait for simulation to be ready
after 2000

# Add signals to waveform (with error handling)
if {[catch {
    add_wave {{/tb_ethernet_frame_gen/dut/*}}
    add_wave {{/tb_ethernet_frame_gen/clk}}
    add_wave {{/tb_ethernet_frame_gen/rst_n}}
    add_wave {{/tb_ethernet_frame_gen/start_frame}}
    add_wave {{/tb_ethernet_frame_gen/frame_done}}
    add_wave {{/tb_ethernet_frame_gen/frame_data}}
    add_wave {{/tb_ethernet_frame_gen/frame_valid}}
} err]} {
    puts "Warning: Could not add all waveforms: $err"
}

# Configure wave window (with error handling)
if {[catch {
    configure_wave -namecolwidth 200
    configure_wave -valuecolwidth 100
    configure_wave -justifyvalue left
    configure_wave -signalnamewidth 1
    configure_wave -snapdistance 10
    configure_wave -datasetprefix 0
    configure_wave -rowmargin 4
    configure_wave -childrowmargin 2
} err]} {
    puts "Warning: Could not configure waveform: $err"
}

# Run simulation for specified time
puts "Running simulation for 1ms..."
run 1ms

puts "Ethernet Frame Generator simulation completed successfully"
puts "Results saved in: $sim_dir"
puts "Check the waveform viewer for detailed signal analysis"

# Optional: Close project if running in batch mode
# close_project
