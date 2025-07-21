# Pin Assignment Constraints for Ethernet Frame Generator
# Compatible with Vivado XDC format
# 
# Note: These are example pin assignments for Artix-7 FPGA
# Modify according to your specific FPGA board and requirements

# Clock and Reset
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# Control Signals
set_property PACKAGE_PIN T18 [get_ports start_frame]
set_property IOSTANDARD LVCMOS33 [get_ports start_frame]

set_property PACKAGE_PIN W19 [get_ports frame_ready]
set_property IOSTANDARD LVCMOS33 [get_ports frame_ready]

# Status Outputs
set_property PACKAGE_PIN U15 [get_ports frame_done]
set_property IOSTANDARD LVCMOS33 [get_ports frame_done]

set_property PACKAGE_PIN U14 [get_ports frame_valid]
set_property IOSTANDARD LVCMOS33 [get_ports frame_valid]

set_property PACKAGE_PIN V14 [get_ports frame_sop]
set_property IOSTANDARD LVCMOS33 [get_ports frame_sop]

set_property PACKAGE_PIN V13 [get_ports frame_eop]
set_property IOSTANDARD LVCMOS33 [get_ports frame_eop]

set_property PACKAGE_PIN V3 [get_ports payload_ready]
set_property IOSTANDARD LVCMOS33 [get_ports payload_ready]

set_property PACKAGE_PIN W3 [get_ports payload_valid]
set_property IOSTANDARD LVCMOS33 [get_ports payload_valid]

# Data Buses (8-bit frame_data)
set_property PACKAGE_PIN W7 [get_ports {frame_data[0]}]
set_property PACKAGE_PIN W6 [get_ports {frame_data[1]}]
set_property PACKAGE_PIN U8 [get_ports {frame_data[2]}]
set_property PACKAGE_PIN V8 [get_ports {frame_data[3]}]
set_property PACKAGE_PIN U5 [get_ports {frame_data[4]}]
set_property PACKAGE_PIN V5 [get_ports {frame_data[5]}]
set_property PACKAGE_PIN U7 [get_ports {frame_data[6]}]
set_property PACKAGE_PIN V7 [get_ports {frame_data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {frame_data[*]}]

# Payload data bus
set_property PACKAGE_PIN A14 [get_ports {payload_data[0]}]
set_property PACKAGE_PIN A16 [get_ports {payload_data[1]}]
set_property PACKAGE_PIN B15 [get_ports {payload_data[2]}]
set_property PACKAGE_PIN B16 [get_ports {payload_data[3]}]
set_property PACKAGE_PIN A15 [get_ports {payload_data[4]}]
set_property PACKAGE_PIN A17 [get_ports {payload_data[5]}]
set_property PACKAGE_PIN C15 [get_ports {payload_data[6]}]
set_property PACKAGE_PIN C16 [get_ports {payload_data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {payload_data[*]}]

# MAC Address Configuration (using DIP switches - lower 16 bits only for demo)
# Destination MAC [15:0]
set_property PACKAGE_PIN V17 [get_ports {dest_mac[0]}]
set_property PACKAGE_PIN V16 [get_ports {dest_mac[1]}]
set_property PACKAGE_PIN W16 [get_ports {dest_mac[2]}]
set_property PACKAGE_PIN W17 [get_ports {dest_mac[3]}]
set_property PACKAGE_PIN W15 [get_ports {dest_mac[4]}]
set_property PACKAGE_PIN V15 [get_ports {dest_mac[5]}]
set_property PACKAGE_PIN W14 [get_ports {dest_mac[6]}]
set_property PACKAGE_PIN W13 [get_ports {dest_mac[7]}]
set_property PACKAGE_PIN V2 [get_ports {dest_mac[8]}]
set_property PACKAGE_PIN T3 [get_ports {dest_mac[9]}]
set_property PACKAGE_PIN T2 [get_ports {dest_mac[10]}]
set_property PACKAGE_PIN R3 [get_ports {dest_mac[11]}]
set_property PACKAGE_PIN W2 [get_ports {dest_mac[12]}]
set_property PACKAGE_PIN U1 [get_ports {dest_mac[13]}]
set_property PACKAGE_PIN T1 [get_ports {dest_mac[14]}]
set_property PACKAGE_PIN R2 [get_ports {dest_mac[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dest_mac[*]}]

# Source MAC [15:0] (using push buttons for demo)
set_property PACKAGE_PIN U18 [get_ports {src_mac[0]}]
set_property PACKAGE_PIN T18 [get_ports {src_mac[1]}]
set_property PACKAGE_PIN W19 [get_ports {src_mac[2]}]
set_property PACKAGE_PIN T17 [get_ports {src_mac[3]}]
set_property PACKAGE_PIN U17 [get_ports {src_mac[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {src_mac[*]}]

# EtherType Configuration (using additional switches)
set_property PACKAGE_PIN R2 [get_ports {ether_type[0]}]
set_property PACKAGE_PIN T1 [get_ports {ether_type[1]}]
set_property PACKAGE_PIN U1 [get_ports {ether_type[2]}]
set_property PACKAGE_PIN W2 [get_ports {ether_type[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {ether_type[*]}]

# Payload Length (using rotary encoder or additional inputs)
set_property PACKAGE_PIN M17 [get_ports {payload_length[0]}]
set_property PACKAGE_PIN M18 [get_ports {payload_length[1]}]
set_property PACKAGE_PIN N17 [get_ports {payload_length[2]}]
set_property PACKAGE_PIN N18 [get_ports {payload_length[3]}]
set_property PACKAGE_PIN L17 [get_ports {payload_length[4]}]
set_property PACKAGE_PIN L18 [get_ports {payload_length[5]}]
set_property PACKAGE_PIN H17 [get_ports {payload_length[6]}]
set_property PACKAGE_PIN K15 [get_ports {payload_length[7]}]
set_property PACKAGE_PIN J15 [get_ports {payload_length[8]}]
set_property PACKAGE_PIN H15 [get_ports {payload_length[9]}]
set_property PACKAGE_PIN G15 [get_ports {payload_length[10]}]

set_property IOSTANDARD LVCMOS33 [get_ports {payload_length[*]}]

# I/O Standards and Drive Strength
set_property DRIVE 8 [get_ports {frame_data[*]}]
set_property SLEW FAST [get_ports {frame_data[*]}]

set_property DRIVE 8 [get_ports frame_valid]
set_property DRIVE 8 [get_ports frame_sop]
set_property DRIVE 8 [get_ports frame_eop]
set_property DRIVE 8 [get_ports frame_done]
set_property DRIVE 8 [get_ports payload_ready]

# Input termination (for high-speed signals)
# set_property DIFF_TERM TRUE [get_ports {high_speed_inputs[*]}]

# Clock configuration
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports clk]

puts "Pin constraints loaded successfully"
puts "Note: Verify pin assignments match your target FPGA board"
