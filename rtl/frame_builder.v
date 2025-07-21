/*
 * Frame Builder Module
 * 
 * This module assists in building Ethernet frame components and manages
 * frame structure validation. It provides utilities for frame formatting
 * and validation according to IEEE 802.3 standards.
 * 
 * Features:
 * - Frame structure validation
 * - Header field extraction and formatting
 * - Payload length validation
 * - Frame size calculations
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

module frame_builder #(
    parameter DATA_WIDTH = 8,
    parameter MAX_FRAME_SIZE = 1518
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Configuration inputs
    input  wire [47:0]             dest_mac,
    input  wire [47:0]             src_mac,
    input  wire [15:0]             ether_type,
    input  wire [10:0]             payload_length,
    
    // Frame validation
    output reg                     frame_valid,
    output reg                     length_valid,
    output reg                     mac_valid,
    output reg                     ether_type_valid,
    
    // Frame size calculations
    output reg  [11:0]             total_frame_size,
    output reg  [11:0]             header_size,
    output reg  [11:0]             min_frame_size,
    output reg  [11:0]             max_frame_size,
    
    // Frame component outputs (for debugging/monitoring)
    output reg  [7:0]              frame_component,
    output reg  [3:0]              component_type,
    
    // Status outputs
    output reg                     build_complete,
    output reg                     build_error
);

// Frame component types
localparam [3:0] COMP_PREAMBLE   = 4'h0;
localparam [3:0] COMP_SFD        = 4'h1;
localparam [3:0] COMP_DEST_MAC   = 4'h2;
localparam [3:0] COMP_SRC_MAC    = 4'h3;
localparam [3:0] COMP_ETHER_TYPE = 4'h4;
localparam [3:0] COMP_PAYLOAD    = 4'h5;
localparam [3:0] COMP_PAD        = 4'h6;
localparam [3:0] COMP_FCS        = 4'h7;

// Frame size constants
localparam [11:0] PREAMBLE_SIZE   = 12'd7;
localparam [11:0] SFD_SIZE        = 12'd1;
localparam [11:0] MAC_ADDR_SIZE   = 12'd6;
localparam [11:0] ETHER_TYPE_SIZE = 12'd2;
localparam [11:0] FCS_SIZE        = 12'd4;
localparam [11:0] MIN_PAYLOAD     = 12'd46;
localparam [11:0] MAX_PAYLOAD     = 12'd1500;

// Validation logic
always @(*) begin
    // MAC address validation (check for valid unicast/multicast)
    mac_valid = (dest_mac != 48'h0) && (src_mac != 48'h0);
    
    // Payload length validation
    length_valid = (payload_length >= MIN_PAYLOAD) && (payload_length <= MAX_PAYLOAD);
    
    // EtherType validation (check for common valid types)
    ether_type_valid = (ether_type >= 16'h0600) ||  // Length/Type disambiguation
                       (ether_type == 16'h0800) ||  // IPv4
                       (ether_type == 16'h0806) ||  // ARP
                       (ether_type == 16'h86DD);    // IPv6
    
    // Overall frame validation
    frame_valid = mac_valid && length_valid && ether_type_valid;
end

// Frame size calculations
always @(*) begin
    // Calculate header size (without preamble and SFD)
    header_size = (2 * MAC_ADDR_SIZE) + ETHER_TYPE_SIZE;
    
    // Calculate total frame size including all components
    total_frame_size = PREAMBLE_SIZE + SFD_SIZE + header_size + 
                      ((payload_length < MIN_PAYLOAD) ? MIN_PAYLOAD : payload_length) + 
                      FCS_SIZE;
    
    // Frame size limits
    min_frame_size = PREAMBLE_SIZE + SFD_SIZE + header_size + MIN_PAYLOAD + FCS_SIZE;  // 72 bytes
    max_frame_size = PREAMBLE_SIZE + SFD_SIZE + header_size + MAX_PAYLOAD + FCS_SIZE;  // 1526 bytes
end

// Frame component extraction for debugging
reg [2:0] debug_state;
reg [3:0] byte_index;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_component <= 8'h0;
        component_type <= 4'h0;
        build_complete <= 1'b0;
        build_error <= 1'b0;
        debug_state <= 3'h0;
        byte_index <= 4'h0;
    end else begin
        build_error <= !frame_valid;
        
        case (debug_state)
            3'h0: begin  // DEST_MAC
                component_type <= COMP_DEST_MAC;
                frame_component <= dest_mac[47-byte_index*8 -: 8];
                if (byte_index == 4'd5) begin
                    debug_state <= 3'h1;
                    byte_index <= 4'h0;
                end else begin
                    byte_index <= byte_index + 1'b1;
                end
            end
            
            3'h1: begin  // SRC_MAC
                component_type <= COMP_SRC_MAC;
                frame_component <= src_mac[47-byte_index*8 -: 8];
                if (byte_index == 4'd5) begin
                    debug_state <= 3'h2;
                    byte_index <= 4'h0;
                end else begin
                    byte_index <= byte_index + 1'b1;
                end
            end
            
            3'h2: begin  // ETHER_TYPE
                component_type <= COMP_ETHER_TYPE;
                frame_component <= ether_type[15-byte_index*8 -: 8];
                if (byte_index == 4'd1) begin
                    debug_state <= 3'h3;
                    byte_index <= 4'h0;
                    build_complete <= 1'b1;
                end else begin
                    byte_index <= byte_index + 1'b1;
                end
            end
            
            3'h3: begin  // Complete
                build_complete <= 1'b1;
            end
            
            default: debug_state <= 3'h0;
        endcase
    end
end

endmodule

/*
 * Frame Validator Module
 * 
 * This module provides comprehensive validation of incoming Ethernet frames
 * for compliance with IEEE 802.3 standards.
 */
module frame_validator #(
    parameter DATA_WIDTH = 8
)(
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Frame input
    input  wire [DATA_WIDTH-1:0]  frame_data,
    input  wire                   frame_valid,
    input  wire                   frame_sop,
    input  wire                   frame_eop,
    
    // Validation results
    output reg                    preamble_valid,
    output reg                    sfd_valid,
    output reg                    length_valid,
    output reg                    crc_valid,
    output reg                    frame_format_valid,
    
    // Frame information extraction
    output reg  [47:0]           dest_mac_out,
    output reg  [47:0]           src_mac_out,
    output reg  [15:0]           ether_type_out,
    output reg  [10:0]           payload_length_out,
    
    // Status
    output reg                   validation_complete,
    output reg                   validation_error
);

// Validation state machine
localparam [3:0] WAIT_SOP     = 4'h0;
localparam [3:0] CHECK_PREAMBLE = 4'h1;
localparam [3:0] CHECK_SFD    = 4'h2;
localparam [3:0] EXTRACT_DEST = 4'h3;
localparam [3:0] EXTRACT_SRC  = 4'h4;
localparam [3:0] EXTRACT_TYPE = 4'h5;
localparam [3:0] COUNT_PAYLOAD = 4'h6;
localparam [3:0] CHECK_CRC    = 4'h7;
localparam [3:0] VALIDATE     = 4'h8;

reg [3:0] current_state, next_state;

// Internal registers
reg [3:0]  byte_counter;
reg [10:0] payload_counter;
reg [47:0] dest_mac_reg;
reg [47:0] src_mac_reg;
reg [15:0] ether_type_reg;
reg [31:0] received_crc;
reg [31:0] calculated_crc;

// Preamble and SFD constants
localparam [7:0] PREAMBLE_BYTE = 8'h55;
localparam [7:0] SFD_BYTE      = 8'hD5;

// CRC calculation for validation
wire [31:0] crc_out;
reg         crc_enable;
reg         crc_reset;

crc32_gen crc_validator (
    .clk(clk),
    .rst_n(rst_n && !crc_reset),
    .data_in(frame_data),
    .enable(crc_enable),
    .crc_out(crc_out)
);

// State machine logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= WAIT_SOP;
        // Reset all outputs
        preamble_valid <= 1'b0;
        sfd_valid <= 1'b0;
        length_valid <= 1'b0;
        crc_valid <= 1'b0;
        frame_format_valid <= 1'b0;
        validation_complete <= 1'b0;
        validation_error <= 1'b0;
        byte_counter <= 4'h0;
        payload_counter <= 11'h0;
        crc_reset <= 1'b1;
    end else begin
        case (current_state)
            WAIT_SOP: begin
                if (frame_sop && frame_valid) begin
                    current_state <= CHECK_PREAMBLE;
                    crc_reset <= 1'b1;
                    byte_counter <= 4'h0;
                    preamble_valid <= 1'b1;  // Assume valid until proven otherwise
                end
            end
            
            CHECK_PREAMBLE: begin
                if (frame_valid) begin
                    if (frame_data != PREAMBLE_BYTE && byte_counter < 7) begin
                        preamble_valid <= 1'b0;
                    end
                    
                    if (byte_counter == 4'd6) begin
                        current_state <= CHECK_SFD;
                    end else begin
                        byte_counter <= byte_counter + 1'b1;
                    end
                end
            end
            
            CHECK_SFD: begin
                if (frame_valid) begin
                    sfd_valid <= (frame_data == SFD_BYTE);
                    current_state <= EXTRACT_DEST;
                    byte_counter <= 4'h0;
                    crc_reset <= 1'b0;
                end
            end
            
            EXTRACT_DEST: begin
                if (frame_valid) begin
                    dest_mac_reg[47-byte_counter*8 -: 8] <= frame_data;
                    if (byte_counter == 4'd5) begin
                        current_state <= EXTRACT_SRC;
                        byte_counter <= 4'h0;
                    end else begin
                        byte_counter <= byte_counter + 1'b1;
                    end
                end
            end
            
            EXTRACT_SRC: begin
                if (frame_valid) begin
                    src_mac_reg[47-byte_counter*8 -: 8] <= frame_data;
                    if (byte_counter == 4'd5) begin
                        current_state <= EXTRACT_TYPE;
                        byte_counter <= 4'h0;
                    end else begin
                        byte_counter <= byte_counter + 1'b1;
                    end
                end
            end
            
            EXTRACT_TYPE: begin
                if (frame_valid) begin
                    ether_type_reg[15-byte_counter*8 -: 8] <= frame_data;
                    if (byte_counter == 4'd1) begin
                        current_state <= COUNT_PAYLOAD;
                        payload_counter <= 11'h0;
                    end else begin
                        byte_counter <= byte_counter + 1'b1;
                    end
                end
            end
            
            COUNT_PAYLOAD: begin
                if (frame_valid && !frame_eop) begin
                    payload_counter <= payload_counter + 1'b1;
                end else if (frame_eop) begin
                    current_state <= VALIDATE;
                    calculated_crc <= crc_out;
                end
            end
            
            VALIDATE: begin
                // Perform final validation
                dest_mac_out <= dest_mac_reg;
                src_mac_out <= src_mac_reg;
                ether_type_out <= ether_type_reg;
                payload_length_out <= payload_counter;
                
                length_valid <= (payload_counter >= 46) && (payload_counter <= 1500);
                frame_format_valid <= preamble_valid && sfd_valid && length_valid;
                validation_complete <= 1'b1;
                
                current_state <= WAIT_SOP;
            end
            
            default: current_state <= WAIT_SOP;
        endcase
    end
end

// CRC enable logic
always @(*) begin
    crc_enable = frame_valid && (current_state == EXTRACT_DEST || 
                                current_state == EXTRACT_SRC || 
                                current_state == EXTRACT_TYPE || 
                                current_state == COUNT_PAYLOAD);
end

endmodule
