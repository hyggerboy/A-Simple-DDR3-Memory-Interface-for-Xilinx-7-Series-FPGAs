set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { bnt }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]

set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { tx }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { rx }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in

set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { tx }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { rx }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in



set_property SLEW FAST [get_ports {ddr3_dqs_p_0[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_0[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr3_dqs_p_0[0]}]
set_property PACKAGE_PIN N2 [get_ports {ddr3_dqs_p_0[0]}]

# PadFunction: IO_L3N_T0_DQS_34 
set_property SLEW FAST [get_ports {ddr3_dqs_n_0[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_0[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr3_dqs_n_0[0]}]
set_property PACKAGE_PIN N1 [get_ports {ddr3_dqs_n_0[0]}]


set_property SLEW FAST [get_ports {ddr3_dqs_p_1[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_p_1[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr3_dqs_p_1[0]}]
set_property PACKAGE_PIN U2 [get_ports {ddr3_dqs_p_1[0]}]

# PadFunction: IO_L9N_T1_DQS_34 
set_property SLEW FAST [get_ports {ddr3_dqs_n_1[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {ddr3_dqs_n_1[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr3_dqs_n_1[0]}]
set_property PACKAGE_PIN V2 [get_ports {ddr3_dqs_n_1[0]}]



set_property SLEW FAST [get_ports {DDR_A[13]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[13]}]
set_property PACKAGE_PIN T8 [get_ports {DDR_A[13]}]

# PadFunction: IO_L23N_T3_34 
set_property SLEW FAST [get_ports {DDR_A[12]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[12]}]
set_property PACKAGE_PIN T6 [get_ports {DDR_A[12]}]

# PadFunction: IO_L22N_T3_34 
set_property SLEW FAST [get_ports {DDR_A[11]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[11]}]
set_property PACKAGE_PIN U6 [get_ports {DDR_A[11]}]

# PadFunction: IO_L19P_T3_34 
set_property SLEW FAST [get_ports {DDR_A[10]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[10]}]
set_property PACKAGE_PIN R6 [get_ports {DDR_A[10]}]

# PadFunction: IO_L20P_T3_34 
set_property SLEW FAST [get_ports {DDR_A[9]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[9]}]
set_property PACKAGE_PIN V7 [get_ports {DDR_A[9]}]

# PadFunction: IO_L24P_T3_34 
set_property SLEW FAST [get_ports {DDR_A[8]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[8]}]
set_property PACKAGE_PIN R8 [get_ports {DDR_A[8]}]

# PadFunction: IO_L22P_T3_34 
set_property SLEW FAST [get_ports {DDR_A[7]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[7]}]
set_property PACKAGE_PIN U7 [get_ports {DDR_A[7]}]

# PadFunction: IO_L20N_T3_34 
set_property SLEW FAST [get_ports {DDR_A[6]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[6]}]
set_property PACKAGE_PIN V6 [get_ports {DDR_A[6]}]

# PadFunction: IO_L23P_T3_34 
set_property SLEW FAST [get_ports {DDR_A[5]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[5]}]
set_property PACKAGE_PIN R7 [get_ports {DDR_A[5]}]

# PadFunction: IO_L18N_T2_34 
set_property SLEW FAST [get_ports {DDR_A[4]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[4]}]
set_property PACKAGE_PIN N6 [get_ports {DDR_A[4]}]

# PadFunction: IO_L17N_T2_34 
set_property SLEW FAST [get_ports {DDR_A[3]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[3]}]
set_property PACKAGE_PIN T1 [get_ports {DDR_A[3]}]

# PadFunction: IO_L16N_T2_34 
set_property SLEW FAST [get_ports {DDR_A[2]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[2]}]
set_property PACKAGE_PIN N4 [get_ports {DDR_A[2]}]

# PadFunction: IO_L18P_T2_34 
set_property SLEW FAST [get_ports {DDR_A[1]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[1]}]
set_property PACKAGE_PIN M6 [get_ports {DDR_A[1]}]

# PadFunction: IO_L15N_T2_DQS_34 
set_property SLEW FAST [get_ports {DDR_A[0]}]
set_property IOSTANDARD SSTL135 [get_ports {DDR_A[0]}]
set_property PACKAGE_PIN R2 [get_ports {DDR_A[0]}]

set_property -dict {PACKAGE_PIN R1 IOSTANDARD SSTL135} [get_ports {DDR_BA[0]}]
set_property -dict {PACKAGE_PIN P4 IOSTANDARD SSTL135} [get_ports {DDR_BA[1]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD SSTL135} [get_ports {DDR_BA[2]}]

set_property SLEW FAST [get_ports {ddr_clk_p[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr_clk_p[0]}]
set_property PACKAGE_PIN U9 [get_ports {ddr_clk_p[0]}]

## PadFunction: IO_L21N_T3_DQS_34
set_property SLEW FAST [get_ports {ddr_clk_n[0]}]
set_property IOSTANDARD DIFF_SSTL135 [get_ports {ddr_clk_n[0]}]
set_property PACKAGE_PIN V9 [get_ports {ddr_clk_n[0]}]



set_property -dict {PACKAGE_PIN P3 IOSTANDARD SSTL135} [get_ports DDR_RAS_n]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD SSTL135} [get_ports DDR_CAS_n]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD SSTL135} [get_ports DDR_WE_n]

set_property -dict {PACKAGE_PIN U8 IOSTANDARD SSTL135} [get_ports DDR_CS_n]
set_property -dict {PACKAGE_PIN N5 IOSTANDARD SSTL135} [get_ports DDR_CKE]


set_property -dict {PACKAGE_PIN K6 IOSTANDARD SSTL135} [get_ports DDR_RESET_n]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]






set_property SLEW FAST [get_ports {DQ_ddr[0]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[0]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[0]}]
set_property PACKAGE_PIN K5 [get_ports {DQ_ddr[0]}]

# PadFunction: IO_L2N_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[1]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[1]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[1]}]
set_property PACKAGE_PIN L3 [get_ports {DQ_ddr[1]}]

# PadFunction: IO_L2P_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[2]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[2]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[2]}]
set_property PACKAGE_PIN K3 [get_ports {DQ_ddr[2]}]

# PadFunction: IO_L6P_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[3]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[3]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[3]}]
set_property PACKAGE_PIN L6 [get_ports {DQ_ddr[3]}]

# PadFunction: IO_L4P_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[4]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[4]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[4]}]
set_property PACKAGE_PIN M3 [get_ports {DQ_ddr[4]}]

# PadFunction: IO_L1N_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[5]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[5]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[5]}]
set_property PACKAGE_PIN M1 [get_ports {DQ_ddr[5]}]

# PadFunction: IO_L5N_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[6]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[6]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[6]}]
set_property PACKAGE_PIN L4 [get_ports {DQ_ddr[6]}]

# PadFunction: IO_L4N_T0_34 
set_property SLEW FAST [get_ports {DQ_ddr[7]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[7]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[7]}]
set_property PACKAGE_PIN M2 [get_ports {DQ_ddr[7]}]

# PadFunction: IO_L10N_T1_34 
set_property SLEW FAST [get_ports {DQ_ddr[8]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[8]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[8]}]
set_property PACKAGE_PIN V4 [get_ports {DQ_ddr[8]}]

# PadFunction: IO_L12P_T1_MRCC_34 
set_property SLEW FAST [get_ports {DQ_ddr[9]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[9]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[9]}]
set_property PACKAGE_PIN T5 [get_ports {DQ_ddr[9]}]

# PadFunction: IO_L8P_T1_34 
set_property SLEW FAST [get_ports {DQ_ddr[10]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[10]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[10]}]
set_property PACKAGE_PIN U4 [get_ports {DQ_ddr[10]}]

# PadFunction: IO_L10P_T1_34 
set_property SLEW FAST [get_ports {DQ_ddr[11]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[11]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[11]}]
set_property PACKAGE_PIN V5 [get_ports {DQ_ddr[11]}]

# PadFunction: IO_L7N_T1_34 
set_property SLEW FAST [get_ports {DQ_ddr[12]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[12]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[12]}]
set_property PACKAGE_PIN V1 [get_ports {DQ_ddr[12]}]

# PadFunction: IO_L11N_T1_SRCC_34 
set_property SLEW FAST [get_ports {DQ_ddr[13]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[13]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[13]}]
set_property PACKAGE_PIN T3 [get_ports {DQ_ddr[13]}]

# PadFunction: IO_L8N_T1_34 
set_property SLEW FAST [get_ports {DQ_ddr[14]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[14]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[14]}]
set_property PACKAGE_PIN U3 [get_ports {DQ_ddr[14]}]

# PadFunction: IO_L11P_T1_SRCC_34 
set_property SLEW FAST [get_ports {DQ_ddr[15]}]
set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {DQ_ddr[15]}]
set_property IOSTANDARD SSTL135 [get_ports {DQ_ddr[15]}]
set_property PACKAGE_PIN R3 [get_ports {DQ_ddr[15]}]


set_property SLEW FAST [get_ports {WM0_w}]
set_property IOSTANDARD SSTL135 [get_ports {WM0_w}]
set_property PACKAGE_PIN L1 [get_ports {WM0_w}]

set_property SLEW FAST [get_ports {WM1_w}]
set_property IOSTANDARD SSTL135 [get_ports {WM1_w}]
set_property PACKAGE_PIN U1 [get_ports {WM1_w}]




#set_output_delay -max 0.2 [get_ports {DQ_ddr[0]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[0]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[1]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[1]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[2]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[2]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[3]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[3]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[4]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[4]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[5]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[5]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[6]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[6]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[7]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[7]}]

#set_output_delay -clock clk -max 0.2 [get_ports {DQ_ddr[*]}]
#set_output_delay -clock clk -min -0.2 [get_ports {DQ_ddr[*]}]



#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]

#set_output_delay -clock [get_clocks sys_clk_pin] -max 10.500 [get_ports {DQ_ddr[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {DQ_ddr[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -max 10.500 [get_ports {DQ_ddr[*]}] -clock_fall -add_delay
#set_output_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {DQ_ddr[*]}] -clock_fall -add_delay


#set_input_delay -clock [get_clocks sys_clk_pin] -max 5.500 [get_ports {ddr3_dqs_p_0[0]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {ddr3_dqs_p_0[0]}]

#set_input_delay -clock [get_clocks sys_clk_pin] -max 5.500 [get_ports {ddr3_dqs_n_0[0]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {ddr3_dqs_n_0[0]}]

#set_input_delay -clock [get_clocks sys_clk_pin] -max 5.500 [get_ports {ddr3_dqs_p_1[0]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {ddr3_dqs_p_1[0]}]

#set_input_delay -clock [get_clocks sys_clk_pin] -max 5.500 [get_ports {ddr3_dqs_n_1[0]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min 2.500 [get_ports {ddr3_dqs_n_1[0]}]