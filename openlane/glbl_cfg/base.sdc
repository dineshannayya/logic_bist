###############################################################################
# Created by write_sdc
# Sat Nov 13 06:33:41 2021
###############################################################################
current_design glbl_cfg
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name mclk -period 10.0000 [get_ports {mclk}]
set_clock_uncertainty -rise_from [get_clocks {mclk}] -rise_to [get_clocks {mclk}]  -hold 0.1000
set_clock_uncertainty -rise_from [get_clocks {mclk}] -rise_to [get_clocks {mclk}]  -setup 0.2000
set_clock_uncertainty -rise_from [get_clocks {mclk}] -fall_to [get_clocks {mclk}]  -hold 0.1000
set_clock_uncertainty -rise_from [get_clocks {mclk}] -fall_to [get_clocks {mclk}]  -setup 0.2000
set_clock_uncertainty -fall_from [get_clocks {mclk}] -rise_to [get_clocks {mclk}]  -hold 0.1000
set_clock_uncertainty -fall_from [get_clocks {mclk}] -rise_to [get_clocks {mclk}]  -setup 0.2000
set_clock_uncertainty -fall_from [get_clocks {mclk}] -fall_to [get_clocks {mclk}]  -hold 0.1000
set_clock_uncertainty -fall_from [get_clocks {mclk}] -fall_to [get_clocks {mclk}]  -setup 0.2000

set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_cs}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wr}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reset_n}]

set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_addr[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_be[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_cs}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wdata[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_wr}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reset_n}]

set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_ack}]
set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_rdata[*]}]

set_output_delay -min 1.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_ack}]
set_output_delay -min 1.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {reg_rdata[*]}]


set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_done[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_correct[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_done[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt0[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt1[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt2[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt3[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt4[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt5[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt6[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt7[*]}]
set_input_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_sdo[*]}]

set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_done[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_correct[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_done[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt0[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt1[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt2[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt3[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt4[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt5[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt6[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_error_cnt7[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_sdo[*]}]


set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_en}]
set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_run[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_load[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_sdi[*]}]
set_output_delay -max 6.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_shift[*]}]

set_output_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_en}]
set_output_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_run[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_load[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_sdi[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {mclk}] -add_delay [get_ports {bist_shift[*]}]

# Set max delay for clock skew
set_max_delay   3.5 -from [get_ports {wbd_clk_int}]
set_max_delay   2.5 -from wbd_clk_int -to wbd_clk_glbl

set_case_analysis 0 [get_ports {cfg_cska_glbl[0]}]
set_case_analysis 0 [get_ports {cfg_cska_glbl[1]}]
set_case_analysis 0 [get_ports {cfg_cska_glbl[2]}]
set_case_analysis 0 [get_ports {cfg_cska_glbl[3]}]

set_case_analysis 0 [get_ports {scan_en}]
set_case_analysis 0 [get_ports {scan_mode}]
set_false_path -from [get_ports {scan_in[*]}]
set_false_path -to [get_ports {scan_out[*]}]

###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]


###############################################################################
# Design Rules
###############################################################################
