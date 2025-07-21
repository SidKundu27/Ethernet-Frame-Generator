# Ethernet Frame Format Reference

## IEEE 802.3 Ethernet Frame Structure

The Ethernet frame generator creates frames compliant with the IEEE 802.3 standard. This document provides detailed information about the frame format and implementation specifics.

### Frame Structure Overview

```
| Preamble | SFD | Destination MAC | Source MAC | EtherType/Length | Payload | FCS |
|  7 bytes | 1B  |    6 bytes     |  6 bytes   |     2 bytes      |  46-1500B| 4B |
```

**Total Frame Size:** 64-1518 bytes (including all headers and FCS)

### Field Descriptions

#### 1. Preamble (7 bytes)
- **Value:** `0x55 0x55 0x55 0x55 0x55 0x55 0x55`
- **Purpose:** Synchronization pattern for physical layer
- **Binary:** `01010101` repeated 7 times
- **Function:** Allows receiving stations to synchronize with the incoming signal

#### 2. Start Frame Delimiter (SFD) (1 byte)
- **Value:** `0xD5`
- **Binary:** `11010101`
- **Purpose:** Indicates the start of the actual frame data
- **Note:** Combined with preamble for 8-byte synchronization sequence

#### 3. Destination MAC Address (6 bytes)
- **Format:** 48-bit MAC address
- **Byte Order:** Network byte order (big-endian)
- **Types:**
  - **Unicast:** LSB of first byte = 0
  - **Multicast:** LSB of first byte = 1
  - **Broadcast:** `FF:FF:FF:FF:FF:FF`
- **Examples:**
  - Unicast: `00:11:22:33:44:55`
  - Multicast: `01:00:5E:xx:xx:xx` (IPv4 multicast)
  - Broadcast: `FF:FF:FF:FF:FF:FF`

#### 4. Source MAC Address (6 bytes)
- **Format:** 48-bit MAC address
- **Byte Order:** Network byte order (big-endian)
- **Constraint:** Must be unicast (LSB of first byte = 0)
- **Purpose:** Identifies the sending station

#### 5. EtherType/Length Field (2 bytes)
- **Values ≥ 1536 (0x0600):** EtherType (protocol identifier)
- **Values < 1536:** Length of payload in bytes
- **Byte Order:** Network byte order (big-endian)

**Common EtherType Values:**
| Protocol | EtherType | Description |
|----------|-----------|-------------|
| IPv4 | 0x0800 | Internet Protocol version 4 |
| ARP | 0x0806 | Address Resolution Protocol |
| IPv6 | 0x86DD | Internet Protocol version 6 |
| VLAN | 0x8100 | VLAN-tagged frame |
| MPLS | 0x8847 | MPLS unicast |
| PPPoE | 0x8864 | PPP over Ethernet |

#### 6. Payload (46-1500 bytes)
- **Minimum:** 46 bytes (padded with zeros if necessary)
- **Maximum:** 1500 bytes
- **Padding:** If payload < 46 bytes, pad with zeros to reach minimum
- **Content:** Upper layer protocol data (IP packet, ARP message, etc.)

#### 7. Frame Check Sequence (FCS) (4 bytes)
- **Algorithm:** CRC-32 (IEEE 802.3 polynomial)
- **Polynomial:** `0x04C11DB7`
- **Initial Value:** `0xFFFFFFFF`
- **Final XOR:** `0xFFFFFFFF`
- **Scope:** Covers Destination MAC through Payload (excludes Preamble and SFD)
- **Byte Order:** Network byte order (big-endian)

### Frame Size Constraints

#### Minimum Frame Size
- **Total:** 64 bytes (including Preamble and SFD)
- **Without Preamble/SFD:** 56 bytes
- **Payload minimum:** 46 bytes (padded if necessary)

#### Maximum Frame Size
- **Standard:** 1518 bytes (including Preamble and SFD)
- **Without Preamble/SFD:** 1510 bytes
- **Jumbo frames:** Up to 9000 bytes (non-standard)

### CRC-32 Calculation Details

#### Polynomial
```
G(x) = x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
```

#### Algorithm Steps
1. Initialize CRC register to `0xFFFFFFFF`
2. For each data byte (from Destination MAC to end of Payload):
   - XOR byte with least significant byte of CRC
   - Shift CRC right by 8 bits
   - XOR with polynomial if bit was shifted out
3. Invert final CRC value (`CRC XOR 0xFFFFFFFF`)
4. Transmit in network byte order

#### Example CRC Calculation
For the string "123456789":
- Input: `0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39`
- Expected CRC: `0xCBF43926`

### Byte Ordering

All multi-byte fields use **network byte order** (big-endian):
- Most significant byte transmitted first
- Applies to: MAC addresses, EtherType, FCS

### Error Detection

The CRC-32 can detect:
- All single-bit errors
- All double-bit errors
- All burst errors ≤ 32 bits
- 99.9999% of longer burst errors

### Implementation Notes

#### Performance Considerations
- Parallel CRC calculation enables single-cycle operation
- Table-based CRC lookup can improve timing at cost of memory
- Pipeline registers may be needed for high-frequency operation

#### FPGA Resource Usage
- Combinational CRC: ~100 LUTs
- Table-based CRC: 1 BRAM + ~50 LUTs
- Frame buffering: Depends on buffer size (typically 1-4 BRAMs)

### Compliance Testing

To verify IEEE 802.3 compliance, test with:
1. Standard frame sizes (64, 128, 256, 512, 1024, 1518 bytes)
2. Various EtherTypes (IPv4, ARP, IPv6)
3. Known CRC test vectors
4. Edge cases (minimum payload, padding verification)

### References

- IEEE 802.3-2018: Ethernet Standard
- RFC 894: IP over Ethernet
- RFC 1042: IP and ARP over IEEE 802 Networks
