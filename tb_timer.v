`timescale 1ns/1ps

module downcounter_7seg_tb;

    // ---------------------------
    // Testbench clock parameters
    // ---------------------------
    // We'll pretend the clock is only 100 Hz so that TICKS_PER_SEC = 99
    // That way, every 100 cycles (1 second in DUT-time) occurs quickly in simulation.
    localparam TB_CLK_FREQ_HZ = 100;
    localparam TB_MAX_COUNT    = 59;
    parameter TB_TICKS_PER_SEC = 99;  // =99999 for 100 kHz
    // The design's TICKS_PER_SEC = TB_CLK_FREQ_HZ - 1 = 99
    // So the DUT "one_sec_pulse" will happen every 100 cycles in simulation.

    // ---------------------------
    // DUT signals
    // ---------------------------
    reg         clk;
    reg         rst;
    wire [6:0]  seg_left;
    wire [6:0]  seg_right;

    // Instantiate the DUT with the testbench clock freq
    downcounter_7seg #(
        .CLK_FREQ_HZ(TB_CLK_FREQ_HZ),
        .MAX_COUNT(TB_MAX_COUNT)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .seg_left  (seg_left),
        .seg_right (seg_right)
    );

    // ---------------------------
    // Clock generation
    // ---------------------------
    // 100 Hz => period = 10,000,000 ns (10 ms).
    // But for demonstration, let's do a smaller period so the test runs quickly.
    // We'll do 100 kHz instead of 100 Hz to speed up the sim (param name remains the same).
    // Then TICKS_PER_SEC = 999 in the DUT. We'll see "1-second" pulses quickly.

    localparam CLK_PERIOD = 10000; // 10 us => 100 kHz
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---------------------------
    // Reading expected patterns
    // ---------------------------
    // We'll store the 60 lines of patterns for "59 down to 0".
    integer file, status;
    reg [6:0] tens_exp [0:59];
    reg [6:0] ones_exp [0:59];
    integer i;

    initial begin
        file = $fopen("expected_vals.txt", "r");
        if (file == 0) begin
            $display("ERROR: Cannot open expected_vals.txt");
            $finish;
        end

        // Read all 60 lines into arrays
        for (i = 0; i < 60; i = i + 1) begin
            status = $fscanf(file, "%b %b\n", tens_exp[i], ones_exp[i]);
            if (status != 2) begin
                $display("ERROR: File read issue on line %0d", i+1);
                $finish;
            end
        end
        $fclose(file);
    end

    // ---------------------------
    // Test sequence
    // ---------------------------
    integer errors = 0;

    initial begin

        $dumpfile("tb_timer.vcd");
        $dumpvars(0, downcounter_7seg_tb);
        // Apply reset
        rst = 1;
        # (10 * CLK_PERIOD); // wait some cycles
        rst = 0;
        // Wait a bit for the DUT to load "59"
        # (2 * CLK_PERIOD);

        // Our DUT will show "59" immediately after reset goes low.
        // Then after each "1-second" pulse (which in sim is TICKS_PER_SEC cycles),
        // it decrements from 59..0.

        //   We check the current digit,
        //   then do "repeat(TICKS_PER_SEC) @(posedge clk)" to wait 1 second in DUT time.
        //   This is a purely linear approach, but you must ensure it aligns with the
        //   internal one_sec_pulse. We'll add 1 or 2 extra cycles to be safe.

        // Because we used 100 kHz for the clock, 1 second = 100k cycles => TICKS_PER_SEC=99999.
        // Let's define a localparam for that: TB_TICKS_PER_SEC = 99999. It has to be defined in the beginning of the module. 

        for (i = 0; i < 60; i = i + 1) begin
            // Compare the current output
            if (seg_left !== tens_exp[i] || seg_right !== ones_exp[i]) begin
                $display("ERROR @ time %0t sec=%0d: seg_left=%b, seg_right=%b | expected=%b %b",
                          $time, (59 - i), seg_left, seg_right, tens_exp[i], ones_exp[i]);
                errors = errors + 1;
            end

            // Wait one "DUT second" before checking the next value
            // We do TICKS_PER_SEC + a few extra cycles
            repeat (TB_TICKS_PER_SEC + 2) @(posedge clk);
        end

        // At this point, the counter should be at 0. If it continued, it’d stay at 0.

        // Report results
        if (errors == 0)
            $display("TEST PASSED! No mismatches found.");
        else
            $display("TEST FAILED with %0d errors.", errors);

        $finish;
    end

    // Monitor changes for debugging
    initial begin
        $monitor("t=%0t | rst=%b => seg_left=%b seg_right=%b",
                 $time, rst, seg_left, seg_right);
    end


endmodule
