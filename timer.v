`timescale 1ns / 1ps

module downcounter_7seg
#(
    parameter CLK_FREQ_HZ = 50_000_000,  // e.g., 50MHz for real hardware
    parameter MAX_COUNT    = 59          // countdown start
)
(
    input  wire        clk,      // System clock
    input  wire        rst,      // Synchronous reset (active high)
    output wire [6:0]  seg_left, // Tens digit (7-seg)
    output wire [6:0]  seg_right // Ones digit (7-seg)
);

    //----------------------------------------------------------------------
    // 1) Generate a 1-second pulse from clk
    //----------------------------------------------------------------------
    localparam integer TICKS_PER_SEC = CLK_FREQ_HZ - 1; // e.g., 49_999_999 for 50MHz
    reg [31:0] div_counter   = 0;
    reg        one_sec_pulse = 0;

    always @(posedge clk) begin
        if (rst) begin
            div_counter   <= 0;
            one_sec_pulse <= 0;
        end else begin
            if (div_counter == TICKS_PER_SEC) begin
                div_counter   <= 0;
                one_sec_pulse <= 1;
            end else begin
                div_counter   <= div_counter + 1;
                one_sec_pulse <= 0;
            end
        end
    end

    //----------------------------------------------------------------------
    // 2) Downcounter logic: from MAX_COUNT down to 0
    //----------------------------------------------------------------------
    reg [7:0] current_count;  // up to 99 if needed

    always @(posedge clk) begin
        if (rst) begin
            current_count <= MAX_COUNT;
        end else if (one_sec_pulse) begin
            if (current_count > 0)
                current_count <= current_count - 1;
            else
                current_count <= 0;  
                // or wrap to MAX_COUNT if desired
        end
    end

    //----------------------------------------------------------------------
    // 3) Split current_count into tens and ones
    //----------------------------------------------------------------------
    wire [3:0] tens_digit  = current_count / 10;
    wire [3:0] ones_digit  = current_count % 10;

    //----------------------------------------------------------------------
    // 4) 7-seg decoder (common-anode)
    //----------------------------------------------------------------------
    function [6:0] seven_seg_decode;
        input [3:0] bin;
        begin
            case (bin)
                4'd0 : seven_seg_decode = 7'b1000000; // 0
                4'd1 : seven_seg_decode = 7'b1111001; // 1
                4'd2 : seven_seg_decode = 7'b0100100; // 2
                4'd3 : seven_seg_decode = 7'b0110000; // 3
                4'd4 : seven_seg_decode = 7'b0011001; // 4
                4'd5 : seven_seg_decode = 7'b0010010; // 5
                4'd6 : seven_seg_decode = 7'b0000010; // 6
                4'd7 : seven_seg_decode = 7'b1111000; // 7
                4'd8 : seven_seg_decode = 7'b0000000; // 8
                4'd9 : seven_seg_decode = 7'b0010000; // 9
                default: seven_seg_decode = 7'b1111111; // blank
            endcase
        end
    endfunction

    assign seg_left  = seven_seg_decode(tens_digit);
    assign seg_right = seven_seg_decode(ones_digit);

endmodule
