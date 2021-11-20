# SPDX-FileCopyrightText: 2020 Efabless Corporation
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

# Base Configurations. Don't Touch
# section begin

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations
#
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1


## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

set ::env(SYNTH_DEFINES) [list SYNTHESIS ]

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i user_clock2"
set ::env(CLOCK_NET) "wb_clk_i user_clock2"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros

### Macro Placement
set ::env(FP_SIZING) "absolute"
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

set ::env(PDN_CFG) $script_dir/pdn.tcl

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/sram_macros/sky130_sram_2kbyte_1rw1r_32x512_8.v \
	$script_dir/../../verilog/rtl/sram_macros/sky130_sram_1kbyte_1rw1r_32x256_8.v \
	$script_dir/../../verilog/gl/wb_interconnect.v \
	$script_dir/../../verilog/gl/wb_host.v \
	$script_dir/../../verilog/gl/glbl_cfg.v\
	$script_dir/../../verilog/gl/mbist1.v\
	$script_dir/../../verilog/gl/mbist2.v\
	"

set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/sky130_sram_2kbyte_1rw1r_32x512_8.lef \
	$script_dir/../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef \
	$script_dir/../../lef/glbl_cfg.lef \
	$script_dir/../../lef/mbist1.lef \
	$script_dir/../../lef/mbist2.lef \
	$script_dir/../../lef/wb_interconnect.lef \
	$script_dir/../../lef/wb_host.lef"

set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/sky130_sram_2kbyte_1rw1r_32x512_8.gds \
	$script_dir/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds \
	$script_dir/../../gds/glbl_cfg.gds \
	$script_dir/../../gds/mbist1.gds \
	$script_dir/../../gds/mbist2.gds \
	$script_dir/../../gds/wb_interconnect.gds \
	$script_dir/../../gds/wb_host.gds"

set ::env(SDC_FILE) "$script_dir/base.sdc"
set ::env(BASE_SDC_FILE) "$script_dir/base.sdc"

set ::env(GLB_RT_MAXLAYER) 5

# disable pdn check nodes becuase it hangs with multiple power domains.
# any issue with pdn connections will be flagged with LVS so it is not a critical check.
set ::env(FP_PDN_CHECK_NODES) 0


## Internal Macros
### Macro PDN Connections
#set ::env(FP_PDN_ENABLE_MACROS_GRID) "0"
#set ::env(FP_PDN_ENABLE_GLOBAL_CONNECTIONS) "1"

set ::env(VDD_NETS) "vccd1 vccd2 vdda1 vdda2"
set ::env(GND_NETS) "vssd1 vssd2 vssa1 vssa2"

# Add Blockage arond the SRAM to avoid Magic DRC & 
# add signal routing blockage for met5
set ::env(GLB_RT_OBS) "met1 2000.00 800.00  2683.10 1216.54, \
	               met2 2000.00 800.00  2683.10 1216.54, \
		       met3 2000.00 800.00  2683.10 1216.54, \
	               met1 2000.00 1400.00 2683.10 1816.54, \
	               met2 2000.00 1400.00 2683.10 1816.54, \
	               met3 2000.00 1400.00 2683.10 1816.54, \
	               met1 2000.00 2000.00 2683.10 2316.54, \
	               met2 2000.00 2000.00 2683.10 2316.54, \
	               met3 2000.00 2000.00 2683.10 2316.54, \
	               met1 2000.00 2600.00 2683.10 3000.54, \
	               met2 2000.00 2600.00 2683.10 3000.54, \
	               met3 2000.00 2600.00 2683.10 3000.54, \
	               met1 200.00 1200.00 679.78 1597.5, \
	               met2 200.00 1200.00 679.78 1597.5, \
	               met3 200.00 1200.00 679.78 1597.5, \
	               met1 200.00 1800.00 679.78 2197.5, \
	               met2 200.00 1800.00 679.78 2197.5, \
	               met3 200.00 1800.00 679.78 2197.5, \
	               met1 200.00 2400.00 679.78 2797.5, \
	               met2 200.00 2400.00 679.78 2797.5, \
	               met3 200.00 2400.00 679.78 2797.5, \
	               met1 200.00 3000.00 679.78 3397.5, \
	               met2 200.00 3000.00 679.78 3397.5, \
	               met3 200.00 3000.00 679.78 3397.5, \
		       met5 0 0 2920 3520"


set ::env(FP_PDN_MACRO_HOOKS) "\
     u_wb_host	vccd1 vssd1 \
     u_intercon	vccd1 vssd1 \
     u_glbl	vccd1 vssd1 \
     u_mbist1   vccd1 vssd1 \
     u_mbist2   vccd1 vssd1 \
     u_mbist3   vccd1 vssd1 \
     u_mbist4   vccd1 vssd1 \
     u_mbist5   vccd1 vssd1 \
     u_mbist6   vccd1 vssd1 \
     u_mbist7   vccd1 vssd1 \
     u_mbist8   vccd1 vssd1 \
     u_sram1_2kb vccd1 vssd1 \
     u_sram2_2kb vccd1 vssd1 \
     u_sram3_2kb vccd1 vssd1 \
     u_sram4_2kb vccd1 vssd1 \
     u_sram5_1kb vccd1 vssd1 \
     u_sram6_1kb vccd1 vssd1 \
     u_sram7_1kb vccd1 vssd1 \
     u_sram8_1kb vccd1 vssd1 \
     "


# The following is because there are no std cells in the example wrapper project.
set ::env(SYNTH_TOP_LEVEL) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(FP_PDN_ENABLE_RAILS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(QUIT_ON_LVS_ERROR) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_NEGATIVE_WNS) "0"
set ::env(QUIT_ON_SLEW_VIOLATIONS) "0"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_TR_DRC) "0"


