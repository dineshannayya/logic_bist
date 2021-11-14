# SPDX-FileCopyrightText:  2021 , Dinesh Annayya
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileContributor: Modified by Dinesh Annayya <dinesha@opencores.org>


set_units -time ns
set ::env(WBM_CLOCK_PERIOD) "10"
set ::env(WBM_CLOCK_PORT)   "wb_clk_i"
set ::env(WBM_CLOCK_NAME)   "wbm_clk_i"

set ::env(WBS_CLOCK_PERIOD) "10"
set ::env(WBS_CLOCK_PORT)   "u_wb_host*mem_clk"
set ::env(WBS_CLOCK_NAME)   "mem_clk"

set ::env(BIST_CLOCK_PERIOD) "20"
set ::env(BIST_CLOCK_PORT)   "u_wb_host*bist_clk"
set ::env(BIST_CLOCK_NAME)   "bist_clk"

######################################
# WB MASTER Clock domain input output
######################################
create_clock [get_ports $::env(WBM_CLOCK_PORT)]  -name $::env(WBM_CLOCK_NAME)  -period $::env(WBM_CLOCK_PERIOD)
set wb_input_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.54]
set wb_output_delay_value [expr $::env(WBM_CLOCK_PERIOD) * 0.54]
puts "\[INFO\]: Setting wb output delay to:$wb_output_delay_value"
puts "\[INFO\]: Setting wb input delay to: $wb_input_delay_value"

set_false_path -from [get_pins {u_wb_host/bist_en}]

set_input_delay 2.0 -clock [get_clocks $::env(WBM_CLOCK_NAME)] {wb_rst_i}

set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_stb_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_cyc_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_we_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_sel_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_dat_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_adr_i*]
set_input_delay  $wb_input_delay_value   -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wb_cti_i*]

set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_dat_o*]
set_output_delay $wb_output_delay_value  -clock [get_clocks $::env(WBM_CLOCK_NAME)] [get_port wbs_ack_o*]

######################################
# WishBone Slave Port
#######################################
create_clock [get_pins -hierarchical $::env(WBS_CLOCK_PORT)]  -name $::env(WBS_CLOCK_NAME)  -period $::env(WBS_CLOCK_PERIOD)
######################################
# BIST Clock domain input output
######################################
create_clock [get_pins -hierarchical $::env(BIST_CLOCK_PORT)]  -name $::env(BIST_CLOCK_NAME)  -period $::env(BIST_CLOCK_PERIOD)

set_clock_groups -name async_clock -asynchronous -comment "Async Clock group" -group [get_clocks $::env(WBM_CLOCK_NAME)] -group [get_clocks $::env(WBS_CLOCK_NAME)] -group [get_clocks $::env(BIST_CLOCK_NAME)] 


## Add clock uncertainty
#Note: We have PAD_BIST_CLOCK_NAME => BIST_CLOCK_NAME path only

set_clock_uncertainty -from $::env(WBM_CLOCK_NAME)          -to $::env(WBM_CLOCK_NAME)  -setup 0.200
set_clock_uncertainty -from $::env(WBS_CLOCK_NAME)          -to $::env(WBS_CLOCK_NAME)  -setup 0.200
set_clock_uncertainty -from $::env(BIST_CLOCK_NAME)        -to $::env(BIST_CLOCK_NAME)  -setup 0.200

set_clock_uncertainty -from $::env(WBM_CLOCK_NAME)          -to $::env(WBM_CLOCK_NAME)  -hold 0.100
set_clock_uncertainty -from $::env(WBS_CLOCK_NAME)          -to $::env(WBS_CLOCK_NAME)  -hold 0.100
set_clock_uncertainty -from $::env(BIST_CLOCK_NAME)        -to $::env(BIST_CLOCK_NAME)  -hold 0.100

# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

## 2 Multi-cycle setup and 0 hold
set_multicycle_path -setup -from wbs_adr_i* 2
set_multicycle_path -hold -from wbs_adr_i* 2

set_multicycle_path -setup -from wbs_we_i* 2
set_multicycle_path -hold -from wbs_we_i* 2
