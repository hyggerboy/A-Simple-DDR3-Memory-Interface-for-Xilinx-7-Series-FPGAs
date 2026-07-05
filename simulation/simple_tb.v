`timescale 1ns / 1ps

// Simple testbench for observing the initialization sequence and the first calibration write.

module tb_ubertop_v2;

    reg clk = 1'b0;
    reg rx  = 1'b1;   // UART idle

    wire tx;
    wire WM0_w;
    wire WM1_w;

    wire [0:0] ddr3_dqs_p_0;
    wire [0:0] ddr3_dqs_n_0;
    wire [0:0] ddr3_dqs_p_1;
    wire [0:0] ddr3_dqs_n_1;

    wire DDR_RESET_n;
    wire DDR_CKE;
    wire DDR_CS_n;
    wire DDR_RAS_n;
    wire DDR_CAS_n;
    wire DDR_WE_n;
    wire [2:0]  DDR_BA;
    wire [13:0] DDR_A;
    wire [0:0] ddr_clk_n;
    wire [0:0] ddr_clk_p;
    wire [15:0] DQ_ddr;

    always #5 clk = ~clk; // 100 MHz

    ubertop_v2 dut (
        .clk(clk),

        .ddr3_dqs_p_0(ddr3_dqs_p_0),
        .ddr3_dqs_n_0(ddr3_dqs_n_0),
        .ddr3_dqs_p_1(ddr3_dqs_p_1),
        .ddr3_dqs_n_1(ddr3_dqs_n_1),

        .DDR_RESET_n(DDR_RESET_n),
        .DDR_CKE(DDR_CKE),
        .DDR_CS_n(DDR_CS_n),
        .DDR_RAS_n(DDR_RAS_n),
        .DDR_CAS_n(DDR_CAS_n),
        .DDR_WE_n(DDR_WE_n),
        .DDR_BA(DDR_BA),
        .DDR_A(DDR_A),
        .ddr_clk_n(ddr_clk_n),
        .ddr_clk_p(ddr_clk_p),
        .DQ_ddr(DQ_ddr),

        .tx(tx),
        .rx(rx),
        .WM0_w(WM0_w),
        .WM1_w(WM1_w)
    );

    initial begin
   

    #1000;
    $finish;
   
    end

endmodule