`timescale 1ns/1ns

//thist module combines the phy and the ddr contoller in one module 

module top_ddrcontroller_v3 (
    input  [1:0] operation,
    output [127:0] data_out,

    input  wire clk,
    inout  wire [0:0] ddr3_dqs_p_0,
    inout  wire [0:0] ddr3_dqs_n_0,
    inout  wire [0:0] ddr3_dqs_p_1,
    inout  wire [0:0] ddr3_dqs_n_1,

    output wire DDR_RESET_n,
    output wire DDR_CKE,
    output wire DDR_CS_n,
    output wire DDR_RAS_n,
    output wire DDR_CAS_n,
    output wire DDR_WE_n,
    output wire [2:0]  DDR_BA,
    output wire [13:0] DDR_A,
    output wire [0:0] ddr_clk_n,
    output wire [0:0] ddr_clk_p,

    inout  wire [15:0] DQ_ddr,

    output DDR_busy,
    output wire [127:0] output_data_w,

    input  wire [9:0]  row_adresse,
    input  wire [13:0] col_adresse,
    input  wire [2:0]  bank_adresse,
    input  wire [127:0] data_to_wrtie_in_mem,

    output wire fast_clk,
    output wire [3:0] c_state,
    input  wire [4:0] cnt_dely_w,
    input  wire cal_active,
    output wire clk_div,
    output wire refresh_w,
    output wire WM0_w,
    output wire WM1_w,
    input wire [15:0] data_masking
    
);

    wire [2:0] CMD;
    wire ddr_reset_i;
    wire CKE_i;
    wire [13:0] A_i;
    wire [2:0] BA_i;

    wire [1:0] DQ_in;
    wire DQS_flag;
    wire READ_IS_NOW;
    wire DQS_in_read_or_write = 1'b0;

    wire clk_90;
    wire clk_div_90;
    wire clk_200;

    wire ddr_reset_o;
    wire ddr_ras_o;
    wire ddr_cas_o;
    wire ddr_we_o;
    wire [13:0] A_o;
    wire [2:0] BA_o;

    clk_wiz_0 clk_gen (
        .clk_90    (clk_90),
        .clk_div   (clk_div),
        .fast_clk  (fast_clk),
        .clk_div_90(clk_div_90),
        .reset     (1'b0),
        .locked    (),
        .clk       (clk),
        .clk_200   (clk_200),
        .ila_clk   (ila_clk)
    );

    ddrcontroller_v4 u_ctrl (
        .fast_clk      (fast_clk),
        .CMD           (CMD),
        .ddr_reset     (ddr_reset_i),
        .CKE           (CKE_i),
        .A             (A_i),
        .BA            (BA_i),
        .operation     (operation),
        .DDR_busy      (DDR_busy),
        .DQ_in         (DQ_in),
        .DQS_flag      (DQS_flag),
        .READ_IS_NOW   (READ_IS_NOW),
        .row_adresse   (row_adresse),
        .col_adresse   (col_adresse),
        .bank_adresse  (bank_adresse),
        .c_state       (c_state),
        .clk_div_90    (clk_div_90),
        .refresh_w(refresh_w)
    );

   phy_v5 u_phy_v5 (
    .CMD(CMD),
    .ddr_reset(ddr_reset_i),
    .A(A_i),
    .BA(BA_i),

    .clk_90(clk_90),
    .clk_div(clk_div),
    .fast_clk(fast_clk),
    .clk_div_90(clk_div_90),

    .ddr3_dqs_p_0(ddr3_dqs_p_0),
    .ddr3_dqs_n_0(ddr3_dqs_n_0),
    .ddr3_dqs_p_1(ddr3_dqs_p_1),
    .ddr3_dqs_n_1(ddr3_dqs_n_1),
    .DQ_ddr(DQ_ddr),

    .ddr_reset_o(ddr_reset_o),
    .ddr_cas_o(ddr_cas_o),
    .ddr_we_o(ddr_we_o),
    .ddr_ras_o(ddr_ras_o),
    .A_o(A_o),
    .BA_o(BA_o),

    .ddr_clk_n(ddr_clk_n),
    .ddr_clk_p(ddr_clk_p),

    

    .DQS_flag(DQS_flag),
    .READ_IS_NOW(READ_IS_NOW),
    .output_data_w(output_data_w),
    .clk_200(clk_200),
    .data_to_wrtie_in_mem(data_to_wrtie_in_mem),
    .cnt_dely_w(cnt_dely_w),
    .cal_active(cal_active),
    .WM0_w(WM0_w),
    .WM1_w(WM1_w),
    .data_masking(data_masking)
);

    assign DDR_RESET_n = ddr_reset_o;
    assign DDR_RAS_n = ddr_ras_o;
    assign DDR_CAS_n = ddr_cas_o;
    assign DDR_WE_n = ddr_we_o;
    assign DDR_A = A_o;
    assign DDR_BA = BA_o;
    assign DDR_CKE = CKE_i;
    assign DDR_CS_n = 1'b0;

    assign data_out = output_data_w;

endmodule