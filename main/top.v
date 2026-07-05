`timescale 1ns / 1ps

module ubertop_v2(
    input clk,

    // i/o to ddr 
    inout wire [0:0] ddr3_dqs_p_0,
    inout wire [0:0] ddr3_dqs_n_0,
    inout wire [0:0] ddr3_dqs_p_1,
    inout wire [0:0] ddr3_dqs_n_1,
    
    output wire DDR_RESET_n,
    output wire DDR_CKE,
    output wire DDR_CS_n,
    output wire DDR_RAS_n,
    output wire DDR_CAS_n,
    output wire DDR_WE_n,
    output wire [2:0] DDR_BA,
    output wire [13:0] DDR_A,
    output wire [0:0] ddr_clk_n,
    output wire [0:0] ddr_clk_p,
    inout wire [15:0] DQ_ddr,
    output wire WM0_w,
    output wire WM1_w,

    //I/o for uart 
    output wire tx,
    input wire rx,

    input wire bnt
    

);



    
wire fast_clk;
wire memory_bussy;
wire write_to_mem;
wire read_from_mem;
wire [127:0] mem_data;
wire [127:0] data_to_mem;

//(* DONT_TOUCH = "TRUE" *)     
operation_controller op(
    .clk(clk),
    // i/o to ddr 
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
    .memory_bussy(memory_bussy),
    .write_to_mem(write_to_mem),
    .read_from_mem(read_from_mem),
    .fast_clk(fast_clk),
    .data_to_write(data_to_mem),
    .data_to_read(mem_data),
    .adress(adresse_r),
    .WM0_w(WM0_w),
    .WM1_w(WM1_w),
    .data_masking_byte(mask)
);

wire [2:0] state_w;
wire [31:0] adresse_r;

//uart_test_v2 uarttest(
//    .clk(fast_clk),
//    .tx(tx),
//    .rx(rx),
//    .bnt(bnt),
//    .bnt1(bnt1),
//    .mem_data(mem_data),
//    .data_to_mem(data_to_mem),
//    .read_from_mem(read_from_mem),
//    .write_to_mem(write_to_mem),
//    .ddr_bussy(memory_bussy),
//    .state_w(state_w),
//    .adresse_r(adresse_r)
//);

wire [15:0] mask;

fasttest fasttest1(
    .clk(fast_clk),
    .rx(rx),
    .tx(tx),

    .ddr_bussy(memory_bussy),
    .data_from_mem(mem_data),

    .write_to_mem(write_to_mem),
    .read_from_mem(read_from_mem),
    .adresse(adresse_r),
    .data_to_write_to_mem(data_to_mem),
    .bnt(bnt),
    .mask(mask)
);



    
endmodule
