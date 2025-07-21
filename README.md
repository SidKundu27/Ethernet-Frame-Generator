# Ethernet Frame Generator

A Verilog RTL implementation of an IEEE 802.3 compliant Ethernet frame generator for FPGA deployment.

## Overview

This project implements a configurable Ethernet frame generator that creates valid IEEE 802.3 Ethernet frames with the following features:

- **IEEE 802.3 Compliance**: Generates standard Ethernet frames with proper structure
- **Configurable Parameters**: Supports multiple frame sizes and protocols
- **CRC-32 Calculation**: Hardware implementation of CRC-32 for frame check sequence
- **Comprehensive Validation**: Complete frame structure validation including preamble, header, payload, and FCS
- **FPGA Ready**: Synthesizable Verilog code optimized for FPGA implementation

## Project Structure

```
├── rtl/                    # RTL source files
│   ├── ethernet_frame_gen.v    # Main Ethernet frame generator
│   ├── crc32_gen.v            # CRC-32 calculation module
│   ├── frame_builder.v        # Frame structure builder
│   └── packet_buffer.v        # Packet buffering and management
├── tb/                     # Testbenches
│   ├── tb_ethernet_frame_gen.v # Main testbench
│   ├── tb_crc32_gen.v         # CRC-32 testbench
│   └── test_vectors/          # Test data files
├── constraints/            # FPGA constraints
│   ├── timing.xdc            # Timing constraints
│   └── pins.xdc             # Pin assignments
├── docs/                   # Documentation
│   ├── ethernet_frame_format.md
│   └── implementation_notes.md
└── scripts/               # Build and simulation scripts
    ├── simulate.tcl
    └── synthesize.tcl
```

## Ethernet Frame Structure

The generator creates frames with the following IEEE 802.3 structure:

```
| Preamble | SFD | Destination MAC | Source MAC | EtherType/Length | Payload | FCS |
|  7 bytes | 1B  |    6 bytes     |  6 bytes   |     2 bytes      |  46-1500B| 4B |
```

## Features

### Core Functionality
- ✅ IEEE 802.3 compliant frame generation
- ✅ Configurable source and destination MAC addresses
- ✅ Support for EtherType and Length fields
- ✅ Variable payload size (46-1500 bytes)
- ✅ Hardware CRC-32 calculation
- ✅ Preamble and SFD generation

### Parameters
- **Clock Frequency**: Configurable (default: 125 MHz for Gigabit Ethernet)
- **Data Width**: 8-bit interface (expandable to 32/64-bit)
- **Frame Size**: 64-1518 bytes (including headers)
- **MAC Addresses**: 48-bit configurable source/destination
- **EtherType**: 16-bit configurable protocol field

### Protocols Supported
- IPv4 (EtherType: 0x0800)
- ARP (EtherType: 0x0806)
- IPv6 (EtherType: 0x86DD)
- Custom protocols (configurable EtherType)

## Getting Started

### Prerequisites
- Verilog simulator (ModelSim, Vivado Simulator, or Icarus Verilog)
- FPGA development tools (Vivado, Quartus, etc.)
- Basic knowledge of Ethernet protocols

### Simulation
```bash
# Run main testbench
cd scripts
source simulate.tcl

# Or using Icarus Verilog
iverilog -o ethernet_sim ../tb/tb_ethernet_frame_gen.v ../rtl/*.v
vvp ethernet_sim
```

### Synthesis
```bash
# Using Vivado
cd scripts
source synthesize.tcl
```

## Usage Example

```verilog
// Instantiate Ethernet frame generator
ethernet_frame_gen #(
    .CLK_FREQ(125_000_000),
    .DATA_WIDTH(8)
) eth_gen (
    .clk(clk),
    .rst_n(rst_n),
    .start_frame(start_frame),
    .dest_mac(48'hFF_FF_FF_FF_FF_FF),
    .src_mac(48'h00_11_22_33_44_55),
    .ether_type(16'h0800),
    .payload_data(payload_data),
    .payload_length(payload_length),
    .frame_valid(frame_valid),
    .frame_data(frame_data),
    .frame_done(frame_done)
);
```

## Implementation Details

### CRC-32 Algorithm
- Polynomial: 0x04C11DB7 (IEEE 802.3 standard)
- Initial value: 0xFFFFFFFF
- Post-processing: Bitwise inversion
- Hardware optimized for single-cycle operation

### Performance
- **Throughput**: Up to 1 Gbps (8-bit interface at 125 MHz)
- **Latency**: Configurable based on buffering strategy
- **Resource Usage**: Optimized for minimal LUT and BRAM usage

## Testing

The project includes comprehensive testbenches that verify:
- Frame structure compliance
- CRC-32 calculation accuracy
- Multiple packet sizes (64, 128, 256, 512, 1024, 1518 bytes)
- Different protocol types
- Error injection and handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## References

- IEEE 802.3 Ethernet Standard
- RFC 894 - A Standard for the Transmission of IP Datagrams over Ethernet Networks
- Xilinx UG901 - Vivado Design Suite User Guide: Synthesis
