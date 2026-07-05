module phy_v5(


    input  [2:0] CMD,  
    input  ddr_reset,
    input  CKE,                
    input  [13:0] A,
    input  [2:0] BA,
    
    input wire clk_90,
    input wire clk_div,
    input wire fast_clk,
    input clk_div_90,
 
   //dqs 

    inout wire [0:0] ddr3_dqs_p_0,
    inout wire [0:0] ddr3_dqs_n_0,
    inout wire [0:0] ddr3_dqs_p_1,
    inout wire [0:0] ddr3_dqs_n_1,
    
    inout wire [15:0] DQ_ddr,

    //syct outputs

    output reg ddr_reset_o,
    output reg ddr_cas_o = 1'b1,
    output reg ddr_we_o = 1'b1,
    output reg ddr_ras_o = 1'b1,
    output wire [13:0] A_o,
    output reg [2:0] BA_o,
    
    output wire ddr_clk_n,
    output wire ddr_clk_p,

    
    
    
    input wire DQS_flag,
    
    input wire READ_IS_NOW,
    output wire [127:0] output_data_w,
    input wire clk_200,
    
    input wire [127:0] data_to_wrtie_in_mem,
    input wire [4:0] cnt_dely_w,
    input wire cal_active,
    output wire WM0_w,
    output wire WM1_w,
    input wire [15:0] data_masking
    
);


wire [63:0] data_in;




wire [15:0] DQ_internal_out;
wire [15:0] DQ_internal_in;



reg [3:0] tristate_contoller_DQS;
reg [3:0] tristate_contoller_DQ;

wire data_strope_0;
wire data_strope_1;



wire TQ_DQS_0;
wire TQ_DQS_1;
wire [15:0] TQ_DQ;

assign A_o = A;


always @(posedge fast_clk) begin
    ddr_reset_o <= ddr_reset;
    ddr_cas_o <= CMD[1];
    ddr_we_o <= CMD[0];
    ddr_ras_o <= CMD[2];
    
    BA_o <= BA;
end

genvar i;

 
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_dq_iobuf

        IOBUF #(
            .IOSTANDARD("SSTL135"),
            .SLEW("FAST")
        ) IOBUF_inst_DQ (
            .O (DQ_internal_out[i]),
            .IO(DQ_ddr[i]),
            .I (DQ_internal_in[i]),
            .T (TQ_DQ[i])
        );
    end
endgenerate



wire ddr3_dqs_r_1;
wire ddr3_dqs_r_0;

//creats the diff output
OBUFDS #(
   .IOSTANDARD("SSTL135") // Specify the output I/O standard
) OBUFDS_inst (
   .O(ddr_clk_p),     // Diff_p output (connect directly to top-level port)
   .OB(ddr_clk_n),   // Diff_n output (connect directly to top-level port)
   .I(fast_clk)      // Buffer input
);




// IOBUFDS: Differential Bi-directional Buffer
//          7 Series
// Xilinx HDL Language Template, version 2025.2

IOBUFDS #(

   .IOSTANDARD("DIFF_SSTL135") // Specify the I/O standard
  
) IOBUFDS_inst0 (
   .O(ddr3_dqs_r_0),     // Buffer output
   .IO(ddr3_dqs_p_0),   // Diff_p inout (connect directly to top-level port)
   .IOB(ddr3_dqs_n_0), // Diff_n inout (connect directly to top-level port)
   .I(data_strope_0),     // Buffer input
   .T(TQ_DQS_0)      // 3-state enable input, high=input, low=output
);

IOBUFDS #(

   .IOSTANDARD("DIFF_SSTL135") // Specify the I/O standard
  
) IOBUFDS_inst1 (
   .O(ddr3_dqs_r_1),     // Buffer output
   .IO(ddr3_dqs_p_1),   // Diff_p inout (connect directly to top-level port)
   .IOB(ddr3_dqs_n_1), // Diff_n inout (connect directly to top-level port)
   .I(data_strope_1),     // Buffer input
   .T(TQ_DQS_1)      // 3-state enable input, high=input, low=output
);






wire reset_for_Oser_DQS;
wire reset_for_Oser_DQ;


reg [5:0] cnt_DQ = 0; 


assign reset_for_Oser_DQS = ~ddr_reset;



assign reset_for_Oser_DQ = ~ddr_reset;


localparam ideal = 3'b000, start = 3'b001, start2 = 3'b010, start3 = 2'b011, start4 = 2'b100;


reg [2:0] state = ideal , next_state; 

always @* begin
    next_state = state;

    case (state)
        ideal: begin
             if (DQS_flag) begin 
                next_state = start;
             end else begin 
                next_state = ideal;
             end
        end
        start: begin
            next_state = start2;
        end
        start2: begin
            next_state = start3;
        end
        start3: begin
            next_state = start4;
        end
        start4: begin
            next_state = ideal;
        end
  
        default: begin
            next_state = ideal;
        end
    endcase
end

always @(posedge clk_div) begin
    case (state)
        ideal: begin
            tristate_contoller_DQS <= 4'hF;
  
        end

        start: begin
            tristate_contoller_DQS <= 4'h7;
        end

        start2: begin
            tristate_contoller_DQS <= 4'h0;
        end
        
        start3: begin
            tristate_contoller_DQS <= 4'h0;
        end
        
        start4: begin
            tristate_contoller_DQS <= 4'he;
        end

        default: begin
            tristate_contoller_DQS <= 4'hF;
        end
    endcase
end

localparam ideal_DQ = 2'b00, start_DQ = 2'b01,start_DQ_2 = 2'b10;

reg [1:0] state_DQ, next_state_DQ; 

always @* begin

next_state_DQ = state_DQ;


 
    case(state_DQ)
        ideal_DQ: begin
            if (DQ_flag) begin
                next_state_DQ = start_DQ;
            end else begin    
                next_state_DQ = ideal_DQ;
           end
        end 
        start_DQ: begin

            next_state_DQ = start_DQ_2;
        end
        start_DQ_2: begin
            next_state_DQ = ideal_DQ;
        end
             
       default : next_state_DQ = ideal_DQ;
    endcase
end

always@(posedge fast_clk) begin 
    DQ_flag_0 <= DQS_flag; 
end

reg DQ_flag_0;
reg DQ_flag;  

reg [7:0] data_mask;

reg [7:0] data_mask_pip;


always @(posedge clk_div_90) begin
    DQ_flag <= DQ_flag_0;

    case (next_state_DQ)
        ideal_DQ: begin
            tristate_contoller_DQ <= 4'hF;
        end

        start_DQ: begin
            data_mask_pip <= data_masking[15:8];


            data_pip[15] <= data_to_wrtie_in_mem[127:124];
            data_pip[14] <= data_to_wrtie_in_mem[119:116];
            data_pip[13] <= data_to_wrtie_in_mem[111:108];
            data_pip[12] <= data_to_wrtie_in_mem[103:100];

            data_pip[11] <= data_to_wrtie_in_mem[95:92];
            data_pip[10] <= data_to_wrtie_in_mem[87:84];
            data_pip[9]  <= data_to_wrtie_in_mem[79:76];
            data_pip[8]  <= data_to_wrtie_in_mem[71:68];

            data_pip[7]  <= data_to_wrtie_in_mem[63:60];
            data_pip[6]  <= data_to_wrtie_in_mem[55:52];
            data_pip[5]  <= data_to_wrtie_in_mem[47:44];
            data_pip[4]  <= data_to_wrtie_in_mem[39:36];

            data_pip[3]  <= data_to_wrtie_in_mem[31:28];
            data_pip[2]  <= data_to_wrtie_in_mem[23:20];
            data_pip[1]  <= data_to_wrtie_in_mem[15:12];
            data_pip[0]  <= data_to_wrtie_in_mem[7:4];

            tristate_contoller_DQ <= 4'h0;
        end

        start_DQ_2: begin
            data_mask_pip <= data_masking[7:0];
         

            data_pip[15] <= data_to_wrtie_in_mem[123:120];
            data_pip[14] <= data_to_wrtie_in_mem[115:112];
            data_pip[13] <= data_to_wrtie_in_mem[107:104];
            data_pip[12] <= data_to_wrtie_in_mem[99:96];

            data_pip[11] <= data_to_wrtie_in_mem[91:88];
            data_pip[10] <= data_to_wrtie_in_mem[83:80];
            data_pip[9]  <= data_to_wrtie_in_mem[75:72];
            data_pip[8]  <= data_to_wrtie_in_mem[67:64];

            data_pip[7]  <= data_to_wrtie_in_mem[59:56];
            data_pip[6]  <= data_to_wrtie_in_mem[51:48];
            data_pip[5]  <= data_to_wrtie_in_mem[43:40];
            data_pip[4]  <= data_to_wrtie_in_mem[35:32];

            data_pip[3]  <= data_to_wrtie_in_mem[27:24];
            data_pip[2]  <= data_to_wrtie_in_mem[19:16];
            data_pip[1]  <= data_to_wrtie_in_mem[11:8];
            data_pip[0]  <= data_to_wrtie_in_mem[3:0];

            tristate_contoller_DQ <= 4'h0;
        end

        default: begin
            tristate_contoller_DQ <= 4'hF;
        end
    endcase
end



reg [3:0] data_pip [15:0];


always@(posedge clk_div_90) begin
        state_DQ <= next_state_DQ;

end



 
OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_RATE_TQ("DDR"),
   .DATA_WIDTH(4),
   .SERDES_MODE("MASTER"),
   .TRISTATE_WIDTH(4)
) OSERDESE2_inst_DQS0 (
   .OFB(),
   .OQ(data_strope_0),
   .TBYTEOUT(),
   .TFB(),
   .TQ(TQ_DQS_0), 
   .CLK(fast_clk),
   .CLKDIV(clk_div),
   .D1(1'b1),
   .D2(1'b0),
   .D3(1'b1),
   .D4(1'b0),
   .D5(),
   .D6(),
   .D7(),
   .D8(),
   

   
   .OCE(1'b1),
   .RST(reset_for_Oser_DQS),
   .SHIFTIN1(),
   .SHIFTIN2(),
   .T1(tristate_contoller_DQS[0]),
   .T2(tristate_contoller_DQS[1]),
   .T3(tristate_contoller_DQS[2]),
   .T4(tristate_contoller_DQS[3]),
   .TBYTEIN(1'b0),
   .TCE(1'b1)
);


OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_RATE_TQ("DDR"),
   .DATA_WIDTH(4),
   .SERDES_MODE("MASTER"),
   .TRISTATE_WIDTH(4)
) OSERDESE2_inst_DQS1 (
   .OFB(),
   .OQ(data_strope_1),
   .TBYTEOUT(),
   .TFB(),
   .TQ(TQ_DQS_1), 
   .CLK(fast_clk),
   .CLKDIV(clk_div),
   .D1(1'b1),
   .D2(1'b0),
   .D3(1'b1),
   .D4(1'b0),
   .D5(),
   .D6(),
   .D7(),
   .D8(),
   

   
   .OCE(1'b1),
   .RST(reset_for_Oser_DQS),
   .SHIFTIN1(),
   .SHIFTIN2(),
   .T1(tristate_contoller_DQS[0]),
   .T2(tristate_contoller_DQS[1]),
   .T3(tristate_contoller_DQS[2]),
   .T4(tristate_contoller_DQS[3]),
   .TBYTEIN(1'b0),
   .TCE(1'b1)
);


//DQ 0 signal 

genvar idq; 

generate
    for (idq = 0; idq < 16; idq = idq + 1) begin : OSERDESE2_inst_DQ

OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_RATE_TQ("DDR"),
   .DATA_WIDTH(4),
   .SERDES_MODE("MASTER"),
   .TRISTATE_WIDTH(4)
) OSERDESE2_inst_DQ0 (
   .OQ(DQ_internal_in[idq]),
   .CLK(clk_90),
   .CLKDIV(clk_div_90),
   
   .TBYTEOUT(),
   .TFB(),
   .TQ(TQ_DQ[idq]),
   
   .D1(data_pip[idq][3]),
   .D2(data_pip[idq][2]),
   .D3(data_pip[idq][1]),
   .D4(data_pip[idq][0]),
   .D5(),
   .D6(),
   .D7(),
   .D8(),
   .OCE(1'b1),
   .RST(reset_for_Oser_DQ),
   .SHIFTIN1(1'b0),
   .SHIFTIN2(1'b0),
   .T1(tristate_contoller_DQ[0]),
   .T2(tristate_contoller_DQ[1]),
   .T3(tristate_contoller_DQ[2]),
   .T4(tristate_contoller_DQ[3]),
   .TBYTEIN(1'b0),
   .TCE(1'b1)
);
end

endgenerate



OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_RATE_TQ("BUF"),
   .DATA_WIDTH(4),
   .SERDES_MODE("MASTER"),
   .TRISTATE_WIDTH(1)
) OSERDESE2_inst_WM0 (
   .OQ(WM0),
   .CLK(clk_90),
   .CLKDIV(clk_div_90),
   
   .TBYTEOUT(),
   .TFB(),
   .TQ(),
   
   .D4(data_mask_pip[0]),
   .D3(data_mask_pip[2]),
   .D2(data_mask_pip[4]),
   .D1(data_mask_pip[6]),
   .D5(),
   .D6(),
   .D7(),
   .D8(),
   .OCE(1'b1),
   .RST(reset_for_Oser_DQ),
   .SHIFTIN1(1'b0),
   .SHIFTIN2(1'b0),
   .T1(1'b0),
   .T2(1'b0),
   .T3(1'b0),
   .T4(1'b0),
   .TBYTEIN(1'b0),
   .TCE(1'b1)
);

wire WM1;

OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),
   .DATA_RATE_TQ("BUF"),
   .DATA_WIDTH(4),
   .SERDES_MODE("MASTER"),
   .TRISTATE_WIDTH(1)
) OSERDESE2_inst_WM1 (
   .OQ(WM1),
   .CLK(clk_90),
   .CLKDIV(clk_div_90),
   
   .TBYTEOUT(),
   .TFB(),
   .TQ(),
   
   .D4(data_mask_pip[1]),
   .D3(data_mask_pip[3]),
   .D2(data_mask_pip[5]),
   .D1(data_mask_pip[7]),
   .D5(),
   .D6(),
   .D7(),
   .D8(),
   .OCE(1'b1),
   .RST(reset_for_Oser_DQ),
   .SHIFTIN1(1'b0),
   .SHIFTIN2(1'b0),
   .T1(1'b0),
   .T2(1'b0),
   .T3(1'b0),
   .T4(1'b0),
   .TBYTEIN(1'b0),
   .TCE(1'b1)
);

assign WM1_w = WM1;

assign WM0_w = WM0; 

wire WM0;








localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;


reg [1:0] next_state_c;
reg [1:0] state_c; 

always@(posedge clk_div) begin
        state_c <= next_state_c;
end

always@(negedge  clk_div) begin
  
        state <= next_state;

end


// 128-bit output
assign output_data_w = {
    output_data_15, output_data_14, output_data_13, output_data_12,
    output_data_11, output_data_10, output_data_9,  output_data_8,
    output_data_7,  output_data_6,  output_data_5,  output_data_4,
    output_data_3,  output_data_2,  output_data_1,  output_data_0
};

reg [7:0] output_data_pip_0;
reg [7:0] output_data_pip_1;
reg [7:0] output_data_pip_2;
reg [7:0] output_data_pip_3;
reg [7:0] output_data_pip_4;
reg [7:0] output_data_pip_5;
reg [7:0] output_data_pip_6;
reg [7:0] output_data_pip_7;
reg [7:0] output_data_pip_8;
reg [7:0] output_data_pip_9;
reg [7:0] output_data_pip_10;
reg [7:0] output_data_pip_11;
reg [7:0] output_data_pip_12;
reg [7:0] output_data_pip_13;
reg [7:0] output_data_pip_14;
reg [7:0] output_data_pip_15;

reg [7:0] output_data_0;
reg [7:0] output_data_1;
reg [7:0] output_data_2;
reg [7:0] output_data_3;
reg [7:0] output_data_4;
reg [7:0] output_data_5;
reg [7:0] output_data_6;
reg [7:0] output_data_7;
reg [7:0] output_data_8;
reg [7:0] output_data_9;
reg [7:0] output_data_10;
reg [7:0] output_data_11;
reg [7:0] output_data_12;
reg [7:0] output_data_13;
reg [7:0] output_data_14;
reg [7:0] output_data_15;




always @(posedge clk_div_90) begin
    case (state_c)
        s1: begin
            output_data_pip_0 [7:4]  <= data_in[3:0];
            output_data_pip_1 [7:4]  <= data_in[7:4];
            output_data_pip_2 [7:4]  <= data_in[11:8];
            output_data_pip_3 [7:4]  <= data_in[15:12];
            output_data_pip_4 [7:4]  <= data_in[19:16];
            output_data_pip_5 [7:4]  <= data_in[23:20];
            output_data_pip_6 [7:4]  <= data_in[27:24];
            output_data_pip_7 [7:4]  <= data_in[31:28];

            output_data_pip_8 [7:4]  <= data_in[35:32];
            output_data_pip_9 [7:4]  <= data_in[39:36];
            output_data_pip_10[7:4]  <= data_in[43:40];
            output_data_pip_11[7:4]  <= data_in[47:44];
            output_data_pip_12[7:4]  <= data_in[51:48];
            output_data_pip_13[7:4]  <= data_in[55:52];
            output_data_pip_14[7:4]  <= data_in[59:56];
            output_data_pip_15[7:4]  <= data_in[63:60];
        end

        s2: begin
            output_data_pip_0 [3:0]  <= data_in[3:0];
            output_data_pip_1 [3:0]  <= data_in[7:4];
            output_data_pip_2 [3:0]  <= data_in[11:8];
            output_data_pip_3 [3:0]  <= data_in[15:12];
            output_data_pip_4 [3:0]  <= data_in[19:16];
            output_data_pip_5 [3:0]  <= data_in[23:20];
            output_data_pip_6 [3:0]  <= data_in[27:24];
            output_data_pip_7 [3:0]  <= data_in[31:28];

            output_data_pip_8 [3:0]  <= data_in[35:32];
            output_data_pip_9 [3:0]  <= data_in[39:36];
            output_data_pip_10[3:0]  <= data_in[43:40];
            output_data_pip_11[3:0]  <= data_in[47:44];
            output_data_pip_12[3:0]  <= data_in[51:48];
            output_data_pip_13[3:0]  <= data_in[55:52];
            output_data_pip_14[3:0]  <= data_in[59:56];
            output_data_pip_15[3:0]  <= data_in[63:60];
        end
    endcase
end


always @(posedge fast_clk) begin
    output_data_0  <= output_data_pip_0;
    output_data_1  <= output_data_pip_1;
    output_data_2  <= output_data_pip_2;
    output_data_3  <= output_data_pip_3;
    output_data_4  <= output_data_pip_4;
    output_data_5  <= output_data_pip_5;
    output_data_6  <= output_data_pip_6;
    output_data_7  <= output_data_pip_7;

    output_data_8  <= output_data_pip_8;
    output_data_9  <= output_data_pip_9;
    output_data_10 <= output_data_pip_10;
    output_data_11 <= output_data_pip_11;
    output_data_12 <= output_data_pip_12;
    output_data_13 <= output_data_pip_13;
    output_data_14 <= output_data_pip_14;
    output_data_15 <= output_data_pip_15;
end
             

always @* begin 
    next_state_c = state_c;
    case(state_c)
    
        s0: begin 
            if (READ_IS_NOW) begin 
                next_state_c = s1;
            end else begin 
                next_state_c = s0;
            end
        end
        
        s1: begin 
            next_state_c = s2;
        end
        
        s2: begin
            next_state_c = s0;
        end 
        default: begin 
            next_state_c = s0;
        end    
    
    endcase
    
end

wire [15:0] DATAOUT;
reg pre_cnt_dely = 0;
reg inc_dely_c = 0;
reg inc_dely_d = 0;
reg CE_d = 0;
reg CE_c = 0;
reg Ld_d = 0;
reg Ld_c = 0;

reg[4:0] sunnyboy_cnt = 0;
reg pre_sunnyboy_cnt;



reg [4:0] cnt_dely_w_d = 5'd0;

always @(posedge fast_clk) begin
    cnt_dely_w_d <= cnt_dely_w;

    inc_dely_d <= 1'b0;
    CE_d <= 1'b0;
    Ld_d <= 1'b0;

    inc_dely_c <= 1'b0;
    CE_c <= 1'b0;
    Ld_c <= 1'b0;

    if (cal_active) begin

        if (cnt_dely_w != cnt_dely_w_d) begin
            inc_dely_d <= 1'b1;
            CE_d <= 1'b1;
        end

        if (cnt_dely_w_d == 5'd31 && cnt_dely_w == 5'd0 && (cnt_dely_w_d != cnt_dely_w) ) begin
            sunnyboy_cnt <= sunnyboy_cnt + 1'b1;
            Ld_d <= 1'b1;   

            inc_dely_c <= 1'b1;
            CE_c <= 1'b1;   
            if (sunnyboy_cnt == 5'd31) begin
                Ld_d <= 1'b1;
                Ld_c <= 1'b1;
            end
        end
    end
end

IDELAYCTRL u_idelayctrl (
    .REFCLK(clk_200),   
    .RST(reset_for_Oser_DQ),  
    .RDY()
);

genvar idq_delay; 

generate
    for (idq_delay = 0; idq_delay < 16; idq_delay = idq_delay + 1) begin : u_idelay_DQ

IDELAYE2 #(
    .DELAY_SRC("DATAIN"),
    .IDELAY_TYPE("VARIABLE"),
    .IDELAY_VALUE(0),          // change 0..31
    .REFCLK_FREQUENCY(200.00),
    .SIGNAL_PATTERN("DATA"),
    .HIGH_PERFORMANCE_MODE("TRUE"),
    .PIPE_SEL("FALSE"),
    .CINVCTRL_SEL("FALSE")
) u_idelay_DQ (
    .IDATAIN(1'b0),
    .DATAIN(DQ_internal_out[idq_delay]),
    .DATAOUT(DATAOUT[idq_delay]),

    .C(fast_clk),                
    .CE(CE_d),
    .INC(1'b1),
    .LD(Ld_d),
    .LDPIPEEN(1'b0),
    .CNTVALUEIN(5'b0),
    .CNTVALUEOUT(),
    .CINVCTRL(1'b0),
    .REGRST(1'b0)
);

end 

endgenerate



wire dqs_delayed_0;
wire dqs_delayed_1;
wire dqs_delayed_r_0;
wire dqs_delayed_r_1;

BUFG BUFG_inst_0 (
   .O(dqs_delayed_0), // 1-bit output: Clock output
   .I(dqs_delayed_r_0)  // 1-bit input: Clock input
);

BUFG BUFG_inst_1 (
   .O(dqs_delayed_1), // 1-bit output: Clock output
   .I(dqs_delayed_r_1)  // 1-bit input: Clock input
);


 
 IDELAYE2 #(
    .DELAY_SRC("DATAIN"),
    .IDELAY_TYPE("VARIABLE"),
    .IDELAY_VALUE(0),         
    .REFCLK_FREQUENCY(200.00),
    .SIGNAL_PATTERN("CLOCK"),
    .HIGH_PERFORMANCE_MODE("TRUE"),
    .PIPE_SEL("FALSE"),
    .CINVCTRL_SEL("FALSE")
) u_idelay_clk_0 (
    .DATAIN(ddr3_dqs_r_0),
    .IDATAIN(1'b0),
    .DATAOUT(dqs_delayed_r_0),

    .C(fast_clk),           
    .CE(CE_c),
    .INC(1'b1),
    .LD(Ld_c),
    .LDPIPEEN(1'b0),
    .CNTVALUEIN(5'b0),
    .CNTVALUEOUT(),
    .CINVCTRL(1'b0),
    .REGRST(1'b0)
);


 IDELAYE2 #(
    .DELAY_SRC("DATAIN"),
    .IDELAY_TYPE("VARIABLE"),
    .IDELAY_VALUE(0),         
    .REFCLK_FREQUENCY(200.00),
    .SIGNAL_PATTERN("CLOCK"),
    .HIGH_PERFORMANCE_MODE("TRUE"),
    .PIPE_SEL("FALSE"),
    .CINVCTRL_SEL("FALSE")
) u_idelay_clk_1 (
    .DATAIN(ddr3_dqs_r_1),
    .IDATAIN(1'b0),
    .DATAOUT(dqs_delayed_r_1),

    .C(fast_clk),           
    .CE(CE_c),
    .INC(1'b1),
    .LD(Ld_c),
    .LDPIPEEN(1'b0),
    .CNTVALUEIN(5'b0),
    .CNTVALUEOUT(),
    .CINVCTRL(1'b0),
    .REGRST(1'b0)
);    
 
genvar idq_SERDESE_0; 

generate
    for (idq_SERDESE_0 = 0; idq_SERDESE_0 < 8; idq_SERDESE_0 = idq_SERDESE_0 + 1) begin : u_serdes_DQ_0
    
    localparam integer data_in_num = idq_SERDESE_0*4 ;
         

ISERDESE2
#(
    .SERDES_MODE("MASTER"),
    .INTERFACE_TYPE("MEMORY"),
    .DATA_WIDTH(4),
    .DATA_RATE("DDR"),
    .NUM_CE(1),
    .IOBDELAY("IFD")
)
u_serdes_dq_in_15
(
    // Raw DQS strobe, no IDELAY
    .CLK(dqs_delayed_0),
    .CLKB(~dqs_delayed_0),

    .OCLK(fast_clk),
    .OCLKB(~fast_clk),

    // Divided clock
    .CLKDIV(clk_div),
    .RST(reset_for_Oser_DQ),

    .BITSLIP(1'b0),
    .CE1(1'b1),

    // Raw DQ, no IDELAY
    .D(1'b0),
    .DDLY(DATAOUT[idq_SERDESE_0]),

    // Parallel output
    .Q4(data_in[data_in_num+3]),
    .Q3(data_in[data_in_num+2]),
    .Q2(data_in[data_in_num+1]),
    .Q1(data_in[data_in_num]),

    // Unused
    .O(),
    .SHIFTOUT1(),
    .SHIFTOUT2(),
    .CE2(1'b1),
    .CLKDIVP(1'b0),
    .DYNCLKDIVSEL(1'b0),
    .DYNCLKSEL(1'b0),
    .OFB(1'b0),
    .SHIFTIN1(1'b0),
    .SHIFTIN2(1'b0)
);

end 

endgenerate 


genvar idq_SERDESE_1; 

generate
    for (idq_SERDESE_1 = 8; idq_SERDESE_1 < 16; idq_SERDESE_1 = idq_SERDESE_1 + 1) begin : u_serdes_DQ_1
    
    localparam integer data_in_num = idq_SERDESE_1*4 ;
         

ISERDESE2
#(
    .SERDES_MODE("MASTER"),
    .INTERFACE_TYPE("MEMORY"),
    .DATA_WIDTH(4),
    .DATA_RATE("DDR"),
    .NUM_CE(1),
    .IOBDELAY("IFD")
)
u_serdes_dq_in_15
(
    // Raw DQS strobe, no IDELAY
    .CLK(dqs_delayed_1),
    .CLKB(~dqs_delayed_1),

    .OCLK(fast_clk),
    .OCLKB(~fast_clk),

    // Divided clock
    .CLKDIV(clk_div),
    .RST(reset_for_Oser_DQ),

    .BITSLIP(1'b0),
    .CE1(1'b1),

    // Raw DQ, no IDELAY
    .D(1'b0),
    .DDLY(DATAOUT[idq_SERDESE_1]),

    // Parallel output
    .Q4(data_in[data_in_num+3]),
    .Q3(data_in[data_in_num+2]),
    .Q2(data_in[data_in_num+1]),
    .Q1(data_in[data_in_num]),

    // Unused
    .O(),
    .SHIFTOUT1(),
    .SHIFTOUT2(),
    .CE2(1'b1),
    .CLKDIVP(1'b0),
    .DYNCLKDIVSEL(1'b0),
    .DYNCLKSEL(1'b0),
    .OFB(1'b0),
    .SHIFTIN1(1'b0),
    .SHIFTIN2(1'b0)
);

end 

endgenerate 







endmodule