/*
 * Ethernet Frame Generator
 * 
 * This module generates IEEE 802.3 compliant Ethernet frames with configurable
 * parameters including MAC addresses, EtherType, and payload data.
 * 
 * Features:
 * - IEEE 802.3 frame structure compliance
 * - Configurable source/destination MAC addresses
 * - Variable payload length (46-1500 bytes)
 * - Hardware CRC-32 calculation
 * - Preamble and Start Frame Delimiter generation
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

module ethernet_frame_gen #(
    parameter CLK_FREQ = 125_000_000,  // Clock frequency in Hz
    parameter DATA_WIDTH = 8,          // Data interface width
    parameter MAX_PAYLOAD = 1500       // Maximum payload size in bytes
)(
    // Clock and Reset
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Control Interface
    input  wire                    start_frame,     // Start frame generation
    input  wire [47:0]            dest_mac,        // Destination MAC address
    input  wire [47:0]            src_mac,         // Source MAC address
    input  wire [15:0]            ether_type,      // EtherType/Length field
    input  wire [10:0]            payload_length,  // Payload length (46-1500)
    
    // Payload Interface
    input  wire [DATA_WIDTH-1:0]  payload_data,    // Payload data input
    input  wire                   payload_valid,   // Payload data valid
    output reg                    payload_ready,   // Ready for payload data
    
    // Frame Output Interface  
    output reg  [DATA_WIDTH-1:0]  frame_data,      // Generated frame data
    output reg                    frame_valid,     // Frame data valid
    output reg                    frame_sop,       // Start of packet
    output reg                    frame_eop,       // End of packet
    output reg                    frame_done,      // Frame generation complete
    input  wire                   frame_ready      // Downstream ready
);

// Frame generation states
localparam [3:0] IDLE        = 4'h0;
localparam [3:0] PREAMBLE    = 4'h1;
localparam [3:0] SFD         = 4'h2;
localparam [3:0] DEST_MAC    = 4'h3;
localparam [3:0] SRC_MAC     = 4'h4;
localparam [3:0] ETHER_TYPE  = 4'h5;
localparam [3:0] PAYLOAD     = 4'h6;
localparam [3:0] PAD         = 4'h7;
localparam [3:0] CRC         = 4'h8;
localparam [3:0] COMPLETE    = 4'h9;

reg [3:0] current_state, next_state;

// Internal registers
reg [3:0]  byte_counter;
reg [10:0] payload_counter;
reg [10:0] total_payload_length;
reg [47:0] dest_mac_reg;
reg [47:0] src_mac_reg;
reg [15:0] ether_type_reg;

// Frame structure constants
localparam [7:0] PREAMBLE_BYTE = 8'h55;
localparam [7:0] SFD_BYTE      = 8'hD5;

// CRC-32 interface
wire [31:0] crc_out;
wire        crc_enable;
reg         crc_reset;
wire [7:0]  crc_data;

// Payload buffering
reg [DATA_WIDTH-1:0] payload_buffer [0:MAX_PAYLOAD-1];
reg [10:0] payload_write_ptr;
reg [10:0] payload_read_ptr;
reg        payload_complete;

// Instantiate CRC-32 generator
crc32_gen crc_inst (
    .clk(clk),
    .rst_n(rst_n && !crc_reset),
    .data_in(crc_data),
    .enable(crc_enable),
    .crc_out(crc_out)
);

// Assign CRC data based on current state
assign crc_data = frame_data;
assign crc_enable = frame_valid && frame_ready && 
                   (current_state != IDLE && current_state != PREAMBLE && 
                    current_state != SFD && current_state != CRC && 
                    current_state != COMPLETE);

// State machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    next_state = current_state;
    
    case (current_state)
        IDLE: begin
            if (start_frame && payload_complete)
                next_state = PREAMBLE;
        end
        
        PREAMBLE: begin
            if (frame_ready && byte_counter == 4'd6)
                next_state = SFD;
        end
        
        SFD: begin
            if (frame_ready)
                next_state = DEST_MAC;
        end
        
        DEST_MAC: begin
            if (frame_ready && byte_counter == 4'd5)
                next_state = SRC_MAC;
        end
        
        SRC_MAC: begin
            if (frame_ready && byte_counter == 4'd5)
                next_state = ETHER_TYPE;
        end
        
        ETHER_TYPE: begin
            if (frame_ready && byte_counter == 4'd1)
                next_state = PAYLOAD;
        end
        
        PAYLOAD: begin
            if (frame_ready && payload_counter == total_payload_length - 1) begin
                if (total_payload_length < 46)
                    next_state = PAD;
                else
                    next_state = CRC;
            end
        end
        
        PAD: begin
            if (frame_ready && payload_counter == 11'd45)
                next_state = CRC;
        end
        
        CRC: begin
            if (frame_ready && byte_counter == 4'd3)
                next_state = COMPLETE;
        end
        
        COMPLETE: begin
            if (frame_ready)
                next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

// Output logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_data <= 8'h00;
        frame_valid <= 1'b0;
        frame_sop <= 1'b0;
        frame_eop <= 1'b0;
        frame_done <= 1'b0;
        byte_counter <= 4'h0;
        payload_counter <= 11'h0;
        crc_reset <= 1'b1;
        dest_mac_reg <= 48'h0;
        src_mac_reg <= 48'h0;
        ether_type_reg <= 16'h0;
        total_payload_length <= 11'h0;
        payload_read_ptr <= 11'h0;
    end else begin
        // Default assignments
        frame_valid <= 1'b0;
        frame_sop <= 1'b0;
        frame_eop <= 1'b0;
        frame_done <= 1'b0;
        crc_reset <= 1'b0;
        
        case (current_state)
            IDLE: begin
                if (start_frame && payload_complete) begin
                    dest_mac_reg <= dest_mac;
                    src_mac_reg <= src_mac;
                    ether_type_reg <= ether_type;
                    total_payload_length <= payload_length;
                    byte_counter <= 4'h0;
                    payload_counter <= 11'h0;
                    payload_read_ptr <= 11'h0;
                    crc_reset <= 1'b1;
                end
            end
            
            PREAMBLE: begin
                if (frame_ready) begin
                    frame_data <= PREAMBLE_BYTE;
                    frame_valid <= 1'b1;
                    if (byte_counter == 4'h0)
                        frame_sop <= 1'b1;
                    byte_counter <= byte_counter + 1'b1;
                end
            end
            
            SFD: begin
                if (frame_ready) begin
                    frame_data <= SFD_BYTE;
                    frame_valid <= 1'b1;
                    byte_counter <= 4'h0;
                end
            end
            
            DEST_MAC: begin
                if (frame_ready) begin
                    frame_data <= dest_mac_reg[47-byte_counter*8 -: 8];
                    frame_valid <= 1'b1;
                    byte_counter <= byte_counter + 1'b1;
                end
            end
            
            SRC_MAC: begin
                if (frame_ready) begin
                    frame_data <= src_mac_reg[47-byte_counter*8 -: 8];
                    frame_valid <= 1'b1;
                    byte_counter <= byte_counter + 1'b1;
                end
            end
            
            ETHER_TYPE: begin
                if (frame_ready) begin
                    frame_data <= ether_type_reg[15-byte_counter*8 -: 8];
                    frame_valid <= 1'b1;
                    byte_counter <= byte_counter + 1'b1;
                end
            end
            
            PAYLOAD: begin
                if (frame_ready) begin
                    frame_data <= payload_buffer[payload_read_ptr];
                    frame_valid <= 1'b1;
                    payload_counter <= payload_counter + 1'b1;
                    payload_read_ptr <= payload_read_ptr + 1'b1;
                end
            end
            
            PAD: begin
                if (frame_ready) begin
                    frame_data <= 8'h00;  // Padding with zeros
                    frame_valid <= 1'b1;
                    payload_counter <= payload_counter + 1'b1;
                end
            end
            
            CRC: begin
                if (frame_ready) begin
                    // Output CRC bytes in network byte order (MSB first)
                    frame_data <= crc_out[31-byte_counter*8 -: 8];
                    frame_valid <= 1'b1;
                    byte_counter <= byte_counter + 1'b1;
                    if (byte_counter == 4'd3)
                        frame_eop <= 1'b1;
                end
            end
            
            COMPLETE: begin
                if (frame_ready) begin
                    frame_done <= 1'b1;
                end
            end
        endcase
    end
end

// Payload buffering logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        payload_write_ptr <= 11'h0;
        payload_complete <= 1'b0;
        payload_ready <= 1'b0;
    end else begin
        if (current_state == IDLE) begin
            payload_ready <= 1'b1;
            if (start_frame) begin
                payload_write_ptr <= 11'h0;
                payload_complete <= 1'b0;
            end
        end else if (current_state == COMPLETE) begin
            payload_ready <= 1'b0;
            payload_complete <= 1'b0;
        end
        
        // Buffer payload data
        if (payload_valid && payload_ready && !payload_complete) begin
            payload_buffer[payload_write_ptr] <= payload_data;
            payload_write_ptr <= payload_write_ptr + 1'b1;
            
            if (payload_write_ptr == payload_length - 1) begin
                payload_complete <= 1'b1;
                payload_ready <= 1'b0;
            end
        end
    end
end

endmodule
