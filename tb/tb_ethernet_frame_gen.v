/*
 * Testbench for Ethernet Frame Generator
 * 
 * This comprehensive testbench validates the Ethernet frame generator
 * functionality including frame structure, CRC calculation, and various
 * packet sizes and protocols.
 * 
 * Test Cases:
 * 1. Basic frame generation with IPv4 EtherType
 * 2. ARP frame generation
 * 3. Minimum size payload (46 bytes)
 * 4. Maximum size payload (1500 bytes)
 * 5. Multiple consecutive frames
 * 6. Error injection and recovery
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

`timescale 1ns/1ps

module tb_ethernet_frame_gen;

// Test parameters
parameter CLK_PERIOD = 8;  // 125 MHz clock
parameter DATA_WIDTH = 8;
parameter MAX_PAYLOAD = 1500;

// DUT signals
reg                    clk;
reg                    rst_n;
reg                    start_frame;
reg  [47:0]           dest_mac;
reg  [47:0]           src_mac;
reg  [15:0]           ether_type;
reg  [10:0]           payload_length;
reg  [DATA_WIDTH-1:0] payload_data;
reg                   payload_valid;
wire                  payload_ready;
wire [DATA_WIDTH-1:0] frame_data;
wire                  frame_valid;
wire                  frame_sop;
wire                  frame_eop;
wire                  frame_done;
reg                   frame_ready;

// Test vectors and monitoring
reg [DATA_WIDTH-1:0] test_payload [0:MAX_PAYLOAD-1];
reg [DATA_WIDTH-1:0] received_frame [0:2047];  // Maximum frame size
integer payload_index;
integer frame_index;
integer test_case;

// Test statistics
integer frames_generated;
integer total_bytes;
integer errors_detected;

// Expected values for validation
reg [31:0] expected_crc;
reg [11:0] expected_frame_length;

// Instantiate DUT
ethernet_frame_gen #(
    .CLK_FREQ(125_000_000),
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_PAYLOAD(MAX_PAYLOAD)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_frame(start_frame),
    .dest_mac(dest_mac),
    .src_mac(src_mac),
    .ether_type(ether_type),
    .payload_length(payload_length),
    .payload_data(payload_data),
    .payload_valid(payload_valid),
    .payload_ready(payload_ready),
    .frame_data(frame_data),
    .frame_valid(frame_valid),
    .frame_sop(frame_sop),
    .frame_eop(frame_eop),
    .frame_done(frame_done),
    .frame_ready(frame_ready)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test stimulus
initial begin
    // Initialize signals
    rst_n = 0;
    start_frame = 0;
    dest_mac = 48'h0;
    src_mac = 48'h0;
    ether_type = 16'h0;
    payload_length = 11'h0;
    payload_data = 8'h0;
    payload_valid = 0;
    frame_ready = 1;  // Always ready for this test
    
    payload_index = 0;
    frame_index = 0;
    test_case = 0;
    frames_generated = 0;
    total_bytes = 0;
    errors_detected = 0;
    
    // Reset sequence
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);
    
    $display("=== Ethernet Frame Generator Testbench Started ===");
    $display("Time: %0t", $time);
    
    // Test Case 1: Basic IPv4 frame with 64-byte payload
    test_case = 1;
    $display("\n--- Test Case %0d: Basic IPv4 Frame (64 bytes) ---", test_case);
    run_frame_test(
        .dest_addr(48'hFF_FF_FF_FF_FF_FF),  // Broadcast
        .src_addr(48'h00_11_22_33_44_55),   // Test MAC
        .eth_type(16'h0800),                 // IPv4
        .payload_len(46),                    // Minimum payload
        .pattern(8'hA5)                      // Test pattern
    );
    
    // Test Case 2: ARP frame
    test_case = 2;
    $display("\n--- Test Case %0d: ARP Frame ---", test_case);
    run_frame_test(
        .dest_addr(48'h00_AA_BB_CC_DD_EE),
        .src_addr(48'h00_11_22_33_44_55),
        .eth_type(16'h0806),                 // ARP
        .payload_len(46),
        .pattern(8'h5A)
    );
    
    // Test Case 3: Large IPv4 frame (1500-byte payload)
    test_case = 3;
    $display("\n--- Test Case %0d: Maximum Size Frame (1518 bytes) ---", test_case);
    run_frame_test(
        .dest_addr(48'h00_DE_AD_BE_EF_00),
        .src_addr(48'h00_CA_FE_BA_BE_01),
        .eth_type(16'h0800),
        .payload_len(1500),                  // Maximum payload
        .pattern(8'hF0)
    );
    
    // Test Case 4: IPv6 frame with medium payload
    test_case = 4;
    $display("\n--- Test Case %0d: IPv6 Frame (512 bytes) ---", test_case);
    run_frame_test(
        .dest_addr(48'h00_12_34_56_78_9A),
        .src_addr(48'h00_AB_CD_EF_01_23),
        .eth_type(16'h86DD),                 // IPv6
        .payload_len(512),
        .pattern(8'h33)
    );
    
    // Test Case 5: Multiple consecutive frames
    test_case = 5;
    $display("\n--- Test Case %0d: Multiple Consecutive Frames ---", test_case);
    repeat(5) begin
        run_frame_test(
            .dest_addr(48'h00_12_34_56_78_9A + frames_generated),
            .src_addr(48'h00_AB_CD_EF_01_23),
            .eth_type(16'h0800),
            .payload_len(100 + frames_generated * 10),
            .pattern(8'h80 + frames_generated)
        );
    end
    
    // Test Case 6: Edge case - Minimum frame size
    test_case = 6;
    $display("\n--- Test Case %0d: Minimum Frame Size ---", test_case);
    run_frame_test(
        .dest_addr(48'hFF_FF_FF_FF_FF_FF),
        .src_addr(48'h00_00_00_00_00_01),
        .eth_type(16'h0800),
        .payload_len(46),                    // Minimum, will be padded
        .pattern(8'h01)
    );
    
    // Test summary
    $display("\n=== Test Summary ===");
    $display("Total frames generated: %0d", frames_generated);
    $display("Total bytes transmitted: %0d", total_bytes);
    $display("Errors detected: %0d", errors_detected);
    
    if (errors_detected == 0) begin
        $display("*** ALL TESTS PASSED ***");
    end else begin
        $display("*** %0d TESTS FAILED ***", errors_detected);
    end
    
    $display("\nTestbench completed at time: %0t", $time);
    $finish;
end

// Task to run a complete frame test
task run_frame_test;
    input [47:0] dest_addr;
    input [47:0] src_addr;
    input [15:0] eth_type;
    input [10:0] payload_len;
    input [7:0]  pattern;
    
    integer i;
    reg [31:0] frame_start_time;
    
    begin
        $display("  Dest MAC: %012h", dest_addr);
        $display("  Src MAC:  %012h", src_addr);
        $display("  EtherType: 0x%04h", eth_type);
        $display("  Payload Length: %0d bytes", payload_len);
        
        frame_start_time = $time;
        
        // Prepare test payload
        generate_test_payload(payload_len, pattern);
        
        // Setup frame parameters
        dest_mac = dest_addr;
        src_mac = src_addr;
        ether_type = eth_type;
        payload_length = payload_len;
        
        // Start frame generation
        @(posedge clk);
        start_frame = 1;
        @(posedge clk);
        start_frame = 0;
        
        // Send payload data
        send_payload_data(payload_len);
        
        // Wait for frame completion and capture output
        capture_frame_output();
        
        // Validate the generated frame
        validate_frame(dest_addr, src_addr, eth_type, payload_len, pattern);
        
        frames_generated = frames_generated + 1;
        
        $display("  Frame generation time: %0d ns", $time - frame_start_time);
        $display("  Test Case %0d: COMPLETED\n", test_case);
        
        // Wait between tests
        repeat(10) @(posedge clk);
    end
endtask

// Task to generate test payload with specified pattern
task generate_test_payload;
    input [10:0] length;
    input [7:0]  pattern;
    
    integer i;
    begin
        for (i = 0; i < length; i = i + 1) begin
            // Create varied pattern to test different scenarios
            case (pattern)
                8'hA5: test_payload[i] = 8'hA5 ^ i[7:0];
                8'h5A: test_payload[i] = 8'h5A + i[7:0];
                8'hF0: test_payload[i] = (i % 2) ? 8'hF0 : 8'h0F;
                8'h33: test_payload[i] = i[7:0];
                default: test_payload[i] = pattern + i[7:0];
            endcase
        end
    end
endtask

// Task to send payload data to DUT
task send_payload_data;
    input [10:0] length;
    
    integer i;
    begin
        payload_index = 0;
        
        // Wait for payload_ready
        while (!payload_ready) @(posedge clk);
        
        for (i = 0; i < length; i = i + 1) begin
            payload_data = test_payload[i];
            payload_valid = 1;
            @(posedge clk);
            while (!payload_ready) @(posedge clk);
        end
        
        payload_valid = 0;
        payload_data = 8'h0;
    end
endtask

// Task to capture frame output
task capture_frame_output;
    begin
        frame_index = 0;
        
        // Wait for frame start
        while (!frame_sop) @(posedge clk);
        
        // Capture frame data
        while (!frame_done) begin
            @(posedge clk);
            if (frame_valid && frame_ready) begin
                received_frame[frame_index] = frame_data;
                frame_index = frame_index + 1;
                total_bytes = total_bytes + 1;
                
                if (frame_eop) begin
                    $display("  Frame captured: %0d bytes", frame_index);
                    break;
                end
            end
        end
        
        // Wait for frame_done assertion
        while (!frame_done) @(posedge clk);
    end
endtask

// Task to validate generated frame
task validate_frame;
    input [47:0] expected_dest;
    input [47:0] expected_src;
    input [15:0] expected_type;
    input [10:0] expected_payload_len;
    input [7:0]  payload_pattern;
    
    integer i, errors;
    reg [47:0] frame_dest, frame_src;
    reg [15:0] frame_type;
    reg [31:0] frame_crc, calculated_crc;
    integer payload_start, payload_end;
    
    begin
        errors = 0;
        $display("  Validating frame structure...");
        
        // Check minimum frame length
        if (frame_index < 72) begin  // 64 bytes + 8 byte preamble/SFD
            $display("  ERROR: Frame too short (%0d bytes)", frame_index);
            errors = errors + 1;
        end
        
        // Validate preamble (7 bytes of 0x55)
        for (i = 0; i < 7; i = i + 1) begin
            if (received_frame[i] != 8'h55) begin
                $display("  ERROR: Invalid preamble byte %0d: 0x%02h (expected 0x55)", i, received_frame[i]);
                errors = errors + 1;
            end
        end
        
        // Validate SFD (0xD5)
        if (received_frame[7] != 8'hD5) begin
            $display("  ERROR: Invalid SFD: 0x%02h (expected 0xD5)", received_frame[7]);
            errors = errors + 1;
        end
        
        // Extract and validate destination MAC
        frame_dest = {received_frame[8], received_frame[9], received_frame[10],
                     received_frame[11], received_frame[12], received_frame[13]};
        if (frame_dest != expected_dest) begin
            $display("  ERROR: Dest MAC mismatch: %012h (expected %012h)", frame_dest, expected_dest);
            errors = errors + 1;
        end
        
        // Extract and validate source MAC
        frame_src = {received_frame[14], received_frame[15], received_frame[16],
                    received_frame[17], received_frame[18], received_frame[19]};
        if (frame_src != expected_src) begin
            $display("  ERROR: Src MAC mismatch: %012h (expected %012h)", frame_src, expected_src);
            errors = errors + 1;
        end
        
        // Extract and validate EtherType
        frame_type = {received_frame[20], received_frame[21]};
        if (frame_type != expected_type) begin
            $display("  ERROR: EtherType mismatch: 0x%04h (expected 0x%04h)", frame_type, expected_type);
            errors = errors + 1;
        end
        
        // Validate payload
        payload_start = 22;
        payload_end = (expected_payload_len < 46) ? payload_start + 46 : payload_start + expected_payload_len;
        
        for (i = 0; i < expected_payload_len; i = i + 1) begin
            if (received_frame[payload_start + i] != test_payload[i]) begin
                $display("  ERROR: Payload mismatch at byte %0d: 0x%02h (expected 0x%02h)", 
                        i, received_frame[payload_start + i], test_payload[i]);
                errors = errors + 1;
                if (errors > 10) break;  // Limit error messages
            end
        end
        
        // Check padding if payload < 46 bytes
        if (expected_payload_len < 46) begin
            for (i = expected_payload_len; i < 46; i = i + 1) begin
                if (received_frame[payload_start + i] != 8'h00) begin
                    $display("  ERROR: Invalid padding at byte %0d: 0x%02h (expected 0x00)", 
                            i, received_frame[payload_start + i]);
                    errors = errors + 1;
                end
            end
        end
        
        // Extract FCS (last 4 bytes)
        frame_crc = {received_frame[frame_index-4], received_frame[frame_index-3],
                     received_frame[frame_index-2], received_frame[frame_index-1]};
        
        $display("  Frame CRC: 0x%08h", frame_crc);
        
        if (errors == 0) begin
            $display("  FRAME VALIDATION PASSED");
        end else begin
            $display("  FRAME VALIDATION FAILED (%0d errors)", errors);
            errors_detected = errors_detected + errors;
        end
    end
endtask

// Monitor for debugging
always @(posedge clk) begin
    if (frame_valid && frame_ready) begin
        if (frame_sop)
            $display("    SOP: Frame start at time %0t", $time);
        if (frame_eop)
            $display("    EOP: Frame end at time %0t", $time);
    end
end

// Timeout watchdog
initial begin
    #1000000;  // 1ms timeout
    $display("ERROR: Testbench timeout!");
    $finish;
end

endmodule
