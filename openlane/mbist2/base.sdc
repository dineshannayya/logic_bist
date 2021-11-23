###############################################################################
# Created by write_sdc
# Sun Nov 14 09:33:23 2021
###############################################################################
current_design mbist_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name wb_clk_i -period 8.0000 [get_ports {wb_clk_i}]
create_generated_clock -name bist_mem_clk_a -add -source [get_ports {wb_clk_i}] -master_clock [get_clocks wb_clk_i] -divide_by 1 -comment {Mem Clock A} [get_ports mem_clk_a]
create_generated_clock -name bist_mem_clk_b -add -source [get_ports {wb_clk_i}] -master_clock [get_clocks wb_clk_i] -divide_by 1 -comment {Mem Clock B} [get_ports mem_clk_b]

set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks {wb_clk_i bist_mem_clk_a bist_mem_clk_b}]  

set_clock_transition 0.1500 [get_clocks {wb_clk_i}]
set_clock_uncertainty -setup 0.2500 wb_clk_i
set_clock_uncertainty -setup 0.2500 mem_clk_a
set_clock_uncertainty -setup 0.2500 mem_clk_b

set_clock_uncertainty -hold 0.1500 wb_clk_i
set_clock_uncertainty -hold 0.1500 mem_clk_a
set_clock_uncertainty -hold 0.1500 mem_clk_b

set_input_delay  -max 5.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {rst_n}]
set_input_delay  -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {rst_n}]

set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_correct}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_done}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[0]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[1]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[2]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[3]}]
set_output_delay -max 4.5000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_sdo}]

set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_correct}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_done}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[0]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[1]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[2]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_error_cnt[3]}]
set_output_delay -min 2.0000 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_sdo}]

set_false_path -from [get_ports {bist_en}]
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_load}]
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_run}]
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_sdi}]
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_shift}]

set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_en}]
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_load}]
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_run}]
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_sdi}]
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay [get_ports {bist_shift}]

## Functional Inputs
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_adr_i[*]}]  
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_stb_i}]      
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_cyc_i}]      
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_we_i}]      
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wbd_mbist1_dat_o[*]}] 
set_input_delay -max 4 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_sel_i[*]}]

set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_adr_i[*]}]  
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_stb_i}]      
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_cyc_i}]      
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_we_i}]      
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wbd_mbist1_dat_o[*]}] 
set_input_delay -min 2 -clock [get_clocks {wb_clk_i}] -add_delay   [get_ports {wb_sel_i[*]}]

set_output_delay -max 5 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_dat_o[*]}]  
set_output_delay -max 5 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_ack_o}]  
set_output_delay -max 5 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_err_o}]  

set_output_delay -min 1 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_dat_o[*]}]  
set_output_delay -min 1 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_ack_o}]  
set_output_delay -min 1 -clock [get_clocks {wb_clk_i}] -add_delay     [get_ports {wb_err_o}]  

## Towards MEMORY from MBIST CLOCK
## PORT-A
set_input_delay -max 4.0000 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_dout_a[*]}]
set_input_delay -min 1.0000 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_dout_a[*]}]


set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_addr_a[*]}]
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_cen_a}]

set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_addr_a[*]}]
set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_a}] -add_delay [get_ports {mem_cen_a}]



## PORT-B
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_cen_b}]
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_din_b[*]}]
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_mask_b[*]}]
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_web_b}]
set_output_delay -max 4 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_addr_b[*]}]

set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_cen_b}]
set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_din_b[*]}]
set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_mask_b[*]}]
set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_web_b}]
set_output_delay -min -0.5 -clock [get_clocks {bist_mem_clk_b}] -add_delay [get_ports {mem_addr_b[*]}]

# Set max delay for clock skew
set_max_delay   3.5 -from [get_ports {wbd_clk_int}]
set_max_delay   2 -to   [get_ports {wbd_clk_mbist}]
set_max_delay 3.5 -from wbd_clk_int -to wbd_clk_mbist

###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {bist_correct}]
set_load -pin_load 0.0334 [get_ports {bist_done}]
set_load -pin_load 0.0334 [get_ports {bist_error}]
set_load -pin_load 0.0334 [get_ports {bist_sdo}]
set_load -pin_load 0.0334 [get_ports {mem_cen_a}]
set_load -pin_load 0.0334 [get_ports {mem_cen_b}]
set_load -pin_load 0.0334 [get_ports {mem_clk_a}]
set_load -pin_load 0.0334 [get_ports {mem_clk_b}]
set_load -pin_load 0.0334 [get_ports {mem_web_b}]
set_load -pin_load 0.0334 [get_ports {bist_error_cnt[3]}]
set_load -pin_load 0.0334 [get_ports {bist_error_cnt[2]}]
set_load -pin_load 0.0334 [get_ports {bist_error_cnt[1]}]
set_load -pin_load 0.0334 [get_ports {bist_error_cnt[0]}]
set_load -pin_load 0.0334 [get_ports {wb_cyc_i}]
set_load -pin_load 0.0334 [get_ports {wb_stb_i}]
set_load -pin_load 0.0334 [get_ports {wb_adr_i[*]}]
set_load -pin_load 0.0334 [get_ports {wb_we_i}]
set_load -pin_load 0.0334 [get_ports {wb_dat_i[*]}]
set_load -pin_load 0.0334 [get_ports {wb_sel_i[*]}]
set_load -pin_load 0.0334 [get_ports {mem_addr_a[*]}]
set_load -pin_load 0.0334 [get_ports {mem_addr_b[*]}]
set_load -pin_load 0.0334 [get_ports {mem_din_b[*]}]
set_load -pin_load 0.0334 [get_ports {mem_mask_b[*]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_cyc_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bist_en}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bist_load}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bist_run}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bist_sdi}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bist_shift}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_cyc_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_adr_i[*]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_we_i}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_dat_i[*]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {wb_sel_i[*]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_n}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {mem_dout_a[*]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 4.0000 [current_design]
