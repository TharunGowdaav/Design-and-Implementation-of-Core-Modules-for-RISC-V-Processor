module riscv_top_tb();
    // Clock and reset
    reg clk;
    reg reset;
    reg [31:0] instruction;
    wire [31:0] alu_result;
    wire reg_write;
    wire reg_read;
    
    // Test statistics and coverage
    integer test_count;
    integer error_count;
    integer warning_count;
    time test_start_time;
    time test_end_time;
    real success_rate;
    time current_test_start;  // Added this declaration at the module level
    
    // Coverage tracking
    reg [7:0] opcode_coverage[0:127];  // Track instruction coverage
    reg [31:0] result_coverage[0:15];  // Track different result ranges
    
    // Performance metrics
    time max_execution_time;
    time min_execution_time;
    time avg_execution_time;
    time total_execution_time;
    
    // Timeout parameters
    localparam TIMEOUT_CYCLES = 1000;
    integer timeout_counter;
    
    // Test case information structure
    typedef struct {
        string test_name;
        reg [31:0] instruction;
        reg [31:0] expected_result;
        time execution_time;
        bit passed;
    } test_case_t;
    
    test_case_t test_cases[$];  // Queue to store test results
    
    // Instantiate the top module
    riscv_top dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_result(alu_result),
        .reg_write(reg_write),
        .reg_read(reg_read)
    );

    // Clock generation with configurable frequency
    real clock_period = 10;  // in ns
    initial begin
        clk = 0;
        forever #(clock_period/2) clk = ~clk;
    end

    // Enhanced result checking task
    task automatic check_result;
        input [31:0] expected;
        input string test_name;
        input time start_time;
        begin
            test_case_t current_test;
            time execution_time = $time - start_time;
            
            // Update test statistics
            test_count = test_count + 1;
            
            // Check result
            if (alu_result !== expected) begin
                print_error(test_name, expected, alu_result);
                error_count = error_count + 1;
                current_test.passed = 0;
            end else begin
                $display("[PASS] %s - Result matches expected value 0x%h", test_name, expected);
                current_test.passed = 1;
            end
            
            // Check control signals
            check_control_signals(test_name);
            
            // Update coverage
            update_coverage(instruction, alu_result);
            
            // Update timing statistics
            update_timing_stats(execution_time);
            
            // Store test case information
            current_test.test_name = test_name;
            current_test.instruction = instruction;
            current_test.expected_result = expected;
            current_test.execution_time = execution_time;
            test_cases.push_back(current_test);
        end
    endtask

    // Task to check control signals
    task automatic check_control_signals;
        input string test_name;
        begin
            if (!reg_read) begin
                $display("[WARNING] %s - reg_read not enabled", test_name);
                warning_count = warning_count + 1;
            end
            if (!reg_write) begin
                $display("[WARNING] %s - reg_write not enabled", test_name);
                warning_count = warning_count + 1;
            end
        end
    endtask

    // Task to print detailed error information
    task automatic print_error;
        input string test_name;
        input [31:0] expected;
        input [31:0] actual;
        begin
            $display("\n[ERROR] Test '%s' failed", test_name);
            $display("Expected: 0x%h (%0d)", expected, expected);
            $display("Got:      0x%h (%0d)", actual, actual);
            $display("Difference: 0x%h (%0d)", (expected ^ actual), (expected - actual));
            print_instruction_decode(instruction);
        end
    endtask

    // Task to decode and print instruction information
    task automatic print_instruction_decode;
        input [31:0] instr;
        begin
            $display("Instruction decode:");
            $display("Opcode: 0x%h", instr[6:0]);
            $display("rd: %0d", instr[11:7]);
            $display("rs1: %0d", instr[19:15]);
            $display("rs2: %0d", instr[24:20]);
            $display("funct3: 0x%h", instr[14:12]);
            $display("funct7: 0x%h", instr[31:25]);
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize all counters and storage
        test_count = 0;
        error_count = 0;
        warning_count = 0;
        timeout_counter = 0;
        max_execution_time = 0;
        min_execution_time = 0;
        avg_execution_time = 0;
        total_execution_time = 0;
        test_start_time = $time;

        // Initialize coverage arrays
        for (int i = 0; i < 128; i++) opcode_coverage[i] = 0;
        for (int i = 0; i < 16; i++) result_coverage[i] = 0;

        // Reset sequence
        reset = 1;
        instruction = 32'b0;
        #20;
        reset = 0;
        #20;

        // Test 1: ADD x3, x1, x2 (R-type)
        current_test_start = $time;
        instruction = 32'b00000000001000001000000110110011;
        #20;
        check_result(32'h3, "ADD x3, x1, x2", current_test_start);

        // Test 2: ADDI x3, x1, 5 (I-type)
        current_test_start = $time;
        instruction = 32'b00000000010100001000000110010011;
        #20;
        check_result(32'h6, "ADDI x3, x1, 5", current_test_start);

        // Test 3: SUB x3, x2, x1 (R-type)
        current_test_start = $time;
        instruction = 32'b01000000000100010000000110110011;
        #20;
        check_result(32'h1, "SUB x3, x2, x1", current_test_start);

        // Test 4: XOR x3, x1, x2 (R-type)
        current_test_start = $time;
        instruction = 32'b00000000001000001100000110110011;
        #20;
        check_result(32'h3, "XOR x3, x1, x2", current_test_start);
//////////////////////////////////
// Test 8: ORI x3, x1, 6 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000011000001110000110010011;
        #20;
        check_result(32'h7, "ORI x3, x1, 6", current_test_start);

        // Test 9: AND x3, x1, x2 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001111000110110011;
        #20;
        check_result(32'h0, "AND x3, x1, x2", current_test_start);

        // Test 10: SRL x3, x2, x1 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000000100010101000110110011;
        #20;
        check_result(32'h1, "SRL x3, x2, x1", current_test_start);

        // Test 11: SRA x3, x2, x1 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b01000000000100010101000110110011;
        #20;
        check_result(32'h1, "SRA x3, x2, x1", current_test_start);

        // Test 12: SLLI x3, x1, 2 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001001000110010011;
        #20;
        check_result(32'h4, "SLLI x3, x1, 2", current_test_start);

        // Test 13: SRLI x3, x2, 1 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000000100010101000110010011;
        #20;
        check_result(32'h1, "SRLI x3, x2, 1", current_test_start);

        // Test 14: SRAI x3, x2, 1 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b01000000000100010101000110010011;
        #20;
        check_result(32'h1, "SRAI x3, x2, 1", current_test_start);

        // Test 15: SLT x3, x1, x2 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001010000110110011;
        #20;
        check_result(32'h1, "SLT x3, x1, x2", current_test_start);

        // Test 16: SLTU x3, x1, x2 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001011000110110011;
        #20;
        check_result(32'h1, "SLTU x3, x1, x2", current_test_start);

        // Test 17: SLTIU x3, x1, 2 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001011000110010011;
        #20;
        check_result(32'h1, "SLTIU x3, x1, 2", current_test_start);

        // Test 18: XORI x3, x1, 3 (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001100001100000110010011;
        #20;
        check_result(32'h2, "XORI x3, x1, 3", current_test_start);

        

        

        // Test 21: OR x3, x1, x2 (R-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000001000001110000110110011;
        #20;
        check_result(32'h3, "OR x3, x1, x2", current_test_start);

        

       

        // Test 24: Zero immediate ADD (I-type)
        #20;
        current_test_start <= $time;
        instruction <= 32'b00000000000000001000000110010011;
        #20;
        check_result(32'h1, "ADDI x3, x1, 0", current_test_start);

        

//////////////////////////////////

        // Record end time and generate report
        test_end_time = $time;
        generate_report();
        
        $finish;
    end

    // Task to update coverage information
    task automatic update_coverage;
        input [31:0] instr;
        input [31:0] result;
        begin
            opcode_coverage[instr[6:0]] = opcode_coverage[instr[6:0]] + 1;
            result_coverage[result[31:28]] = result_coverage[result[31:28]] + 1;
        end
    endtask

    // Task to update timing statistics
    task automatic update_timing_stats;
        input time execution_time;
        begin
            if (test_count == 1) begin
                max_execution_time = execution_time;
                min_execution_time = execution_time;
            end else begin
                if (execution_time > max_execution_time) max_execution_time = execution_time;
                if (execution_time < min_execution_time) min_execution_time = execution_time;
            end
            
            total_execution_time = total_execution_time + execution_time;
            avg_execution_time = total_execution_time / test_count;
        end
    endtask

    // Task to generate detailed test report
    task automatic generate_report;
        begin
            success_rate = ((test_count - error_count) * 100.0) / test_count;
            
            $display("\n=== Detailed Test Report ===");
            $display("Test Duration: %0t ns", test_end_time - test_start_time);
            $display("\nTest Statistics:");
            $display("  Total Tests:  %0d", test_count);
            $display("  Passed:       %0d", test_count - error_count);
            $display("  Failed:       %0d", error_count);
            $display("  Warnings:     %0d", warning_count);
            $display("  Success Rate: %0.2f%%", success_rate);
            
            $display("\nTiming Statistics:");
            $display("  Maximum Execution Time: %0t ns", max_execution_time);
            $display("  Minimum Execution Time: %0t ns", min_execution_time);
            $display("  Average Execution Time: %0t ns", avg_execution_time);
            
            print_coverage_report();
            print_detailed_test_results();
        end
    endtask

    // Task to print coverage information
    task automatic print_coverage_report;
        integer i;
        begin
            $display("\nInstruction Coverage:");
            for (i = 0; i < 128; i++) begin
                if (opcode_coverage[i] > 0) begin
                    $display("  Opcode 0x%h: %0d executions", i, opcode_coverage[i]);
                end
            end
            
            $display("\nResult Range Coverage:");
            for (i = 0; i < 16; i++) begin
                if (result_coverage[i] > 0) begin
                    $display("  Range 0x%h_: %0d results", i, result_coverage[i]);
                end
            end
        end
    endtask

    // Task to print detailed test results
    task automatic print_detailed_test_results;
        test_case_t test_case;
        begin
            $display("\nDetailed Test Results:");
            foreach (test_cases[i]) begin
                test_case = test_cases[i];
                $display("\nTest Case: %s", test_case.test_name);
                $display("  Status: %s", test_case.passed ? "PASSED" : "FAILED");
                $display("  Instruction: 0x%h", test_case.instruction);
                $display("  Expected: 0x%h", test_case.expected_result);
                $display("  Execution Time: %0t ns", test_case.execution_time);
            end
        end
    endtask

    // Timeout checker
    always @(posedge clk) begin
        if (!reset) begin
            timeout_counter <= timeout_counter + 1;
            if (timeout_counter >= TIMEOUT_CYCLES) begin
                $display("\n[ERROR] Test timeout after %0d cycles", TIMEOUT_CYCLES);
                generate_report();
                $finish;
            end
        end
    end

    // Waveform generation
    initial begin
        $shm_open("wave.shm");
        $shm_probe("ACTMF");
    end

    // Enhanced signal monitoring
    initial begin
        $monitor("[%0t] instruction=0x%h alu_result=0x%h reg_write=%b reg_read=%b",
                 $time, instruction, alu_result, reg_write, reg_read);
    end

endmodule
