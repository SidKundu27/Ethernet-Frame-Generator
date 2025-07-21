# Synthesis Script for Ethernet Frame Generator
# Compatible with Vivado

# Set project variables
set project_name "ethernet_frame_generator"
set part_name "xc7a35tcpg236-1"  # Artix-7 FPGA (can be changed as needed)
set top_module "ethernet_frame_gen"

# Create synthesis project
create_project $project_name ./synth -part $part_name -force

# Add RTL source files
add_files [glob ../rtl/*.v]

# Set top module
set_property top $top_module [current_fileset]

# Add timing constraints if available
if {[file exists ../constraints/timing.xdc]} {
    add_files -fileset constrs_1 ../constraints/timing.xdc
}

# Add pin constraints if available
if {[file exists ../constraints/pins.xdc]} {
    add_files -fileset constrs_1 ../constraints/pins.xdc
}

# Configure synthesis settings
set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
set_property steps.synth_design.args.flatten_hierarchy rebuilt [get_runs synth_1]
set_property steps.synth_design.args.gated_clock_conversion off [get_runs synth_1]
set_property steps.synth_design.args.bufg 12 [get_runs synth_1]
set_property steps.synth_design.args.fanout_limit 10000 [get_runs synth_1]
set_property steps.synth_design.args.directive AreaOptimized_high [get_runs synth_1]
set_property steps.synth_design.args.control_set_opt_threshold auto [get_runs synth_1]

# Run synthesis
puts "Starting synthesis for $top_module..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed!"
} else {
    puts "Synthesis completed successfully!"
}

# Open synthesized design
open_run synth_1 -name synth_1

# Generate reports
puts "Generating synthesis reports..."

# Timing report
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -file ./synth/timing_summary.rpt

# Utilization report
report_utilization -file ./synth/utilization.rpt

# Power report
report_power -file ./synth/power.rpt

# DRC report
report_drc -file ./synth/drc.rpt

# Clock report
report_clocks -file ./synth/clocks.rpt

puts "Synthesis reports generated in ./synth/ directory"

# Print resource utilization summary
puts "\n=== Resource Utilization Summary ==="
puts "LUTs: [get_property LUT.used [get_cells -hierarchical]]"
puts "FFs:  [get_property FF.used [get_cells -hierarchical]]"
puts "BRAMs: [get_property RAMB36E1.used [get_cells -hierarchical]]"
puts "DSPs: [get_property DSP48E1.used [get_cells -hierarchical]]"

puts "\nSynthesis script completed successfully!"
puts "Check ./synth/ directory for detailed reports"
