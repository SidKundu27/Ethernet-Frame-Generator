/*
 * CRC-32 Generator for Ethernet Frame Check Sequence
 * 
 * This module implements the IEEE 802.3 CRC-32 algorithm used for
 * Ethernet Frame Check Sequence (FCS) calculation.
 * 
 * Polynomial: 0x04C11DB7 (x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + 
 *                          x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1)
 * 
 * Features:
 * - Single-cycle operation for 8-bit data
 * - IEEE 802.3 compliant algorithm
 * - Optimized for FPGA implementation
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

module crc32_gen (
    input  wire        clk,        // Clock
    input  wire        rst_n,      // Active-low reset
    input  wire [7:0]  data_in,    // Input data byte
    input  wire        enable,     // Enable CRC calculation
    output reg  [31:0] crc_out     // CRC-32 output
);

// IEEE 802.3 CRC-32 polynomial: 0x04C11DB7
// The polynomial coefficients for parallel CRC calculation
wire [31:0] crc_next;

// CRC calculation logic for 8-bit parallel processing
// This implements the CRC-32 algorithm in a single clock cycle
assign crc_next[0]  = crc_out[24] ^ crc_out[30] ^ data_in[0] ^ data_in[6];
assign crc_next[1]  = crc_out[24] ^ crc_out[25] ^ crc_out[30] ^ crc_out[31] ^ data_in[0] ^ data_in[1] ^ data_in[6] ^ data_in[7];
assign crc_next[2]  = crc_out[24] ^ crc_out[25] ^ crc_out[26] ^ crc_out[30] ^ crc_out[31] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7];
assign crc_next[3]  = crc_out[25] ^ crc_out[26] ^ crc_out[27] ^ crc_out[31] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
assign crc_next[4]  = crc_out[24] ^ crc_out[26] ^ crc_out[27] ^ crc_out[28] ^ crc_out[30] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
assign crc_next[5]  = crc_out[24] ^ crc_out[25] ^ crc_out[27] ^ crc_out[28] ^ crc_out[29] ^ crc_out[30] ^ crc_out[31] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
assign crc_next[6]  = crc_out[25] ^ crc_out[26] ^ crc_out[28] ^ crc_out[29] ^ crc_out[30] ^ crc_out[31] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
assign crc_next[7]  = crc_out[24] ^ crc_out[26] ^ crc_out[27] ^ crc_out[29] ^ crc_out[31] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7];
assign crc_next[8]  = crc_out[0] ^ crc_out[24] ^ crc_out[25] ^ crc_out[27] ^ crc_out[28] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4];
assign crc_next[9]  = crc_out[1] ^ crc_out[25] ^ crc_out[26] ^ crc_out[28] ^ crc_out[29] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5];
assign crc_next[10] = crc_out[2] ^ crc_out[24] ^ crc_out[26] ^ crc_out[27] ^ crc_out[29] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5];
assign crc_next[11] = crc_out[3] ^ crc_out[24] ^ crc_out[25] ^ crc_out[27] ^ crc_out[28] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4];
assign crc_next[12] = crc_out[4] ^ crc_out[24] ^ crc_out[25] ^ crc_out[26] ^ crc_out[28] ^ crc_out[29] ^ crc_out[30] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6];
assign crc_next[13] = crc_out[5] ^ crc_out[25] ^ crc_out[26] ^ crc_out[27] ^ crc_out[29] ^ crc_out[30] ^ crc_out[31] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7];
assign crc_next[14] = crc_out[6] ^ crc_out[26] ^ crc_out[27] ^ crc_out[28] ^ crc_out[30] ^ crc_out[31] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7];
assign crc_next[15] = crc_out[7] ^ crc_out[27] ^ crc_out[28] ^ crc_out[29] ^ crc_out[31] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7];
assign crc_next[16] = crc_out[8] ^ crc_out[24] ^ crc_out[28] ^ crc_out[29] ^ data_in[0] ^ data_in[4] ^ data_in[5];
assign crc_next[17] = crc_out[9] ^ crc_out[25] ^ crc_out[29] ^ crc_out[30] ^ data_in[1] ^ data_in[5] ^ data_in[6];
assign crc_next[18] = crc_out[10] ^ crc_out[26] ^ crc_out[30] ^ crc_out[31] ^ data_in[2] ^ data_in[6] ^ data_in[7];
assign crc_next[19] = crc_out[11] ^ crc_out[27] ^ crc_out[31] ^ data_in[3] ^ data_in[7];
assign crc_next[20] = crc_out[12] ^ crc_out[28] ^ data_in[4];
assign crc_next[21] = crc_out[13] ^ crc_out[29] ^ data_in[5];
assign crc_next[22] = crc_out[14] ^ crc_out[24] ^ data_in[0];
assign crc_next[23] = crc_out[15] ^ crc_out[24] ^ crc_out[25] ^ crc_out[30] ^ data_in[0] ^ data_in[1] ^ data_in[6];
assign crc_next[24] = crc_out[16] ^ crc_out[25] ^ crc_out[26] ^ crc_out[31] ^ data_in[1] ^ data_in[2] ^ data_in[7];
assign crc_next[25] = crc_out[17] ^ crc_out[26] ^ crc_out[27] ^ data_in[2] ^ data_in[3];
assign crc_next[26] = crc_out[18] ^ crc_out[24] ^ crc_out[27] ^ crc_out[28] ^ crc_out[30] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6];
assign crc_next[27] = crc_out[19] ^ crc_out[25] ^ crc_out[28] ^ crc_out[29] ^ crc_out[31] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
assign crc_next[28] = crc_out[20] ^ crc_out[26] ^ crc_out[29] ^ crc_out[30] ^ data_in[2] ^ data_in[5] ^ data_in[6];
assign crc_next[29] = crc_out[21] ^ crc_out[27] ^ crc_out[30] ^ crc_out[31] ^ data_in[3] ^ data_in[6] ^ data_in[7];
assign crc_next[30] = crc_out[22] ^ crc_out[28] ^ crc_out[31] ^ data_in[4] ^ data_in[7];
assign crc_next[31] = crc_out[23] ^ crc_out[29] ^ data_in[5];

// Sequential logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Initialize CRC to all 1's as per IEEE 802.3
        crc_out <= 32'hFFFFFFFF;
    end else if (enable) begin
        // Update CRC with new data
        crc_out <= crc_next;
    end
end

endmodule

/*
 * Alternative table-based CRC-32 implementation
 * This version uses a lookup table for potentially better timing
 * at the cost of additional memory usage.
 */
module crc32_gen_table (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  data_in,
    input  wire        enable,
    output reg  [31:0] crc_out
);

// CRC-32 lookup table for bytes 0x00 to 0xFF
// This table is pre-computed for the IEEE 802.3 polynomial
reg [31:0] crc_table [0:255];

// Initialize the CRC table
initial begin
    integer i, j;
    reg [31:0] crc_temp;
    
    for (i = 0; i < 256; i = i + 1) begin
        crc_temp = i;
        for (j = 0; j < 8; j = j + 1) begin
            if (crc_temp[0])
                crc_temp = (crc_temp >> 1) ^ 32'hEDB88320;  // Reversed polynomial
            else
                crc_temp = crc_temp >> 1;
        end
        crc_table[i] = crc_temp;
    end
end

// Table lookup for CRC calculation
wire [7:0] table_index;
assign table_index = crc_out[7:0] ^ data_in;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        crc_out <= 32'hFFFFFFFF;
    end else if (enable) begin
        crc_out <= (crc_out >> 8) ^ crc_table[table_index];
    end
end

endmodule
