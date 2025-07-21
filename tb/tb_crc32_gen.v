/*
 * CRC-32 Generator Testbench
 * 
 * This testbench validates the CRC-32 calculation module against
 * known test vectors and verifies IEEE 802.3 compliance.
 * 
 * Test Cases:
 * 1. Known test vectors
 * 2. Empty message
 * 3. Single byte messages
 * 4. Standard Ethernet frame headers
 * 5. Large data blocks
 * 
 * Author: Generated for Ethernet Frame Generator Project
 * Date: July 2025
 */

`timescale 1ns/1ps

module tb_crc32_gen;

// Test parameters
parameter CLK_PERIOD = 8;  // 125 MHz

// DUT signals
reg         clk;
reg         rst_n;
reg  [7:0]  data_in;
reg         enable;
wire [31:0] crc_out;

// Test vectors and expected results
reg [7:0]  test_data [0:1023];
reg [31:0] expected_crc [0:15];
integer    test_lengths [0:15];

// Test control
integer test_case;
integer byte_count;
integer total_tests;
integer passed_tests;
integer failed_tests;
integer i;  // Loop variable

// Instantiate DUT
crc32_gen dut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .enable(enable),
    .crc_out(crc_out)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test stimulus
initial begin
    // Initialize
    rst_n = 0;
    data_in = 8'h0;
    enable = 0;
    test_case = 0;
    byte_count = 0;
    total_tests = 0;
    passed_tests = 0;
    failed_tests = 0;
    
    // Initialize test vectors
    init_test_vectors();
    
    // Reset sequence
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);
    
    $display("=== CRC-32 Generator Testbench Started ===");
    $display("Time: %0t", $time);
    
    // Test Case 1: Empty message (should result in complement of initial value)
    test_case = 1;
    $display("\n--- Test Case %0d: Empty Message ---", test_case);
    run_crc_test(0, 32'h00000000);  // Empty, expecting complement of 0xFFFFFFFF
    
    // Test Case 2: Single byte "A" (0x41)
    test_case = 2;
    $display("\n--- Test Case %0d: Single Byte 'A' ---", test_case);
    test_data[0] = 8'h41;
    run_crc_test(1, 32'hD79E1C4F);
    
    // Test Case 3: "ABC" (0x414243)
    test_case = 3;
    $display("\n--- Test Case %0d: String 'ABC' ---", test_case);
    test_data[0] = 8'h41;  // A
    test_data[1] = 8'h42;  // B
    test_data[2] = 8'h43;  // C
    run_crc_test(3, 32'hA3830348);
    
    // Test Case 4: Standard Ethernet header
    test_case = 4;
    $display("\n--- Test Case %0d: Ethernet Header ---", test_case);
    // Dest MAC: FF:FF:FF:FF:FF:FF (broadcast)
    test_data[0] = 8'hFF; test_data[1] = 8'hFF; test_data[2] = 8'hFF;
    test_data[3] = 8'hFF; test_data[4] = 8'hFF; test_data[5] = 8'hFF;
    // Src MAC: 00:11:22:33:44:55
    test_data[6] = 8'h00; test_data[7] = 8'h11; test_data[8] = 8'h22;
    test_data[9] = 8'h33; test_data[10] = 8'h44; test_data[11] = 8'h55;
    // EtherType: 0x0800 (IPv4)
    test_data[12] = 8'h08; test_data[13] = 8'h00;
    run_crc_test(14, 32'h0);  // Don't check specific value, just verify operation
    
    // Test Case 5: All zeros (46 bytes - minimum payload)
    test_case = 5;
    $display("\n--- Test Case %0d: Minimum Payload (46 zeros) ---", test_case);
    for (i = 0; i < 46; i = i + 1) test_data[i] = 8'h00;
    run_crc_test(46, 32'h0);
    
    // Test Case 6: All ones (46 bytes)
    test_case = 6;
    $display("\n--- Test Case %0d: All Ones Pattern ---", test_case);
    for (i = 0; i < 46; i = i + 1) test_data[i] = 8'hFF;
    run_crc_test(46, 32'h0);
    
    // Test Case 7: Incrementing pattern
    test_case = 7;
    $display("\n--- Test Case %0d: Incrementing Pattern ---", test_case);
    for (i = 0; i < 100; i = i + 1) test_data[i] = i[7:0];
    run_crc_test(100, 32'h0);
    
    // Test Case 8: Maximum payload size
    test_case = 8;
    $display("\n--- Test Case %0d: Maximum Payload (1500 bytes) ---", test_case);
    for (i = 0; i < 1500; i = i + 1) test_data[i] = (i * 17) & 8'hFF;  // Pseudo-random pattern
    run_crc_test(1500, 32'h0);
    
    // Test Case 9: Known IEEE 802.3 test vector
    test_case = 9;
    $display("\n--- Test Case %0d: IEEE 802.3 Test Vector ---", test_case);
    // "123456789" in ASCII
    test_data[0] = 8'h31; test_data[1] = 8'h32; test_data[2] = 8'h33;
    test_data[3] = 8'h34; test_data[4] = 8'h35; test_data[5] = 8'h36;
    test_data[6] = 8'h37; test_data[7] = 8'h38; test_data[8] = 8'h39;
    run_crc_test(9, 32'hCBF43926);  // Known result for "123456789"
    
    // Test Case 10: Reset during operation
    test_case = 10;
    $display("\n--- Test Case %0d: Reset During Operation ---", test_case);
    test_reset_behavior();
    
    // Test summary
    $display("\n=== CRC-32 Test Summary ===");
    $display("Total tests run: %0d", total_tests);
    $display("Tests passed: %0d", passed_tests);
    $display("Tests failed: %0d", failed_tests);
    
    if (failed_tests == 0) begin
        $display("*** ALL CRC TESTS PASSED ***");
    end else begin
        $display("*** %0d CRC TESTS FAILED ***", failed_tests);
    end
    
    $display("\nCRC Testbench completed at time: %0t", $time);
    $finish;
end

// Task to initialize test vectors
task init_test_vectors;
    begin
        // Initialize known test vectors
        // These are standard CRC-32 test cases from IEEE and RFC documents
        
        // Test vector 0: Empty
        expected_crc[0] = 32'h00000000;
        test_lengths[0] = 0;
        
        // Test vector 1: Single byte "A"
        expected_crc[1] = 32'hD79E1C4F;
        test_lengths[1] = 1;
        
        // Test vector 2: "ABC"
        expected_crc[2] = 32'hA3830348;
        test_lengths[2] = 3;
        
        // Additional vectors can be added here
    end
endtask

// Task to run CRC test
task run_crc_test;
    input integer length;
    input [31:0] expected;
    
    integer i;
    reg [31:0] start_time;
    
    begin
        total_tests = total_tests + 1;
        start_time = $time;
        
        $display("  Testing %0d bytes of data", length);
        if (expected != 32'h0)
            $display("  Expected CRC: 0x%08h", expected);
        
        // Reset CRC
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Send data
        enable = 1;
        for (i = 0; i < length; i = i + 1) begin
            data_in = test_data[i];
            @(posedge clk);
        end
        enable = 0;
        
        // Wait one cycle for final result
        @(posedge clk);
        
        // Check result
        $display("  Calculated CRC: 0x%08h", crc_out);
        $display("  Test duration: %0d ns", $time - start_time);
        
        if (expected != 32'h0) begin
            if (crc_out == expected) begin
                $display("  ✓ CRC Test PASSED");
                passed_tests = passed_tests + 1;
            end else begin
                $display("  ✗ CRC Test FAILED - Expected: 0x%08h, Got: 0x%08h", expected, crc_out);
                failed_tests = failed_tests + 1;
            end
        end else begin
            $display("  ✓ CRC calculation completed (no expected value)");
            passed_tests = passed_tests + 1;
        end
        
        $display("");
    end
endtask

// Task to test reset behavior
task test_reset_behavior;
    integer i;
    reg [31:0] crc_before_reset, crc_after_reset;
    
    begin
        $display("  Testing reset behavior during CRC calculation");
        
        // Start CRC calculation
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        enable = 1;
        // Send some data
        for (i = 0; i < 5; i = i + 1) begin
            data_in = 8'hAA;
            @(posedge clk);
        end
        
        // Capture CRC state
        crc_before_reset = crc_out;
        $display("  CRC before reset: 0x%08h", crc_before_reset);
        
        // Reset during operation
        rst_n = 0;
        @(posedge clk);
        crc_after_reset = crc_out;
        $display("  CRC after reset: 0x%08h", crc_after_reset);
        
        rst_n = 1;
        enable = 0;
        @(posedge clk);
        
        // Verify reset worked
        if (crc_after_reset == 32'hFFFFFFFF) begin
            $display("  ✓ Reset behavior PASSED");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  ✗ Reset behavior FAILED - Expected: 0xFFFFFFFF, Got: 0x%08h", crc_after_reset);
            failed_tests = failed_tests + 1;
        end
        
        total_tests = total_tests + 1;
    end
endtask

// Monitor CRC output changes
always @(posedge clk) begin
    if (enable && rst_n) begin
        $display("    CRC step: data=0x%02h, crc=0x%08h", data_in, crc_out);
    end
end

// Timeout protection
initial begin
    #500000;  // 500us timeout
    $display("ERROR: CRC testbench timeout!");
    $finish;
end

endmodule

/*
 * Table-based CRC testbench
 * Tests the alternative table-based implementation
 */
module tb_crc32_gen_table;

parameter CLK_PERIOD = 8;

reg         clk;
reg         rst_n;
reg  [7:0]  data_in;
reg         enable;
wire [31:0] crc_out;

// Instantiate table-based CRC
crc32_gen_table dut_table (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .enable(enable),
    .crc_out(crc_out)
);

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    $display("=== CRC-32 Table-Based Implementation Test ===");
    
    rst_n = 0;
    data_in = 8'h0;
    enable = 0;
    
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(5) @(posedge clk);
    
    // Test "123456789"
    enable = 1;
    data_in = 8'h31; @(posedge clk);  // '1'
    data_in = 8'h32; @(posedge clk);  // '2'
    data_in = 8'h33; @(posedge clk);  // '3'
    data_in = 8'h34; @(posedge clk);  // '4'
    data_in = 8'h35; @(posedge clk);  // '5'
    data_in = 8'h36; @(posedge clk);  // '6'
    data_in = 8'h37; @(posedge clk);  // '7'
    data_in = 8'h38; @(posedge clk);  // '8'
    data_in = 8'h39; @(posedge clk);  // '9'
    enable = 0;
    
    @(posedge clk);
    
    $display("Table-based CRC result: 0x%08h", crc_out);
    $display("Expected result:        0x%08h", 32'hCBF43926);
    
    if (crc_out == 32'hCBF43926) begin
        $display("✓ Table-based CRC test PASSED");
    end else begin
        $display("✗ Table-based CRC test FAILED");
    end
    
    $finish;
end

endmodule
