`timescale 1ns/1ns

//tb for init test

module tb;

    reg fast_clk;
    reg clk_div_90;

    reg [1:0] operation;
    reg [1:0] DQ_in;
    reg [9:0] row_adresse;
    reg [14:0] col_adresse;
    reg [2:0] bank_adresse;

    wire DDR_busy;
    wire [2:0] CMD;
    wire ddr_reset;
    wire CKE;
    wire [14:0] A;
    wire [2:0] BA;
    wire DQS_flag;
    wire READ_IS_NOW;
    wire [3:0] c_state;
    wire fail;
    wire refresh_w;

    wire cs;
    wire RAS;
    wire CAS;
    wire WE;
    wire ODT;
    wire ddrclk;

    assign cs = 1'b0;
    assign ODT = 1'b0;

    //mimic the phy deley
    assign {RAS, CAS, WE} = delyCMD;
    reg [2:0] delyCMD;
    reg [2:0] delyBA; 
    always@(posedge fast_clk) begin
        delyCMD <= CMD;
        delyBA <= BA;
    end


    assign ddrclk = fast_clk;

    // 100 MHz fast clock
    initial begin
        fast_clk = 1'b0;
        forever #5 fast_clk = ~fast_clk;
    end

    // 50 MHz phase-shifted clock
    initial begin
        clk_div_90 = 1'b0;
        #5;
        forever #10 clk_div_90 = ~clk_div_90;
    end

    initial begin
        operation    = 2'b00;
        DQ_in        = 2'b00;
        row_adresse  = 10'd0;
        col_adresse  = 15'd0;
        bank_adresse = 3'd0;

    

        #10000000;
        $finish;
    end

    // New DDR controller
    ddrcontroller_v4 dut (
        .fast_clk      (fast_clk),
        .operation     (operation),
        .DQ_in         (DQ_in),
        .row_adresse   (row_adresse),
        .col_adresse   (col_adresse),
        .bank_adresse  (bank_adresse),
        .DDR_busy      (DDR_busy),

        .CMD           (CMD),
        .ddr_reset     (ddr_reset),
        .CKE           (CKE),
        .A             (A),
        .BA            (BA),
        .DQS_flag      (DQS_flag),
        .READ_IS_NOW   (READ_IS_NOW),
        .c_state       (c_state),
        .clk_div_90    (clk_div_90),
        .fail          (fail),
        .refresh_w     (refresh_w)
    );

    // Existing DDR setup checker
    mem_setup_tb setup_tb_test (
        .clk   (ddrclk),
        .nclk  (~ddrclk),

        .CKE   (CKE),
        .cs    (cs),
        .RAS   (RAS),
        .CAS   (CAS),
        .WE    (WE),
        .BA    (delyBA),
        .A     (A),
        .RESET (ddr_reset)
  
    );

endmodule