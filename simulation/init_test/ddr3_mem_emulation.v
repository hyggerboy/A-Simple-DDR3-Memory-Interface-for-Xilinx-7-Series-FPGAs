`timescale 1ns/1ns
//"siumlate the behavior off the mem at init"
module mem_setup_tb (
    input  wire        clk,
    input  wire        nclk,
    input  wire        CKE,
    input  wire        cs,
    input  wire        ODT,
    input  wire        RAS,
    input  wire        CAS,
    input  wire        WE,
    input  wire [2:0]  BA,
    input  [14:0] A,

    input  wire        RESET

);


    `define	max2(v1, v2) ((v1) > (v2) ? (v1) : (v2))






parameter time    min_time_for_reset_to_be_held = 200_000; // ns (Minimum 200 µs [1])
parameter time    CKE_MIN_AFTER_RESET_NS        = 500_000; // ns (Minimum 500 µs [1])
parameter integer TXPR_MIN_CYC                  = 17;      
parameter time    TXPR_MIN_NS                   = 170;     
parameter integer TMRD_MIN_CYC                  = 4;       
parameter integer TMOD_MIN_CYC                  = 12;      
parameter integer TDLLK_CYC                     = 512;     
parameter integer TZQINIT_CYC                   = 512;     
parameter time    tZQinit                       = 5120;    
parameter time    active_bank_time              = 20;      
reg is_there_a_clock_eged_at_active_cmd = 1'b0;

    
    localparam [3:0]
        CMD_MRS = 3'd0,
        CMD_REF = 3'd1,
        CMD_PRE = 3'd2,
        CMD_rd= 3'd3,
        CMD_ZQ = 3'd4,
        CMD_NOP = 3'd5,
        CMD_DES = 3'd6,
        CMD_ACT = 3'd7;

    reg  [2:0] cmd;

    always @* begin
        if (cs) begin
            cmd = CMD_DES;
        end else begin
            case ({RAS, CAS, WE})
                3'b111: cmd = CMD_NOP;
                3'b000: cmd = CMD_MRS;
                3'b001: cmd = CMD_REF;
                3'b010: cmd = CMD_PRE;
                3'b011: cmd = CMD_ACT;
                3'b101: cmd = CMD_rd;
                3'b110: cmd = CMD_ZQ;
                default: cmd = CMD_NOP;
            endcase
        end
    end
    integer clk_before_first_MRS_CMD = 0;
    integer clocks_since_reset_release = 0;
    integer clk_at_first_MRS_CMD = 0;
    integer clocks_after_cke;
    integer clocks_since_last_mrs;
    integer tmod_count;
    integer dllk_count;
    integer zq_count;

    time reset_release_time;
    time CKE_time_after_RESET;
    time MRS_time;
    time reset_start_time;
    time reset_end_time;
    time reset_deta; 
    time after_reset_start;
    time CKEUP_time;
    time deta_CKE_time;
    time ZQE_start_time;
    time ZQE_end_time;
    time active_state_time;
    time active_end_time;

    //name is mislaed just counts clk's 

    initial begin
        forever begin
           @(posedge clk);
           clocks_since_reset_release = clocks_since_reset_release+1; 
        end
    end
    reg[2:0] prev_cmd;
    integer CMD_failes_ACT = 0;
    integer CMD_failes_rd = 0;
    integer CMD_failes_ZQ = 0;
    integer CMD_failes_MRS = 0;



initial begin
  prev_cmd = CMD_NOP;
  forever begin
    @(posedge clk);

    if (prev_cmd == cmd && cmd != CMD_NOP) begin
      case (prev_cmd)
        CMD_ACT: CMD_failes_ACT++;
        CMD_rd : begin CMD_failes_rd++;  end
        CMD_ZQ : CMD_failes_ZQ++;
        CMD_MRS: begin CMD_failes_MRS++;  end
       
      endcase
    end

    prev_cmd <= cmd; // update after checking
  end
end
    
    initial begin
        //check if reset was low for the time it needed

        $display("test stats:");

        wait(RESET == 1'b0);
        reset_start_time = $time;

        wait(RESET == 1'b1);
        reset_end_time = $time;

        reset_deta = reset_end_time-reset_start_time;
        $display("Reset was hold down for %0t",(reset_deta));

        if(reset_deta < min_time_for_reset_to_be_held) begin
            $display("failed reset wasa not hold low long enug %0t",reset_deta);
        end else begin
            $display("passed reset was hold for %0t",reset_deta);
        end

        after_reset_start = reset_end_time;

        //test if CKE comes at rigth time after reset
        wait(CKE == 1'b1);

        CKEUP_time = $time;
        deta_CKE_time = CKEUP_time-after_reset_start;

        $display("CKE time after reset = %0t",deta_CKE_time);

        if(deta_CKE_time < CKE_MIN_AFTER_RESET_NS) begin
            $display("failed CKE enabl to eraly %0t",deta_CKE_time);
        end else begin
            $display("Passed CKE enal at good time %0t",deta_CKE_time);
        end
        #0;

        if(clocks_since_reset_release < 5) begin
            $display("failed clk is: %d", clocks_since_reset_release);
        end else begin
            $display("passed clk is %d", clocks_since_reset_release);
        end 

        if(cmd == CMD_NOP) begin
            $display("passed CMD == nop");
        end else begin
            $display("CMD != nop");        
        end
        
    $display("Set up of MR2");
    $display("");
        
    #0;
        clk_before_first_MRS_CMD = $time;

        
   
        @(posedge (cmd == CMD_MRS));

        clk_at_first_MRS_CMD = $time;

            if(clk_at_first_MRS_CMD-CKEUP_time < 170) begin
                $display("failed,MRS CMD TO erly after CKE goes high %d",clk_at_first_MRS_CMD-CKEUP_time);
            end else begin
                $display("passed MRS CMD at right time after CKE %d",clk_at_first_MRS_CMD-CKEUP_time);
            end
        
        $display("=%b",BA[1:0]);
        if (BA[1:0]== 2'b10 && cmd == CMD_MRS) begin

            $display("Passed: MR2 chosen=%b",BA[1:0]);

            $display("A=%b",A);

            case (A[5:3])
            3'b000: $display("MR2: CWL (A[5:3]) = 000 -> CWL=5");
            3'b001: $display("MR2: CWL (A[5:3]) = 001 -> CWL=6");
            3'b010: $display("MR2: CWL (A[5:3]) = 010 -> CWL=7");
            3'b011: $display("MR2: CWL (A[5:3]) = 011 -> CWL=8");
            3'b100: $display("MR2: CWL (A[5:3]) = 100 -> CWL=9");
            3'b101: $display("MR2: CWL (A[5:3]) = 101 -> CWL=10");
            3'b110: $display("MR2: CWL (A[5:3]) = 110 -> reserved/invalid");
            3'b111: $display("MR2: CWL (A[5:3]) = 111 -> reserved/invalid");
            endcase

            // ASR (A6)
            case (A[6])
            1'b0: $display("MR2: ASR (A6) = 0 -> disabled");
            1'b1: $display("MR2: ASR (A6) = 1 -> enabled");
            endcase

            // SRT (A7)
            case (A[7])
            1'b0: $display("MR2: SRT (A7) = 0 -> normal temperature range");
            1'b1: $display("MR2: SRT (A7) = 1 -> extended temperature range");
            endcase

            // RTT_WR (A[10:9])
            case (A[10:9])
            2'b00: $display("MR2: RTT_WR (A[10:9]) = 00 -> Dynamic ODT off");
            2'b01: $display("MR2: RTT_WR (A[10:9]) = 01 -> RZQ/4");
            2'b10: $display("MR2: RTT_WR (A[10:9]) = 10 -> RZQ/2");
            2'b11: $display("MR2: RTT_WR (A[10:9]) = 11 -> reserved/invalid");
            endcase

            // PASR (A[2:0])
            case (A[2:0])
            3'b000: $display("MR2: PASR (A[2:0]) = 000 -> Full Array");
            3'b001: $display("MR2: PASR (A[2:0]) = 001 -> Half Array");
            3'b010: $display("MR2: PASR (A[2:0]) = 010 -> Quarter Array");
            3'b011: $display("MR2: PASR (A[2:0]) = 011 -> 1/8 Array");
            3'b100: $display("MR2: PASR (A[2:0]) = 100 -> 3/4 Array");
            3'b101: $display("MR2: PASR (A[2:0]) = 101 -> Half Array (upper)");
            3'b110: $display("MR2: PASR (A[2:0]) = 110 -> Quarter Array (upper)");
            3'b111: $display("MR2: PASR (A[2:0]) = 111 -> 1/8 Array (top)");
            endcase

        

        end else begin
            $display("failed: MR2 is not chosen=%b",BA[1:0]);
        end 
    
    
    
    
    wait(cmd == CMD_NOP);

    clk_before_first_MRS_CMD = clocks_since_reset_release;
    
    $display("Set up of MR3");
    $display("");
        

    wait(cmd == CMD_MRS);

    clk_at_first_MRS_CMD = clocks_since_reset_release;


            if(clk_at_first_MRS_CMD - clk_before_first_MRS_CMD < 5) begin
                $display("failed,MRS CMD TO erly after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
            end else begin
                $display("passed MRS CMD at right time after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
            end

if (BA[1:0]== 2'b11 && cmd == CMD_MRS) begin

    $display("Passed: MR3 chosen=%b",BA[1:0]);
    $display("A=%b",A);

    case (A[2])
      1'b0: $display("MR3: MPR Enable (A2) = 0 -> normal operation");
      1'b1: $display("MR3: MPR Enable (A2) = 1 -> MPR enabled");
    endcase

    // MPR Read Function (A[1:0]) (often only 00 is used)
    case (A[1:0])
      2'b00: $display("MR3: MPR Read Function (A[1:0]) = 00 -> predefined pattern");
      2'b01: $display("MR3: MPR Read Function (A[1:0]) = 01 -> reserved/invalid");
      2'b10: $display("MR3: MPR Read Function (A[1:0]) = 10 -> reserved/invalid");
      2'b11: $display("MR3: MPR Read Function (A[1:0]) = 11 -> reserved/invalid");
    endcase

    end else begin
        $display("failed MR3 not choosen=%b",BA[1:0]);
    end

    wait(cmd == CMD_NOP);

    clk_before_first_MRS_CMD = clocks_since_reset_release;


    $display("test MR1");


    wait(cmd == CMD_MRS);

    clk_at_first_MRS_CMD = clocks_since_reset_release;


    if(clk_at_first_MRS_CMD - clk_before_first_MRS_CMD < 5) begin
        $display("failed,MRS CMD TO erly after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
    end else begin
        $display("passed MRS CMD at right time after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
    end
if (BA[1:0]== 2'b01 && RAS == 0) begin
    $display("passed, MR1 choosen=%b",BA[1:0]);
    $display("A=%b",A);

    case (A[0])
      1'b0: $display("MR1: DLL Enable (A0) = 0 -> DLL enabled");
      1'b1: $display("MR1: DLL Enable (A0) = 1 -> DLL disabled");
    endcase

    // Output Driver Impedance Control (DIC) ({A5,A1})
    case ({A[5], A[1]})
      2'b00: $display("MR1: Output Driver Impedance ({A5,A1}) = 00 -> RZQ/6");
      2'b01: $display("MR1: Output Driver Impedance ({A5,A1}) = 01 -> RZQ/7");
      2'b10: $display("MR1: Output Driver Impedance ({A5,A1}) = 10 -> reserved/invalid");
      2'b11: $display("MR1: Output Driver Impedance ({A5,A1}) = 11 -> reserved/invalid");
    endcase

    // RTT_NOM ({A9,A6,A2})
    case ({A[9], A[6], A[2]})
      3'b000: $display("MR1: RTT_NOM ({A9,A6,A2}) = 000 -> ODT disabled");
      3'b001: $display("MR1: RTT_NOM ({A9,A6,A2}) = 001 -> RZQ/4");
      3'b010: $display("MR1: RTT_NOM ({A9,A6,A2}) = 010 -> RZQ/2");
      3'b011: $display("MR1: RTT_NOM ({A9,A6,A2}) = 011 -> RZQ/6");
      3'b100: $display("MR1: RTT_NOM ({A9,A6,A2}) = 100 -> RZQ/12");
      3'b101: $display("MR1: RTT_NOM ({A9,A6,A2}) = 101 -> RZQ/8");
      3'b110: $display("MR1: RTT_NOM ({A9,A6,A2}) = 110 -> reserved/invalid");
      3'b111: $display("MR1: RTT_NOM ({A9,A6,A2}) = 111 -> reserved/invalid");
    endcase

    // Additive Latency (A[4:3])
    case (A[4:3])
      2'b00: $display("MR1: Additive Latency (A[4:3]) = 00 -> AL=0");
      2'b01: $display("MR1: Additive Latency (A[4:3]) = 01 -> AL=CL-1");
      2'b10: $display("MR1: Additive Latency (A[4:3]) = 10 -> AL=CL-2");
      2'b11: $display("MR1: Additive Latency (A[4:3]) = 11 -> reserved/invalid");
    endcase

    // Write Leveling (A7)
    case (A[7])
      1'b0: $display("MR1: Write Leveling (A7) = 0 -> disabled");
      1'b1: $display("MR1: Write Leveling (A7) = 1 -> enabled");
    endcase

    // TDQS (A11)
    case (A[11])
      1'b0: $display("MR1: TDQS (A11) = 0");
      1'b1: $display("MR1: TDQS (A11) = 1");
    endcase

    // Qoff (A12)
    case (A[12])
      1'b0: $display("MR1: Qoff (A12) = 0 -> output buffer enabled");
      1'b1: $display("MR1: Qoff (A12) = 1 -> output buffer disabled");
    endcase
end else begin
    $display("failed MR1 not chosen=%b",BA[1:0]);
    $display("A=%b",A);
end
    wait(cmd == CMD_NOP);

    clk_before_first_MRS_CMD = clocks_since_reset_release;

    $display("test MR0");

    wait(cmd == CMD_MRS);

    clk_at_first_MRS_CMD = clocks_since_reset_release;

if (BA[1:0]== 2'b00) begin
    $display("passed MRS0 is choosen=%b",BA[1:0]);
    $display("A=%b",A);
    if(clk_at_first_MRS_CMD - clk_before_first_MRS_CMD < 5) begin
        $display("failed,MRS CMD TO erly after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
    end else begin
        $display("passed MRS CMD at right time after last MRS %d",clk_at_first_MRS_CMD - clk_before_first_MRS_CMD);
    end


    case (A[8])
      1'b0: $display("MR0: DLL Reset (A8) = 0 -> normal");
      1'b1: $display("MR0: DLL Reset (A8) = 1 -> reset");
    endcase

    // Test Mode (A7)
    case (A[7])
      1'b0: $display("MR0: Test Mode (A7) = 0 -> normal");
      1'b1: $display("MR0: Test Mode (A7) = 1 -> test");
    endcase

    // Read Burst Type (A3)
    case (A[3])
      1'b1: $display("MR0: Read Burst Type (A3) = 0 -> interleaved");
      1'b0: $display("MR0: Read Burst Type (A3) = 1 -> sequential");
    endcase

    // DLL Control for Precharge PD (A12) (often “fast exit” in some notes)
    case (A[12])
      1'b0: $display("MR0: DLL Control (A12) = 0");
      1'b1: $display("MR0: DLL Control (A12) = 1");
    endcase

    // Burst Length (A[1:0])
    case (A[1:0])
      2'b00: $display("MR0: Burst Length (A[1:0]) = 00 -> BL8 (fixed)");
      2'b01: $display("MR0: Burst Length (A[1:0]) = 01 -> BC4 or BL8 (on-the-fly)");
      2'b10: $display("MR0: Burst Length (A[1:0]) = 10 -> BC4 (fixed)");
      2'b11: $display("MR0: Burst Length (A[1:0]) = 11 -> reserved/invalid");
    endcase

    // CAS Latency code {A[6:4],A[2]}
    case ({A[6:4], A[2]})
      4'b0010: $display("MR0: CL code {A[6:4],A[2]} = 0010 -> CL=5");
      4'b0100: $display("MR0: CL code {A[6:4],A[2]} = 0100 -> CL=6");
      4'b0110: $display("MR0: CL code {A[6:4],A[2]} = 0110 -> CL=7");
      4'b1000: $display("MR0: CL code {A[6:4],A[2]} = 1000 -> CL=8");
      4'b1010: $display("MR0: CL code {A[6:4],A[2]} = 1010 -> CL=9");
      4'b1100: $display("MR0: CL code {A[6:4],A[2]} = 1100 -> CL=10");
      4'b1110: $display("MR0: CL code {A[6:4],A[2]} = 1110 -> CL=11");
      4'b0001: $display("MR0: CL code {A[6:4],A[2]} = 0001 -> CL=12");
      4'b0011: $display("MR0: CL code {A[6:4],A[2]} = 0011 -> CL=13");
      4'b0101: $display("MR0: CL code {A[6:4],A[2]} = 0101 -> CL=14");
      default: $display("MR0: CL code {A[6:4],A[2]} = %b -> unknown/invalid", {A[6:4], A[2]});
    endcase

    // Write Recovery (A[11:9])
    case (A[11:9])
      3'b000: $display("MR0: WR (A[11:9]) = 000 -> WR=16");
      3'b001: $display("MR0: WR (A[11:9]) = 001 -> WR=5");
      3'b010: $display("MR0: WR (A[11:9]) = 010 -> WR=6");
      3'b011: $display("MR0: WR (A[11:9]) = 011 -> WR=7");
      3'b100: $display("MR0: WR (A[11:9]) = 100 -> WR=8");
      3'b101: $display("MR0: WR (A[11:9]) = 101 -> WR=10");
      3'b110: $display("MR0: WR (A[11:9]) = 110 -> WR=12");
      3'b111: $display("MR0: WR (A[11:9]) = 111 -> WR=14");
    endcase
end else begin
    $display("failed, MR0 is not chosen=%b",BA[1:0]); 
end

#1;

$display("CMD=%b",cmd);



wait(cmd == CMD_ZQ);


wait(cmd == CMD_NOP);
ZQE_start_time = $time;




#0;

wait(cmd == CMD_NOP);



wait(cmd == CMD_ACT);
ZQE_end_time =$time;
if (ZQE_end_time-ZQE_start_time < tZQinit) begin
    $display("failed, tZQinit was not met=%d",ZQE_end_time-ZQE_start_time);
end else begin
    $display("passed tZQinit was met=%d",ZQE_end_time-ZQE_start_time);
end

$display("CDM_ACT");
is_there_a_clock_eged_at_active_cmd = 1'b1;

wait(cmd == CMD_NOP);
$display("cCMD_nop");
active_state_time = $time;
is_there_a_clock_eged_at_active_cmd =1'b0;
#0;
$display(RAS,CAS,WE);
wait(cmd == CMD_rd);
$display("CMD_re");
active_end_time = $time;


if ((active_end_time-active_state_time) < active_bank_time) begin
    $display("failed, banck time open time was not met=%0t",active_end_time-active_state_time );
end else begin
    $display("passed, banck time open time was met=%0t",active_end_time-active_state_time );
end



$display("CMD_failes_ACT=%d",CMD_failes_ACT);
$display("CMD_failes_MRS=%d",CMD_failes_MRS);
$display("CMD_failes_ZQ=%d",CMD_failes_ZQ);
$display("CMD_failes_rd=%d",CMD_failes_rd);
end

initial begin
    wait(is_there_a_clock_eged_at_active_cmd);
    @(posedge clk);
    $display("Passed: there was a clock at CMD_active");
end


endmodule
