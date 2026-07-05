`timescale 1ns/1ns

module ddrcontroller_v4 (
    input  fast_clk,   
    input [1:0] operation,   
    input wire [1:0] DQ_in,  
    input wire [9:0] row_adresse,
    input wire [13:0] col_adresse,   
    input wire [2:0] bank_adresse,   
    output reg DDR_busy,

    input [32:0] data_in,
    output reg [2:0] CMD = 3'b111,  
    output reg ddr_reset,
    output reg CKE,                
    output reg [14:0] A,
    output reg [2:0] BA, 
    output reg DQS_flag,  
    output reg READ_IS_NOW,
    output wire [3:0] c_state,
    input wire clk_div_90,
    output wire refresh_w
);

//ila_3 your_instance_name (
//	.clk(fast_clk), // input wire clk


//	.probe0(active_or_not), // input wire [0:0]  probe0  
//	.probe1(open_col), // input wire [13:0]  probe1 
//	.probe2(col_adresse) // input wire [13:0]  probe2
//);


    assign c_state = state;
 
    parameter hold_reset_time = 200_00;
    parameter time_before_CKE = 500_00;
    parameter TXPR = 17;
    parameter tMRD = 4+1;
    parameter tMOD = 12;
    parameter tZQinit = 512;
    parameter active_back_time = 3;
    parameter bank_refresh_time = 16;

    localparam MR3 = 14'b00_0000_0000_0000;
    localparam MR2 = 14'b00_0000_0000_1000;
    localparam MR1 = 14'b00_0000_0000_0001;
    localparam MR0 = 14'b00_0001_0010_0000;

    localparam [2:0] 
        CMD_NOP  = 3'b111,
        CMD_ZQ   = 3'b110,
        CMD_MRS  = 3'b000,
        CMD_ACT  = 3'b011,
        CMD_RD   = 3'b101,
        CMD_WR   = 3'b100,
        CMD_REF  = 3'b001,
        CMD_PREA = 3'b010;

    localparam [3:0]
        POWERON                    = 4'd0,
        WAIT_FOR_CKE_TO_GO_HIGH    = 4'd1,
        WAIT_TXPR_BEFORE_FIRST_MRS = 4'd2,
        ISSUE_MR2                  = 4'd3,
        ISSUE_MR0                  = 4'd4,
        ISSUE_MR1                  = 4'd5,
        ISSUE_MR3                  = 4'd6,
        wait_tMRD_before_ZQC       = 4'd7,
        ZQC                        = 4'd8,
        Ideal                      = 4'd9,
        prechage                   = 4'd10,
        active_bank_row            = 4'd11,
        Read1                      = 4'd12,
        write1                     = 4'd13,
        done                       = 4'd14,
        refresh                    = 4'd15;

    reg [4:0] state = 4'b0000, nextstate;  
    reg [16:0] cnt = 32'd0;
    reg [13:0] refresh_cnt = 16'd0;

    reg [2:0] nextCMD;
    reg [7:0] next_data, data_in_r;
    reg next_DQS_flag = 1'b0;
    reg [14:0] next_A;
    reg next_READ_IS_NOW;
    reg flag_for_syc;
    wire active_or_not;
    reg [3:0] open_bank = 4'd3;
    reg [13:0] open_col = 14'd3;
    reg write_or_read = 1'b0;  // 0=write, 1=read
    reg next_write_or_read;

    assign active_or_not = ((open_bank == bank_adresse) && (open_col == col_adresse));  
    assign refresh_w = (refresh_cnt == 15_000);

    always @* begin
        nextstate          = state;
        nextCMD            = CMD_NOP;
        ddr_reset          = 1'b1;
        CKE                = 1'b1;
        next_A             = A;
        BA                 = 3'b000;
        next_data          = data_in_r;
        DDR_busy           = 1'b1;
        next_DQS_flag      = 1'b0;
        next_READ_IS_NOW   = READ_IS_NOW;
        flag_for_syc       = 1'b0;
        next_write_or_read = write_or_read;

        case (state)

            POWERON: begin
                next_A           = 14'b00_0000_0000_0000;
                BA               = 3'b000;
                ddr_reset        = 1'b0;
                CKE              = 1'b0;
                nextCMD          = CMD_NOP;
                next_READ_IS_NOW = 0;
                if (cnt == hold_reset_time)
                    nextstate = WAIT_FOR_CKE_TO_GO_HIGH;
                end

            WAIT_FOR_CKE_TO_GO_HIGH: begin
                CKE     = 1'b0;
                nextCMD = CMD_NOP;
                if (cnt == time_before_CKE)
                    nextstate = WAIT_TXPR_BEFORE_FIRST_MRS;
            end

            WAIT_TXPR_BEFORE_FIRST_MRS: begin
                if (cnt == TXPR) begin 
                    nextstate = ISSUE_MR2;
                    nextCMD   = CMD_MRS;
                end else begin
                    nextstate = WAIT_TXPR_BEFORE_FIRST_MRS;
                end
            end

            ISSUE_MR2: begin
                nextCMD   = CMD_NOP;
                next_A    = MR2;
                BA        = 3'b010;
                nextstate = ISSUE_MR2;
                if (cnt == tMRD) begin
                    nextstate = ISSUE_MR3;
                    nextCMD   = CMD_MRS;
                end
            end

            ISSUE_MR3: begin
                nextCMD   = CMD_NOP;
                next_A    = MR3;
                BA        = 3'b011;
                nextstate = ISSUE_MR3;
                if (cnt == tMRD) begin
                    nextstate = ISSUE_MR1;
                    nextCMD   = CMD_MRS;
                end
            end

            ISSUE_MR1: begin
                nextCMD   = CMD_NOP;
                next_A    = MR1;
                BA        = 3'b001;
                nextstate = ISSUE_MR1;
                if (cnt == tMRD) begin
                    nextstate = ISSUE_MR0;
                    nextCMD   = CMD_MRS;
                end
            end

            ISSUE_MR0: begin
                nextCMD   = CMD_NOP;
                next_A    = MR0;
                BA        = 3'b000;
                nextstate = ISSUE_MR0;
                if (cnt == tMRD) begin
                    nextstate = wait_tMRD_before_ZQC;
                    nextCMD   = CMD_NOP;
                end
            end

            wait_tMRD_before_ZQC: begin
                if (cnt == tMOD) begin
                    nextstate = ZQC;
                    nextCMD   = CMD_ZQ;
                end else begin
                    nextstate = wait_tMRD_before_ZQC;
                end
            end

            ZQC: begin
                nextCMD = CMD_NOP;
                next_A  = 14'b00_0100_0000_0000;
                if (cnt == tZQinit)
                    nextstate = Ideal;
                else
                    nextstate = ZQC;
            end

            Ideal: begin
            nextCMD = CMD_NOP;
                
                    if (pending_sync) begin
                        DDR_busy = 1'b1;
                        flag_for_syc = 1'b1;
                
                        if (sync) begin
                            flag_for_syc = 1'b0;
                            DDR_busy = 1'b1;
                
                            case (write_or_read)
                                1'b0: begin  // write
                                    nextstate     = write1;
                                    next_DQS_flag = 1'b1;
                                    nextCMD       = CMD_WR;
                                    BA            = bank_adresse;
                                    next_A        = {4'b0000, row_adresse};
                                end
                
                                1'b1: begin  // read
                                    nextstate = Read1;
                                    nextCMD   = CMD_RD;
                                    BA        = bank_adresse;
                                    next_A    = {4'b0000, row_adresse};
                                end
                            endcase
                        end else begin
                            nextstate = Ideal;
                        end
                    end else begin
                        DDR_busy = 1'b0;
                
                        if (refresh_cnt < 15000) begin
                            case (operation)
                                2'b00: begin
                                    nextstate = Ideal;
                                    nextCMD   = CMD_NOP;
                                end
                
                                2'b01: begin  // read request
                                    
                                    next_write_or_read = 1'b1;
                
                                    if (bank_has_been_closed) begin
                                        nextstate = active_bank_row;
                                    end else if (!active_or_not) begin
                                        nextstate = prechage;
                                    end else begin
                                        flag_for_syc = 1'b1;
                                        nextstate = Ideal;
                                    end
                                end
                
                                2'b10: begin  // write request
                                    
                                    next_write_or_read = 1'b0;
                
                                    if (bank_has_been_closed) begin
                                        nextstate = active_bank_row;
                                    end else if (!active_or_not) begin
                                        nextstate = prechage;
                                    end else begin
                                        
                                        flag_for_syc = 1'b1;
                                        nextstate = Ideal;
                                    end
                                end
                            endcase
                        end else begin
                            DDR_busy  = 1'b1;
                            nextstate = refresh;
                            nextCMD   = CMD_PREA;
                            next_A    = {4'b0001, row_adresse};
                        end
                    end
                end     

            prechage: begin
                if (cnt == 0) begin
                    nextCMD    = CMD_PREA;
                    next_A    = {4'b0001, row_adresse};
                    BA         = bank_adresse;
                end
                if (cnt > 3) begin
                    nextstate = active_bank_row;
                end else begin
                    nextstate = prechage;
                end
            end 

            active_bank_row: begin
                if (sync) begin
                    case (write_or_read)
                        1'b1: begin  // read
                            nextstate    = Read1;
                            nextCMD      = CMD_RD;
                            BA           = bank_adresse;
                            next_A       = {4'b0000, row_adresse};
                            flag_for_syc = 1'b0;
                        end 
                        1'b0: begin  // write
                            nextstate     = write1;
                            nextCMD       = CMD_WR;
                            BA            = bank_adresse;
                            next_A        = {4'b0000, row_adresse};
                            next_DQS_flag = 1'b1;
                            flag_for_syc  = 1'b0;
                        end 
                    endcase
                end else begin
                    if (cnt == 0) begin
                        nextCMD = CMD_ACT;
                        BA = bank_adresse;
                        next_A  = col_adresse;
                    end
                    if (cnt < active_back_time) begin
                        nextstate = active_bank_row;
                        flag_for_syc = 1'b0;
                    end else begin
                        flag_for_syc = 1'b1;
                    end
                end
            end

            refresh: begin
                if (cnt == 2) begin
                    nextCMD  = CMD_REF;
                    nextstate = refresh;
                end else begin
                    if (cnt < bank_refresh_time + 3) begin
                        nextstate = refresh;
                    end else begin
                        nextCMD   = CMD_NOP; 
                        nextstate = Ideal;
                    end
                end
            end

            Read1: begin
                BA = bank_adresse;
                nextCMD  = CMD_NOP;
                if (cnt > 8) begin
                    if (cnt < 13) begin 
                        next_READ_IS_NOW = 1'b1;
                        nextstate = Read1;                     
                    end else begin
                        next_READ_IS_NOW = 1'b0; 
                        nextstate = done;
                    end
                end else begin 
                    nextstate = Read1;
                end
            end
            
            done: begin 
                nextstate = Ideal; 
            end

            write1: begin
                BA            = bank_adresse;
                DDR_busy = 1'b1;
                next_A        = {4'b0000, row_adresse};              
                next_DQS_flag = 1'b0;
                if (cnt > 7)
                    nextstate = done;
            end

            default: begin
                nextstate = POWERON;
                nextCMD   = CMD_NOP;
                CKE       = 1'b0;
            end

        endcase
    end
    
    reg pending_sync =1'b0;
    
    always@(posedge fast_clk) begin 
        if(flag_for_syc) begin
            pending_sync <= 1'b1;
        end else begin
            pending_sync <= 1'b0;
        end
    end 
            
            
             
            
    
    always @(posedge clk_div_90) begin 
        if (flag_for_syc)
            sync_pip <= 1'b1;
        else
            sync_pip <= 1'b0;
    end
    
    reg sync_pip = 1'b0;
    reg sync     = 1'b0;
    reg bank_has_been_closed = 1'b0;
    
    always @(negedge fast_clk) begin 
        sync <= sync_pip;
    end

    reg mid_flag;
    
    

    always @(posedge fast_clk) begin
        

        if (state == Ideal)
            write_or_read <= next_write_or_read;
        
        if ((state == write1) || (state == Read1)) begin 
            open_col             <= col_adresse;
            open_bank            <= bank_adresse;
            bank_has_been_closed <= 1'b0;
        end     
        
        state       <= nextstate;
        CMD         <= nextCMD;
        READ_IS_NOW <= next_READ_IS_NOW;
        mid_flag    <= next_DQS_flag;
        A           <= next_A;
        
        if (state == refresh || state == ZQC) begin 
            refresh_cnt          <= 0;
            bank_has_been_closed <= 1'b1;
        end else begin 
            refresh_cnt <= refresh_cnt + 1;
        end
        
        DQS_flag <= mid_flag;

        if (nextstate != state)
            cnt <= 16'd0;
        else
            cnt <= cnt + 16'd1;
    end

endmodule