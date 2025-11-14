`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Smart Traffic Light Controller (Basys3)
// --------------------------------------
// Author: Prakhar
// Version: Exclusive-Mode + Display Edition (Stable Release)
// Description:
//   • Default = FSM traffic sequence (shows seconds left)
//   • BTNU = Night mode (all yellow blink)
//   • BTNL = M1 + MT green override
//   • BTNR = M2 green override
//   • BTND = S green override
//   • Pressing one mode cancels any other
//   • Press same button again → return to normal FSM
//   • 7-segment display shows countdown seconds only in FSM mode
//////////////////////////////////////////////////////////////////////////////////

module Traffic_Light_Controller(
    input clk, rst,
    input btnU, btnL, btnR, btnD,
    output reg [2:0] light_M1,
    output reg [2:0] light_S,
    output reg [2:0] light_MT,
    output reg [2:0] light_M2,
    output wire [6:0] seg,
    output wire [3:0] an,
    output wire dp
);

    //----------------------------------------
    // Parameters & States
    //----------------------------------------
    parameter  S1=0, S2=1, S3=2, S4=3, S5=4, S6=5;
    reg [2:0] ps;
    reg [3:0] count;
    parameter sec7=7, sec5=5, sec2=2, sec3=3;

    //----------------------------------------
    // Clock Divider (for FSM & Blink)
    //----------------------------------------
    reg [27:0] div;
    always @(posedge clk or posedge rst)
        if (rst)
            div <= 0;
        else
            div <= div + 1;

    // ~0.7s tick for FSM, ~1Hz for blink
    wire slow_clk  = div[25];   // FSM step clock
    wire blink_clk = div[23];   // Night blink clock

    //----------------------------------------
    // Button Synchronization & Mode Control
    //----------------------------------------
    reg [1:0] syncU, syncL, syncR, syncD;
    reg [2:0] active_mode;  // 0=normal, 1=night, 2=M1, 3=M2, 4=S

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {syncU, syncL, syncR, syncD} <= 8'b0;
            active_mode <= 3'd0;
        end else begin
            // Synchronize button inputs
            syncU <= {syncU[0], btnU};
            syncL <= {syncL[0], btnL};
            syncR <= {syncR[0], btnR};
            syncD <= {syncD[0], btnD};

            // Rising edge detection & exclusive mode toggle
            if (syncU == 2'b01)
                active_mode <= (active_mode==3'd1) ? 3'd0 : 3'd1;
            else if (syncL == 2'b01)
                active_mode <= (active_mode==3'd2) ? 3'd0 : 3'd2;
            else if (syncR == 2'b01)
                active_mode <= (active_mode==3'd3) ? 3'd0 : 3'd3;
            else if (syncD == 2'b01)
                active_mode <= (active_mode==3'd4) ? 3'd0 : 3'd4;
        end
    end

    //----------------------------------------
    // FSM - runs only in Normal Mode
    //----------------------------------------
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            ps <= S1;
            count <= 0;
        end
        else if (active_mode == 3'd0) begin
            case(ps)
                S1: if (count < sec7) count <= count + 1; else begin ps <= S2; count <= 0; end
                S2: if (count < sec2) count <= count + 1; else begin ps <= S3; count <= 0; end
                S3: if (count < sec5) count <= count + 1; else begin ps <= S4; count <= 0; end
                S4: if (count < sec2) count <= count + 1; else begin ps <= S5; count <= 0; end
                S5: if (count < sec3) count <= count + 1; else begin ps <= S6; count <= 0; end
                S6: if (count < sec2) count <= count + 1; else begin ps <= S1; count <= 0; end
                default: ps <= S1;
            endcase
        end
    end

    //----------------------------------------
    // Output Logic (priority-based)
    //----------------------------------------
    always @(*) begin
        // Default OFF to avoid latch conflicts
        light_M1 = 3'b000;
        light_M2 = 3'b000;
        light_MT = 3'b000;
        light_S  = 3'b000;

        case(active_mode)
            //  NIGHT MODE: all yellow blink
            3'd1: begin
                if (blink_clk) begin
                    light_M1 = 3'b010;
                    light_M2 = 3'b010;
                    light_MT = 3'b010;
                    light_S  = 3'b010;
                end
            end

            //  M1 MODE (M1 + MT green)
            3'd2: begin
                light_M1 = 3'b001; light_MT = 3'b001;
                light_M2 = 3'b100; light_S  = 3'b100;
            end

            //  M2 MODE (M2 green)
            3'd3: begin
                light_M1 = 3'b100; light_MT = 3'b100;
                light_M2 = 3'b001; light_S  = 3'b100;
            end

            //  S MODE (Side Road green)
            3'd4: begin
                light_M1 = 3'b100; light_MT = 3'b100;
                light_M2 = 3'b100; light_S  = 3'b001;
            end

            //  NORMAL FSM OPERATION
            default: begin
                case(ps)
                    S1: begin light_M1=3'b001; light_M2=3'b001; light_MT=3'b100; light_S=3'b100; end
                    S2: begin light_M1=3'b001; light_M2=3'b010; light_MT=3'b100; light_S=3'b100; end
                    S3: begin light_M1=3'b001; light_M2=3'b100; light_MT=3'b001; light_S=3'b100; end
                    S4: begin light_M1=3'b010; light_M2=3'b100; light_MT=3'b010; light_S=3'b100; end
                    S5: begin light_M1=3'b100; light_M2=3'b100; light_MT=3'b100; light_S=3'b001; end
                    S6: begin light_M1=3'b100; light_M2=3'b100; light_MT=3'b100; light_S=3'b010; end
                    default: begin light_M1=3'b000; light_M2=3'b000; light_MT=3'b000; light_S=3'b000; end
                endcase
            end
        endcase
    end

    //----------------------------------------
    // Remaining Seconds for 7-Segment
    //----------------------------------------
    reg [3:0] remain;
    always @(*) begin
        case(ps)
            S1: remain = (sec7>count)?(sec7-count):0;
            S2: remain = (sec2>count)?(sec2-count):0;
            S3: remain = (sec5>count)?(sec5-count):0;
            S4: remain = (sec2>count)?(sec2-count):0;
            S5: remain = (sec3>count)?(sec3-count):0;
            S6: remain = (sec2>count)?(sec2-count):0;
            default: remain = 0;
        endcase
        if (remain>9) remain=9;
        if (active_mode!=3'd0) remain=0; // blank when in special modes
    end

    //----------------------------------------
    // 7-Segment Display Driver
    //----------------------------------------
    SevenSegDriver display(
        .clk(clk),
        .rst(rst),
        .d3(4'hF), .d2(4'hF), .d1(4'hF), .d0(remain),
        .seg(seg), .an(an), .dp(dp)
    );
endmodule

// ============================================================================
// 7-Segment Display Driver (Common Anode, Active-Low)
// ============================================================================
module SevenSegDriver(
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] d3, d2, d1, d0,
    output reg  [6:0] seg,
    output reg  [3:0] an,
    output wire       dp
);
    localparam DIV = 100_000; // refresh ~1 kHz
    reg [16:0] cnt;
    always @(posedge clk)
        if (rst) cnt <= 0;
        else if (cnt==DIV-1) cnt<=0;
        else cnt<=cnt+1;
    wire tick=(cnt==DIV-1);

    reg [1:0] sel;
    always @(posedge clk)
        if (rst) sel<=0;
        else if (tick) sel<=sel+1;

    reg [3:0] val;
    always @(*) begin
        case(sel)
            2'd0: begin an=4'b1110; val=d0; end
            2'd1: begin an=4'b1101; val=d1; end
            2'd2: begin an=4'b1011; val=d2; end
            2'd3: begin an=4'b0111; val=d3; end
        endcase
    end

    always @(*) begin
        case(val)
            4'h0: seg=7'b1000000;
            4'h1: seg=7'b1111001;
            4'h2: seg=7'b0100100;
            4'h3: seg=7'b0110000;
            4'h4: seg=7'b0011001;
            4'h5: seg=7'b0010010;
            4'h6: seg=7'b0000010;
            4'h7: seg=7'b1111000;
            4'h8: seg=7'b0000000;
            4'h9: seg=7'b0010000;
            default: seg=7'b1111111;
        endcase
    end

    assign dp = 1'b1; // decimal point OFF
endmodule
