# Timing Constraints for Ethernet Frame Generator
# Compatible with Vivado XDC format

# Primary clock constraint (125 MHz for Gigabit Ethernet)
create_clock -period 8.000 -name sys_clk [get_ports clk]

# Clock domain crossing constraints
# If using dual-clock buffers, add appropriate timing constraints
# set_clock_groups -asynchronous -group [get_clocks sys_clk] -group [get_clocks other_clk]

# Input/Output delay constraints
# Adjust these values based on your specific FPGA and board requirements

# Input delays (assuming external devices have 2ns setup/hold)
set_input_delay -clock sys_clk -min -add_delay 1.000 [get_ports {rst_n start_frame payload_* frame_ready dest_mac* src_mac* ether_type*}]
set_input_delay -clock sys_clk -max -add_delay 3.000 [get_ports {rst_n start_frame payload_* frame_ready dest_mac* src_mac* ether_type*}]

# Output delays (assuming external devices have 2ns setup/hold)
set_output_delay -clock sys_clk -min -add_delay 1.000 [get_ports {frame_* payload_ready}]
set_output_delay -clock sys_clk -max -add_delay 3.000 [get_ports {frame_* payload_ready}]

# False paths for reset signals
set_false_path -from [get_ports rst_n]

# Multicycle paths if any (example for configuration signals)
# set_multicycle_path -setup 2 -from [get_ports {dest_mac* src_mac* ether_type*}]
# set_multicycle_path -hold 1 -from [get_ports {dest_mac* src_mac* ether_type*}]

# Maximum delay constraints for combinational logic
set_max_delay 6.000 -from [get_cells -hierarchical *crc*] -to [get_cells -hierarchical *frame*]

# Timing exceptions for asynchronous resets
set_false_path -from [get_pins -hierarchical *rst_n*] -to [get_pins -hierarchical */D]

# Clock uncertainty (account for PLL jitter, board routing, etc.)
set_clock_uncertainty -setup 0.200 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.100 [get_clocks sys_clk]

# Case analysis for static configuration
# set_case_analysis 0 [get_ports config_static_pin]

# Timing ignore for debug/test signals
# set_false_path -to [get_ports debug_*]

puts "Timing constraints loaded successfully"
