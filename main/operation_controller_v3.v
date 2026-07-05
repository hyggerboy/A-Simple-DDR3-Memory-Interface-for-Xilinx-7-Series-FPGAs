//`include "test_vars.vh"

module operation_controller (
    input wire clk,
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
    output wire [2:0]  DDR_BA,
    output wire [13:0] DDR_A,
    output wire [0:0] ddr_clk_n,
    output wire [0:0] ddr_clk_p,
    inout wire [15:0] DQ_ddr,

    output reg memory_bussy,
    input  wire write_to_mem,
    input  wire read_from_mem,
    output wire fast_clk,
    input [127:0] data_to_write,
    output wire [127:0] data_to_read ,
    input wire [31:0] adress,
    output wire WM0_w,
    output wire WM1_w,
    input wire [15:0] data_masking_byte
         
);

//used for debuging and calbration test

//reg [1024:0]calvals;
//reg [16:0] cnt_for_cal_check = 0;

//ila_2 your_instance_name (
//	.clk(fast_clk), // input wire clk


//	.probe0(calvals), // input wire [1368:0] probe0
//	.probe1(state)
//);


//always@(posedge fast_clk) begin 
//    if(state == cal_check && nextstate !=cal_check && cnt_for_cal_check < 1024) begin
//        cnt_for_cal_check <= cnt_for_cal_check +1;  
//        if(output_data_w != traning_byte) begin
//            calvals[cnt_for_cal_check] <= 1'b0;
//        end else begin
//            calvals[cnt_for_cal_check] <= 1'b1;
//        end 
//    end
// end
             
             
//ila_0 your_instance_name (
//	.clk(fast_clk), // input wire clk


//	.probe0(adress[26:0]), // input wire [26:0]  probe0  
//	.probe1(memory_bussy),
//	.probe2(state),
//	.probe3(DDR_busy),
//	.probe4(data_to_read),
//	.probe5(col_adresse),
//	.probe6(row_adresse),
//	.probe7(col_adresse_2w)
//);

wire [127:0] data_to_write_to_mem_w;

wire [127:0] data_out_w;

adresse_decoder adc(
    .data_to_store(data_to_write),
    .adresse(adress),
    .ofsetread_data(data_out_w),
    .data_to_write_to_mem_dc(data_to_write_to_mem_w),
    .masking_byte(data_masking_byte),
    .bank_adresse(bank_adresse_w),
    .col_adresse(col_adresse_w),
    .row_adresse(row_adresse_w),
    .data_read_from_mem_cd(output_data_w),
    .mask_1_write(mask_1_write),
    .mask_2_write(mask_2_write),
    .first_read(first_read),
    .bank_adresse_2(bank_adresse_2w),
    .col_adresse_2(col_adresse_2w),
    .row_adresse_2(row_adresse_2w)


);

wire [2:0] bank_adresse_2w;
wire [9:0] row_adresse_2w;
wire [13:0] col_adresse_2w;

wire [15:0] mask_1_write;
wire [15:0] mask_2_write;


wire [2:0] bank_adresse_w;
wire [13:0] col_adresse_w;
wire [9:0] row_adresse_w;

 
localparam wait_for_normalopration = 4'b0000,
           cal_write_start = 4'b0001,
           cal_write_wait = 4'b0010,
           cal_read_start = 4'b0011,
           cal_read_wait = 4'b0100,
           cal_check = 4'b0101,
           ideal = 4'b0110,
           wrtie_start = 4'b0111,
           wrtie_wait = 4'b1000,
           read_start = 4'b1001,
           read_wait = 4'b1010; 
           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

reg [3:0] nextstate;
reg [3:0] state = wait_for_normalopration;

assign data_to_read = data_out_w;

reg [7:0] wrtie_date;
wire DDR_busy;

reg [1:0] operation;
//used for debug
wire [31:0] data_in;

wire [127:0] output_data_w;



wire fast_clk;
wire cal_fail_flag;
//state off ddr conroler used for debug
wire  [3:0] c_state;
wire [4:0] cnt_dely_w;

reg [4:0] cnt_dely  = 5'd0;
assign cnt_dely_w = cnt_dely;





top_ddrcontroller_v3 dut(
    // i/o for the device to talk to the me
    .operation(next_operation),

    //
    .clk(clk),
    .ddr3_dqs_p_0(ddr3_dqs_p_0),
    .ddr3_dqs_n_0(ddr3_dqs_n_0),
    .ddr3_dqs_p_1(ddr3_dqs_p_1),
    .ddr3_dqs_n_1(ddr3_dqs_n_1),

    // DDR3 pins (command/address style)
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
    .DDR_busy(DDR_busy),
    .output_data_w(output_data_w),
    .row_adresse(row_adresse),
    .bank_adresse(bank_adresse),
    .data_to_wrtie_in_mem(data_to_wrtie_in_mem),
    .fast_clk(fast_clk),
    .c_state(c_state),
    .cnt_dely_w(cnt_dely_w),
    .cal_active(cal_active),
    .clk_div(clk_div),
    .col_adresse(col_adresse),
    .refresh_w(refresh_w),
    .WM0_w(WM0_w),
    .WM1_w(WM1_w),
    .data_masking(data_masking)
);
//use to find then the refish happenede
wire refresh_w;


reg [15:0] data_masking;

reg [127:0] output_data_w_ila_pip;

reg [127:0] next_first_read;
reg [127:0] first_read;

//always @(posedge fast_clk) begin
//    output_data_w_ila_pip <=  output_data_w;
    
//end




localparam [127:0] traning_byte = 128'haa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa_aa;

reg [13:0] col_adresse;
reg [13:0] next_col_adresse;
reg [9:0] row_adresse;
reg [2:0] next_bank_adresse;
reg [2:0] bank_adresse;
reg [127:0] data_to_wrtie_in_mem;
reg [127:0] next_data_to_wrtie_in_mem;
reg [9:0] next_row_adresse;

reg cal_active = 0;


reg [15:0] next_data_masking;

reg f_or_s_w;
reg next_f_or_s_w;



always @* begin
    next_operation = 2'b00;
    next_row_adresse = row_adresse;
    next_data_to_wrtie_in_mem = data_to_wrtie_in_mem;
    next_bank_adresse = bank_adresse;
    next_col_adresse = col_adresse;
    nextstate = state;
    cal_active = 1'b0;
    next_memory_bussy = 1'b1;
    next_data_masking = data_masking;
    next_f_or_s_w = f_or_s_w;
    next_first_read = first_read; 

    case (state)

        wait_for_normalopration: begin
            if (~DDR_busy) begin
                nextstate = cal_write_start;
            end else begin
                nextstate = wait_for_normalopration;
            end
        end

        cal_write_start: begin
            cal_active = 1'b1;

            next_row_adresse = 10'd0;
            next_bank_adresse = 3'd0;
            next_col_adresse = 14'd0;
            next_data_to_wrtie_in_mem = traning_byte;
            next_data_masking = 8'h00;

            if (~DDR_busy ) begin
                next_operation = 2'b10;
                nextstate = cal_write_wait;
            end else begin
                next_operation = 2'b00;
                nextstate = cal_write_start;
            end
        end

        cal_write_wait: begin
            cal_active = 1'b1;
            next_operation = 2'b00;

            if (~DDR_busy ) begin
                nextstate = cal_read_start;
            end else begin
                nextstate = cal_write_wait;
            end
        end

        cal_read_start: begin
            cal_active = 1'b0;

            next_row_adresse = 10'd0;
            next_bank_adresse = 3'd0;
            next_col_adresse = 14'd0;

            if (~DDR_busy) begin
                
                next_operation = 2'b01;
                nextstate = cal_read_wait;
                 
            end else begin
                next_operation = 2'b00;
                nextstate = cal_read_start;
            end
        end

        cal_read_wait: begin
            cal_active = 1'b1;
            next_operation = 2'b00;

            if (~DDR_busy) begin
                nextstate = cal_check;
            end else begin
                nextstate = cal_read_wait;
            end
        end

        cal_check: begin
            cal_active = 1'b1;
//            if (output_data_w[63:0] == 64'h1f31ba31001b34) begin
            if (output_data_w == traning_byte) begin
                nextstate = ideal;
            end else begin
                nextstate = cal_write_start;
            end
        end

        ideal: begin
            next_memory_bussy = 1'b0;
            
            next_bank_adresse = bank_adresse_w;
            next_col_adresse = col_adresse_w;
            next_data_to_wrtie_in_mem = data_to_write_to_mem_w;
            next_data_masking = mask_1_write;
            next_f_or_s_w = 1'b0;
 
                if (write_to_mem && ~read_from_mem && ~memory_bussy ) begin
                    next_row_adresse = row_adresse_w;
                    nextstate = wrtie_start;
                    
    
                end else begin
                    if (read_from_mem && ~write_to_mem && ~memory_bussy) begin
                        next_row_adresse = {row_adresse_w[9:3],3'b000};
                        nextstate = read_start;
    
                    end else begin         
                        nextstate = ideal;
                end
        end
        end

        wrtie_start: begin
            if (~DDR_busy) begin
                if (1'b0 == 1'b0) begin 
                    next_operation = 2'b10;
                    nextstate = wrtie_wait;
                end else begin 
                    nextstate = wrtie_start;
                    next_operation = 2'b00;
                end
            end else begin
                next_operation = 2'b00;
                nextstate = wrtie_start;
            end
        end

        wrtie_wait: begin
            operation = 2'b00;
            if ((~DDR_busy) && ((adress[2:0]== 3'b000) || (f_or_s_w == 1'b1 && ~DDR_busy) )) begin
                nextstate = ideal;
            end else if ((~DDR_busy) && (adress[2:0]!= 3'b000) && (f_or_s_w == 1'b0)) begin 
                nextstate = wrtie_start;
                next_data_to_wrtie_in_mem = data_to_write_to_mem_w;
                next_row_adresse = row_adresse_2w;
                next_bank_adresse = bank_adresse_2w;
                next_col_adresse = col_adresse_2w;
                next_data_masking = mask_2_write;
                next_f_or_s_w = 1'b1;               
            end else begin
                nextstate = wrtie_wait;
            end
        end

        read_start: begin
 

            if (~DDR_busy) begin
                if(1'b0 == 1'b0) begin 
                    next_operation = 2'b01;
                    nextstate = read_wait;
                end else begin 
                    nextstate = read_start;
                end
            end else begin
                next_operation = 2'b00;
                nextstate = read_start;
            end
        end
        
        read_wait: begin
            next_operation = 2'b00;

            if (~DDR_busy && ((adress[2:0]== 3'b000) || (f_or_s_w == 1'b1 && ~DDR_busy))) begin
                nextstate = ideal;
    
            end else if ((~DDR_busy) && (adress[2:0]!= 3'b000) && (f_or_s_w == 1'b0)) begin 
                next_first_read = output_data_w;
                nextstate = read_start;
                next_row_adresse = {row_adresse_2w[9:3],3'b000};
                next_bank_adresse = bank_adresse_2w;
                next_col_adresse = col_adresse_2w;
                next_f_or_s_w = 1'b1;
                    
            
            end else begin
                nextstate = read_wait;
            end
        end



        default: begin
            nextstate = wait_for_normalopration;
        end

    endcase
end

reg [1:0] next_operation;
reg [1:0] offsetopration;

reg next_memory_bussy;

always @(posedge fast_clk) begin
    state <= nextstate;
    offsetopration <= next_operation;
    data_to_wrtie_in_mem <= next_data_to_wrtie_in_mem;
    row_adresse <= next_row_adresse;
    col_adresse <= next_col_adresse;
    bank_adresse <= next_bank_adresse;
    memory_bussy <= next_memory_bussy;
    data_masking <= next_data_masking;
    f_or_s_w <= next_f_or_s_w; 
    first_read <= next_first_read;
    


    if ((state == cal_check) && (nextstate == cal_write_start)) begin
        cnt_dely <= cnt_dely + 1'b1;
    end

  


end

endmodule