/*
 * Packet Buffer Module
 * 
 * This module provides buffering and management for Ethernet frame data.
 * It includes FIFO buffers for payload data, flow control, and packet
 * queuing capabilities.
 * 
 * Features:
 * - Configurable buffer depth
 * - FIFO-based packet buffering
 * - Flow control and backpressure
 * - Packet boundary management
 * - Buffer status monitoring
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

module packet_buffer #(
    parameter DATA_WIDTH = 8,
    parameter BUFFER_DEPTH = 2048,    // Buffer depth in bytes
    parameter ADDR_WIDTH = $clog2(BUFFER_DEPTH)
)(
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Write interface (packet input)
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire                   wr_valid,
    input  wire                   wr_sop,      // Start of packet
    input  wire                   wr_eop,      // End of packet
    output reg                    wr_ready,
    
    // Read interface (packet output)
    output reg  [DATA_WIDTH-1:0]  rd_data,
    output reg                    rd_valid,
    output reg                    rd_sop,
    output reg                    rd_eop,
    input  wire                   rd_ready,
    
    // Buffer status
    output reg  [ADDR_WIDTH:0]    buffer_level,     // Current buffer occupancy
    output reg                    buffer_full,
    output reg                    buffer_empty,
    output reg                    buffer_almost_full,
    output reg                    buffer_almost_empty,
    
    // Packet count
    output reg  [7:0]             packet_count,     // Number of complete packets in buffer
    output reg                    packet_available,
    
    // Error flags
    output reg                    overflow_error,
    output reg                    underflow_error
);

// Buffer memory
reg [DATA_WIDTH-1:0] buffer_mem [0:BUFFER_DEPTH-1];

// Address pointers
reg [ADDR_WIDTH:0] wr_ptr;
reg [ADDR_WIDTH:0] rd_ptr;

// Packet boundary tracking
reg [ADDR_WIDTH:0] packet_start_addr [0:255];  // Support up to 256 packets
reg [7:0] packet_wr_ptr;
reg [7:0] packet_rd_ptr;

// Internal signals
wire [ADDR_WIDTH:0] next_wr_ptr;
wire [ADDR_WIDTH:0] next_rd_ptr;
wire buffer_wr_en;
wire buffer_rd_en;

// Threshold values
localparam [ADDR_WIDTH:0] ALMOST_FULL_THRESHOLD  = BUFFER_DEPTH - 16;
localparam [ADDR_WIDTH:0] ALMOST_EMPTY_THRESHOLD = 16;

// Next pointer calculations
assign next_wr_ptr = (wr_ptr == BUFFER_DEPTH - 1) ? {(ADDR_WIDTH+1){1'b0}} : wr_ptr + 1'b1;
assign next_rd_ptr = (rd_ptr == BUFFER_DEPTH - 1) ? {(ADDR_WIDTH+1){1'b0}} : rd_ptr + 1'b1;

// Buffer control signals
assign buffer_wr_en = wr_valid && wr_ready;
assign buffer_rd_en = rd_ready && rd_valid;

// Buffer level calculation
always @(*) begin
    if (wr_ptr >= rd_ptr) begin
        buffer_level = wr_ptr - rd_ptr;
    end else begin
        buffer_level = BUFFER_DEPTH - rd_ptr + wr_ptr;
    end
end

// Buffer status flags
always @(*) begin
    buffer_full = (next_wr_ptr == rd_ptr);
    buffer_empty = (wr_ptr == rd_ptr);
    buffer_almost_full = (buffer_level >= ALMOST_FULL_THRESHOLD);
    buffer_almost_empty = (buffer_level <= ALMOST_EMPTY_THRESHOLD);
    packet_available = (packet_count > 0);
end

// Write side control
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= {(ADDR_WIDTH+1){1'b0}};
        packet_wr_ptr <= 8'h0;
        wr_ready <= 1'b1;
        overflow_error <= 1'b0;
    end else begin
        // Default ready unless buffer is full
        wr_ready <= !buffer_full;
        
        if (buffer_wr_en) begin
            // Write data to buffer
            buffer_mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= next_wr_ptr;
            
            // Track packet boundaries
            if (wr_sop) begin
                packet_start_addr[packet_wr_ptr] <= wr_ptr;
            end
            
            if (wr_eop) begin
                packet_wr_ptr <= packet_wr_ptr + 1'b1;
            end
            
            // Check for overflow
            if (buffer_full) begin
                overflow_error <= 1'b1;
                wr_ready <= 1'b0;
            end
        end
        
        // Clear overflow error when buffer has space
        if (!buffer_almost_full) begin
            overflow_error <= 1'b0;
        end
    end
end

// Read side control
reg reading_packet;
reg [ADDR_WIDTH:0] current_packet_start;
reg [ADDR_WIDTH:0] next_packet_start;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= {(ADDR_WIDTH+1){1'b0}};
        packet_rd_ptr <= 8'h0;
        rd_valid <= 1'b0;
        rd_sop <= 1'b0;
        rd_eop <= 1'b0;
        rd_data <= {DATA_WIDTH{1'b0}};
        reading_packet <= 1'b0;
        current_packet_start <= {(ADDR_WIDTH+1){1'b0}};
        underflow_error <= 1'b0;
    end else begin
        // Default values
        rd_sop <= 1'b0;
        rd_eop <= 1'b0;
        
        if (packet_available && rd_ready && !reading_packet) begin
            // Start reading a new packet
            reading_packet <= 1'b1;
            current_packet_start <= packet_start_addr[packet_rd_ptr];
            rd_sop <= 1'b1;
            rd_valid <= 1'b1;
            rd_data <= buffer_mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= next_rd_ptr;
        end else if (reading_packet && rd_ready) begin
            // Continue reading current packet
            rd_data <= buffer_mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_valid <= 1'b1;
            
            // Check if this is the last byte of the packet
            if (packet_rd_ptr < packet_wr_ptr - 1) begin
                next_packet_start = packet_start_addr[packet_rd_ptr + 1];
            end else begin
                next_packet_start = wr_ptr;
            end
            
            if (next_rd_ptr == next_packet_start) begin
                // End of current packet
                rd_eop <= 1'b1;
                reading_packet <= 1'b0;
                packet_rd_ptr <= packet_rd_ptr + 1'b1;
            end
            
            rd_ptr <= next_rd_ptr;
        end else if (!packet_available) begin
            rd_valid <= 1'b0;
            reading_packet <= 1'b0;
        end
        
        // Check for underflow
        if (buffer_rd_en && buffer_empty) begin
            underflow_error <= 1'b1;
        end
        
        // Clear underflow error when data is available
        if (!buffer_empty) begin
            underflow_error <= 1'b0;
        end
    end
end

// Packet count calculation
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        packet_count <= 8'h0;
    end else begin
        case ({wr_eop && buffer_wr_en, rd_eop && buffer_rd_en})
            2'b00: packet_count <= packet_count;              // No change
            2'b01: packet_count <= packet_count - 1'b1;       // Packet read
            2'b10: packet_count <= packet_count + 1'b1;       // Packet written
            2'b11: packet_count <= packet_count;              // Both, no net change
        endcase
    end
end

endmodule

/*
 * Dual-Clock Packet Buffer
 * 
 * This version supports different clock domains for write and read sides,
 * useful for clock domain crossing applications.
 */
module packet_buffer_dual_clock #(
    parameter DATA_WIDTH = 8,
    parameter BUFFER_DEPTH = 2048,
    parameter ADDR_WIDTH = $clog2(BUFFER_DEPTH)
)(
    // Write side (input clock domain)
    input  wire                    wr_clk,
    input  wire                    wr_rst_n,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire                   wr_valid,
    input  wire                   wr_sop,
    input  wire                   wr_eop,
    output reg                    wr_ready,
    
    // Read side (output clock domain)
    input  wire                    rd_clk,
    input  wire                    rd_rst_n,
    output reg  [DATA_WIDTH-1:0]  rd_data,
    output reg                    rd_valid,
    output reg                    rd_sop,
    output reg                    rd_eop,
    input  wire                   rd_ready,
    
    // Status (in respective clock domains)
    output reg  [ADDR_WIDTH:0]    wr_buffer_level,
    output reg  [ADDR_WIDTH:0]    rd_buffer_level,
    output reg                    buffer_full,
    output reg                    buffer_empty,
    output reg  [7:0]             packet_count
);

// Gray code counters for clock domain crossing
reg [ADDR_WIDTH:0] wr_gray, wr_gray_next;
reg [ADDR_WIDTH:0] rd_gray, rd_gray_next;

// Synchronized gray code pointers
reg [ADDR_WIDTH:0] wr_gray_sync [0:1];
reg [ADDR_WIDTH:0] rd_gray_sync [0:1];

// Binary pointers
reg [ADDR_WIDTH:0] wr_bin, rd_bin;

// Buffer memory (must be inferred as dual-port RAM)
reg [DATA_WIDTH-1:0] buffer_mem [0:BUFFER_DEPTH-1];

// Gray code conversion functions
function [ADDR_WIDTH:0] bin_to_gray;
    input [ADDR_WIDTH:0] bin;
    begin
        bin_to_gray = bin ^ (bin >> 1);
    end
endfunction

function [ADDR_WIDTH:0] gray_to_bin;
    input [ADDR_WIDTH:0] gray;
    integer i;
    begin
        gray_to_bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
        for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin
            gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
        end
    end
endfunction

// Write side logic
always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_bin <= {(ADDR_WIDTH+1){1'b0}};
        wr_gray <= {(ADDR_WIDTH+1){1'b0}};
    end else if (wr_valid && wr_ready) begin
        buffer_mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
        wr_bin <= wr_bin + 1'b1;
        wr_gray <= bin_to_gray(wr_bin + 1'b1);
    end
end

// Read side logic
always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_bin <= {(ADDR_WIDTH+1){1'b0}};
        rd_gray <= {(ADDR_WIDTH+1){1'b0}};
        rd_data <= {DATA_WIDTH{1'b0}};
        rd_valid <= 1'b0;
    end else if (rd_ready && !buffer_empty) begin
        rd_data <= buffer_mem[rd_bin[ADDR_WIDTH-1:0]];
        rd_valid <= 1'b1;
        rd_bin <= rd_bin + 1'b1;
        rd_gray <= bin_to_gray(rd_bin + 1'b1);
    end else begin
        rd_valid <= 1'b0;
    end
end

// Synchronize gray pointers across clock domains
always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        rd_gray_sync[0] <= {(ADDR_WIDTH+1){1'b0}};
        rd_gray_sync[1] <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        rd_gray_sync[0] <= rd_gray;
        rd_gray_sync[1] <= rd_gray_sync[0];
    end
end

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        wr_gray_sync[0] <= {(ADDR_WIDTH+1){1'b0}};
        wr_gray_sync[1] <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        wr_gray_sync[0] <= wr_gray;
        wr_gray_sync[1] <= wr_gray_sync[0];
    end
end

// Generate status flags
always_comb begin
    buffer_full = (wr_gray_next == rd_gray_sync[1]);
    buffer_empty = (rd_gray == wr_gray_sync[1]);
    wr_ready = !buffer_full;
end

assign wr_gray_next = bin_to_gray(wr_bin + 1'b1);

endmodule
