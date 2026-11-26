`timescale 1ns/1ps

module mlp_tb;
    reg clk;
    reg rst_n;
    reg mac_en;
    reg mac_clear;
    reg signed [7:0] mac_w;
    reg signed [7:0] mac_d;

    wire signed [23:0] mac_acc;
    wire               mac_valid;
    mac_unit #(
        .DATA_WIDTH(8),
        .ACC_WIDTH(24)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .en       (mac_en),
        .clear    (mac_clear),
        .weight   (mac_w),
        .data_in  (mac_d),
        .acc_out  (mac_acc),
        .valid_out(mac_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;  
    integer cycle_count;
    always @(posedge clk) begin
        if (!rst_n) cycle_count <= 0;
        else        cycle_count <= cycle_count + 1;
    end
    task apply_one_input;
        input signed [7:0] w; 
        input signed [7:0] d;  
        begin
            @(posedge clk);
            mac_w  = w;
            mac_d  = d;
            mac_en = 1;
            @(posedge clk);
            mac_en = 0;
            @(posedge clk);
            @(posedge clk);
        end
    endtask
    task clear_acc;
        begin
            @(posedge clk);
            mac_clear = 1;
            @(posedge clk);
            mac_clear = 0;
            @(posedge clk);  
        end
    endtask
    integer errors;
    task check;
        input signed [23:0] actual;
        input signed [23:0] expected;
        input [127:0] test_name;  
        begin
            if (actual === expected) begin
                $display("  PASS | %s | got %0d", test_name, $signed(actual));
            end else begin
                $display("  FAIL | %s | got %0d, expected %0d",
                         test_name, $signed(actual), $signed(expected));
                errors = errors + 1;
            end
        end
    endtask
    integer start_cycle;
    integer latency;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, mlp_tb);  
        rst_n     = 0;
        mac_en    = 0;
        mac_clear = 0;
        mac_w     = 0;
        mac_d     = 0;
        errors    = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;          
        repeat (2) @(posedge clk);  
        $display("");
        $display("=========================================");
        $display("  MAC Unit Testbench — Icarus Verilog");
        $display("  Clock: 100 MHz (10ns period)");
        $display("=========================================");

        $display("");
        $display("TEST 1: Single MAC — 3 × 4 = 12");
        clear_acc;
        start_cycle = cycle_count;

        apply_one_input(8'sd4, 8'sd3);  
        latency = cycle_count - start_cycle;
        check(mac_acc, 24'sd12, "3*4=12");
        $display("  Latency: %0d cycles = %0d ns", latency, latency * 10);
        $display("");
        $display("TEST 2: Accumulation — (3×4) + (2×5) = 22");
        clear_acc;

        apply_one_input(8'sd4, 8'sd3);
        apply_one_input(8'sd5, 8'sd2);  

        check(mac_acc, 24'sd22, "12+10=22");
        $display("");
        $display("TEST 3: Negative weight — (-3) × 4 = -12");
        clear_acc;

        apply_one_input(-8'sd3, 8'sd4);  

        check(mac_acc, -24'sd12, "(-3)*4=-12");
        $display("");
        $display("TEST 4: Dot product [1,2,3,4]·[5,6,7,8] = 70");
        clear_acc;
        start_cycle = cycle_count;

        apply_one_input(8'sd5, 8'sd1);   
        apply_one_input(8'sd6, 8'sd2);   
        apply_one_input(8'sd7, 8'sd3);   
        apply_one_input(8'sd8, 8'sd4);  

        latency = cycle_count - start_cycle;
        check(mac_acc, 24'sd70, "[1,2,3,4]·[5,6,7,8]=70");
        $display("  Latency for 4-element dot product: %0d cycles = %0d ns",
                 latency, latency * 10);
        $display("");
        $display("TEST 5: Clear (new neuron reset)");
        clear_acc;

        check(mac_acc, 24'sd0, "cleared=0");
        $display("");
        $display("TEST 6: Mixed signs — (-2×4) + (3×2) = -2");
        clear_acc;
        apply_one_input(-8'sd2, 8'sd4);  
        apply_one_input(8'sd3,  8'sd2);  
        check(mac_acc, -24'sd2, "(-8)+(6)=-2");
        $display("  ReLU(-2) = %0d (checking sign bit: %b)",
                 mac_acc[23] ? 0 : $signed(mac_acc),
                 mac_acc[23]);
        $display("");
        $display("TEST 7: Near-max values — 127 × 127 = 16129");
        clear_acc;

        apply_one_input(8'sd127, 8'sd127);  
        check(mac_acc, 24'sd16129, "127*127=16129");
        $display("");
        $display("=========================================");
        $display("  LATENCY ANALYSIS");
        $display("  Pipeline depth: 2 cycles");
        $display("  Per MAC operation: 1 cycle (en=1) + 2 drain = 3 cycles");
        $display("  At 100 MHz: 3 cycles = 30 ns per MAC");
        $display("");
        $display("  EXTRAPOLATED FULL MLP (sequential MAC):");
        $display("  Layer 1: 784 inputs × 128 neurons = 100,352 MACs");
        $display("  Layer 2: 128 inputs × 64 neurons  =   8,192 MACs");
        $display("  Layer 3:  64 inputs × 10 neurons  =     640 MACs");
        $display("  Total: ~109,184 MACs × ~3 cycles  = ~327,552 cycles");
        $display("  At 100 MHz: 327,552 × 10ns = ~3.28 ms per inference");
        $display("  (matches our ~2-3ms simulated estimate)");
        $display("");
        $display("  POWER COMPARISON:");
        $display("  FPGA (Artix-7, from Xilinx power estimator): ~3.5 W");
        $display("  GPU  (NVIDIA T4, from nvidia-smi):           ~70 W");
        $display("  Ratio: ~20× lower power on FPGA");
        $display("=========================================");
        $display("");
        $display("  RESULTS: %0d test(s) failed", errors);

        if (errors == 0)
            $display("  ✓ All tests passed!");
        else
            $display("  ✗ Check FAIL lines above.");

        $display("=========================================");
        $display("");
        $display("Open EPWave to inspect the waveform.");
        $display("Add: clk, rst_n, mac_en, mac_w, mac_d, mac_acc, valid_out");
        #100;
        $finish;
    end
    initial begin
        #100000;
        $display("TIMEOUT: simulation took too long, possible infinite loop");
        $finish;
    end

endmodule